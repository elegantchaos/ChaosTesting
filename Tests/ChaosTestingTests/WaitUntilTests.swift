// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ChaosTesting
import Observation
import Testing

/// Checks that waiting on observable state returns once the condition holds.
@MainActor
struct WaitUntilTests {
  /// A condition that already holds returns at once.
  @Test(.timeLimit(.minutes(1)))
  func returnsAtOnceWhenTheConditionHolds() async {
    let counter = Counter()
    counter.value = 1

    await waitUntil { counter.value == 1 }

    #expect(counter.value == 1)
  }

  /// A condition made true by a later change returns after that change.
  @Test(.timeLimit(.minutes(1)))
  func returnsAfterTheObservedValueChanges() async {
    let counter = Counter()
    Task { @MainActor in
      for _ in 0..<3 { counter.value += 1 }
    }

    await waitUntil { counter.value == 3 }

    #expect(counter.value == 3)
  }
}

/// Observable state for the tests to wait on.
@MainActor
@Observable
private final class Counter {
  /// The value the tests change and wait on.
  var value = 0
}
