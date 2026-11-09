// Driver for tool/cr160/queue_lock_check.sh (CR-160 I7): one process that
// appends to, or removes from, the shared queue through the real
// `DotQueue` (ios/Shared/DotStore.swift), as the app, the share extension
// and the widget extension do in their own processes.
//
//   qlock <suite> <lock dir> append <tag> <n>
//   qlock <suite> <lock dir> remove <id> ...
//   qlock <suite> <lock dir> publish <marker json>
//   qlock <suite> <lock dir> count
//
// The control run gives each process its own lock dir: no exclusion.
import Foundation

let args = CommandLine.arguments
let suite = args[1]
QueueLock.directoryOverride = URL(fileURLWithPath: args[2])
let queue = DotQueue(defaults: UserDefaults(suiteName: suite)!, suite: suite)

switch args[3] {
case "append":
  let tag = args[4]
  var refused = 0
  for i in 0..<Int(args[5])! {
    if !queue.append(DotQueue.entry(.addTask, text: "\(tag)-\(i)")) { refused += 1 }
  }
  print("refused \(refused)")
case "remove":
  for id in args[4...] { queue.remove([id]) }
case "publish":
  queue.publishOwner(args[4])
case "count":
  let entries = queue.entries()
  let owners = Set(entries.compactMap { $0["owner"] as? String })
  print("entries \(entries.count) owners \(owners.sorted().joined(separator: ","))")
default:
  exit(2)
}
