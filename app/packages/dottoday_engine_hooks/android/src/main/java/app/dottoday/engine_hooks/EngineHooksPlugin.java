package app.dottoday.engine_hooks;

import android.content.Context;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;

/**
 * Hands every Flutter engine's messenger to the app (ADR-0019). The app's
 * own channels registered in MainActivity reach only the activity's
 * engine; a plugin is attached to every engine, the workmanager background
 * engine included, so `dottoday/alarm` can follow a plan the background
 * resync changed (R-10, docs/15 W1b).
 */
public final class EngineHooksPlugin implements FlutterPlugin {
    /** Attaches the app's channels to one engine. */
    public interface Hook {
        void attach(@NonNull Context context, @NonNull BinaryMessenger messenger);
    }

    private static volatile Hook hook;

    /** Called once from Application.onCreate, before any engine starts. */
    public static void install(@NonNull Hook h) {
        hook = h;
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        Hook h = hook;
        if (h == null) return;
        h.attach(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}
}
