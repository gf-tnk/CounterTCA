# CounterTCA

A counter demo built with [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) (TCA).

## What it does

- Increment / decrement a counter
- Fetch a "fact" about the current number from a number-facts API
- Start/stop a timer that increments the counter every second

## Structure

`ContentFeature` is the app root — it composes three independent child features via `Scope`,
each with its own `State`/`Action`/view:

- `CounterFeature` — `count`, `decrementButtonTapped`/`incrementButtonTapped` (`CounterView`)
- `NumberFactFeature` — `fact`, `isLoadingFact`, `getFactButtonTapped(number:)`/`factResponse`
  (`NumberFactView`); the current count is passed in as an action parameter, not owned by this
  feature
- `TimerFeature` — `isTimerOn`, `toggleTimerButtonTapped`/`tick` (`TimerView`); emits `tick` but
  doesn't own `count`, so `ContentFeature` listens for `.timer(.tick)` and increments
  `state.counter.count` itself

`ContentView` scopes `StoreOf<ContentFeature>` into each child store
(`store.scope(state:action:)`) and hands them to the child views.

`NumberFactClient` — dependency for fetching facts, registered via `DependencyKey`

## Requirements

- Xcode 16+, iOS 16+
- swift-composable-architecture ≥ 1.24.0 (resolved via Swift Package Manager)

## Run

Open `CounterTCA.xcodeproj` in Xcode and run the `CounterTCA` scheme.

## Test

```bash
xcodebuild test -project CounterTCA.xcodeproj -scheme CounterTCA -destination "platform=iOS Simulator,name=iPhone 15 Pro"
```

Tests use `TestStore` with controlled dependencies (`TestClock`, stubbed `numberFact.fetch`) — no network or timing flakiness.
