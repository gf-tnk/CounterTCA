import ComposableArchitecture
import SwiftUI

@Reducer
struct NumberFactFeature {
  @ObservableState
  struct State: Equatable {
    var fact: String?
    var isLoadingFact = false
  }

  enum Action {
    case factResponse(String)
    case getFactButtonTapped(number: Int)
  }

  @Dependency(\.numberFact) var numberFact

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case let .factResponse(fact):
        state.fact = fact
        state.isLoadingFact = false
        return .none

      case let .getFactButtonTapped(number):
        state.fact = nil
        state.isLoadingFact = true
        return .run { send in
          try await send(.factResponse(self.numberFact.fetch(number)))
        }
      }
    }
  }
}

struct NumberFactView: View {
  let store: StoreOf<NumberFactFeature>
  let number: Int

  var body: some View {
    WithPerceptionTracking {
      Section {
        Button {
          store.send(.getFactButtonTapped(number: number))
        } label: {
          HStack {
            Text("Get fact")
            if store.isLoadingFact {
              Spacer()
              ProgressView()
            }
          }
        }
        if let fact = store.fact {
          Text(fact)
        }
      }
    }
  }
}
