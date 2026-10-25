import AppIntents
import Foundation

// The five B6 intents (docs/11 §0, docs/09 M9.2), compiled into the app and
// the widget extension. Widgets, controls, the Live Activity and Siri call
// these and nothing else; each one queues for the app (DotActions).

@available(iOS 16.0, macOS 13.0, *)
struct AddTaskIntent: AppIntent {
  static var title: LocalizedStringResource = "intentAddTaskTitle"
  static var description = IntentDescription("intentAddTaskDescription")

  @Parameter(title: "intentParamText")
  var text: String

  init() {}
  init(text: String) { self.text = text }

  func perform() async throws -> some IntentResult & ProvidesDialog {
    DotActions.perform(.addTask, text: text)
    return .result(dialog: IntentDialog("intentAddTaskDone"))
  }
}

@available(iOS 16.0, macOS 13.0, *)
struct WhatsNextIntent: AppIntent {
  static var title: LocalizedStringResource = "intentWhatsNextTitle"
  static var description = IntentDescription("intentWhatsNextDescription")

  func perform() async throws -> some IntentResult & ProvidesDialog {
    guard let snapshot = DotActions.storedSnapshot(),
      let answer = DotActions.whatsNext(snapshot, at: Date())
    else { return .result(dialog: IntentDialog("intentNoSnapshot")) }
    return .result(dialog: IntentDialog(stringLiteral: answer))
  }
}

@available(iOS 16.0, macOS 13.0, *)
struct MarkDoneIntent: AppIntent {
  static var title: LocalizedStringResource = "intentMarkDoneTitle"

  /// The dot; none (Siri, Shortcuts) = the one under way now.
  @Parameter(title: "intentParamTask")
  var occurrenceId: String?

  init() {}
  init(occurrenceId: String) { self.occurrenceId = occurrenceId }

  func perform() async throws -> some IntentResult {
    guard let id = occurrenceId ?? DotActions.currentBlock()?.id else { return .result() }
    DotActions.perform(.markDone, occurrenceId: id)
    return .result()
  }
}

@available(iOS 16.0, macOS 13.0, *)
struct AddFifteenIntent: AppIntent {
  static var title: LocalizedStringResource = "intentAddFifteenTitle"

  /// The dot; none (Siri, Shortcuts) = the one under way now.
  @Parameter(title: "intentParamTask")
  var occurrenceId: String?

  /// The end the surface showed (ms since 1970): +15 applies only while
  /// the task still ends there (lib/domain/intents/dot_action.dart).
  @Parameter(title: "intentParamEnd")
  var plannedEndMs: Int?

  init() {}
  init(occurrenceId: String, plannedEndMs: Int) {
    self.occurrenceId = occurrenceId
    self.plannedEndMs = plannedEndMs
  }

  func perform() async throws -> some IntentResult {
    let current = DotActions.currentBlock()
    guard let id = occurrenceId ?? current?.id,
      let endMs = plannedEndMs.map(Double.init) ?? current?.endMs
    else { return .result() }
    DotActions.perform(
      .addFifteen, occurrenceId: id, plannedEnd: Date(timeIntervalSince1970: endMs / 1000))
    return .result()
  }
}

@available(iOS 16.0, macOS 13.0, *)
struct StartFocusIntent: AppIntent {
  static var title: LocalizedStringResource = "intentStartFocusTitle"
  static var openAppWhenRun = true

  /// The dot; none (Siri, the control) = the one under way, else the next.
  @Parameter(title: "intentParamTask")
  var occurrenceId: String?

  init() {}
  init(occurrenceId: String) { self.occurrenceId = occurrenceId }

  func perform() async throws -> some IntentResult {
    guard let id = occurrenceId ?? DotActions.currentBlock(orNext: true)?.id else { return .result() }
    DotActions.perform(.startFocus, occurrenceId: id)
    return .result()
  }
}

/// "Add task" from Control Center, the Action button or the Lock Screen
/// (iOS 18, docs/09 M9.5): opens Quick Add (`dottoday://add`).
@available(iOS 18.0, *)
struct OpenQuickAddIntent: AppIntent {
  static var title: LocalizedStringResource = "intentAddTaskTitle"
  static var isDiscoverable = false
  static var openAppWhenRun = true

  func perform() async throws -> some IntentResult & OpensIntent {
    .result(opensIntent: OpenURLIntent(URL(string: "dottoday://add")!))
  }
}
