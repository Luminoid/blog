---
title: "WWDC 2008 revisited: the four sessions still shaping iOS"
date: 2026-05-11 12:00:00
categories:
- iOS
- WWDC
tags:
- UIKit
- Cocoa
- Objective-C
- GCD
- Swift
- history
---

WWDC 2008 was the year third-party iPhone development became possible. The SDK opened in March, the App Store opened in July, and Apple shipped four design-principle sessions that year that still describe the shape of every iOS app I write in 2026: 312 (the SDK runtime), 348 (the Cocoa philosophy), 940 (Obj-C 2.0 properties and protocols), and 382 (the GCD preview). Three of the four bets paid off in the form they were originally pitched. One had to be rewritten twice before it stuck.

<!-- more -->

## The four sessions

| Session | Subject | What it shipped | What survives in 2026 |
|---|---|---|---|
| **312** iPhone Application Development Fundamentals | The SDK runtime | `UIApplication` + `UIWindow` + `UIViewController` + `AppDelegate` | The same four classes, in the same arrangement, in every iOS app |
| **348** Cocoa Fundamentals | The design philosophy | MVC, delegation, target-action, KVO, `NSNotificationCenter`, retain/release | All of the above (KVO via Combine, retain/release via ARC) |
| **940** Mastering Advanced Objective-C Features | The language layer | `@property`, fast enumeration, `@protocol`, GC (Mac-only), 64-bit runtime | Properties, `for x in collection`, protocols (the GC pitch died) |
| **382** Simplifying Multicore with GCD | The concurrency philosophy | "Queues, not threads" (preview only) | The same principle, restated through blocks (2009), `Operation` (2011), Combine (2019), `async`/`await` (2021), Actors (2021) |

What strikes me reading these back to back is the **substrate vs syntax** split. The substrate (the four classes from 312, the broadcast contract from 348, the cooperative-pool bet from 382) is unchanged. The syntax around all three has been rewritten between two and four times. The mental model in your head when you write `Task { @MainActor in ... }` in 2026 is the same one in the head of the engineer who wrote `dispatch_async(dispatch_get_main_queue(), ^{ ... })` in 2010, which is the same one Apple was previewing on stage in 2008. The compiler check is new. The bet is not.

## The 312 reveal: a runtime that owns the loop

Before 312, "an app" on a desktop OS was a `main()` function that drove its own runloop. You initialized your toolkit, opened a window, pumped events. The 312 reveal turned that inside out: the iPhone runtime owns the loop, your code lives inside `UIApplicationDelegate` callbacks, and the system tells you when to wake up, when to save state, when to release caches. You are a guest in the process.

```swift
// 2026 AppDelegate, structurally identical to a 2008 one
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // configure Core Data, register fonts, register for remote notifications
        return true
    }
}
```

The shape (singleton application, delegate protocol, lifecycle callbacks) is the 2008 reveal verbatim. Scenes (2019) added a layer above it for per-window state, but `application(_:didFinishLaunchingWithOptions:)` is still the canonical entry point, and it still does the same thing it did when the iPhone 3G shipped with 128 MB of RAM and one core.

The bet that paid: a system-managed lifecycle catches edge cases (incoming call, low-memory warning, push wake, scene disconnect) that hand-rolled main loops miss. Eighteen years of new edge cases (background fetch in iOS 4, background modes in iOS 7, scene lifecycle in iOS 13, BGTaskScheduler in iOS 13, Live Activities in iOS 16) all hung off the same delegate model. Apple never had to ask app developers to rewrite their entry point.

## The 348 reveal: how the framework wants to be talked to

If 312 is "here is the runtime", 348 is "here is how to write code that fits the runtime". Five patterns, repeated through every framework Apple ships:

- **MVC**: Controller mediates; View and Model don't know about each other.
- **Delegation**: an object holds a `weak` reference to a delegate and calls protocol methods on it for events. One class participates in many concerns without multiple inheritance.
- **Target-action**: `UIControl` reduces button taps and slider drags to a `(target, action)` selector pair. Predates blocks; cheaper than blocks.
- **KVO**: observe property changes by string key path. Modern Combine wraps this with type checking via `publisher(for: \.keyPath)`.
- **NSNotificationCenter**: broadcast when there is no clear delegate. One sender, many observers, no return value.

