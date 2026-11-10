import Foundation
import Security

/// Queued words at rest on iOS and macOS (CR-160 I1, Q3): an `add_task`
/// entry's `text`, `subject` and `note` are sealed to the app's P-256 public
/// key before they reach the App Group, and opened only by the app, which
/// alone holds the private key in its own Keychain.
///
/// - Extensions, widgets and Siri get only the public key and its id,
///   published in the App Group; they can seal, never open.
/// - Sealing is ECIES with AES-GCM and a fresh ephemeral key per seal
///   (`eciesEncryptionStandardVariableIVX963SHA256AESGCM`, Security.framework).
/// - That API takes no associated data, so the entry's immutable metadata
///   (id, time, kind, owner, guest session, shared) is sealed with the
///   words and must match when opened: a changed owner stamp no longer
///   opens, so nothing can be re-attributed.
/// - The private key is `AfterFirstUnlockThisDeviceOnly`, never synced or
///   shared; each sealed entry names its key id, and old private keys are
///   kept, so old entries keep opening after a new key is made.
/// - A missing or wrong key, unknown key id or changed metadata leaves the
///   entry sealed and marked unreadable when read: kept, never applied,
///   never erased.
/// - With no public key published, or a failed seal, the caller refuses
///   the action: there is no plaintext fallback.
/// - The public key sits in writable App Group storage and is not
///   authenticated: a compromised App Group participant could publish its
///   own key for later entries (it could read the words as they are written
///   anyway). This protects words at rest, not against a compromised
///   extension. Nothing here logs words, ciphertext or keys.
enum QueueSeal {
  static let publicKeyKey = "action_queue_public_key"
  static let sealedField = "sealed"
  static let unreadableField = "unreadable"
  static let textFields = ["text", "subject", "note"]
  private static let algorithm = SecKeyAlgorithm.eciesEncryptionStandardVariableIVX963SHA256AESGCM
  private static let tagPrefix = "app.dottoday.planner.queue."

  /// Whether [entry] holds plaintext words that should be sealed.
  static func hasPlainText(_ entry: [String: Any]) -> Bool {
    entry[sealedField] == nil && textFields.contains { entry[$0] != nil }
  }

