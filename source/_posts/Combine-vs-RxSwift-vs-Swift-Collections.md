---
title: "Combine vs RxSwift vs Swift collection chains"
date: 2026-05-07 12:00:00
categories:
- iOS
tags:
- Swift
- Combine
- RxSwift
- Reactive
- Functional
---

`map`, `filter`, `flatMap`, `reduce`. Swift has them on `Array`. RxSwift has them on `Observable`. Combine has them on `Publisher`. The names line up, the chains *look* the same, and that surface similarity is exactly what makes mixing the three confusing. They are not the same thing.

Three things separate them: sync vs async, eager vs lazy, and whether values arrive over time. Errors, cancellation, threading, and testing all fall out of those.

<!-- more -->

## TL;DR

| | **Swift collections** | **Combine** | **RxSwift** |
|---|---|---|---|
| **Type** | `Array`, `Sequence`, `LazySequence` | `Publisher`, `Subscriber` | `Observable`, `Observer` |
| **Domain** | Values in memory | Values over time | Values over time |
| **Evaluation** | Eager (default), lazy via `.lazy` | Lazy (cold) until subscribed | Lazy (cold) until subscribed |
| **Direction** | Pull (you iterate) | Push (subscribers receive) with demand | Push (subscribers receive) |
| **Backpressure** | N/A | Yes (`Subscribers.Demand`) | No (manual) |
| **Errors** | `throws` (sync) or none | Typed `Failure` associated type | Untyped `Error` |
| **Cancellation** | N/A | `AnyCancellable` | `Disposable` / `DisposeBag` |
| **Threading** | Caller's thread | `subscribe(on:)` / `receive(on:)` | `subscribeOn` / `observeOn` |
| **Subjects** | N/A | `PassthroughSubject`, `CurrentValueSubject` | `PublishSubject`, `BehaviorSubject`, `ReplaySubject` |
| **Platform** | All Swift | iOS 13+, macOS 10.15+ | All (third-party) |
| **Today's role** | Always relevant | Apple's official path | Legacy / cross-platform |

## The three worlds, in one diagram

