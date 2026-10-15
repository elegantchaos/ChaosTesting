// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Observation

/// Suspends until `condition` holds, re-checking it whenever something it reads changes.
///
/// The condition is evaluated under observation tracking, so it must read the `@Observable`
/// state whose changes can make it true; a change to anything else does not wake the wait.
/// It does not time out, so pair it with a `.timeLimit` trait on the test.
@MainActor
public func waitUntil(_ condition: @escaping @MainActor () -> Bool) async {
  while !condition() {
    await withCheckedContinuation { continuation in
      withObservationTracking {
        _ = condition()
      } onChange: {
        continuation.resume()
      }
    }
  }
}