Pick any modern detail screen in a real iOS app and you will find all five at work. The screen is a `UIViewController` (Controller) hosting a `UICollectionView` (View) backed by a repository object (Model). The collection view talks back through `UICollectionViewDataSource` and `UICollectionViewDelegate` (delegation). The Edit button is wired with `target: self, action: #selector(editTapped)` (target-action). Cross-device CloudKit sync arrives via `.NSPersistentStoreRemoteChange` (broadcast). The currently selected item's ID surfaces to widgets via a Combine publisher on a `\.selectedItemID` key path (KVO with types).

That code would have read identically in 2010, with `[control addTarget:self action:@selector(editTapped:) forControlEvents:UIControlEventTouchUpInside]` instead of the `#selector` form. The only thing that changed is the spelling.

The one place 348 needed a refinement is the broadcast pattern. `NSNotificationCenter` itself is fine. What 348 did not anticipate is that CloudKit catchup republishes `.NSPersistentStoreRemoteChange` repeatedly during boot, so any consumer that does whole-store work from that notification needs to debounce or it stampedes itself. The pattern is right; the volume crossed a threshold the original designers did not see.

## The 940 reveal: the language Swift inherited

940 was the *advanced* Obj-C 2.0 session. The language features themselves (`@property`, fast enumeration, `@protocol`, the modern runtime) had already shipped a year earlier with Leopard / WWDC 2007; 940 was the deep dive on mastering them, with garbage collection as the headline topic. Reading it now is mostly a list of features that turned into Swift one-to-one:

```objc
// Obj-C 2.0, 2008
@property (nonatomic, strong) NSString *name;

for (id obj in array) {
    NSLog(@"%@", obj);
}

@protocol UITableViewDelegate <NSObject>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end
```

```swift
// Swift, 2026
var name: String

for obj in array {
    print(obj)
}

protocol UITableViewDelegate: AnyObject {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
}
```

Same shape, same semantics, different syntax. The compiler-synthesized backing storage from `@synthesize` (which became implicit in Xcode 4) is exactly the compiler-synthesized backing storage Swift gives you for `var name: String`. The fast-enumeration protocol (`NSFastEnumeration`) is structurally `Sequence`/`IteratorProtocol`. Existential types (`id<MyProtocol>` in Obj-C, `any MyProtocol` in modern Swift) are the same idea; Swift made the existential explicit because the implicit version turned out to hide a performance cliff (boxing) that became hard to reason about at scale.

The one bet from 940 that did not pay was **garbage collection**. Apple shipped opt-in tracing GC for Mac apps in 10.5, pitched it as the modern memory-management story, deprecated it five years later in 10.8 Mountain Lion (2012), and removed it from the runtime entirely in macOS Sierra (2016). iOS never had GC at all. ARC (2011) is the actual successor, and ARC took the lessons that GC taught: you cannot interop a tracing collector cleanly with C-level frameworks (Core Foundation, libdispatch, `malloc`-allocated buffers passed across the boundary), the finalizer ordering problem is real, and "the system handles memory" is not a promise an OS framework can make when half its surface area is C. ARC said "the system handles the *boilerplate*; you handle the *graph*", and that is the rule we still live with: structure your retain graph, mark cycles `weak`, cancel your tasks on `deinit`. The 940 GC pitch is a historical curiosity; the principle that survived is the property-level memory annotation (`strong`/`weak`/`unowned`), which 940 introduced and ARC formalized.

## The 382 reveal: queues, not threads

382 is the talk that aged best. It was previewed in 2008, fully shipped in 2009 (406), ported to iPhone in 2010 (206), and the design principle in the title is the same one driving every concurrency feature Apple has shipped since.

The framing: every modern Mac has 2+ cores, the iPhone is single-core today but multi-core is coming, and apps written with `pthread_create` are either too few threads (under-utilization) or too many (context-switch thrashing). The proposed answer is a system-shared thread pool, scaled by hardware, fed by per-app queues. Apps express **what work** (a closure), not **which thread** (an `NSThread` instance). The system multiplexes.

That sentence describes:

- **GCD blocks** (2009): `dispatch_async(queue, ^{ ... })`
- **`NSOperationQueue`** (2007, retrofitted onto GCD): `operationQueue.addOperation { ... }`
- **Combine schedulers** (2019): `.receive(on: DispatchQueue.main)`
- **Swift Concurrency** (2021): `Task { ... }`, `await`, actors, `withTaskGroup`
- **Swift 6 strict concurrency** (2024): the same model with compile-time isolation checking