The mental model that helps most: collections operate over **values in space** (what's already in memory); reactive streams operate over **values in time** (what arrives later). The operators look identical because both are pipelines, but one runs to completion now, the other runs whenever a value shows up.

{% mermaid %}
flowchart LR
    subgraph C["Swift collections (space)"]
        direction LR
        A1["[1, 2, 3, 4]"] --> A2[".filter { > 1 }"]
        A2 --> A3[".map { * 2 }"]
        A3 --> A4["[4, 6, 8]"]
    end

    subgraph R["Reactive streams (time)"]
        direction LR
        B1["values...<br/>over time"] --> B2[".filter"]
        B2 --> B3[".map"]
        B3 --> B4["subscriber"]
    end

    style C fill:#eef,stroke:#669
    style R fill:#efe,stroke:#696
{% endmermaid %}

In the collection pipeline the entire dataset is known up front; the chain runs to completion synchronously when you call it (or on demand for each element if you wrap with `.lazy`). In the reactive pipeline the source emits whenever it wants, possibly forever, and operators are *templates* that get instantiated when somebody subscribes.

## Same chain, three implementations

Take a tiny task: "Given a list of numbers, keep the evens, double them, and sum the result."

```swift
// Swift collections: eager, synchronous
let result = [1, 2, 3, 4, 5, 6]
    .filter { $0.isMultiple(of: 2) }
    .map { $0 * 2 }
    .reduce(0, +)
// result == 24 immediately
```

```swift
// Combine: lazy, push-based
import Combine

var bag = Set<AnyCancellable>()
[1, 2, 3, 4, 5, 6].publisher
    .filter { $0.isMultiple(of: 2) }
    .map { $0 * 2 }
    .reduce(0, +)
    .sink { print($0) } // prints 24 on subscription
    .store(in: &bag)
```

```swift
// RxSwift: lazy, push-based
import RxSwift

let disposeBag = DisposeBag()
Observable.from([1, 2, 3, 4, 5, 6])
    .filter { $0.isMultiple(of: 2) }
    .map { $0 * 2 }
    .reduce(0, accumulator: +)
    .subscribe(onNext: { print($0) }) // prints 24 on subscription
    .disposed(by: disposeBag)
```

Looks identical. They are not. The collection version runs the moment you write it. The other two build a pipeline description and don't run anything until `sink` / `subscribe` is called. Drop those final lines and Combine/RxSwift produce zero work.

## Lazy collections: the closest cousin

Swift collections *can* be lazy, and that's the closest sync analogue to a reactive pipeline:

```swift
let pipeline = (1...).lazy
    .filter { $0.isMultiple(of: 2) }
    .map { $0 * $0 }
// nothing computed yet
let firstThree = Array(pipeline.prefix(3)) // [4, 16, 36]
```

`LazySequence` is pull-based (the consumer iterates), reactive streams are push-based (the producer emits), but the laziness is the same idea: nothing happens until somebody asks. The remaining gap is **time**. `LazySequence` cannot represent "a value will arrive in 200 ms," only "a value will be computed when iterated."

## Eager vs lazy execution

{% mermaid %}
sequenceDiagram
    participant Caller
    participant Pipeline
    Note over Caller,Pipeline: Swift collection (eager)
    Caller->>Pipeline: filter
    Pipeline-->>Caller: [2,4,6]
    Caller->>Pipeline: map
    Pipeline-->>Caller: [4,8,12]
    Caller->>Pipeline: reduce
    Pipeline-->>Caller: 24
{% endmermaid %}

Each operator on `Array` allocates a new array. Three operators, three intermediate allocations. For small collections this is fine; for large ones, switch to `.lazy`.

{% mermaid %}
sequenceDiagram
    participant Source as Publisher / Observable
    participant Op1 as filter
    participant Op2 as map
    participant Sub as Subscriber
    Note over Source,Sub: Combine / RxSwift (lazy, push)
    Sub->>Op2: subscribe
    Op2->>Op1: subscribe
    Op1->>Source: subscribe
    Source-->>Op1: 1
    Op1-->>Source: (drop)
    Source-->>Op1: 2
    Op1-->>Op2: 2
    Op2-->>Sub: 4
    Source-->>Op1: 3
    Op1-->>Source: (drop)
    Source-->>Op1: complete
    Op1-->>Op2: complete
    Op2-->>Sub: complete
{% endmermaid %}

Subscription chains *upstream* (the subscriber is at the bottom and asks the source for values), values flow *downstream*. That direction is the bit reactive newcomers tend to get backwards.

## The operator name overlap is a trap

`flatMap` is the canonical example. Three different things:

- **`Array.flatMap`**: flatten one level. `[[1,2],[3]].flatMap { $0 } == [1,2,3]`. Synchronous.
- **`Publisher.flatMap`**: for each value, subscribe to a returned publisher and merge their outputs. Concurrency-bounded by `maxPublishers`.
- **`Observable.flatMap`**: project each value into an `Observable` and merge. RxSwift also has `flatMapLatest` (cancels the previous inner) and `concatMap` (queues serially). Combine has `switchToLatest` for the same purpose, applied differently.

Knowing what `flatMap` returns isn't enough; you also need to know which *flavor* you want: merge, switch-to-latest, or concat. Reach for the wrong one and you get either lost values or stale ones.

## Errors

```swift
// Swift collections
struct ParseError: Error {}
do {
    let parsed = try ["1", "2", "x"].map { s -> Int in
        guard let n = Int(s) else { throw ParseError() }
        return n
    }
} catch { /* throw escapes out of the chain */ }
```

```swift
// Combine: typed errors
let p: AnyPublisher<String, MyError> = ...
p.tryMap { try parse($0) }      // erases failure to Error
 .mapError { MyError.wrap($0) } // back to typed
 .catch { _ in Just(0) }        // recover with another publisher
```

```swift
// RxSwift: Error (untyped)
let o: Observable<String> = ...
o.map { try parse($0) }
 .catch { _ in .just(0) }
```

The practical difference: Combine's typed `Failure` lets the compiler tell you when an upstream can or can't fail. `Publisher<Output, Never>` is a strong guarantee, and `sink(receiveValue:)` (no completion handler) is only available when failure is `Never`. RxSwift erases all errors to `Error`, so the compiler can't help you.

A reactive stream also **terminates on error**: once it errors, it's done forever. I've shipped this bug more than once: catch a transient failure during dev, see one retry succeed, ship, then watch the pipeline silently die in production after the first real error. Use `catch` / `retry` / `replaceError` to keep it alive.

## Cancellation

Collections don't cancel: they're synchronous, you either let them finish or never call them. Reactive pipelines own real resources (timers, network requests, KVO observers) and must be torn down explicitly.

```swift
// Combine
let cancellable = publisher.sink { ... }
cancellable.cancel() // or store in Set<AnyCancellable> and let it dealloc

// RxSwift
let disposable = observable.subscribe { ... }
disposable.dispose() // or .disposed(by: disposeBag)
```

Both follow the same rule: when the cancellable / disposable is deallocated, the subscription is torn down. Forget to retain it and the chain dies *before any values arrive*. Forget to release it and you get retain cycles via `[weak self]` mistakes.

## Threading and scheduling

```swift
// Combine
URLSession.shared.dataTaskPublisher(for: url)
    .subscribe(on: DispatchQueue.global())   // upstream work off main
    .map { decode($0.data) }
    .receive(on: DispatchQueue.main)         // downstream delivery on main
    .sink { update(with: $0) }
```

```swift
// RxSwift
URLSession.shared.rx.data(request: req)
    .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    .map { decode($0) }
    .observeOn(MainScheduler.instance)
    .subscribe(onNext: { update(with: $0) })
```

Same shape, slightly different vocabulary. The two non-obvious rules apply to both:

1. `subscribe(on:)` / `subscribeOn` affects work **upstream** of where you call it (subscription, source emission). Calling it late in the chain is a common bug.
2. `receive(on:)` / `observeOn` affects everything **downstream**. UIKit/SwiftUI work belongs on main.

## Hot vs cold

A **cold** publisher/observable starts producing on subscription, and each subscriber gets its own run (e.g. a network request fires per subscriber). A **hot** one is already running; subscribers see whatever's emitted from now on.

Both libraries provide subjects to bridge the two:

| Need | Combine | RxSwift |
|---|---|---|
| Multicast event bus | `PassthroughSubject` | `PublishSubject` |
| "Current value, plus future" | `CurrentValueSubject` | `BehaviorSubject` |
| Replay last N | `.share(replay:)` via custom | `ReplaySubject` |

The most common bug: subscribing to a cold publisher twice (e.g. binding the same `URLSession.dataTaskPublisher` to two views) and seeing two requests. Fix with `.share()` (Combine) or `.share(replay:)` (RxSwift) to make it hot/multicast.

## Backpressure

Combine has it; RxSwift doesn't.

In Combine, subscribers signal demand: `Subscribers.Demand.max(N)` or `.unlimited`. Operators respect that demand and propagate it upstream. This is what makes Combine viable for fast producers (file reads, large CSV streams) without forcing buffering.

RxSwift has no formal backpressure. If your producer is faster than your consumer, you buffer or drop manually with `buffer`, `throttle`, `debounce`, `sample`. RxJava has `Flowable` for this; RxSwift never adopted the equivalent.

In practice most app-level reactive code is event-rate-limited (taps, network responses, KVO) and backpressure doesn't matter. It matters once you stream large datasets through a reactive pipeline.

## Testing

```swift
// Combine: synchronous via Just / Fail / scheduler injection
func testParse() {
    let cancellable = Just("42")
        .tryMap { try Int($0, strict: true) }
        .sink(receiveCompletion: { _ in }, receiveValue: { XCTAssertEqual($0, 42) })
    _ = cancellable
}
```

```swift
// RxSwift: RxTest with TestScheduler and virtual time
func testParse() {
    let scheduler = TestScheduler(initialClock: 0)
    let source = scheduler.createHotObservable([
        .next(10, "42"),
        .completed(20)
    ])
    let observer = scheduler.createObserver(Int.self)
    source.map { Int($0)! }.subscribe(observer).disposed(by: bag)
    scheduler.start()
    XCTAssertEqual(observer.events, [.next(10, 42), .completed(20)])
}
```

RxSwift's `RxTest` virtual-time scheduler is genuinely excellent for time-based tests (debounce, throttle, retry intervals). Combine's official testing story is weaker; the community settled on [`combine-schedulers`](https://github.com/pointfreeco/combine-schedulers) for the Combine equivalent, and [`swift-clocks`](https://github.com/pointfreeco/swift-clocks) for the `async`/`await` side.

## Other "values over time" structures in the Swift ecosystem

The three I started with aren't the whole story. A few more pipeline-shaped APIs you'll meet in real Swift code:

### `AsyncSequence` / `AsyncStream` / `AsyncThrowingStream`

The Swift Concurrency answer to reactive streams. Pull-based (the consumer iterates), but the iteration itself can suspend until the next value arrives:

```swift
for await value in numbers.filter({ $0.isMultiple(of: 2) }).map({ $0 * 2 }) {
    sum += value
}
```

`AsyncStream` lets you bridge any callback-based source (KVO, delegate, `NotificationCenter`) into `AsyncSequence`:

```swift
let timer = AsyncStream<Date> { continuation in
    let t = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
        continuation.yield(Date())
    }
    continuation.onTermination = { _ in t.invalidate() }
}
for await tick in timer.prefix(5) { print(tick) }
```

Where it lines up with Combine/RxSwift, and where it doesn't:

| | `AsyncSequence` | Combine `Publisher` |
|---|---|---|
| Direction | Pull (consumer iterates) | Push (with demand) |
| Cancellation | `Task` cancellation | `AnyCancellable.cancel()` |
| Multicast | No (single consumer) | Yes (`.share()`, subjects) |
| Backpressure | Implicit (consumer suspends) | Explicit (`Demand`) |
| Operators | `map`, `filter`, `prefix`, `compactMap`, `dropFirst`... | Larger set, plus time operators |
| Time operators | None in stdlib (community: [`AsyncAlgorithms`](https://github.com/apple/swift-async-algorithms)) | Built-in (`debounce`, `throttle`...) |
| Cold/Hot | Always cold per-iteration | Both, via subjects |

`AsyncSequence` is closer to `LazySequence` with suspension points than to `Observable`. If you only need to *consume* a stream of values one place, async iteration wins. If you need to fan out to multiple consumers, share state, or use rich time operators, you still want Combine (or `AsyncAlgorithms`'s `AsyncChannel` + multicast helpers).

### Combine ↔ `AsyncSequence` bridges

These exist in both directions and you'll use them:

```swift
// Publisher -> AsyncSequence (built-in)
for await value in publisher.values { print(value) }
// publisher.values is AsyncPublisher, which conforms to AsyncSequence.

// AsyncSequence -> Publisher (no built-in)
// Drive a Subject from a Task and expose its eraseToAnyPublisher().
let subject = PassthroughSubject<Int, Never>()
Task {
    for await v in asyncSequence { subject.send(v) }
    subject.send(completion: .finished)
}
let publisher = subject.eraseToAnyPublisher()
```

In practice, most modern code subscribes once (`for await ... in publisher.values`) and lets Combine do the multicast / hot-stream side, while consumers stay in async land. The reverse direction is rarer and you build it by hand.

### The Observation framework (`@Observable`, iOS 17+)

Not a pipeline, but worth flagging because it's often confused with reactive streams. The new `@Observable` macro replaces `ObservableObject` + `@Published` for SwiftUI state observation:

```swift
@Observable final class ViewModel {
    var name = ""
    var count = 0
}
```

SwiftUI views auto-track *exactly* the properties they read: no `@Published`, no `objectWillChange`, no Combine subscription. It's not a stream you can `map` over; it's a fine-grained dependency tracker. If you tried to model "give me a stream of `count` changes" you'd reach for `withObservationTracking` (a low-level escape hatch) or wrap the property in `AsyncStream`. For normal SwiftUI work, you don't need a stream at all.

### `@Published` (the bridge in the middle)

`@Published` is a Combine `Publisher`, full stop:

```swift
final class VM: ObservableObject {
    @Published var count = 0
}
let vm = VM()
vm.$count.sink { print($0) }
```

The `$count` projection is a `Publisher<Int, Never>`. SwiftUI uses it via `ObservableObject`; you can also subscribe directly. As `@Observable` takes over, `@Published` is the "I still want a Combine pipeline off this property" tool.

### TCA `Effect`, `EffectPublisher`

If you use [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture), `Effect` is a wrapper that started life as a Combine `Publisher` and migrated to async/await. Same pipeline shape, narrower role: it represents work a reducer kicks off, with cancellation by ID baked in. Mention it because TCA codebases blur "Combine vs async": the framework lets you write either inside an `Effect`.

### `Result`, `Optional`: also chainable, also not streams

`Optional.map` and `Result.flatMap` use the same vocabulary, but each represents a *single* value (present-or-not, success-or-failure). They're functor/monad cousins of the others, not stream cousins. Worth knowing because the operator-name overlap can mislead: `flatMap` on `Result<Int, E>` doesn't merge anything, it just chains a fallible step.

## Putting them on one axis

{% mermaid %}
flowchart LR
    subgraph Single["Single value"]
        Opt["Optional<br/>Result"]
    end
    subgraph Many["Many values, in space"]
        Coll["Array / Sequence"]
        LSeq["LazySequence"]
    end
    subgraph Time["Many values, over time"]
        Async["AsyncSequence /<br/>AsyncStream"]
        Comb["Combine Publisher"]
        Rx["RxSwift Observable"]
    end
    Opt -.same operator vocabulary.-> Coll
    Coll -.add laziness.-> LSeq
    LSeq -.add suspension.-> Async
    Async -.add multicast + push.-> Comb
    Comb -.cross-platform variant.-> Rx
{% endmermaid %}

Read it left-to-right as a feature ladder: each step adds one capability. Multiple values, then laziness, then time/suspension, then push semantics + multicast. The operator names (`map`, `filter`, `flatMap`) carry across because the underlying algebra is the same; what changes is the runtime behaviour around them.

## When to pick what

{% mermaid %}
flowchart TD
    Start{Are you operating on<br/>values that exist NOW?}
    Start -->|Yes, all in memory| Coll[Swift collections<br/><i>map / filter / reduce</i>]
    Start -->|Yes, but huge / infinite| Lazy[".lazy on the sequence"]
    Start -->|No - values arrive over time| Time{New code or existing?}
    Time -->|New| Async{Need bidirectional /<br/>multicast / hot streams?}
    Async -->|No| AA["async/await + AsyncSequence"]
    Async -->|Yes| Combine["Combine"]
    Time -->|Existing RxSwift codebase| Rx["RxSwift<br/><i>migrate gradually</i>"]
{% endmermaid %}

In 2026 the picture is:

- **Collections** are foundational; you use them every day regardless.
- **`async`/`await` + `AsyncSequence`** is now the default for "values over time" in new Swift code. Easier to reason about, no subscription lifetime to manage, no operator-name memorisation. Use this first.
- **Combine** is still the right answer when you need true multicast, hot subjects, `@Published`, or when you're glued to `URLSession.dataTaskPublisher` / `NotificationCenter.publisher` / SwiftUI bindings. Apple has slowed down Combine's evolution but it's not deprecated and remains everywhere in the system frameworks.
- **RxSwift** is legacy in pure-Swift Apple work. Keep it for codebases that already use it, or for cross-platform sharing with RxJava / RxJS / RxKotlin where the same mental model travels.

## Operator quick-reference

The same mental operation in all three:

| Intent | Collection | Combine | RxSwift |
|---|---|---|---|
| Transform | `map` | `map` | `map` |
| Filter | `filter` | `filter` | `filter` |
| Drop nils | `compactMap` | `compactMap` | `compactMap` |
| Flatten one level | `flatMap` | `flatMap(maxPublishers:)` | `flatMap` |
| Switch to newest | n/a | `map { ... }.switchToLatest()` | `flatMapLatest` |
| Combine two streams | `zip(a, b)` | `Publishers.Zip` / `combineLatest` | `Observable.zip` / `combineLatest` |
| Accumulate | `reduce(_:_:)` | `reduce` / `scan` | `reduce` / `scan` |
| Drop duplicates | n/a (use `Set`) | `removeDuplicates()` | `distinctUntilChanged()` |
| Take first | `prefix(1)` | `prefix(1)` / `first()` | `take(1)` |
| Drop first | `dropFirst(1)` | `dropFirst(1)` | `skip(1)` |
| Throttle/debounce | n/a | `throttle` / `debounce` | `throttle` / `debounce` |
| Side effect | `forEach` | `handleEvents` | `do(onNext:)` |

## What I reach for

For new code I default to `async`/`await` + `AsyncSequence`. Combine when I actually need multicast, hot subjects, or `@Published` for SwiftUI. RxSwift only when the codebase already runs on it.
