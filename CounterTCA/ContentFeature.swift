import ComposableArchitecture

@Reducer
struct ContentFeature {
  @ObservableState
  struct State: Equatable {
    var counter = CounterFeature.State()
    var fact = NumberFactFeature.State()
    var timer = TimerFeature.State()
  }

  enum Action {
    case counter(CounterFeature.Action)
    case fact(NumberFactFeature.Action)
    case timer(TimerFeature.Action)
  }

  var body: some Reducer<State, Action> {
    Scope(state: \.counter, action: \.counter) {
      CounterFeature()
    }
    Scope(state: \.fact, action: \.fact) {
      NumberFactFeature()
    }
    Scope(state: \.timer, action: \.timer) {
      TimerFeature()
    }
    Reduce { state, action in
      switch action {
      case .counter(.decrementButtonTapped), .counter(.incrementButtonTapped):
        state.fact.fact = nil
        return .none

      case .fact:
        return .none

      case .timer(.tick):
        state.counter.count += 1
        return .none

      case .timer:
        return .none
      }
    }
  }
}
