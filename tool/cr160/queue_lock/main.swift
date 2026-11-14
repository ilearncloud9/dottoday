// Driver for tool/cr160/queue_lock_check.sh (CR-160 I7): one process that
// appends to, or removes from, the shared queue through the real
// `DotQueue` (ios/Shared/DotStore.swift), as the app, the share extension
// and the widget extension do in their own processes.
//
//   qlock <suite> <lock dir> append <tag> <n>
//   qlock <suite> <lock dir> remove <id> ...
//   qlock <suite> <lock dir> publish <marker json>
//   qlock <suite> <lock dir> key
//   qlock <suite> <lock dir> count
//
// `key` publishes a public key (its private half kept in memory, never in
// a keychain) so the appends seal their words as the app's extensions do
// (CR-160 I1); `count` also reports any plaintext words left.
//
// The control run gives each process its own lock dir: no exclusion.
import Foundation
import Security

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
case "key":
  let pair = SecKeyCreateRandomKey(
    [kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom, kSecAttrKeySizeInBits: 256]
      as CFDictionary, nil)!
  let pub = SecKeyCopyExternalRepresentation(SecKeyCopyPublicKey(pair)!, nil)! as Data
  let json = try! JSONSerialization.data(
    withJSONObject: ["v": 1, "id": "lockcheck", "pub": pub.base64EncodedString()])
  UserDefaults(suiteName: suite)!.set(
    String(data: json, encoding: .utf8), forKey: QueueSeal.publicKeyKey)
  CFPreferencesAppSynchronize(suite as CFString)
case "count":
  let entries = queue.entries()
  let owners = Set(entries.compactMap { $0["owner"] as? String })
  let plain = entries.filter { $0["text"] != nil }.count
  print("entries \(entries.count) owners \(owners.sorted().joined(separator: ",")) plaintext \(plain)")
default:
  exit(2)
}
