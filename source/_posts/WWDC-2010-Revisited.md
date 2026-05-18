---
title: "WWDC 2010 revisited: iPad ships, iOS 4 names the primitives"
date: 2026-05-15 12:00:00
categories:
- iOS
- WWDC
tags:
- iPad
- iOS 4
- UIKit
- GCD
- gesture recognizers
- API Design
- Swift
- history
---

2010 was bracketed by two products. The iPad shipped on April 3 and gave Apple a second iOS device weeks before WWDC had a chance to teach it. iOS 4 shipped on June 21 as the first release where "iPhone OS" was renamed "iOS" to acknowledge a second device on one stack. WWDC 2010 sat between the two releases. The sessions that mattered share a single move: patterns developers had been hand-rolling against `touchesBegan:`, `pthread_create`, "is the app foregrounded?" booleans, single-screen iPhone layouts, and folk-wisdom method names finally got named primitives in the SDK to replace them.

<!-- more -->

Same substrate-vs-syntax thread that ran through {% post_link WWDC-2008-Revisited "2008" %} and {% post_link WWDC-2009-Revisited "2009" %}: the contracts shipped in 2010 still describe modern iOS. What changed in 2010 is who held the pen. Up to this point Apple had taught third-party developers by handing them sample code and trusting them to read the pattern. From 2010 on, the patterns came with names, the names came with documented state machines, and the state machines came with delegate hooks that other Apple frameworks were already wired to talk to.

## What the calendar looked like

April 3: iPad ships, ten weeks after Steve Jobs announced it. iPhone OS 3.2 is iPad-only; the iPhone is still on 3.1.3. WWDC convenes June 7. iOS 4 ships June 21 for iPhone (the iPad has to wait until November to get it). The platform now has two devices on two release cadences, sharing one SDK that pretends they are one platform. Five sessions explain the next decade.

## 138: API design becomes a documented contract

138 is the meta-talk. It is the year Apple stopped treating naming as taste and started treating it as a documented framework rule. The headline rule is clarity at the call site over brevity at the declaration: `removeObjectAtIndex:` not `rmObj:`, `tableView(_:cellForRowAt:)` not `cellAt:`. Verbose at the call site is cheap because callers read the line ten times for every time the implementer writes it.

The other rules 138 codified all show up unchanged in the **Swift API Design Guidelines** five years later. No `get` prefix on getters (`get` is reserved for buffer-fill semantics like `getBytes:length:`). Designated initializers chain upward; subclasses must override the one designated initializer of the superclass. Delegation is the composition primitive, not subclassing. Method names omit needless words, name function arguments to read as English phrases, and match the platform's existing vocabulary (`addX:`, `removeX:`, `xAtIndex:`, `xCount`) rather than inventing parallel verbs.

Reading 138 back this year, the rule I noticed most was the one on naming the *role* of an argument rather than its type. The 2010 form is `tableView:didSelectRowAtIndexPath:`; the role-naming discipline says you write `didSelectRowAt indexPath:` because "row at index path" is the role and `NSIndexPath *` is the type. The Swift API Design Guidelines lifted that move directly, and it is the reason modern Swift signatures read aloud in a way that no other mainstream language's signatures do.

What did not translate cleanly is class clusters. The pattern (abstract public class, private concrete subclass returned from the initializer) is the right shape for `NSString`/`NSArray`/`NSNumber`, whose Foundation implementations vary by size and contents. Swift's value types displaced most of the new use cases. You do not author class clusters in Swift; you write value types and let the type checker specialize. The mental model survives in places like SwiftUI's `View`-as-protocol (you do not see the concrete type the body returns), but it shows up under a different name now.

## 105: the app lifecycle gets four named states

Before iOS 4, an iPhone app was either running or not. When the user hit the Home button the app terminated. There was no "still in memory but not visible" state to live in. Apps that wanted to finish an upload, keep playing audio, or maintain a socket for a VoIP call had nowhere to do it. The third-party API surface for backgrounding was empty.

iOS 4 split "running" into four named states: active, inactive, background, suspended. Each transition got a delegate callback. Background work got a documented surface for finishing in-flight tasks (`beginBackgroundTaskWithExpirationHandler:`, paired with `endBackgroundTask:` or the system terminates you when the budget expires) and a documented Info.plist key (`UIBackgroundModes`) for declaring that the app needs to keep running for a small fixed set of reasons. The launch set was narrow: `audio` for music apps, `location` for navigation, a `voip` socket-maintenance mode for Skype-style calls. Apple added `newsstand-content` with iOS 5 (it retired alongside Newsstand itself in 2015), `fetch` and `remote-notification` with iOS 7, the modern deferrable `processing` task with iOS 13.

```objc
// 2010 backgrounding pattern
- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.uploadTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:self.uploadTask];
        self.uploadTask = UIBackgroundTaskInvalid;
    }];
    // finish in-flight upload, then call endBackgroundTask:
}
```

