// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// The folder holding every temporary folder a test process creates.
///
/// Folders go under `<test bundle name>/<process id>` in the user's temporary directory, and
/// the process's folder is removed when the process exits. On first use, folders left by test
/// processes that are no longer running, such as crashed runs, are removed too, so leftovers
/// cannot accumulate. A folder whose process is still running, such as a parallel test run,
/// is left alone. When the test bundle cannot be found, the process name is used instead.
///
/// Call `makeDirectory()` for each folder a test needs; the test does not need to remove it.
public enum TestScratchDirectory {
  /// The current process's folder, created, and registered for removal, on first use.
  static let root: URL = {
    let name = testBundleURL?.lastPathComponent ?? ProcessInfo.processInfo.processName
    let parent = URL.temporaryDirectory.appending(path: name, directoryHint: .isDirectory)
    removeAbandonedFolders(in: parent)
    let root = parent.appending(path: "\(getpid())", directoryHint: .isDirectory)
    try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    atexit {
      try? FileManager.default.removeItem(at: TestScratchDirectory.root)
    }
    return root
  }()

  /// Creates a new, empty folder for one test.
  public static func makeDirectory() throws -> URL {
    let directory = root.appending(path: UUID().uuidString, directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
  }

  /// Removes the folders in `parent` that are named after processes no longer running.
  static func removeAbandonedFolders(in parent: URL) {
    let names = (try? FileManager.default.contentsOfDirectory(atPath: parent.path)) ?? []
    for name in names {
      guard let pid = pid_t(name), !isRunning(pid) else { continue }
      try? FileManager.default.removeItem(at: parent.appending(path: name))
    }
  }

  /// Whether a process with this identifier is still running.
  private static func isRunning(_ pid: pid_t) -> Bool {
    kill(pid, 0) == 0 || errno != ESRCH
  }
}
