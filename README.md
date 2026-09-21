# CounterTCA

A counter demo built with [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) (TCA).

## What it does

- Increment / decrement a counter
- Fetch a "fact" about the current number from a number-facts API
- Start/stop a timer that increments the counter every second

## Structure

- `CounterFeature` — `@Reducer` holding `State`, `Action`, and the reducer logic in `body`
- `ContentView` — SwiftUI view driven by `StoreOf<CounterFeature>`
- `NumberFactClient` — dependency for fetching facts, registered via `DependencyKey`

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