  /// The published `{key id, public key}`, or nil when there is none.
  static func publishedKey(_ defaults: UserDefaults) -> (id: String, key: SecKey)? {
    guard let raw = defaults.string(forKey: publicKeyKey),
      let data = raw.data(using: .utf8),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let id = json["id"] as? String,
      let b64 = json["pub"] as? String,
      let bytes = Data(base64Encoded: b64)
    else { return nil }
    let attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
    ]
    guard let key = SecKeyCreateWithData(bytes as CFData, attributes as CFDictionary, nil)
    else { return nil }
    return (id, key)
  }

  /// [entry] with its words sealed to the published key, or nil (refuse).
  static func seal(_ entry: [String: Any], defaults: UserDefaults) -> [String: Any]? {
    guard let (id, key) = publishedKey(defaults) else { return nil }
    return seal(entry, keyId: id, publicKey: key)
  }

  static func seal(_ entry: [String: Any], keyId: String, publicKey: SecKey) -> [String: Any]? {
    var words: [String: Any] = ["meta": metadata(entry)]
    for field in textFields { if let value = entry[field] { words[field] = value } }
    guard let plain = try? JSONSerialization.data(withJSONObject: words),
      let sealed = SecKeyCreateEncryptedData(publicKey, algorithm, plain as CFData, nil)
    else { return nil }
    var out = entry
    for field in textFields { out.removeValue(forKey: field) }
    out[sealedField] = ["v": 1, "key": keyId, "ct": (sealed as Data).base64EncodedString()]
    return out
  }

  /// [entry] opened for the app; or still sealed and marked unreadable when
  /// it can't be (the app's process only: the private key is its own).
  static func open(_ entry: [String: Any]) -> [String: Any] {
    guard let sealed = entry[sealedField] as? [String: Any] else { return entry }
    var unreadable = entry
    unreadable[unreadableField] = true
    guard let keyId = sealed["key"] as? String,
      let b64 = sealed["ct"] as? String,
      let data = Data(base64Encoded: b64),
      let key = privateKey(keyId),
      let plain = SecKeyCreateDecryptedData(key, algorithm, data as CFData, nil),
      let words = try? JSONSerialization.jsonObject(with: plain as Data) as? [String: Any],
      let meta = words["meta"] as? [String: Any],
      NSDictionary(dictionary: meta).isEqual(to: metadata(entry))
    else { return unreadable }
    var out = entry
    out.removeValue(forKey: sealedField)
    for field in textFields { if let value = words[field] { out[field] = value } }
    return out
  }

  /// The app only: makes sure a key pair exists whose public half is
  /// published. Kept when the published key's private half is here; else a
  /// new pair is made, its private key stored first and its public key
  /// published only then, so no half-made configuration is ever visible.
  @discardableResult
  static func ensureKey(_ defaults: UserDefaults, suite: String) -> Bool {
    if let (id, _) = publishedKey(defaults), privateKey(id) != nil { return true }
    let id = UUID().uuidString.lowercased()
    let attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrKeySizeInBits as String: 256,
      kSecPrivateKeyAttrs as String: [
        kSecAttrIsPermanent as String: true,
        kSecAttrApplicationTag as String: Data((tagPrefix + id).utf8),
        kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
      ],
    ]
    guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, nil),
      let pub = SecKeyCopyPublicKey(key),
      let bytes = SecKeyCopyExternalRepresentation(pub, nil) as Data?,
      let json = try? JSONSerialization.data(
        withJSONObject: ["v": 1, "id": id, "pub": bytes.base64EncodedString()]),
      let raw = String(data: json, encoding: .utf8)
    else { return false }
    defaults.set(raw, forKey: publicKeyKey)
    CFPreferencesAppSynchronize(suite as CFString)
    return true
  }

  /// Removes private key [id] (tests only).
  static func deleteKey(_ id: String) {
    SecItemDelete(
      [
        kSecClass as String: kSecClassKey,
        kSecAttrApplicationTag as String: Data((tagPrefix + id).utf8),
      ] as CFDictionary)
  }

  private static func privateKey(_ id: String) -> SecKey? {
    var item: CFTypeRef?
    let query: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: Data((tagPrefix + id).utf8),
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecReturnRef as String: true,
    ]
    guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess, let item else {
      return nil
    }
    return (item as! SecKey)  // swiftlint:disable:this force_cast
  }

  /// The fields that must never change after sealing.
  static func metadata(_ entry: [String: Any]) -> [String: Any] {
    [
      "id": entry["id"] ?? NSNull(),
      "at_ms": entry["at_ms"] ?? NSNull(),
      "kind": entry["kind"] ?? NSNull(),
      "owner": entry["owner"] ?? NSNull(),
      "guest_session": entry["guest_session"] ?? NSNull(),
      "shared": entry["shared"] as? Bool ?? false,
    ]
  }
}

extension DotQueue {
  /// The app only (CR-160 I1): under the queue's lock, makes sure its key
  /// pair exists, seals any plaintext an earlier version left (all or
  /// nothing, ids, times and owner stamps unchanged; a crash before the
  /// write leaves the queue as it was, after it sealed), and returns the
  /// queue with words opened, or entries marked unreadable. The stored
  /// queue stays sealed. Nil when the queue can't be read.
  func readForApp() -> String? {
    QueueLock.run { () -> String? in
      reload()
      QueueSeal.ensureKey(defaults, suite: suite)
      guard let list = storedEntries() else {
        return defaults.string(forKey: DotStore.queueKey)
      }
      var changed = false
      var sealedList: [Any] = []
      var complete = true
      for item in list {
        guard let entry = item as? [String: Any], QueueSeal.hasPlainText(entry) else {
          sealedList.append(item)
          continue
        }
        guard let sealed = QueueSeal.seal(entry, defaults: defaults) else {
          complete = false
          break
        }
        sealedList.append(sealed)
        changed = true
      }
      let stored = complete && changed && write(sealedList) ? sealedList : list
      let opened: [Any] = stored.map { item in
        guard let entry = item as? [String: Any] else { return item }
        return QueueSeal.open(entry)
      }
      guard let data = try? JSONSerialization.data(withJSONObject: opened) else { return nil }
      return String(data: data, encoding: .utf8)
    }
  }
}
