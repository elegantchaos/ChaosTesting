// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Settings that live in memory, isolated to one test.
///
/// A real suite leaves a preferences file behind once anything is written to it, and
/// `removePersistentDomain(forName:)` only empties that file. Keeping the values out of the
/// preferences system is the only way for a test to leave nothing behind.
///
/// Reading and writing values, registering defaults, and `dictionaryRepresentation()` all
/// stay in memory. SwiftUI's `@AppStorage` reads and writes these values when given the
/// instance as its store.
///
/// It differs from a real `UserDefaults` in these ways:
///
/// - Registered defaults belong to the instance. A real registration domain is shared by
///   the whole process.
/// - Nothing else is in the search list, so `dictionaryRepresentation()` holds only the
///   stored and registered values, and the global and argument domains are not read.
/// - Changes send no key-value observation notifications, so nothing that observes the
///   settings, including a live view, is told about them.
/// - The domain and suite methods, such as `setPersistentDomain(_:forName:)` and
///   `addSuite(named:)`, are inherited unchanged and act on the real preferences system.
///
/// Tests that need any of that should use ``persistentSuite(prefix:)`` instead.
public final class TestSettings: UserDefaults, @unchecked Sendable {
  /// The suite every instance is nominally attached to. Nothing is ever written to it.
  public static let suiteName = "ChaosTesting.TestSettings"

  private let lock = NSLock()
  private var values: [String: Any] = [:]
  private var registered: [String: Any] = [:]

  /// Creates empty settings.
  public init() {
    // The suite name is only refused when it names the main bundle or the global domain.
    super.init(suiteName: Self.suiteName)!
  }

  // Foundation's typed accessors route through the first three of these methods.

  public override func object(forKey defaultName: String) -> Any? {
    lock.withLock { values[defaultName] ?? registered[defaultName] }
  }

  public override func set(_ value: Any?, forKey defaultName: String) {
    lock.withLock { values[defaultName] = value }
  }

  public override func removeObject(forKey defaultName: String) {
    lock.withLock { values[defaultName] = nil }
  }

  public override func register(defaults registrationDictionary: [String: Any]) {
    lock.withLock { registered.merge(registrationDictionary) { _, new in new } }
  }

  public override func dictionaryRepresentation() -> [String: Any] {
    lock.withLock { registered.merging(values) { _, stored in stored } }
  }
}

extension TestSettings {
  /// Returns a unique name for a real suite, in the form `<prefix>-<UUID>`.
  public static func persistentSuiteName(prefix: String) -> String {
    "\(prefix)-\(UUID().uuidString)"
  }

  /// Creates a real suite for a test that needs the preferences system.
  ///
  /// Writing to the suite leaves a `<prefix>-<UUID>.plist` in the user's preferences that
  /// nothing removes. The prefix is there so the leftovers can be recognised and deleted.
  public static func persistentSuite(prefix: String) -> UserDefaults {
    let name = persistentSuiteName(prefix: prefix)
    guard let suite = UserDefaults(suiteName: name) else {
      preconditionFailure("Could not create test settings suite \(name)")
    }
    return suite
  }
}