The `Task { @MainActor in ... }` in your modern code is the 2008 bet with type checking on top. The cost of getting the bet wrong is paid not in concept, but in the syntax churn from `dispatch_async` to `OperationQueue.main.addOperation` to `Task { @MainActor in ... }` over three rewrites. If you only learned the latest spelling, you are reading 348 and 382 as historical trivia. If you have written code in two of the spellings, you can feel the through-line.

The one thing 382 could not anticipate is that `DispatchQueue.main.async { ... }` does not satisfy `@MainActor` in Swift 6. The runtime hop is correct (the closure does run on the main queue), but the compiler cannot prove it, so the closure inherits the isolation of its declaration site. That is a Swift 6 problem, not a GCD problem, and the fix is to write `Task { @MainActor in ... }` or mark the calling method `nonisolated` and dispatch from there. The 2008 mental model is intact. The compiler enforcement got stricter.

## What got redesigned, and why

Two things from 2008 had to be rewritten:

- **Manual retain/release** (the 312 + 348 + 940 memory model) became **ARC** in 2011. The rewrite was syntactic: the compiler inserts the `retain` and `release` calls; you reason about the graph. Same model, less typing.
- **Garbage collection** (the 940 Mac-only pitch) became **ARC** in 2011. The rewrite was conceptual: trace-collected memory does not interop with C-level frameworks cleanly, so Apple gave up on tracing and committed to refcounting with compiler insertion. The lesson taught: a memory-management strategy on a platform with extensive C interop has to play nicely with `malloc`. Tracing does not.

Notice both rewrites land at ARC. There was a moment around 2008 to 2011 when Apple had three concurrent stories about how memory should work (retain/release on iPhone, GC on Mac, the implicit promise that "the system will figure it out"), and ARC collapsed all three into one model. The 2008 reveals predate that consolidation; you can read the GC topic in 940 and feel the world that did not happen.

## The audit you can run on your own codebase

The reason I wrote this post is that I was auditing my own iOS code against the 2008 reveals to see whether anything had drifted. Three short greps for any iOS codebase:

```bash
# 940: pre-fast-enumeration iteration patterns. Should be 0 hits in modern Swift.
grep -rn "while let _ = .*next()" Sources/

# 940: existential types missing the `any` qualifier (Swift 5.6+ rule).
grep -rEn "(let|var|func .* :|->)\s*[A-Z][A-Za-z]*Protocol\b" Sources/ \
  | grep -v "any "

# 348: high-frequency NSNotificationCenter consumers that may need debouncing.
# .NSPersistentStoreRemoteChange is the canonical example for CloudKit-backed apps.
grep -rn "NSPersistentStoreRemoteChange" Sources/
```

The first one should be zero. The second one is a SwiftLint-able rule (`existential_any`); if you have a hit, the fix is one keyword. The third one is the only one that typically needs real action: any consumer that does whole-store work (full search-index rebuild, full UI regeneration, full export) wants `.debounce(for: .seconds(1), scheduler: DispatchQueue.main)` and a single replace-on-write `Task<Void, Never>?`, not a `Task` array. Per-event tasks are right for *independent* per-record work (one task per object that actually changed), and wrong for *replace-the-world* work, where the only one that matters is the last.

That is a 2026 problem, written against a 2008 broadcast contract, with a 2024 fix. Eighteen years end to end. The contract is fine. The pattern around it just had to grow up.

## If you want to read the originals

Apple's own developer.apple.com no longer hosts pre-2020 WWDC videos (the current video library starts at WWDC20). Session metadata (titles, abstracts, durations, speakers) is browsable at the [nonstrict.eu WWDC Index](https://nonstrict.eu/wwdcindex/wwdc2008/), and the videos themselves have been preserved on the [Internet Archive](https://archive.org/search?query=wwdc+2008). Four sessions worth reading in this order:

1. **312** for the SDK runtime
2. **940** for the language Swift inherited
3. **348** for the design patterns the framework expects
4. **382** for the concurrency mental model

About sixty minutes each. The video quality is rough (480p H.264 at best), and the slide decks date themselves with the iPhone OS 2.0 chrome, but the talks themselves do not feel old. Most of what you will recognize is your own code, written eighteen years before you arrived.
