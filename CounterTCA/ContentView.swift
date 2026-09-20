import SwiftUI
import ComposableArchitecture

struct NumberFactClient {
  var fetch: @Sendable (Int) async throws -> String
}

extension NumberFactClient: DependencyKey {
  static let liveValue = Self { number in
    let (data, _) = try await URLSession.shared.data(
      from: URL(string: "http://www.numbersapi.com/\(number)")!
    )
    return String(decoding: data, as: UTF8.self)
  }
}

extension DependencyValues {
  var numberFact: NumberFactClient {
    get { self[NumberFactClient.self] }
    set { self[NumberFactClient.self] = newValue }
  }
}

@Reducer
struct CounterFeature {
  
  @Dependency(\.continuousClock) var clock
  @Dependency(\.numberFact) var numberFact
  
  @ObservableState
  struct State: Equatable {
    var count = 0
    var fact: String?
    var isLoadingFact = false
    var isTimerOn = false
  }
  
  enum Action: Equatable {
    case decrementButtonTapped
    case factResponse(String)
    case getFactButtonTapped
    case incrementButtonTapped
    case timerTicked
    case toggleTimerButtonTapped
  }
  
  private nonisolated enum CancelID: Hashable {
    case timer
  }
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .decrementButtonTapped:
        state.count -= 1
        state.fact = nil
        return .none
        
      case let .factResponse(fact):
        state.fact = fact
        state.isLoadingFact = false
        return .none
        
      case .getFactButtonTapped:
        state.fact = nil
        state.isLoadingFact = true
        return .run { [state] send in
          try await send(.factResponse(self.numberFact.fetch(state.count)))
        }
        
      case .incrementButtonTapped:
        state.count += 1
        state.fact = nil
        return .none
        
      case .timerTicked:
        state.count += 1
        return .none
        
      case .toggleTimerButtonTapped:
        state.isTimerOn.toggle()
        if state.isTimerOn {
          return .run { send in
            for await _ in await self.clock.timer(interval: .seconds(1)) {
              await send(.timerTicked)
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

struct ContentView: View {
  let store: StoreOf<CounterFeature>
  
  var body: some View {
    WithPerceptionTracking {
      Form {
        Section {
          Text("\(store.count)")
          Button("Decrement") {
            store.send(.decrementButtonTapped)
          }
          Button("Increment") {
            store.send(.incrementButtonTapped)
          }
        }
        Section {
          Button {
            store.send(.getFactButtonTapped)
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
}

#Preview {
  ContentView(
    store: Store(
      initialState: CounterFeature.State()
    ) {
      CounterFeature()
        ._printChanges()
    }
  )
}