The state machine survived 16 years intact. iOS 7 added background fetch. iOS 13 split the lifecycle per scene (`UISceneDelegate`) for multi-window iPad and Mac Catalyst. iOS 13 also added `BGTaskScheduler`, the modern way to schedule opportunistic background work, which is the spiritual descendant of `beginBackgroundTaskWithExpirationHandler:`. The four state names did not change. The transitions did not change. The delegate-as-lifecycle-owner shape did not change.

What 2010 could not see is that `remote-notification` would join the list with iOS 7 and that the silent-push channel under it would become the transport substrate for CloudKit cross-device sync. The launch modes were for apps with their own reasons to keep running. The mode that mattered most by 2020 was for apps that needed to be woken up by Apple's servers on someone else's behalf.

## 206: queues replace threads on iPhone

GCD shipped on the Mac with Snow Leopard in 2009 (the {% post_link WWDC-2009-Revisited "2009 post" %} covers it). iOS 4 was where it crossed over. The 2010 session was essentially "this is now available on the device most of your users have."

The pitch is the same it has always been: queues, not threads. You express what work needs to happen by handing the runtime a closure; the runtime schedules it onto a system-managed thread pool sized to the hardware. You stop reasoning about thread count and start reasoning about queue confinement. The pre-GCD alternatives (`NSThread`, `pthread_create`) forced you to manage thread lifetimes, signaling primitives, the choice of how many threads to spin up, and what to do when one of them stalled.

```objc
// 2010: nested dispatch_async to hop off-main and back
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSData *data = loadFromDisk();
    dispatch_async(dispatch_get_main_queue(), ^{
        self.label.text = renderText(data);
    });
});
```

```swift
// 2026: the same hops, expressed as a single Task on a MainActor-isolated caller
Task { @MainActor in
    let data = await loadFromDisk()
    label.text = renderText(data)
}
```

The work the runtime does is identical. The 2026 syntax compresses two `dispatch_async` calls and an explicit queue selection into a single `Task { @MainActor in }`, but the closure still gets pulled off a queue, run, and the result still gets handed back across an actor boundary that is, underneath the type system, a queue hop. Swift's `Task` and Swift's actors are the GCD bet with a type system bolted on top.

The one thing 2010 GCD could not anticipate is that `DispatchQueue.main.async { ... }` would stop satisfying `@MainActor` in Swift 6. The runtime still hops to main correctly. The compiler cannot prove it does, so the closure inherits the isolation of its declaration site, and the fix is to write `Task { @MainActor in ... }` or mark the caller `nonisolated` and dispatch from there. The model is intact. The proof obligations got stricter.

## 120: touch events become a state machine

Before 2010, every iPhone app that wanted to recognize a pinch or a swipe wrote a `UIView` subclass with overridden `touchesBegan:withEvent:`, `touchesMoved:`, `touchesEnded:`, and `touchesCancelled:` methods, kept per-finger state in an `NSMutableDictionary` keyed by `UITouch` pointer identity, and did its own velocity, distance, duration, and hysteresis math. Gesture detection was bespoke per app, and most apps got it subtly wrong (the double-tap that fires while you are still mid-pan; the pinch that registers as a pan because the second finger arrived 30 ms late).

`UIGestureRecognizer` collapsed all of that into a named state machine you attach to a view. Six built-in subclasses shipped in iOS 4: Tap, Pan, Pinch, Rotation, Swipe, LongPress. States are named (`possible → began → changed → ended` for continuous gestures; `possible → recognized` for discrete ones). Composition is a delegate concern: `shouldRecognizeSimultaneouslyWith:` to layer recognizers on the same view, `shouldRequireFailureOf:` to disambiguate (double-tap waits for the single-tap recognizer to fail first).

```swift
// UIKit, 2010 pattern, still current
let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
imageView.addGestureRecognizer(pinch)
```

```swift
// SwiftUI, 2026
imageView
    .scaleEffect(scale)
    .gesture(MagnifyGesture()
        .onChanged { scale = $0.magnification }
    )
```

`MagnifyGesture` (renamed from `MagnificationGesture` in iOS 17) is `UIPinchGestureRecognizer` with the action-target plumbing folded into a modifier. `DragGesture`, `RotateGesture`, `LongPressGesture`, and `TapGesture` follow the same one-to-one mapping. The state machine SwiftUI is running under those names is the 2010 state machine, unmodified.

What got harder, not easier, is *composing* recognizers. Two recognizers on the same view still need either `shouldRecognizeSimultaneouslyWith:` returning true or one waiting on the other via `shouldRequireFailureOf:`. SwiftUI's `.simultaneously(with:)` and `.exclusively(before:)` are the same primitives renamed. The pinch, pan, single-tap, and double-tap combination on a photo viewer is the same multi-recognizer puzzle in both eras, and the puzzle does not get easier when you rename the pieces.

