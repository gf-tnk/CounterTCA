import ComposableArchitecture
import SwiftUI

struct ContentView: View {
  let store: StoreOf<ContentFeature>

  var body: some View {
    WithPerceptionTracking {
      Form {
        CounterView(store: store.scope(state: \.counter, action: \.counter))
        NumberFactView(
          store: store.scope(state: \.fact, action: \.fact),
          number: store.counter.count
        )
        TimerView(store: store.scope(state: \.timer, action: \.timer))
      }
    }
  }
}

#Preview {
  ContentView(
    store: Store(
      initialState: ContentFeature.State()
    ) {
      ContentFeature()
        ._printChanges()
    }
  )
}
