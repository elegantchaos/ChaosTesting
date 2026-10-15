import Foundation
import Testing

@testable import ChaosTesting

/// Test looking up a tool in the system path.
@Test func testURLForBuiltInTool() async throws {
  let url = Test.current?.urlForTool("ls")
  #expect(url?.path == "/bin/ls")
}

/// Test getting the url to the test bundle
@Test func testBundleURL() async throws {
  let url = Test.current?.bundleURL
  print(url!)
  // SwiftPM names the bundle after the package or, in newer toolchains, the test target.
  #expect(["ChaosTestingPackageTests", "ChaosTestingTests"].contains(url?.lastPathComponent))
}

/// Test getting the url to the build folder
@Test func testBuildFolderURL() async throws {
  let url = Test.current?.buildFolderURL
  print(url!)
  // Newer toolchains capitalise the configuration folder.
  #if DEBUG
    #expect(url?.lastPathComponent.lowercased() == "debug")
  #else
    #expect(url?.lastPathComponent.lowercased() == "release")
  #endif
}

/// Test performing some work in a temporary folder.
@Test func testInTempFolder() async throws {
  var savedURL: URL?
  try await Test.current?.inTempFolder { url in
    // check that the folder exists
    #expect(FileManager.default.fileExists(atPath: url.path))

    // check that it's in the expected location
    // macOS temp folder -- not sure whether this is guaranteed to pass on all platforms
    #expect(url.path.hasPrefix("/var/folders/"))
    savedURL = url
  }

  // check that it has been cleaned up
  #expect(FileManager.default.fileExists(atPath: savedURL!.path) == false)

  // check that a second folder has a different name
  try await Test.current?.inTempFolder { url in
    // check that the folder exists
    #expect(savedURL != url)
  }
}