## 103: iPad is a layout opportunity, not a screen size

iPad shipped ten weeks before WWDC. 103 was Apple's first formal teaching of how iPad apps should be shaped. The headline design principle was "more content per screen, not bigger UI." iPad gave you a 1024×768 canvas. The wrong move was to scale the iPhone's controls 2.3× and call it done. The right move was to show roughly three times more of the same content on one screen by adopting a two-column layout: a master list on the left, the detail of the selected item on the right.

`UISplitViewController` shipped as the SDK primitive for that layout. It hosts a master view controller and a detail view controller, manages the orientation behavior (master collapses behind a button in portrait, both visible in landscape), and exposes a `displayModeButtonItem` to toggle the master pane. `UIPopoverController` shipped alongside it as the transient-overlay primitive: anchored at a source view or bar button item, auto-dismissed on outside tap, replacing the modal sheet for sub-decisions like "pick a date" or "choose a font."

The 2010 design lesson survived; the 2010 implementations did not. `UISplitViewController` got rewritten in iOS 8 with adaptive presentation, again in iOS 14 with column-based initialization, and SwiftUI's `NavigationSplitView` (2022) is the third generation of the same idea. `UIPopoverController` was deprecated in iOS 9 and replaced with `popoverPresentationController` on any view controller. The two-column iPad app is still the default shape (Mail, Notes, Settings, Files, every CRUD app in the App Store top 50), but none of those are running 2010 code under the hood.

What 2010 nailed and 16 years still owe it is the principle that screen size is a *layout* property, not a *scale* property. The 44pt minimum tap target is the same on iPhone and iPad. Body font is the same. What changes between the two devices is how many things fit. That principle anchors every responsive-layout system that came after it: size classes (2014), trait collections, `@Environment(\.horizontalSizeClass)` in SwiftUI, the iPadOS multitasking sidebar (2019), and the Stage Manager layout rules (2022) are all corollaries of "scale by adding peer regions, not by zooming."

## What 2010 could not see

One bet from 2010 needs caveats in 2026: the assumption that one app meant one foreground window. The state machine in 105 was four states for one process. The lifecycle delegate methods (`applicationDidBecomeActive:`, `applicationDidEnterBackground:`) fired once per app, because there was no notion of multiple scenes. iPadOS 13 added multi-window for iPad. Mac Catalyst brought it to the Mac. The scene-based lifecycle has the same four states, but they fire per scene now, and the app-level delegate methods became coarser-grained (they fire when the *last* scene resigns or when the *first* scene becomes active).

Apps written against the 2010 single-scene assumption mostly still work, because Apple kept the old delegate methods firing for backwards compatibility, but they handle multi-window awkwardly. A correct multi-window app routes state restoration, deep-link handling, per-scene UI state, and "the user just came back" refresh through the scene delegate, not the app delegate. The 2010 architecture had no language for that, and the iOS 13 retrofit left the app delegate sitting at a level of abstraction that does not quite match either the old single-process model or the new per-scene model.

The other thing 2010 could not anticipate is that the popover chrome would feel wrong on the Mac. iOS 13 Mac Catalyst inherits the iPad layout primitives, and `popoverPresentationController` does the right thing as an anchored popover on Mac. The iPad-era assumption that "popover equals small floating sheet with an arrow pointing at its source" maps unevenly to a desktop OS where the equivalent transient surface is more often a window-attached sheet without an arrow. The mismatch is small but real, and there is no clean fix that does not break iPad behavior.

## If you want to read the originals

Same caveats as the {% post_link WWDC-2009-Revisited "2009 post" %}: Apple's developer.apple.com no longer hosts pre-2020 WWDC videos. Session metadata is at the [nonstrict.eu WWDC Index](https://nonstrict.eu/wwdcindex/wwdc2010/) and the videos themselves live on the [Internet Archive](https://archive.org/search?query=wwdc+2010).

Five sessions in this reading order if you want the same arc as the post:

1. **138** "API Design for Cocoa and Cocoa Touch" for the documented grammar of every Apple framework that came after
2. **105** "Adopting Multitasking on iPhone OS, Part 1" for the four-state lifecycle that became scene phases
3. **206** "Introducing Blocks and Grand Central Dispatch on iPhone" for the concurrency model the modern Swift `Task` descends from
4. **120** "Simplifying Touch Event Handling with Gesture Recognizers" for the state machine SwiftUI gestures are wrapped around
5. **103** "iPad and iPhone User Interface Design" for the layout grammar that still defines two-column apps

About sixty minutes each. The video quality is 480p H.264, the slides date themselves with the iPhone OS 3.x chrome, and the iPad demos run on the original 1024×768 iPad with the home button. The talks themselves do not feel old. Most of what you will recognize is the language Swift still speaks, sixteen years before it learned how to speak it.
