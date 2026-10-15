// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Testing

@testable import ChaosTesting

/// Checks where scratch folders are made and which leftover folders are cleaned up.
struct TestScratchDirectoryTests {
  /// The process's folder sits in the temporary directory, under the test bundle's name.
  @Test
  func processFolderIsNamedAfterTheBundleAndProcess() {
    let root = TestScratchDirectory.root

    #expect(root.lastPathComponent == "\(getpid())")
    #expect(
      root.deletingLastPathComponent().lastPathComponent == "ChaosTestingTests"
        || root.deletingLastPathComponent().lastPathComponent == "ChaosTestingPackageTests")
    #expect(
      root.deletingLastPathComponent().deletingLastPathComponent().standardizedFileURL
        == URL.temporaryDirectory.standardizedFileURL)
  }

  /// Each new folder is empty, distinct, and inside the process's folder.
  @Test
  func newFoldersAreEmptyAndInsideTheProcessFolder() throws {
    let first = try TestScratchDirectory.makeDirectory()
    let second = try TestScratchDirectory.makeDirectory()

    #expect(first != second)
    #expect(try FileManager.default.contentsOfDirectory(atPath: first.path).isEmpty)
    #expect(first.deletingLastPathComponent() == TestScratchDirectory.root)
  }

  /// Folders of processes that have ended are removed; running processes' folders and
  /// folders not named after a process are kept.
  @Test
  func onlyFoldersOfEndedProcessesAreRemoved() throws {
    let parent = try TestScratchDirectory.makeDirectory()
    let ended = parent.appending(path: "\(pid_t.max)")
    let running = parent.appending(path: "\(getpid())")
    let unrelated = parent.appending(path: "unrelated")
    for folder in [ended, running, unrelated] {
      try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    }

    TestScratchDirectory.removeAbandonedFolders(in: parent)

    #expect(FileManager.default.fileExists(atPath: ended.path) == false)
    #expect(FileManager.default.fileExists(atPath: running.path))
    #expect(FileManager.default.fileExists(atPath: unrelated.path))
  }

  /// A temporary folder is made inside the process's folder and removed afterwards.
  @Test
  func temporaryFoldersAreMadeInTheProcessFolder() async throws {
    let folder = try await Test.current?.inTempFolder { url in
      #expect(url.deletingLastPathComponent() == TestScratchDirectory.root)
      return url
    }

    let removed = try #require(folder)
    #expect(FileManager.default.fileExists(atPath: removed.path) == false)
  }
}
