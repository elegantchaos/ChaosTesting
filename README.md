# ChaosTesting

Some swift-test helpers.

## Scratch folders

`TestScratchDirectory.makeDirectory()` returns a new, empty folder for a test to write to:

```swift
let folder = try TestScratchDirectory.makeDirectory()
```

Tests do not need to remove these folders. Every folder a test process makes goes under
`<test bundle name>/<process id>` in the user's temporary directory. That process folder is
removed when the process exits, and folders left by processes that are no longer running, such
as crashed runs, are removed the next time a test process makes a folder.

`Test.current?.inTempFolder { url in ... }` makes its folder the same way, and also removes it as
soon as the closure returns.

## Settings

`TestSettings()` is a `UserDefaults` subclass that keeps its values in memory, so a test can
pass it anywhere a `UserDefaults` is expected without touching the user's preferences or leaving
a preferences file behind. `TestSettings.persistentSuite(prefix:)` makes a real suite with a
recognisable name, for the rare test that needs the preferences system itself.

## Waiting for observable state

`await waitUntil { model.isReady }` suspends until the condition holds, re-checking it whenever
the `@Observable` state it reads changes. It does not time out, so give the test a `.timeLimit`.

## Test bundle and tools

`Test.current?.bundleURL` and `buildFolderURL` locate the running test bundle and the build
folder that holds it. `urlForTool(_:)` finds a tool built alongside the tests, falling back to
the system `PATH`.
