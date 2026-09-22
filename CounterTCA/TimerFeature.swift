import ComposableArchitecture
import SwiftUI

@Reducer
struct TimerFeature {
  @ObservableState
  struct State: Equatable {
    var isTimerOn = false
  }

  enum Action {
    case tick
    case toggleTimerButtonTapped
  }

  @Dependency(\.continuousClock) var clock

  private nonisolated enum CancelID: Hashable {
    case timer
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .tick:
        return .none

      case .toggleTimerButtonTapped:
        state.isTimerOn.toggle()
        if state.isTimerOn {
          return .run { send in
            for await _ in await self.clock.timer(interval: .seconds(1)) {
              await send(.tick)
            }
          }
          .cancellable(id: CancelID.timer)
        } else {
          return .cancel(id: CancelID.timer)
        }
      }
    }
  }
}

struct TimerView: View {
  let store: StoreOf<TimerFeature>

  var body: some View {
    WithPerceptionTracking {
      Section {
        if store.isTimerOn {
          Button("Stop timer") {
            store.send(.toggleTimerButtonTapped)
          }
        } else {
          Button("Start timer") {
            store.send(.toggleTimerButtonTapped)
          }
        }
      }
    }
  }
}
