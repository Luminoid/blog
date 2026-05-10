---
title: "iOS Concurrency and Parallelism Complete Guide"
date: 2026-04-03 12:00:00
categories:
- iOS
tags:
- Swift
- concurrency
- async-await
- GCD
- actors
- Combine
- OperationQueue
---

Every concurrency mechanism on Apple platforms, from `pthread` up to Swift 6.2's approachable concurrency. Runnable examples and migration paths.

<!-- more -->

## Quick comparison

| Mechanism | Introduced | Abstraction level | Cancellation | Priority | Structured | Swift 6 safe |
|-----------|-----------|-------------------|-------------|----------|-----------|-------------|
| POSIX Threads (`pthread`) | Unix (all Apple platforms) | Lowest | Manual | Manual | No | No |
| `Thread` (NSThread) | iOS 2.0 / macOS 10.0 (2001) | Low | Manual via `cancel()` | 5 levels | No | No |
| GCD (`DispatchQueue`) | iOS 4.0 / macOS 10.6 (2009) | Medium | `DispatchWorkItem` | QoS classes | No | No |
| `OperationQueue` | iOS 2.0 / macOS 10.5 (2007) | Medium-High | Built-in `cancel()` | QoS + dependencies | Partial | No |
| Combine | iOS 13 / macOS 10.15, Swift 5.1 (2019) | High (reactive) | `AnyCancellable` | Scheduler-based | No | No |
| `async`/`await` | iOS 13+ (back-deploy) / iOS 15 native, Swift 5.5 (2021) | High | `Task.cancel()` | `TaskPriority` | Yes | Yes |
| Actors | iOS 13+ (back-deploy) / iOS 15 native, Swift 5.5 (2021) | High | Via tasks | Inherited | Yes | Yes |
| `AsyncSequence` / `AsyncStream` | iOS 13+ (back-deploy) / iOS 15 native, Swift 5.5 (2021) | High | Task cancellation | Inherited | Yes | Yes |
| Swift 6 strict concurrency | 6.0 / Xcode 16 (2024); 6.1 (Mar 2025); 6.2 approachable (Sept 2025) | Compile-time | N/A | N/A | Yes | Yes |

{% note info %}
Swift Concurrency (`async`/`await`, actors, `AsyncSequence`) shipped natively with iOS 15 / macOS 12 (2021), but was **back-deployed to iOS 13 / macOS 10.15** starting with Xcode 13.2 (Dec 2021). Some newer APIs like `AsyncStream.makeStream` (Swift 5.9) and `withDiscardingTaskGroup` (Swift 5.9) require later minimum deployments.
{% endnote %}

---

## Mental model

Four ideas hold the rest of the chapter together. Worth carrying in your head before reading any specific API: most of the rules below are corollaries of these.

### Forward-progress contract

Swift Concurrency's runtime owns a small pool of threads, and its contract is that **every thread is always making progress**. A `Task` that calls `Thread.sleep`, `DispatchSemaphore.wait`, blocks on a `pthread_mutex` held by a peer, or makes a synchronous I/O call into a C library *parks the thread*. The runtime can't reclaim it, can't reassign it, and can't apologise: the cooperative pool just stalls.

This is the single biggest mental shift from GCD. Under GCD, blocking a worker was fine: the system spun up another worker. Under Swift Concurrency, blocking is a bug, and the rest of the design exists to make non-blocking ergonomic.

### The cooperative thread pool

GCD's failure mode was thread explosion. A queue with ready work and no available worker would create one: easy to push past the kernel's thread limit on I/O-bound workloads. Swift Concurrency intentionally caps the cooperative pool at roughly **one thread per CPU core, per QoS class**. Adding more threads doesn't help if everyone is parked, so the runtime forces you to *suspend* (release the thread) instead of *block* (occupy it).

This is also why creating millions of tasks is fine: they share that handful of threads via cheap suspensions, not by spawning kernel threads.

### `async` is a state machine, not a thread

The compiler splits each `async` function at every `await` into partial functions. Locals that survive a suspension live in a heap-allocated context; the function "returns" at `await` and the runtime invokes the next partial function when the awaited result is ready.

Two things follow:

- **Suspension is roughly a function call**: no kernel transition, no stack copy, no thread context switch. `await` is closer to `return` than to `Thread.sleep`.
- **Stack traces are split.** A debugger paused inside an async function shows the current partial function, not the whole logical call chain. Xcode's Async Backtrace view stitches the chain back together.

### Executors decide where work runs

Every `async` function runs on an *executor*. The ones you actually meet:

- The **global concurrent executor**: the cooperative pool above. The default for `Task { }` and `Task.detached { }`.
- Each **actor's serial executor**: every actor owns one, and it serializes incoming calls so actor state is data-race-free by construction.
- **`MainActor`'s executor**: the main run loop. `MainActor` is a global actor whose executor happens to be the main thread.

`await` is the place where the runtime can *change executors*. When you call an actor method from outside, the `await` is where you get enqueued on that actor's serial executor. Most of the design choices later in this chapter (actor reentrancy, `Sendable`, region-based isolation, priority escalation) are answers to the same question: *what guarantees do we need to switch executors safely?*

### Three eras, one workspace

GCD (2009) is C-friendly with no structured cancellation and no typed return values. `Operation` (2007, rebuilt on GCD in 2009) adds KVO state and dependency graphs but still no typed returns. Swift Concurrency (2021) replaces both with typed values, structured lifetime, and compile-time isolation. New code should default to Swift Concurrency; the older systems survive because they predate it and Apple frameworks still hand them out.

---

## 1. POSIX Threads (`pthread`)

The lowest-level threading API available on Apple platforms. You almost never need this directly, but understanding it helps reason about everything built on top.

```swift
import Darwin

func posixThreadExample() {
    var thread: pthread_t?

    let result = pthread_create(&thread, nil, { _ in
        print("Running on POSIX thread: \(pthread_self())")
        return nil
    }, nil)

    if result == 0, let thread {
        pthread_join(thread, nil) // Block until thread finishes
    }
}
```

**When to use**: Almost never. Only for C interop or extreme low-level control (custom thread attributes, real-time scheduling).

**Synchronization primitives** (rarely needed directly: Foundation and the standard library wrap them):

```swift
// Mutex
var mutex = pthread_mutex_t()
pthread_mutex_init(&mutex, nil)
pthread_mutex_lock(&mutex)
// critical section
pthread_mutex_unlock(&mutex)
pthread_mutex_destroy(&mutex)
```

