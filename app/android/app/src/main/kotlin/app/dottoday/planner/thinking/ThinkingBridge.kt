package app.dottoday.planner.thinking

import android.content.Context
import androidx.core.content.ContextCompat
import com.google.common.util.concurrent.ListenableFuture
import com.google.mlkit.genai.common.FeatureStatus
import com.google.mlkit.genai.prompt.Generation
import com.google.mlkit.genai.prompt.TextPart
import com.google.mlkit.genai.prompt.generateContentRequest
import com.google.mlkit.genai.prompt.java.GenerativeModelFutures
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * `dottoday/thinking` (lib/data/thinking/channel_thinking_transport.dart,
 * docs/09 M10.1, ADR-0009): Gemini Nano through ML Kit GenAI's Prompt API,
 * run by AICore on the device. `availability` answers "available",
 * "downloadable"/"downloading", "not_eligible" (no AICore, unsupported
 * device) or "unknown" (the check failed; docs/09 M14.1, words pinned by
 * thinking_wire_contract_test); `generate` returns the model's text, which Dart validates as
 * JSON before anything is proposed. The prompt never leaves the device;
 * no network API is used here (policy test).
 */
object ThinkingBridge {
    private var client: GenerativeModelFutures? = null

    fun attach(context: Context, messenger: BinaryMessenger) {
        val main = ContextCompat.getMainExecutor(context)
        MethodChannel(messenger, "dottoday/thinking").setMethodCallHandler { call, result ->
            when (call.method) {
                "availability" -> {
                    val model = model() ?: return@setMethodCallHandler result.success("not_eligible")
                    model.checkStatus().whenDone(main, { result.success(availabilityWord(it)) }) {
                        result.success("unknown")
                    }
                }
                "generate" -> {
                    val instructions = call.argument<String>("instructions")
                    val prompt = call.argument<String>("prompt")
                    val schema = call.argument<String>("schema")
                    val model = model()
                    if (instructions == null || prompt == null || schema == null || model == null) {
                        return@setMethodCallHandler result.error("bad_args", null, null)
                    }
                    val request = generateContentRequest(
                        TextPart("$instructions\nJSON schema: $schema\n$prompt"),
                    ) {
                        // Steady answers; the schema's longest answer fits.
                        temperature = 0.2f
                        maxOutputTokens = 512
                    }
                    model.generateContent(request).whenDone(main, { response ->
                        result.success(response.candidates.firstOrNull()?.text)
                    }) {
                        // No message: it can quote the prompt (CLAUDE.md §4).
                        result.error("no_answer", null, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun availabilityWord(status: Int?): String = when (status) {
        FeatureStatus.AVAILABLE -> "available"
        FeatureStatus.DOWNLOADABLE -> "downloadable"
        FeatureStatus.DOWNLOADING -> "downloading"
        FeatureStatus.UNAVAILABLE -> "not_eligible"
        else -> "unknown"
    }

    /** The client, or null where ML Kit GenAI can't start (no AICore). */
    private fun model(): GenerativeModelFutures? = client ?: try {
        GenerativeModelFutures.from(Generation.getClient()).also { client = it }
    } catch (_: Throwable) {
        null
    }

    private fun <T> ListenableFuture<T>.whenDone(
        executor: java.util.concurrent.Executor,
        onValue: (T) -> Unit,
        onError: () -> Unit,
    ) = addListener({
        val value = try {
            get()
        } catch (_: Throwable) {
            return@addListener onError()
        }
        onValue(value)
    }, executor)
}
