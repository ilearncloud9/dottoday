package app.dottoday.planner.alarms

import android.content.Context
import android.graphics.Typeface
import android.os.Build
import android.view.WindowInsets

/**
 * Manrope, Concept E's type (ED-110), read from the font the Flutter app
 * already bundles, so the ringing screen matches the app without a second
 * copy. Variable, so each weight is set on its axis; cached per weight.
 */
object Manrope {
    const val SEMI_BOLD = 600
    const val BOLD = 700
    const val EXTRA_BOLD = 800

    private const val ASSET = "flutter_assets/assets/fonts/Manrope-Variable.ttf"
    private val cache = mutableMapOf<Int, Typeface>()

    fun of(context: Context, weight: Int): Typeface = cache.getOrPut(weight) {
        try {
            Typeface.Builder(context.assets, ASSET).setFontVariationSettings("'wght' $weight").build()
        } catch (_: RuntimeException) {
            Typeface.create(Typeface.DEFAULT, if (weight >= BOLD) Typeface.BOLD else Typeface.NORMAL)
        }
    }
}

/** The status and navigation bars plus the camera cutout, in px. */
data class SystemInsets(val left: Int, val top: Int, val right: Int, val bottom: Int) {
    companion object {
        fun of(insets: WindowInsets): SystemInsets {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                val i = insets.getInsets(WindowInsets.Type.systemBars() or WindowInsets.Type.displayCutout())
                return SystemInsets(i.left, i.top, i.right, i.bottom)
            }
            @Suppress("DEPRECATION")
            val cut = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) insets.displayCutout else null
            @Suppress("DEPRECATION")
            return SystemInsets(
                maxOf(insets.systemWindowInsetLeft, cut?.safeInsetLeft ?: 0),
                maxOf(insets.systemWindowInsetTop, cut?.safeInsetTop ?: 0),
                maxOf(insets.systemWindowInsetRight, cut?.safeInsetRight ?: 0),
                insets.systemWindowInsetBottom,
            )
        }
    }
}