`pthread` also offers `pthread_rwlock_*` (reader-writer locks) and `pthread_cond_*` (condition variables). For new code use `OSAllocatedUnfairLock`, `NSCondition`, or an `actor` instead: they wrap the same kernel primitives with safe Swift semantics.

---

## 2. `Thread` (NSThread)

Objective-C era thread abstraction (iOS 2.0 / macOS 10.2, 2002). Slightly higher level than pthreads but still manual.

```swift
// Subclass approach
final class BackgroundWorker: Thread {
    override func main() {
        guard !isCancelled else { return }
        print("Worker running on: \(Thread.current)")
        // Long-running work here
    }
}

let worker = BackgroundWorker()
worker.qualityOfService = .userInitiated
worker.name = "com.app.background-worker"
worker.start()

// Detached thread (fire and forget)
Thread.detachNewThread {
    print("Detached thread: \(Thread.current)")
}

// Perform selector on main thread (Obj-C interop)
// myObject.performSelector(onMainThread: #selector(updateUI), with: nil, waitUntilDone: false)
```

**When to use**: Legacy code, run loops that need a dedicated thread (e.g., streaming network connections). Prefer GCD or async/await for new code. For per-thread context, Swift Concurrency's `@TaskLocal` (§7) is the modern replacement for `Thread.current.threadDictionary`.

---

## 3. Grand Central Dispatch (GCD)

Apple's C-based concurrency library, introduced at WWDC 2009 (iOS 4.0 / macOS 10.6 Snow Leopard). Manages a pool of threads automatically: you submit work to queues, GCD decides which thread runs it.

GCD lives in an awkward middle layer today: too low-level for new code (no structured cancellation, no typed return values), too useful to retire (Apple frameworks pass dispatch queues everywhere). Worth knowing in detail because everything around it (Combine schedulers, `OperationQueue`, the Swift Concurrency interop layer) speaks dispatch.

### Serial vs concurrent queues

```swift
// Serial queue: tasks execute one at a time, in order
let serial = DispatchQueue(label: "com.app.serial")
serial.async { print("Task 1") }
serial.async { print("Task 2") } // Always after Task 1

// Concurrent queue: tasks can run simultaneously
let concurrent = DispatchQueue(label: "com.app.concurrent", attributes: .concurrent)
concurrent.async { print("Task A") }
concurrent.async { print("Task B") } // May run alongside Task A

// Global concurrent queues (shared, system-managed)
DispatchQueue.global(qos: .userInteractive).async { /* Highest priority */ }
DispatchQueue.global(qos: .userInitiated).async { /* User triggered, expects quick result */ }
DispatchQueue.global(qos: .default).async { /* Normal priority */ }
DispatchQueue.global(qos: .utility).async { /* Long tasks, progress bar OK */ }
DispatchQueue.global(qos: .background).async { /* User doesn't notice: backups, indexing */ }

// Main queue: always serial, always main thread
DispatchQueue.main.async { /* UI updates here */ }
```

### Sync vs async dispatch

```swift
let queue = DispatchQueue(label: "com.app.sync-demo")

// async: returns immediately, work runs later
queue.async {
    print("Async work")
}
print("This prints before async work")

// sync: blocks the calling thread until work completes
queue.sync {
    print("Sync work")
}
print("This prints after sync work")
```

{% note warning %}
Never call `sync` on the main queue from the main thread: it deadlocks. Never call `sync` on a serial queue from that same queue.
{% endnote %}

### Dispatch groups

Coordinate multiple async tasks and get notified when all finish.

```swift
let group = DispatchGroup()
let queue = DispatchQueue.global(qos: .userInitiated)

group.enter()
queue.async {
    // Fetch user profile
    fetchProfile { _ in group.leave() }
}

group.enter()
queue.async {
    // Fetch user settings
    fetchSettings { _ in group.leave() }
}

// Option 1: Block until all done (don't use on main thread)
group.wait()

// Option 2: Non-blocking notification
group.notify(queue: .main) {
    print("Both requests finished: update UI")
}

// Option 3: Timeout
let result = group.wait(timeout: .now() + 5)
switch result {
case .success: print("All done")
case .timedOut: print("Timed out")
}
```

### Dispatch barriers

Reader-writer lock pattern on concurrent queues.

```swift
final class ThreadSafeArray<Element> {
    private var storage: [Element] = []
    private let queue = DispatchQueue(label: "com.app.thread-safe-array", attributes: .concurrent)

    func append(_ element: Element) {
        queue.async(flags: .barrier) { // Exclusive access: no readers or writers
            self.storage.append(element)
        }
    }

    var elements: [Element] {
        queue.sync { // Concurrent read: multiple readers OK
            storage
        }
    }

    var count: Int {
        queue.sync { storage.count }
    }
}
```

### Dispatch semaphores

Limit concurrent access to a resource.

```swift
// Limit to 3 concurrent downloads
let semaphore = DispatchSemaphore(value: 3)
let queue = DispatchQueue.global(qos: .utility)

for url in urls {
    queue.async {
        semaphore.wait()    // Decrement; blocks if already 0
        defer { semaphore.signal() } // Increment when done
        downloadFile(from: url)
    }
}

// Binary semaphore (mutex)
let mutex = DispatchSemaphore(value: 1)
mutex.wait()
// critical section
mutex.signal()
```

### Dispatch sources

Event-driven callbacks from the system.

```swift
// Timer source
let timer = DispatchSource.makeTimerSource(queue: .main)
timer.schedule(deadline: .now(), repeating: .seconds(1))
timer.setEventHandler {
    print("Tick: \(Date())")
}
timer.resume() // Don't forget: sources start suspended

// File monitoring
let fd = open("/path/to/file", O_EVTONLY)
let fileMonitor = DispatchSource.makeFileSystemObjectSource(
    fileDescriptor: fd,
    eventMask: [.write, .delete, .rename],
    queue: .main
)
fileMonitor.setEventHandler {
    let flags = fileMonitor.data
    if flags.contains(.write) { print("File modified") }
    if flags.contains(.delete) { print("File deleted") }
}
fileMonitor.setCancelHandler { close(fd) }
fileMonitor.resume()

// Memory pressure
let memorySource = DispatchSource.makeMemoryPressureSource(eventMask: [.warning, .critical], queue: .main)
memorySource.setEventHandler {
    if memorySource.data.contains(.critical) {
        print("Critical memory pressure: purge caches")
    }
}
memorySource.resume()
```

