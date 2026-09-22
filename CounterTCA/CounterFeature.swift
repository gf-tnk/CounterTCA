import ComposableArchitecture
import SwiftUI

@Reducer
struct CounterFeature {
  @ObservableState
  struct State: Equatable {
    var count = 0
  }

  enum Action {
    case decrementButtonTapped
    case incrementButtonTapped
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .decrementButtonTapped:
        state.count -= 1
        return .none

      case .incrementButtonTapped:
        state.count += 1
        return .none
      }
    }
  }
}

struct CounterView: View {
  let store: StoreOf<CounterFeature>

  var body: some View {
    WithPerceptionTracking {
      Section {
        Text("\(store.count)")
        Button("Decrement") {
          store.send(.decrementButtonTapped)
        }
        Button("Increment") {
          store.send(.incrementButtonTapped)
        }
      }
    }
  }
}
