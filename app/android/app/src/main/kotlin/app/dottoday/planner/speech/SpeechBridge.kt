package app.dottoday.planner.speech

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognitionSupport
import android.speech.RecognitionSupportCallback
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

/**
 * `dottoday/speech` + `dottoday/speech/events` (lib/data/speech/
 * channel_speech_transport.dart, docs/09 M14.4, ADR-0014): dictation with
 * Android's on-device recognizer only. Below API 31, or where
 * [SpeechRecognizer.isOnDeviceRecognitionAvailable] says no, the answer is
 * "unavailable" and the mic hides (D2): the default recognizer is never
 * used, because the service behind it may send audio to a server. On API
 * 33+ the language must be installed on the device. Words go to Dart only,
 * never to a log; no network API is used here (speech_on_device_test).
 * Listening restarts after each utterance until [stop], and stops when the
 * activity pauses.
 */
object SpeechBridge : EventChannel.StreamHandler {
    private const val REQUEST_CODE = 0x5EEC
    private const val PREFS = "dottoday_speech"
    private const val ASKED = "asked"

    private var activity: Activity? = null
    private var sink: EventChannel.EventSink? = null
    private var recognizer: SpeechRecognizer? = null
    private var listening = false
    private var language = ""
    private var pendingPermission: (() -> Unit)? = null

    fun attach(activity: Activity, messenger: BinaryMessenger) {
        this.activity = activity
        EventChannel(messenger, "dottoday/speech/events").setStreamHandler(this)
        MethodChannel(messenger, "dottoday/speech").setMethodCallHandler { call, result ->
            val tag = call.argument<String>("locale") ?: ""
            when (call.method) {
                "availability" -> availability(tag) { result.success(it) }
                "requestPermission" -> requestPermission { availability(tag) { result.success(it) } }
                "start" -> start(tag)?.let { result.error(it, null, null) } ?: result.success(null)
                "stop" -> {
                    stop()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    /** From MainActivity.onRequestPermissionsResult. */
    fun onPermissionResult(requestCode: Int) {
        if (requestCode != REQUEST_CODE) return
        pendingPermission?.invoke()
        pendingPermission = null
    }

    // Availability and permission

    private fun availability(tag: String, done: (String) -> Unit) {
        val context = activity ?: return done("unavailable")
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
            !SpeechRecognizer.isOnDeviceRecognitionAvailable(context)
        ) {
            return done("unavailable")
        }
        val permission = permissionWord(context)
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return done(permission)
        // API 33+: the language itself must be installed on the device.
        val probe = SpeechRecognizer.createOnDeviceSpeechRecognizer(context)
        probe.checkRecognitionSupport(
            intentFor(tag),
            ContextCompat.getMainExecutor(context),
            object : RecognitionSupportCallback {
                override fun onSupportResult(support: RecognitionSupport) {
                    probe.destroy()
                    val language = languageOf(tag)
                    val installed = support.installedOnDeviceLanguages.any {
                        it.lowercase(Locale.ROOT).startsWith(language)
                    }
                    done(if (installed) permission else "unavailable")
                }

                override fun onError(error: Int) {
                    probe.destroy()
                    done("unavailable")
                }
            },
        )
    }

    private fun permissionWord(context: Activity): String {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            return "available"
        }
        val asked = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean(ASKED, false)
        val canAsk = !asked ||
            ActivityCompat.shouldShowRequestPermissionRationale(context, Manifest.permission.RECORD_AUDIO)
        return if (canAsk) "needs_permission" else "denied"
    }

    /** The system dialog; Dart has shown its rationale first (D5). */
    private fun requestPermission(done: () -> Unit) {
        val context = activity ?: return done()
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putBoolean(ASKED, true).apply()
        pendingPermission = done
        ActivityCompat.requestPermissions(context, arrayOf(Manifest.permission.RECORD_AUDIO), REQUEST_CODE)
    }

    // Listening

    /** Starts listening; an error code, or null when it started. */
    private fun start(tag: String): String? {
        val context = activity ?: return "unavailable"
        stopRecognizer()
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
            !SpeechRecognizer.isOnDeviceRecognitionAvailable(context)
        ) {
            return "unavailable"
        }
        if (permissionWord(context) != "available") return "permission"
        // D1: only the on-device recognizer, never createSpeechRecognizer.
        val r = SpeechRecognizer.createOnDeviceSpeechRecognizer(context)
        r.setRecognitionListener(listener)
        recognizer = r
        language = tag
        listening = true
        r.startListening(intentFor(tag))
        return null
    }

    fun stop() {
        if (!listening) return
        listening = false
        recognizer?.stopListening()
        stopRecognizer()
        send(mapOf("type" to "stopped"))
    }

    private fun stopRecognizer() {
        recognizer?.destroy()
        recognizer = null
    }

    private val listener = object : RecognitionListener {
        override fun onPartialResults(partialResults: Bundle?) {
            val text = best(partialResults) ?: return
            send(mapOf("type" to "partial", "text" to text))
        }

        override fun onResults(results: Bundle?) {
            best(results)?.let { send(mapOf("type" to "final", "text" to it)) }
            again()
        }

        override fun onError(error: Int) {
            when (error) {
                // Silence: keep listening until the user stops.
                SpeechRecognizer.ERROR_NO_MATCH, SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> again()
                SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> fail("permission")
                SpeechRecognizer.ERROR_LANGUAGE_NOT_SUPPORTED,
                SpeechRecognizer.ERROR_LANGUAGE_UNAVAILABLE,
                -> fail("unavailable")
                SpeechRecognizer.ERROR_AUDIO -> fail("interrupted")
                // No message: it can quote what was said.
                else -> fail("recognizer")
            }
        }

        override fun onReadyForSpeech(params: Bundle?) = Unit
        override fun onBeginningOfSpeech() = Unit
        override fun onRmsChanged(rmsdB: Float) = Unit
        override fun onBufferReceived(buffer: ByteArray?) = Unit
        override fun onEndOfSpeech() = Unit
        override fun onEvent(eventType: Int, params: Bundle?) = Unit
    }

    /** One utterance ended: listen for the next while still on. */
    private fun again() {
        if (listening) recognizer?.startListening(intentFor(language))
    }

    private fun fail(code: String) {
        if (!listening) return
        listening = false
        stopRecognizer()
        send(mapOf("type" to "error", "code" to code))
    }

    private fun best(bundle: Bundle?): String? =
        bundle?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)?.firstOrNull()

    private fun intentFor(tag: String) = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
        putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
        putExtra(RecognizerIntent.EXTRA_LANGUAGE, resolve(tag))
        putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
        putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, true)
    }

    /** "en" → the device's own en-XX when it speaks English, else "en". */
    private fun resolve(tag: String): String {
        val language = languageOf(tag)
        val device = Locale.getDefault()
        return if (device.language == language) device.toLanguageTag() else tag
    }

    private fun languageOf(tag: String) = tag.substringBefore('-').lowercase(Locale.ROOT)

    private fun send(event: Map<String, String>) {
        sink?.success(event)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
        stop()
    }
}
