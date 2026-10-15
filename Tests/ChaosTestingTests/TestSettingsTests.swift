// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ChaosTesting
import Foundation
import Testing

/// Checks that test settings behave like `UserDefaults` while keeping everything in memory.
struct TestSettingsTests {
  @Test func storesFoundationTypedValues() {
    let settings = TestSettings()

    settings.set(true, forKey: "flag")
    settings.set(42, forKey: "count")
    settings.set("name", forKey: "label")

    #expect(settings.bool(forKey: "flag"))
    #expect(settings.integer(forKey: "count") == 42)
    #expect(settings.string(forKey: "label") == "name")
  }

  @Test func storesDoublesAndURLs() throws {
    let settings = TestSettings()
    let url = try #require(URL(string: "https://example.com/path"))

    settings.set(1.5, forKey: "ratio")
    settings.set(url, forKey: "link")

    #expect(settings.double(forKey: "ratio") == 1.5)
    #expect(settings.url(forKey: "link") == url)
  }

  @Test func registeredDefaultsAreReadUntilAValueIsSet() {
    let settings = TestSettings()
    settings.register(defaults: ["label": "registered", "count": 1])

    #expect(settings.string(forKey: "label") == "registered")
    #expect(settings.integer(forKey: "count") == 1)

    settings.set("stored", forKey: "label")
    #expect(settings.string(forKey: "label") == "stored")

    settings.removeObject(forKey: "label")
    #expect(settings.string(forKey: "label") == "registered")
  }

  @Test func registeredDefaultsStayWithTheirInstance() {
    let first = TestSettings()
    let second = TestSettings()

    first.register(defaults: ["label": "registered"])

    #expect(second.object(forKey: "label") == nil)
    #expect(UserDefaults.standard.object(forKey: "label") == nil)
  }

  @Test func dictionaryRepresentationHoldsStoredAndRegisteredValues() {
    let settings = TestSettings()
    settings.register(defaults: ["label": "registered", "count": 1])
    settings.set("stored", forKey: "label")
    settings.set(true, forKey: "flag")

    let representation = settings.dictionaryRepresentation()

    #expect(representation.count == 3)
    #expect(representation["label"] as? String == "stored")
    #expect(representation["count"] as? Int == 1)
    #expect(representation["flag"] as? Bool == true)
  }

  @Test func removesValues() {
    let settings = TestSettings()
    settings.set("name", forKey: "label")

    settings.removeObject(forKey: "label")

    #expect(settings.object(forKey: "label") == nil)
  }

  @Test func isolatesInstances() {
    let first = TestSettings()
    let second = TestSettings()

    first.set("name", forKey: "label")

    #expect(second.object(forKey: "label") == nil)
  }

  /// Anything reaching the preferences system leaves a file behind, so nothing may reach it.
  @Test func writesNothingToThePreferencesSystem() throws {
    let settings = TestSettings()

    settings.set("name", forKey: "label")
    settings.set(true, forKey: "flag")

    let persisted = try #require(UserDefaults(suiteName: TestSettings.suiteName))
    #expect(persisted.persistentDomain(forName: TestSettings.suiteName) == nil)
  }

  @Test func persistentSuiteNamesStartWithThePrefix() throws {
    let name = TestSettings.persistentSuiteName(prefix: "ExampleTests")
    let other = TestSettings.persistentSuiteName(prefix: "ExampleTests")

    let suffix = try #require(name.split(separator: "-", maxSplits: 1).last)
    #expect(name.hasPrefix("ExampleTests-"))
    #expect(UUID(uuidString: String(suffix)) != nil)
    #expect(name != other)
  }

  @Test func persistentSuitesAreRealSuites() {
    let settings = TestSettings.persistentSuite(prefix: "ChaosTestingTests")

    #expect(!(settings is TestSettings))
    #expect(settings.object(forKey: "label") == nil)
  }
}

#if canImport(SwiftUI)
  import SwiftUI

  /// Checks that SwiftUI's `@AppStorage` can use test settings as its store.
  struct TestSettingsAppStorageTests {
    @Test func appStorageReadsAndWritesTestSettings() {
      let settings = TestSettings()
      @AppStorage("testString", store: settings) var testString: String = ""

      testString = "foo bar"

      #expect(testString == "foo bar")
      #expect(settings.string(forKey: "testString") == "foo bar")
    }
  }
#endif
