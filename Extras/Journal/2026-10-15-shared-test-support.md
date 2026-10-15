# Shared Test Support

ChaosTesting became the shared home for test helpers that several Elegant Chaos packages had
been copying, starting with the ones Bookish needed to stop its tests leaking files.

## Added

- `TestScratchDirectory`: test folders under `<temp>/<test bundle name>/<pid>/`. The process
  folder is removed at exit, and folders of processes that are no longer running are removed on
  first use. It replaces a copy in each of two Bookish test targets. `inTempFolder` now makes its
  folders there, so a crash inside its closure no longer leaks the folder.
- `TestSettings`: the in-memory `UserDefaults` from Settings' `SettingsTestSupport`, unchanged
  apart from its suite name. Nothing in it was specific to Settings.
- `waitUntil`: suspends until a condition over `@Observable` state holds, re-checking on each
  observed change. Two Bookish test targets had identical copies.

## Platforms and toolchains

- The floor is macOS 14, iOS 17, tvOS 17 and watchOS 10, for Observation and
  `NSLocking.withLock`. Every current consumer is above it.
- SwiftPM 6.4 builds one bundle per test target in `.build/out/Products/Debug`, so the bundle
  and build-folder tests accept both that layout and the older one.

## Left out

- Polling waits, which sleep between checks. Tests should wait on a signal instead.
- Package-specific fixtures and stubs.

## Open

- `persistentSuite(prefix:)` still leaves a preferences file once a test writes to it. Nothing
  sweeps those up yet.