### Work items with cancellation

```swift
// Two-step pattern: declare first so the closure can capture it
var workItem: DispatchWorkItem?

workItem = DispatchWorkItem {
    for i in 0..<1000 {
        guard !(workItem?.isCancelled ?? true) else {
            print("Cancelled at iteration \(i)")
            return
        }
        // Heavy computation
    }
}

DispatchQueue.global().async(execute: workItem!)

// Cancel after 2 seconds
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    workItem?.cancel()
}

// Notification when complete (or cancelled)
workItem?.notify(queue: .main) {
    print("Work item finished, cancelled: \(workItem?.isCancelled ?? false)")
}
```

{% note warning %}
Do NOT use `Thread.current.isCancelled` inside a `DispatchWorkItem`: that checks NSThread cancellation, which is completely unrelated. Always use the work item's own `isCancelled` property.
{% endnote %}

### Dispatch-specific data (per-queue context)

```swift
let key = DispatchSpecificKey<String>()
let queue = DispatchQueue(label: "com.app.identified")
queue.setSpecific(key: key, value: "my-queue")

queue.async {
    let name = DispatchQueue.getSpecific(key: key)
    print("Running on: \(name ?? "unknown")")
}
```

{% note info %}
**Design note: thread explosion.** GCD's worker model creates a new thread whenever a queue has ready work and no available worker. Under I/O-bound load this can exceed the kernel's thread limit and crash the process. Swift Concurrency's cooperative pool (§Mental model) exists primarily to fix this: the same workload becomes thousands of suspended tasks sharing a small pool of threads, not thousands of parked threads.
{% endnote %}

---

## 4. `OperationQueue` and `Operation`

Object-oriented task abstraction (iOS 2.0 / macOS 10.5, 2007). Originally built on threads, reimplemented on top of GCD in iOS 4.0 / macOS 10.6 (2009) when `BlockOperation` was also added. Adds dependency graphs, priorities, KVO-observable state, and built-in cancellation.

**Why this still exists:** GCD added blocks but dropped Operation's structured cancellation, KVO state, and dependency graphs. Swift Concurrency replaces both with typed return values, structured cancellation, and compile-time isolation, and is the right answer for new code. `OperationQueue` survives because Apple frameworks still hand them out, and because explicit dependency graphs (rare) remain easier to read here than in a `TaskGroup`.

### Basic usage

```swift
let queue = OperationQueue()
queue.maxConcurrentOperationCount = 3 // Limit parallelism
queue.qualityOfService = .userInitiated

// Block operations (simple inline work)
let op1 = BlockOperation {
    print("Operation 1: \(Thread.current)")
}

let op2 = BlockOperation {
    print("Operation 2: \(Thread.current)")
}

// Dependencies: op2 runs after op1
op2.addDependency(op1)

queue.addOperations([op1, op2], waitUntilFinished: false)
```

### Custom operations

```swift
final class ImageDownloadOperation: Operation {
    let url: URL
    private(set) var image: UIImage?

    init(url: URL) {
        self.url = url
    }

    override func main() {
        guard !isCancelled else { return }

        guard let data = try? Data(contentsOf: url) else { return }

        guard !isCancelled else { return } // Check again after slow work

        image = UIImage(data: data)
    }
}

let downloadOp = ImageDownloadOperation(url: imageURL)
let filterOp = BlockOperation { [weak downloadOp] in
    guard let image = downloadOp?.image else { return }
    // Apply filter to image
}

filterOp.addDependency(downloadOp) // Filter only runs after download

let queue = OperationQueue()
queue.addOperations([downloadOp, filterOp], waitUntilFinished: false)
```

### Async operations

Wrapping a callback-based API (network, file I/O) inside an `Operation` requires overriding `isAsynchronous`, manually toggling `isExecuting`/`isFinished`, and emitting KVO notifications around each change. The pattern is well-documented but obsolete: Swift Concurrency's `withCheckedContinuation` (§10) does the same job in three lines and is structured. If you're hitting this in legacy code, the migration is mechanical: wrap the callback API with a continuation, kick the work off from a `Task`, and delete the `AsyncOperation` subclass.

### Cancellation propagation

```swift
let queue = OperationQueue()
let ops = (0..<10).map { i in
    BlockOperation {
        Thread.sleep(forTimeInterval: 0.5)
        print("Completed operation \(i)")
    }
}

// Chain dependencies: 0 → 1 → 2 → ... → 9
for i in 1..<ops.count {
    ops[i].addDependency(ops[i - 1])
}

queue.addOperations(ops, waitUntilFinished: false)

// Cancel everything after 2 seconds
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    queue.cancelAllOperations() // Sets isCancelled on all pending ops
}
```

---

## 5. Locks and synchronization primitives

Beyond GCD barriers and semaphores, Foundation and the standard library provide several lock types.

### `NSLock`

```swift
let lock = NSLock()
var balance = 1000

func withdraw(_ amount: Int) -> Bool {
    lock.lock()
    defer { lock.unlock() }
    guard balance >= amount else { return false }
    balance -= amount
    return true
}
```

### `NSRecursiveLock`

Allows the same thread to acquire the lock multiple times without deadlocking.

```swift
let recursiveLock = NSRecursiveLock()

func traverse(node: TreeNode?) {
    recursiveLock.lock()
    defer { recursiveLock.unlock() }
    guard let node else { return }
    process(node)
    traverse(node: node.left)  // Re-enters the lock: OK
    traverse(node: node.right)
}
```

### `os_unfair_lock` (C-level, fastest)

The fastest user-space lock on Apple platforms. Cannot be used across processes. Must not be called from Swift directly in a `struct` (value semantics can copy the lock, causing undefined behavior): use a class wrapper or `OSAllocatedUnfairLock` (iOS 16+).

```swift
import os

// iOS 16+ / macOS 13+: safe Swift wrapper
let lock = OSAllocatedUnfairLock(initialState: 0)

lock.withLock { state in
    state += 1
}

let value = lock.withLock { state in
    state
}
```

### `NSCondition`

A combined mutex + condition variable.

