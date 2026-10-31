package app.dottoday.planner.alarms

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.VibrationEffect
import android.os.VibratorManager
import androidx.core.app.NotificationCompat
import app.dottoday.planner.R

/**
 * Rings one Wake Up alarm (docs/15 W1b): a foreground service so the ring
 * outlives the app, playing the alarm's cue on the alarm stream (it ignores
 * media volume and rings through Do Not Disturb while "Alarms" is allowed)
 * from 40 % up to that stream's volume over the ramp, with vibration. Its
 * notification carries the full-screen [WakeUpAlarmActivity] and the same
 * two buttons, so a revoked full-screen intent still leaves a ringing
 * heads-up (15 §2). It stops on "I'm up", on Snooze and after [CAP_MS].
 */
class WakeUpRingService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private var player: MediaPlayer? = null
    private var ringing: String? = null

    /** The alarm ringing now, if any. */
    val ringingId: String? get() = ringing
    private val cap = Runnable { ringing?.let { WakeUpActions.dismiss(this, it) } }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val alarm = intent?.getStringExtra(EXTRA_ID)?.let { WakeUpAlarms.find(this, it) }
        // startForegroundService promises startForeground, even for an alarm
        // that was disarmed a moment ago; one already ringing goes on.
        startForeground(alarm ?: ringing?.let { WakeUpAlarms.find(this, it) })
        if (alarm == null) {
            if (ringing == null) silence()
            return START_NOT_STICKY
        }
        ringing?.takeIf { it != alarm.id }?.let { WakeUpAlarms.remove(this, it) }
        instance = this
        ringing = alarm.id
        WakeUpAlarms.put(this, alarm.copy(state = WakeUpAlarm.RINGING))
        WakeUpAlarms.record(this, alarm.id, "rang")
        notes().cancel(WakeUpActions.SNOOZED_NOTE)
        play(alarm)
        vibrate()
        handler.removeCallbacks(cap)
        handler.postDelayed(cap, CAP_MS)
        return START_NOT_STICKY
    }

    /** Stops the sound and the service; the alarm's state is the caller's. */
    fun silence() {
        handler.removeCallbacksAndMessages(null)
        player?.run { runCatching { stop() }; release() }
        player = null
        vibrator().cancel()
        ringing = null
        instance = null
        WakeUpAlarmActivity.close()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        if (instance === this) silence()
        super.onDestroy()
    }

    private fun startForeground(alarm: WakeUpAlarm?) {
        ensureChannel(this)
        val note = if (alarm == null) bare() else ringNote(alarm)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(RING_NOTE, note, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
        } else {
            startForeground(RING_NOTE, note)
        }
    }

    private fun bare(): Notification = NotificationCompat.Builder(this, CHANNEL)
        .setSmallIcon(R.mipmap.ic_launcher)
        .setSilent(true)
        .build()

    private fun ringNote(alarm: WakeUpAlarm): Notification {
        val screen = PendingIntent.getActivity(
            this, alarm.id.hashCode(),
            Intent(this, WakeUpAlarmActivity::class.java)
                .putExtra(EXTRA_ID, alarm.id)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_NO_USER_ACTION),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val builder = NotificationCompat.Builder(this, CHANNEL)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(alarm.title)
            .setContentText(alarm.body)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setOngoing(true)
            .setSilent(true)
            .setContentIntent(screen)
            .setFullScreenIntent(screen, true)
        if (alarm.canSnooze) {
            builder.addAction(0, alarm.snooze, WakeUpActions.pending(this, WakeUpActions.SNOOZE, alarm.id))
        }
        return builder
            .addAction(0, alarm.stop, WakeUpActions.pending(this, WakeUpActions.STOP, alarm.id))
            .build()
    }

    private fun play(alarm: WakeUpAlarm) {
        player?.release()
        // keep.xml keeps every sound prefix: they are only named at run time.
        @Suppress("DiscouragedApi")
        val res = resources.getIdentifier(alarm.sound, "raw", packageName)
            .takeIf { it != 0 }
            ?: resources.getIdentifier("dot_alarm", "raw", packageName)
        val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        val audio = getSystemService(AudioManager::class.java)
        val p = MediaPlayer.create(this, res, attributes, audio.generateAudioSessionId()) ?: return
        p.isLooping = true
        player = p
        ramp(p, alarm.rampSec)
        p.start()
    }

    /** 40 % to the stream's own volume over [seconds] (15 §4, 0 = at once). */
    private fun ramp(p: MediaPlayer, seconds: Int) {
        if (seconds <= 0) return p.setVolume(1f, 1f)
        val steps = seconds * 2
        for (i in 0..steps) {
            handler.postDelayed({
                val v = START_VOLUME + (1f - START_VOLUME) * i / steps
                runCatching { p.setVolume(v, v) }
            }, i * 500L)
        }
    }

    private fun vibrate() {
        val pattern = longArrayOf(0, 600, 400, 600, 1400)
        vibrator().vibrate(VibrationEffect.createWaveform(pattern, 0))
    }

    private fun vibrator() =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            getSystemService(VibratorManager::class.java).defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(VIBRATOR_SERVICE) as android.os.Vibrator
        }

    private fun notes() = getSystemService(NotificationManager::class.java)

    companion object {
        const val CHANNEL = "wake_up"
        const val EXTRA_ID = "id"
        private const val RING_NOTE = 0x57414b45 // "WAKE"

        /** The ringing cap (15 §4): it stops itself after 10 minutes. */
        private const val CAP_MS = 10 * 60 * 1000L
        private const val START_VOLUME = 0.4f

        /** The one ringing service, if any (same process as its callers). */
        @Volatile
        var instance: WakeUpRingService? = null
            private set

        fun ring(context: Context, id: String) {
            context.startForegroundService(
                Intent(context, WakeUpRingService::class.java).putExtra(EXTRA_ID, id),
            )
        }

        fun stop(context: Context) {
            instance?.silence()
            context.getSystemService(NotificationManager::class.java).cancel(RING_NOTE)
        }

        /** High importance, silent (the service plays the sound itself). */
        fun ensureChannel(context: Context) {
            val channel = NotificationChannel(
                CHANNEL,
                context.getString(R.string.wake_up_channel),
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                setSound(null, null)
                enableVibration(false)
                setBypassDnd(true)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            context.getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }
}
