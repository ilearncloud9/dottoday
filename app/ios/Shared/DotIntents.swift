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
  static var isDiscoverable = false

  @Parameter(title: "intentParamTask")
  var occurrenceId: String

  init() {}
  init(occurrenceId: String) { self.occurrenceId = occurrenceId }

  func perform() async throws -> some IntentResult {
    DotActions.perform(.markDone, occurrenceId: occurrenceId)
    return .result()
  }
}

@available(iOS 16.0, macOS 13.0, *)
struct AddFifteenIntent: AppIntent {
  static var title: LocalizedStringResource = "intentAddFifteenTitle"
  static var isDiscoverable = false

  @Parameter(title: "intentParamTask")
  var occurrenceId: String

  /// The end the surface showed (ms since 1970): +15 applies only while
  /// the task still ends there (lib/domain/intents/dot_action.dart).
  @Parameter(title: "intentParamEnd")
  var plannedEndMs: Int

  init() {}
  init(occurrenceId: String, plannedEndMs: Int) {
    self.occurrenceId = occurrenceId
    self.plannedEndMs = plannedEndMs
  }

  func perform() async throws -> some IntentResult {
    DotActions.perform(
      .addFifteen, occurrenceId: occurrenceId,
      plannedEnd: Date(timeIntervalSince1970: Double(plannedEndMs) / 1000))
    return .result()
  }
}

@available(iOS 16.0, macOS 13.0, *)
struct StartFocusIntent: AppIntent {
  static var title: LocalizedStringResource = "intentStartFocusTitle"
  static var isDiscoverable = false
  static var openAppWhenRun = true

  @Parameter(title: "intentParamTask")
  var occurrenceId: String

  init() {}
  init(occurrenceId: String) { self.occurrenceId = occurrenceId }

  func perform() async throws -> some IntentResult {
    DotActions.perform(.startFocus, occurrenceId: occurrenceId)
    return .result()
  }
}