```swift
let condition = NSCondition()
var dataReady = false
var sharedData: [Int] = []

// Producer
Thread.detachNewThread {
    condition.lock()
    sharedData = [1, 2, 3]
    dataReady = true
    condition.signal()  // Wake one waiting thread
    condition.unlock()
}

// Consumer
condition.lock()
while !dataReady {
    condition.wait()  // Releases lock, re-acquires on wake
}
print("Got data: \(sharedData)")
condition.unlock()
```

### Atomics (Swift Atomics package)

For lock-free concurrent programming.

```swift
import Atomics

let counter = ManagedAtomic<Int>(0)

// From multiple threads:
counter.wrappingIncrement(ordering: .relaxed)
let value = counter.load(ordering: .acquiring)

// Compare-and-swap
let (exchanged, original) = counter.compareExchange(
    expected: 5,
    desired: 10,
    ordering: .acquiringAndReleasing
)
```

### Lock comparison

| Lock | Reentrant | Speed | Use case |
|------|----------|-------|----------|
| `os_unfair_lock` / `OSAllocatedUnfairLock` | No | Fastest | Hot paths, counters, short critical sections |
| `NSLock` | No | Fast | General mutex, Obj-C interop |
| `NSRecursiveLock` | Yes | Moderate | Recursive algorithms |
| `NSCondition` | No | Moderate | Producer-consumer patterns |
| `DispatchSemaphore` | No | Fast | Resource limiting, async signaling |
| GCD barrier | N/A | Fast | Reader-writer on concurrent queues |
| Swift Atomics | N/A | Lock-free | Counters, flags, CAS loops |

---

## 6. Combine

Apple's reactive framework, introduced at WWDC 2019 (iOS 13 / macOS 10.15, Swift 5.1). Declarative chains of publishers and subscribers that handle async events over time.

