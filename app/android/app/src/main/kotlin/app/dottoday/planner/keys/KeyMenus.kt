package app.dottoday.planner.keys

import android.view.KeyEvent
import android.view.KeyboardShortcutGroup
import android.view.KeyboardShortcutInfo
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * The app's commands in Android's Keyboard Shortcuts Helper (Meta+/, R2-10,
 * ED-095), from the same list as the Mac's and the iPad's menus
 * (lib/app_menus.dart, sent by lib/app_native_menus.dart over
 * `dottoday/key_menus`). Only commands with a key are listed, each under
 * its menu's name, with Ctrl (and Shift). The keys themselves are Flutter's.
 */
object KeyMenus {
    private var menus: List<Map<String, Any?>> = emptyList()

    fun attach(messenger: BinaryMessenger) {
        MethodChannel(messenger, "dottoday/key_menus").setMethodCallHandler { call, result ->
            if (call.method != "set") return@setMethodCallHandler result.notImplemented()
            @Suppress("UNCHECKED_CAST")
            menus = (call.arguments as? List<Map<String, Any?>>).orEmpty()
            result.success(null)
        }
    }

    /** The groups for [android.app.Activity.onProvideKeyboardShortcuts]. */
    fun groups(): List<KeyboardShortcutGroup> = menus.mapNotNull { menu ->
        @Suppress("UNCHECKED_CAST")
        val items = (menu["groups"] as? List<List<Map<String, Any?>>>).orEmpty().flatten()
            .mapNotNull(::shortcut)
        if (items.isEmpty()) null
        else KeyboardShortcutGroup(menu["label"] as? String ?: "", items)
    }

    private fun shortcut(item: Map<String, Any?>): KeyboardShortcutInfo? {
        val label = item["label"] as? String ?: return null
        val code = keyCode(item["key"] as? String ?: return null) ?: return null
        var modifiers = KeyEvent.META_CTRL_ON
        if (item["shift"] == true) modifiers = modifiers or KeyEvent.META_SHIFT_ON
        if (item["alt"] == true) modifiers = modifiers or KeyEvent.META_ALT_ON
        return KeyboardShortcutInfo(label, code, modifiers)
    }

    private fun keyCode(key: String): Int? = when {
        key.length == 1 && key[0] in 'a'..'z' -> KeyEvent.KEYCODE_A + (key[0] - 'a')
        key.length == 1 && key[0] in '0'..'9' -> KeyEvent.KEYCODE_0 + (key[0] - '0')
        key == "[" -> KeyEvent.KEYCODE_LEFT_BRACKET
        key == "]" -> KeyEvent.KEYCODE_RIGHT_BRACKET
        key == "/" -> KeyEvent.KEYCODE_SLASH
        key == "," -> KeyEvent.KEYCODE_COMMA
        else -> null
    }
}
