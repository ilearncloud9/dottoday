import AppIntents

/// Siri and Shortcuts phrases for the five B6 intents (docs/09 M9.5).
/// Done, +15 and Start act on the dot under way (Start: else the next);
/// phrases are translated in <lang>.lproj/AppShortcuts.strings.
@available(iOS 16.0, *)
struct DotShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: AddTaskIntent(), phrases: ["Add a task in \(.applicationName)"],
      shortTitle: "intentAddTaskTitle", systemImageName: "plus.circle")
    AppShortcut(
      intent: WhatsNextIntent(), phrases: ["What's next in \(.applicationName)"],
      shortTitle: "intentWhatsNextTitle", systemImageName: "circle.dotted")
    AppShortcut(
      intent: MarkDoneIntent(), phrases: ["Mark my task done in \(.applicationName)"],
      shortTitle: "intentMarkDoneTitle", systemImageName: "checkmark.circle")
    AppShortcut(
      intent: AddFifteenIntent(), phrases: ["Give my task 15 more minutes in \(.applicationName)"],
      shortTitle: "intentAddFifteenTitle", systemImageName: "plus.circle.fill")
    AppShortcut(
      intent: StartFocusIntent(), phrases: ["Start focus in \(.applicationName)"],
      shortTitle: "intentStartFocusTitle", systemImageName: "smallcircle.filled.circle")
  }
}