{% note info %}
For new code, prefer `AsyncSequence` + the [Swift Async Algorithms](https://github.com/apple/swift-async-algorithms) package (§9). Combine remains the right tool for SwiftUI bindings (`@Published`, `ObservableObject`) and existing pipelines, but most use cases that aren't UIKit-bound now have native async equivalents.
{% endnote %}

For a closer side-by-side of Combine, RxSwift, and synchronous Swift collection chains, see {% post_link Combine-vs-RxSwift-vs-Swift-Collections "Combine vs RxSwift vs Swift collection chains" %}.

### Basics

```swift
import Combine

var cancellables = Set<AnyCancellable>()

// Simple publisher pipeline
[1, 2, 3, 4, 5].publisher
    .filter { $0 % 2 == 0 }
    .map { $0 * 10 }
    .sink { print("Value: \($0)") } // Value: 20, Value: 40
    .store(in: &cancellables)
```

### Concurrency with Combine

```swift
// Background processing with main thread delivery
URLSession.shared.dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: [User].self, decoder: JSONDecoder())
    .receive(on: DispatchQueue.main)     // Switch to main for UI
    .sink(
        receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Error: \(error)")
            }
        },
        receiveValue: { users in
            // Update UI with users: guaranteed main thread
        }
    )
    .store(in: &cancellables)

// Subscribe on a background queue
publisher
    .subscribe(on: DispatchQueue.global(qos: .background)) // Work happens here
    .receive(on: DispatchQueue.main) // Results delivered here
    .sink { value in /* UI update */ }
    .store(in: &cancellables)
```

### Parallel with `MergeMany`

```swift
let urls: [URL] = [url1, url2, url3]

let publishers = urls.map { url in
    URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .catch { _ in Empty<Data, Never>() }
}

Publishers.MergeMany(publishers)
    .collect()                    // Wait for all to finish
    .receive(on: DispatchQueue.main)
    .sink { allData in
        print("Got \(allData.count) responses")
    }
    .store(in: &cancellables)
```

### Subjects (imperative push)

```swift
// PassthroughSubject: no initial value, only emits to current subscribers
let eventBus = PassthroughSubject<String, Never>()
eventBus.send("Hello") // Lost if no subscriber

eventBus
    .sink { print("Event: \($0)") }
    .store(in: &cancellables)
eventBus.send("World") // Received

// CurrentValueSubject: has a current value, replays to new subscribers
let counter = CurrentValueSubject<Int, Never>(0)
counter.value // 0
counter.send(1)
counter.value // 1

counter
    .sink { print("Count: \($0)") } // Immediately prints "Count: 1"
    .store(in: &cancellables)
```

### Debounce, throttle, and timing

```swift
let searchText = PassthroughSubject<String, Never>()

searchText
    .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main) // Wait for pause
    .removeDuplicates()           // Skip if same as last
    .filter { !$0.isEmpty }       // Skip empty strings
    .flatMap { query in           // Cancel previous request
        searchAPI(query: query)
            .catch { _ in Empty() }
    }
    .receive(on: DispatchQueue.main)
    .sink { results in /* Update UI */ }
    .store(in: &cancellables)
```

### Future (single-value async)

```swift
func fetchUser(id: Int) -> Future<User, Error> {
    Future { promise in
        URLSession.shared.dataTask(with: userURL(id)) { data, _, error in
            if let error {
                promise(.failure(error))
            } else if let data, let user = try? JSONDecoder().decode(User.self, from: data) {
                promise(.success(user))
            }
        }.resume()
    }
}

fetchUser(id: 42)
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { _ in },
        receiveValue: { user in print(user.name) }
    )
    .store(in: &cancellables)
```

---

## 7. `async`/`await` (Swift Concurrency)

Introduced in Swift 5.5 at WWDC 2021 (iOS 15 native, back-deployed to iOS 13+ with Xcode 13.2). The modern, recommended approach for all new code.

**The shape: lifetime ⊆ lexical scope.** `async let` and `TaskGroup` guarantee child tasks complete (or are cancelled) before the enclosing scope exits. Errors propagate **up** the task tree, cancellation propagates **down**, and the compiler refuses code that would leak a child past its parent. `Task { }` is the deliberate exception: it returns a handle that outlives the surrounding scope, which is also why unstructured tasks are the most common source of "why is this still running?" bugs.

### Basic async functions

```swift
func fetchUser(id: Int) async throws -> User {
    let (data, response) = try await URLSession.shared.data(from: userURL(id))
    guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
        throw APIError.invalidResponse
    }
    return try JSONDecoder().decode(User.self, from: data)
}

// Calling
Task {
    do {
        let user = try await fetchUser(id: 42)
        print(user.name)
    } catch {
        print("Failed: \(error)")
    }
}
```

### Sequential vs parallel execution

```swift
// Sequential: each awaits before the next starts
func loadProfile() async throws -> Profile {
    let user = try await fetchUser(id: 42)       // Wait...
    let avatar = try await fetchImage(user.avatarURL)  // Then wait...
    let posts = try await fetchPosts(userId: 42)       // Then wait...
    return Profile(user: user, avatar: avatar, posts: posts)
}

// Parallel with async let: all three start concurrently
func loadProfileFast() async throws -> Profile {
    async let user = fetchUser(id: 42)
    async let avatar = fetchImage(avatarURL)
    async let posts = fetchPosts(userId: 42)
    return try await Profile(user: user, avatar: avatar, posts: posts)
}
```

{% note info %}
`async let` bindings start executing immediately when declared. The `await` keyword is where you wait for the result. If you never `await` an `async let`, the task is implicitly cancelled when the scope exits.
{% endnote %}

### Task groups

For dynamic numbers of concurrent tasks.

```swift
func fetchAllUsers(ids: [Int]) async throws -> [User] {
    try await withThrowingTaskGroup(of: User.self) { group in
        for id in ids {
            group.addTask {
                try await fetchUser(id: id)
            }
        }

        var users: [User] = []
        for try await user in group {
            users.append(user)
        }
        return users
    }
}

// With limited concurrency (manual sliding-window pattern)
func fetchAllUsersLimited(ids: [Int]) async throws -> [User] {
    try await withThrowingTaskGroup(of: User.self) { group in
        var iterator = ids.makeIterator()

        // Start initial batch of 5
        for _ in 0..<5 {
            guard let id = iterator.next() else { break }
            group.addTask { try await fetchUser(id: id) }
        }

        var users: [User] = []
        for try await user in group {
            users.append(user)
            // As each completes, start the next
            if let id = iterator.next() {
                group.addTask { try await fetchUser(id: id) }
            }
        }
        return users
    }
}
```

### Discarding task groups (Swift 5.9+)

When you don't need results from individual tasks: just fire-and-forget with structured cancellation.

```swift
try await withThrowingDiscardingTaskGroup { group in
    for connection in connections {
        group.addTask {
            try await handleConnection(connection) // Result is discarded
        }
    }
    // All tasks automatically cancelled if any throws
}
```

### Unstructured tasks

```swift
// Inherits actor context and priority
let task = Task {
    let user = try await fetchUser(id: 42)
    await updateUI(with: user) // Runs on the caller's actor
}

// Does NOT inherit context: runs on global executor
let detached = Task.detached(priority: .background) {
    let data = try await processLargeFile()
    return data
}

// Cancellation
task.cancel()
let result = try await task.value // Still need to await (and handle errors)

// Check cancellation inside a task
func processItems(_ items: [Item]) async throws {
    for item in items {
        try Task.checkCancellation()  // Throws CancellationError
        // Or:
        guard !Task.isCancelled else { return }
        await process(item)
    }
}
```

{% note info %}
**Design intent: cancellation is cooperative.** `task.cancel()` only sets a flag. The runtime never kills a task; it relies on the task itself to call `Task.checkCancellation()` or check `Task.isCancelled` at safe points. This is the same model as `Operation.cancel()` and the opposite of `pthread_cancel` (preemptive at cancellation points). The upside: no broken invariants from a task killed mid-update. The downside: a long synchronous loop with no cancellation check ignores `cancel()` until it ends. Every long loop needs a check.
{% endnote %}

### Task priority and priority escalation

```swift
Task(priority: .high) {
    // High-priority work
}

Task(priority: .low) {
    // Low-priority work: may be escalated if a high-priority task awaits it
}

// Priority escalation happens automatically:
let lowTask = Task(priority: .low) { await heavyComputation() }
Task(priority: .high) {
    let result = await lowTask.value // lowTask gets escalated to .high
}
```

{% note info %}
**Design: escalation, not inversion.** Classic priority inversion (a high-priority task blocked behind a low-priority lock holder) is solved at the OS level by **priority donation**: the lock holder runs at the waiter's priority for as long as it holds the lock. Swift Concurrency generalises this through `await`: when a high-priority task awaits a low-priority task, or an actor with pending low-priority callers, Swift escalates the awaited chain to the higher priority for the duration. You won't usually see "priority inversion" in profilers because the runtime resolves it before it surfaces.
{% endnote %}

### Task-local values

Thread-local storage equivalent for structured concurrency.

```swift
enum RequestContext {
    @TaskLocal static var requestID: String = "none"
    @TaskLocal static var userID: Int?
}

func handleRequest() async {
    await RequestContext.$requestID.withValue("req-\(UUID())") {
        await RequestContext.$userID.withValue(42) {
            await processRequest()
        }
    }
}

func processRequest() async {
    // Available anywhere in the task tree
    print("Request: \(RequestContext.requestID)")
    print("User: \(RequestContext.userID ?? -1)")
}
```

### Task sleep and yielding

```swift
// Sleep (respects cancellation: throws if cancelled)
try await Task.sleep(for: .seconds(1))          // Swift 5.9+ Duration-based
try await Task.sleep(nanoseconds: 1_000_000_000) // Older API

// Yield (give other tasks a chance to run)
await Task.yield()

// Polling with sleep
func waitForCondition() async throws {
    while !isReady {
        try await Task.sleep(for: .milliseconds(100))
    }
}
```

---

## 8. Actors

Reference types that protect their mutable state from concurrent access. The compiler enforces isolation: you must `await` when crossing an actor boundary.

### Basic actor

```swift
actor BankAccount {
    let id: String
    private(set) var balance: Decimal

    init(id: String, balance: Decimal) {
        self.id = id
        self.balance = balance
    }

    func deposit(_ amount: Decimal) {
        balance += amount
    }

    func withdraw(_ amount: Decimal) throws {
        guard balance >= amount else {
            throw BankError.insufficientFunds
        }
        balance -= amount
    }

    // nonisolated: can be called without await (no mutable state access)
    nonisolated var description: String {
        "Account \(id)" // Only accesses let property
    }
}

// Usage: must await
let account = BankAccount(id: "001", balance: 1000)
await account.deposit(500)
let balance = await account.balance
print(account.description) // No await needed: nonisolated
```

### Actor reentrancy

Actors are **reentrant**: when an actor suspends (at an `await`), other callers can execute on it.

```swift
actor ImageCache {
    private var cache: [URL: UIImage] = [:]

    func image(for url: URL) async throws -> UIImage {
        // Check cache BEFORE suspension
        if let cached = cache[url] {
            return cached
        }

        // Suspension point: another caller could modify cache here
        let image = try await downloadImage(from: url)

        // Check AGAIN after suspension: another call may have cached it
        if let cached = cache[url] {
            return cached
        }

        cache[url] = image
        return image
    }
}
```

{% note info %}
**Design intent: reentrancy avoids deadlock.** A non-reentrant actor would deadlock in any A→B→A call chain: a classic mutex pattern that's nearly impossible to avoid in practice. Swift's actors are reentrant by deliberate choice: the runtime can interleave other callers on the actor across each `await`. The trade is that **invariants don't survive a suspension**: any state you read before `await` may have been mutated by another caller by the time you resume. Always re-check conditions after suspension points (the `cache[url]` re-check above is the canonical pattern).
{% endnote %}

### `@MainActor`

A global actor that guarantees execution on the main thread. Essential for UI code.

```swift
@MainActor
final class ProfileViewController: UIViewController {
    private var user: User?

    func loadUser() async {
        // This runs on the main thread (we're @MainActor)
        let user = try? await fetchUser(id: 42) // Suspends, frees main thread
        self.user = user // Back on main thread
        tableView.reloadData() // Safe: main thread
    }
}

// Annotate individual functions
@MainActor
func updateUI(with data: Data) {
    label.text = String(data: data, encoding: .utf8)
}

// Annotate closures
Task { @MainActor in
    progressView.isHidden = true
}
```

### Custom global actors

```swift
@globalActor
actor DatabaseActor {
    static let shared = DatabaseActor()
}

@DatabaseActor
final class UserRepository {
    private var cache: [Int: User] = [:]

    func getUser(id: Int) -> User? {
        cache[id]
    }

    func save(_ user: User) {
        cache[user.id] = user
    }
}

// All methods on UserRepository are isolated to DatabaseActor
// Must await from outside:
let repo = UserRepository()
let user = await repo.getUser(id: 42)
```

### Actor-isolated properties and `Sendable`

```swift
// Sendable: safe to pass across actor boundaries
struct UserDTO: Sendable {
    let id: Int
    let name: String
}

// Not Sendable: has mutable reference state
class MutableState {
    var count = 0 // Compiler warns if sent across actors
}

// Manually mark as @unchecked Sendable (you're responsible for thread safety)
final class ThreadSafeCounter: @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock(initialState: 0)

    func increment() {
        lock.withLock { $0 += 1 }
    }
}
```

{% note info %}
**Design: `Sendable` is a typing discipline, not a runtime check.** It's a marker protocol: the compiler reasons about it at compile time and emits zero runtime overhead. A class is implicitly `Sendable` only if it's `final` *and* every stored property is immutable and Sendable, because that's the only structural form Swift can verify safe without help. `@unchecked Sendable` is the explicit "I've taken a lock, trust me" escape hatch. The discipline was deliberately strict at first, then loosened in Swift 6 by region-based isolation (see §11) when the strictness turned out to make a lot of plainly-safe code uncompilable.
{% endnote %}

---

## 9. `AsyncSequence` and `AsyncStream`

Async equivalents of `Sequence`. Values arrive over time, and iteration suspends between elements.

### Built-in AsyncSequences

```swift
// URL bytes
let (bytes, _) = try await URLSession.shared.bytes(from: url)
for try await byte in bytes {
    process(byte)
}

// File lines
let fileURL = URL(filePath: "/path/to/file.txt")
for try await line in fileURL.lines {
    print(line)
}

// Notifications
let notifications = NotificationCenter.default.notifications(named: .NSManagedObjectContextDidSave)
for await notification in notifications {
    handleSyncChange(notification)
}
```

### `AsyncStream` (custom producer)

```swift
// Continuation-based (push model)
let heartbeats = AsyncStream<Date> { continuation in
    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
        continuation.yield(Date())
    }
    continuation.onTermination = { _ in
        timer.invalidate()
    }
}

for await beat in heartbeats {
    print("Heartbeat: \(beat)")
}

// With buffering policy
let buffered = AsyncStream<Int>(bufferingPolicy: .bufferingNewest(5)) { continuation in
    for i in 0..<100 {
        continuation.yield(i) // Only keeps newest 5 if consumer is slow
    }
    continuation.finish()
}

// AsyncThrowingStream: can produce errors
let dataStream = AsyncThrowingStream<Data, Error> { continuation in
    startMonitoring { result in
        switch result {
        case .success(let data):
            continuation.yield(data)
        case .failure(let error):
            continuation.finish(throwing: error)
        }
    }
}
```

### `AsyncStream.makeStream` (Swift 5.9+)

Returns a tuple of stream + continuation for when the producer and consumer are set up in different scopes.

```swift
let (stream, continuation) = AsyncStream.makeStream(of: String.self)

// Producer (e.g., delegate callback)
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    for location in locations {
        continuation.yield(location.description)
    }
}

// Consumer
Task {
    for await locationString in stream {
        print("Location: \(locationString)")
    }
}
```

### Async algorithms (Swift Async Algorithms package)

```swift
import AsyncAlgorithms

// Merge multiple sequences
let merged = merge(notificationsStream, timerStream)

// Debounce
let debounced = searchTextStream.debounce(for: .milliseconds(300))

// Throttle
let throttled = sensorStream.throttle(for: .seconds(1))

// Combine latest
let combined = combineLatest(locationStream, headingStream)
for await (location, heading) in combined {
    updateMap(location: location, heading: heading)
}

// Zip (pairs elements 1:1)
let zipped = zip(requestStream, responseStream)

// Chain (sequential concatenation)
let chained = chain(cachedResults.async, networkResults)

// Chunked
let batched = dataPoints.chunks(ofCount: 10)
for await batch in batched {
    await uploadBatch(Array(batch))
}
```

---

## 10. Continuations (bridging callback → async)

Convert callback-based APIs to async/await.

### `withCheckedContinuation`

```swift
func fetchLocation() async -> CLLocation {
    await withCheckedContinuation { continuation in
        locationManager.requestLocation { location in
            continuation.resume(returning: location)
        }
    }
}
```

### `withCheckedThrowingContinuation`

```swift
func fetchData(from url: URL) async throws -> Data {
    try await withCheckedThrowingContinuation { continuation in
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                continuation.resume(throwing: error)
            } else if let data {
                continuation.resume(returning: data)
            } else {
                continuation.resume(throwing: URLError(.unknown))
            }
        }.resume()
    }
}
```

{% note warning %}
A continuation must be resumed **exactly once**. Resuming zero times leaks the task. Resuming more than once is undefined behavior. `withCheckedContinuation` traps on double-resume in debug builds; `withUnsafeContinuation` does not check (faster but dangerous).
{% endnote %}

### Delegate pattern bridging

```swift
final class LocationBridge: NSObject, CLLocationManagerDelegate {
    private var continuation: CheckedContinuation<CLLocation, Error>?
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
    }

    func currentLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        continuation?.resume(returning: locations[0])
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
```

---

## 11. Swift 6 strict concurrency

Swift 6.0 (Xcode 16, Sep 2024) makes data-race safety a compile-time guarantee. Code that was valid in Swift 5 may produce errors in Swift 6 strict mode.

### Enabling strict concurrency

```swift
// Package.swift
.target(
    name: "MyTarget",
    swiftSettings: [
        .swiftLanguageMode(.v6),
    ]
)

// Or per-target in Xcode:
// Build Settings → Swift Language Version → 6
```

### `Sendable` enforcement

In Swift 6, the compiler checks that values crossing isolation boundaries are `Sendable`.

```swift
// Automatically Sendable: structs/enums with all Sendable stored properties
struct Point: Sendable {
    let x: Double
    let y: Double
}

// Classes must be final + immutable to be implicitly Sendable
final class Config: Sendable {
    let apiKey: String
    let timeout: Int
    init(apiKey: String, timeout: Int) {
        self.apiKey = apiKey
        self.timeout = timeout
    }
}

// @Sendable closures: no mutable captures
let task = Task { @Sendable in
    // Cannot capture mutable local variables
}

// @Sendable function types
func transform<T: Sendable>(_ items: [T], using block: @Sendable (T) -> T) -> [T] {
    items.map(block)
}
```

### Region-based isolation (Swift 6.0)

**Why it exists:** before SE-0414, you couldn't pass a freshly-built non-Sendable value across an actor boundary, even when no other code could reach it. A `[User]` you just constructed and never aliased was *plainly safe* to transfer, but the compiler had no way to know: `Sendable` is a per-type discipline, but aliasing is a per-value question.

Region-based isolation tracks **isolation regions**: a value with no aliases is in its own region and can be transferred. `sending` declares "this parameter (or return) is in a disconnected region: the callee/caller may take ownership." The compiler tracks which "region" a value belongs to, and values in disconnected regions can be sent across isolation boundaries even if not `Sendable`.

```swift
// This works in Swift 6 because `array` is in a disconnected region
func makeArray() -> sending [String] {
    var array = ["hello"]
    array.append("world")
    return array // Transferred to the caller's region
}

actor Processor {
    func process() async {
        let data = makeArray() // Receives ownership of the array
        print(data)
    }
}
```

### `sending` parameter and return types (Swift 6.0)

```swift
// The caller must give up ownership of the value
actor ImageProcessor {
    func process(_ image: sending UIImage) {
        // This actor now owns the image
    }
}

// The callee guarantees the return value is in a disconnected region
func createBuffer() -> sending [UInt8] {
    [UInt8](repeating: 0, count: 1024)
}
```

### `nonisolated(unsafe)` (escape hatch)

When you know a value is safe but can't prove it to the compiler.

```swift
// Global mutable state that's actually only accessed from one context
nonisolated(unsafe) var legacyCache: [String: Any] = [:]

// Module-level configurable strings
nonisolated(unsafe) var appName = "My App"
```

{% note warning %}
`nonisolated(unsafe)` disables all compiler checks. Use only when you've manually verified safety and can't restructure the code to satisfy the compiler.
{% endnote %}

### `@preconcurrency` (incremental adoption)

Suppress warnings from pre-concurrency modules you don't control.

```swift
@preconcurrency import SomeOldFramework

// SomeOldFramework's types are treated as implicitly Sendable
// Warnings are suppressed at the import boundary
```

### Swift 6.1 (Xcode 16.3, Mar 2025)

Smaller cycle, two notable additions:

- **Isolated synchronous deinits** (`isolated deinit`): a deinit can run on a specific actor, fixing a long-standing "deinit can't safely touch isolated state" gap.
- **`isolated(any)` parameters**: a parameter that says "I run on whichever actor I was given," without making the surrounding function isolated. Useful for higher-order async APIs that need to call a callback on the user's actor.

### Swift 6.2: approachable concurrency (Xcode 26, Sept 2025)

Swift 6.2 reframes the defaults around a different mental model: **start on the main thread, opt into background work**. The 6.0 model was "every async function may hop to the global pool, every closure must prove it's `Sendable`." That produced a mountain of `Sendable` warnings on code that ran nowhere except the main thread. Three pieces, one philosophy.

**`nonisolated(nonsending)`: async stays on the caller's executor.** A `nonisolated async` function used to implicitly hop to the global executor on entry. Now you can ask it to stay where it was called from:

```swift
@MainActor final class ProfileViewModel {
    func loadHeader() async {
        // No hop, no Sendable check at the boundary, no main-thread reschedule on return
        let title = await formatTitle(for: user)
        self.title = title
    }
}

nonisolated(nonsending) func formatTitle(for user: User) async -> String {
    "\(user.name)'s profile"
}
```

**`@concurrent`: opt in to the old behaviour.** When you actually want background execution (heavy CPU work, JSON decoding, image processing), mark the function explicitly:

```swift
@concurrent func decode(_ data: Data) async throws -> [User] {
    try JSONDecoder().decode([User].self, from: data) // Runs on the global pool
}
```

`@concurrent` reads as "I will hop to the global pool"; `nonisolated(nonsending)` reads as "I stay where you called me." The 6.0 default was the former implicitly; the 6.2 default (with the upcoming-feature flag below) is the latter.

**`NonisolatedNonsendingByDefault` upcoming-feature flag**: flips the default. Any unannotated `nonisolated async` declaration behaves as `nonisolated(nonsending)`; functions that need background execution must say `@concurrent` explicitly.

```swift
.target(
    name: "MyTarget",
    swiftSettings: [
        .swiftLanguageMode(.v6),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    ]
)
```

**Default actor isolation (SE-0466)**: set a default isolation for an entire module:

```swift
// Every top-level declaration is implicitly @MainActor
class ProfileViewModel {         // Implicitly @MainActor
    var name = ""                // Isolated to MainActor
    func load() async { }        // Isolated to MainActor
}

// Opt out explicitly
nonisolated func pureComputation(_ x: Int) -> Int {
    x * 2
}
```

**Approachable Concurrency**: a package-level setting that bundles 6.2's new defaults: MainActor isolation by default, async-stays-on-caller, fewer Sendable checks at hot boundaries. The recommended starting point for new app and UI modules:

```swift
.target(
    name: "MyUIModule",
    swiftSettings: [
        .swiftLanguageMode(.v6),
        .defaultIsolation(MainActor.self),                            // SE-0466
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),     // SE-0461
    ]
)
```

With both on, a UI module looks closer to single-threaded code with explicit `@concurrent` doors into the background pool: the inverse of the 6.0 default, and a much shorter path through Sendable warnings for app code.

### Concurrency migration checklist

| Swift 5 pattern | Swift 6 equivalent |
|-----------------|--------------------|
| `DispatchQueue.main.async { }` | `Task { @MainActor in }` or `MainActor.run { }` |
| `var` in closure capture | `@Sendable` closure + `Sendable` captures |
| `class` with `var` properties across threads | `actor` or `@MainActor class` |
| Global `var` | `nonisolated(unsafe)` or actor-isolated |
| `NotificationCenter` + `@objc` handler | `NotificationCenter.default.notifications(named:)` async sequence |
| Delegate pattern | `AsyncStream` or continuation |
| `DispatchGroup` | `async let` or `TaskGroup` |
| GCD barrier queue | `actor` |
| `@objc` callback closure | `withCheckedContinuation` |
| `Thread.sleep()` | `try await Task.sleep(for:)` |

Under Swift 6.2 with `.defaultIsolation(MainActor.self)`, most `@MainActor` annotations in the right column become implicit: UI code is on `MainActor` by default and only background work needs explicit annotation (`@concurrent`).

---

## 12. Concurrency debugging and profiling

### Thread Sanitizer (TSan)

Detects data races at runtime.

```
Product → Scheme → Edit Scheme → Diagnostics → Thread Sanitizer ✓
```

Or via `xcodebuild`:

```bash
xcodebuild test \
    -enableThreadSanitizer YES \
    -scheme MyApp \
    -destination 'platform=iOS Simulator,name=iPhone 17'
```

### Instruments concurrency tools

| Instrument | Purpose |
|------------|---------|
| **Swift Concurrency** | Visualize task trees, actor contention, task creation/completion |
| **Thread State Trace** | Thread blocking, context switches, runnable vs blocked |
| **System Trace** | Low-level thread scheduling, priority inversions |
| **Time Profiler** | CPU time per thread, identify hot code on wrong threads |
| **os_signpost** | Custom intervals for measuring concurrency regions |

### Runtime concurrency checks

```swift
// Assert main thread (UIKit code)
dispatchPrecondition(condition: .onQueue(.main))

// Assert NOT on main thread
dispatchPrecondition(condition: .notOnQueue(.main))

// In async context
assert(Thread.isMainThread, "Must be on main thread")

// Swift 6 strict concurrency checking catches this at compile time
```

### Strict concurrency checking (pre-Swift 6)

Enable warnings before fully migrating:

```swift
// Package.swift
.target(
    name: "MyTarget",
    swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
    ]
)
```

---

## When to use what

| Scenario | Recommended approach |
|----------|---------------------|
| New async code (iOS 15+) | `async`/`await` |
| Protecting mutable state | `actor` (or `@MainActor` for UI) |
| Parallel independent tasks (known count) | `async let` |
| Parallel tasks (dynamic count) | `TaskGroup` |
| UI updates from background | `@MainActor` |
| Bridging callbacks to async | `withCheckedContinuation` |
| Event streams over time | `AsyncStream` / `AsyncSequence` |
| Reactive chains with operators | Combine (or AsyncAlgorithms) |
| Legacy codebase (pre-iOS 15) | GCD |
| Task dependencies / complex graphs | `OperationQueue` |
| Lock-free counters | `OSAllocatedUnfairLock` or Swift Atomics |
| C interop threading | `pthread` |

---

## Further reading

- [Swift concurrency manifesto](https://gist.github.com/lattner/31ed37682ef1576b16bca1432ea9f782): Chris Lattner's original vision
- [SE-0296 async/await](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0296-async-await.md): the proposal that started it all
- [SE-0304 Structured concurrency](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0304-structured-concurrency.md): task groups and child tasks
- [SE-0306 Actors](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0306-actors.md): actor model for Swift
- [SE-0337 Sendable](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0337-support-incremental-migration-to-concurrency-checking.md): incremental Sendable adoption
- [SE-0414 Region-based isolation](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0414-region-based-isolation.md): the typing rules behind `sending`
- [SE-0430 sending parameter](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0430-transferring-parameters-and-results.md): region-based isolation
- [SE-0461 Run nonisolated async functions on the caller's actor](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md): `nonisolated(nonsending)` and `@concurrent`
- [SE-0466 Default isolation](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0466-control-default-actor-isolation.md): module-level default actor isolation
- [Swift Async Algorithms](https://github.com/apple/swift-async-algorithms): merge, debounce, throttle, combineLatest
- [Swift Atomics](https://github.com/apple/swift-atomics): lock-free atomic operations
- [WWDC21: Swift concurrency: Behind the scenes](https://developer.apple.com/videos/play/wwdc2021/10254/): cooperative pool, hop counts, runtime contract
- [WWDC22: Eliminate data races using Swift Concurrency](https://developer.apple.com/videos/play/wwdc2022/110351/)
- [WWDC23: Beyond the basics of structured concurrency](https://developer.apple.com/videos/play/wwdc2023/10170/)
- [Donny Wals: Exploring concurrency changes in Swift 6.2](https://www.donnywals.com/exploring-concurrency-changes-in-swift-6-2/)
- [Donny Wals: What is @concurrent in Swift 6.2?](https://www.donnywals.com/what-is-concurrent-in-swift-6-2/)
- [How is the Cooperative Thread Pool integrated in Swift?: Swift Forums](https://forums.swift.org/t/how-is-the-cooperative-thread-pool-integrated-in-swift/67466)
