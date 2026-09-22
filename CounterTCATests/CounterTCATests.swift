import ComposableArchitecture
import XCTest
@testable import CounterTCA

@MainActor
final class CounterTests: XCTestCase {
  func testCounter() async {
    let store = TestStore(initialState: ContentFeature.State()) {
      ContentFeature()
    }

    await store.send(.counter(.incrementButtonTapped)) {
      $0.counter.count = 1
    }
  }

  func testTimer() async throws {
    let clock = TestClock()

    let store = TestStore(initialState: ContentFeature.State()) {
      ContentFeature()
    } withDependencies: {
      $0.continuousClock = clock
    }

    await store.send(.timer(.toggleTimerButtonTapped)) {
      $0.timer.isTimerOn = true
    }
    await clock.advance(by: .seconds(1))
    await store.receive(\.timer.tick) {
      $0.counter.count = 1
    }
    await clock.advance(by: .seconds(1))
    await store.receive(\.timer.tick) {
      $0.counter.count = 2
    }
    await store.send(.timer(.toggleTimerButtonTapped)) {
      $0.timer.isTimerOn = false
    }
  }

  func testGetFact() async {
    let store = TestStore(initialState: ContentFeature.State()) {
      ContentFeature()
    } withDependencies: {
      $0.numberFact.fetch = { "\($0) is a great number!" }
    }
    await store.send(.fact(.getFactButtonTapped(number: 0))) {
      $0.fact.isLoadingFact = true
    }
    await store.receive(\.fact.factResponse) {
      $0.fact.fact = "0 is a great number!"
      $0.fact.isLoadingFact = false
    }
  }

  func testGetFact_Failure() async {
    let store = TestStore(initialState: ContentFeature.State()) {
      ContentFeature()
    } withDependencies: {
      $0.numberFact.fetch = { _ in
        struct SomeError: Error {}
        throw SomeError()
      }
    }
    XCTExpectFailure()
    await store.send(.fact(.getFactButtonTapped(number: 0))) {
      $0.fact.isLoadingFact = true
    }
  }
}
