---
title: "WWDC 2009 revisited: iPhone OS 3.0 in June, Snow Leopard in August"
date: 2026-05-14 12:00:00
categories:
- iOS
tags:
- WWDC
- GCD
- Core Data
- StoreKit
- HLS
- LLVM
- Swift
- history
---

WWDC 2009 was two releases doing different jobs. iPhone OS 3.0 shipped on June 17 and turned the App Store from a curiosity into a viable place to ship a product. Snow Leopard shipped on August 28 with no new user-facing features at all, marketed literally as "0 new features," because the work that year went into the foundation: a 64-bit rewrite of every Mac framework, the Clang toolchain replacing GCC, and blocks plus Grand Central Dispatch. The two releases ship eleven weeks apart, in different keynotes, and are usually remembered separately. Reading them together is the only honest way to look at 2009, because each release filled a gap the other left.

<!-- more -->

Same substrate-vs-syntax split that ran through {% post_link WWDC-2008-Revisited "the 2008 sessions" %}: the contracts shipped in 2009 still describe modern iOS. The syntax around them has been rewritten two or three times since.

## iPhone OS 3.0 (June): apps become businesses

The App Store was eleven months old when 3.0 shipped. The previous year's SDK was a tech preview that could draw views and read JSON, but a developer who wanted to build something that paid rent had to invent or skip most of the missing pieces. 3.0 was the release where Apple shipped those missing pieces.

### Push notifications

Promised at WWDC 2008 for "this September," slipped to June 2009. Apple Push Notification Service is the async wake-up channel: a server posts to APNs, the OS delivers it to the right device, the app's delegate gets called. Without it, a backgrounded iPhone app was effectively dead, which made entire categories (news alerts, chat, multiplayer turn notifications) impossible on iPhone before 3.0.

The 2009 delegate API still works in 2026:

```swift
func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
    // send token to your server
}
```

The signature was extended in iOS 7 with `fetchCompletionHandler` for silent pushes, and visible alerts now route through `UNUserNotificationCenter`. Below those wrappers, the contract is the 2009 contract: register for a device token, send it to your server, handle the delivery callback when the OS wakes you.

What 2009 could not have anticipated is the silent variant becoming a transport substrate. CloudKit (2014), iCloud Keychain, Find My, Background App Refresh, and `NSPersistentCloudKitContainer` (2019) all ride the silent-push channel. The cross-device "I edited this on my iPhone, it showed up on my Mac" experience that defines modern Apple platforms is implemented on top of a 2009 design that was originally pitched as "your news app should beep when there's news."

### Core Data on iPhone

Core Data shipped on the Mac in Tiger (2005). In iPhone OS 3.0 it came to mobile. The three-class stack from session 421, `NSManagedObjectModel` for the schema, `NSPersistentStoreCoordinator` for the SQLite store, `NSManagedObjectContext` for the in-memory graph, is the same triple every Core Data app uses today.

```swift
let container = NSPersistentContainer(name: "Model")
container.loadPersistentStores { _, error in
    if let error { fatalError("loadPersistentStores failed: \(error)") }
}
let context = container.viewContext
```

`NSPersistentContainer` (iOS 10) wrapped the three primitives in a convenience class. `NSPersistentCloudKitContainer` (iOS 13) added CloudKit sync as a thin layer. SwiftData (iOS 17) replaces the `.xcdatamodel` with `@Model` types declared in Swift. All three layers compile down to the same SQLite store format and the same `NSManagedObjectContext` semantics the 2009 session introduced.

Lightweight migration is the part that survived intact. Add or rename an attribute, bump the model version, set `NSMigratePersistentStoresAutomaticallyOption` and `NSInferMappingModelAutomaticallyOption`, and the framework rewrites the schema in place at load time. No migration script, no DDL, no rollback plan. The 2009 pattern is what carries existing users' data through additive schema changes a decade and a half later.

What 2009 could not have anticipated is the multi-device dimension. When CloudKit was bolted on a decade later, the single-device assumptions had to be reinterpreted: the container now hosts two managed object contexts (Private and Shared databases under Family Sharing), and the merge policy is last-writer-wins and not configurable. Same chassis, new dimensions Apple wired around it.

### In-App Purchase

StoreKit shipped in 3.0 for paid apps in June; Apple extended IAP to free apps in October. The 2009 callsite API (`SKProductsRequest`, `SKPaymentQueue`, the `paymentQueue:updatedTransactions:` observer protocol) is the one piece of the iPhone OS 3.0 surface that StoreKit 2 (2021) replaced wholesale. Modern code calls `Product.products(for:)`, `for await`s over `Transaction.updates`, and there is no global observer to register or unregister. Nothing about the 2009 callsite code survives.

What did survive is the receipt format. The 2009 App Store receipt was a base64-encoded blob signed by Apple, carrying the original transaction identifier, product identifier, purchase date, and a signature you could verify against Apple's certificate or against Apple's verification endpoint. StoreKit 2 wraps that in `Transaction` and `Product` value types with typed field access and JWS verification you can perform locally, but the receipt itself is still the receipt: same signature scheme, same field positions for the original 2009 fields, same role as the single source of truth on whether a purchase happened. The subscription, family-sharing, and app-account-token fields were added on top of the 2009 layout, not in place of it.

What 2009 got wrong was the consumer-economics assumption. It assumed one-time consumable and non-consumable purchases with restoration as a corner case. Auto-renewing subscriptions (2011), introductory pricing (2016), subscription groups (2018), and the EU DMA carve-outs (2024) reshaped the App Store economy around recurring revenue, which the 2009 framing has nothing to say about. The chassis (products, transactions, receipts) is what 2009 nailed; the surface around it has been rewritten about every three years since.

### HTTP Live Streaming

HLS shipped quietly in 3.0 with its own session (313), and it is the streaming format every video player on Apple platforms consumes in 2026. The 2009 design put HTTP at the transport layer (CDN-cacheable, no stateful streaming server) and pushed adaptive-bitrate negotiation to the client via an `.m3u8` manifest pointing at chunked segments. The streaming wars of the 2010s ended with HLS as the universal floor: RTMP died with Flash, MPEG-DASH coexists but never displaced HLS on iOS or Safari, and Smooth Streaming retreated to Microsoft-only deployments.

The 2009 transport was MPEG-2 TS segments. Apple added fragmented MP4 segments in 2016 and Low-Latency HLS in 2019, but a 3.0-era `.m3u8` still plays in `AVPlayer` today and the manifest grammar is unchanged. The decision that mattered most was publishing HLS as an IETF Internet-Draft rather than a proprietary spec. That is the reason HLS became the cross-platform floor instead of an Apple-only format like the FairPlay DRM layered on top of it.

### The rest of 3.0 in one line each

Three more 3.0 additions reshaped categories of apps despite not getting deep-dive sessions. MapKit made location-aware apps a default-on category. Game Kit's peer-to-peer Bluetooth was the first system API for ad-hoc nearby networking and is the conceptual ancestor of Multipeer Connectivity. Accessibility and VoiceOver on iPhone, alongside system-wide cut/copy/paste, are the additions Apple's marketing led with for non-developers and turn out to be the additions that quietly aged best.

## Snow Leopard (August): no features, an entirely new foundation

Apple's marketing copy for Snow Leopard was the phrase "0 new features." The release was, in their framing, devoted to performance, stability, and the underpinnings of the next decade of macOS. Three of those underpinnings are still load-bearing in 2026.

### Blocks and Grand Central Dispatch

The headline. Blocks (`^{ ... }`) shipped as a clang extension, and GCD shipped on top of blocks. The two are intertwined by design: you cannot have a system-managed thread pool that accepts "what work to run" if the language has no way to express "a unit of work" without a class declaration. Pre-blocks Objective-C had `NSInvocation`, which works but is three lines per callsite and a manual `retain` per captured argument. Blocks compressed both into a single literal that the compiler closes over.

```objc
// 2009: GCD with blocks
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSData *data = [self loadFromDisk];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.label.text = [self renderText:data];
    });
});
```

```swift
// 2026: Swift Concurrency from a MainActor-isolated caller
Task { @MainActor in
    let data = await loadFromDisk()
    label.text = renderText(data)
}
```

Two shifts are easy to miss reading these side by side. The priority dance (`DISPATCH_QUEUE_PRIORITY_DEFAULT`) is gone, absorbed first by QoS classes (2014) and then by Swift task priority (2021). The inner main-queue hop became implicit: if the outer `Task` is already `@MainActor`, the body runs on main without a nested dispatch, and you only hop explicitly when you cross an actor boundary. The work the runtime does is the same; the compiler does more of the bookkeeping.

What hasn't aged perfectly is the secondary GCD vocabulary. Dispatch *groups*, *barriers*, and *semaphores* still ship and the runtime still implements them, but Swift Concurrency replaced groups with `withTaskGroup`, barriers with actor isolation, and semaphores with `CheckedContinuation` (or, more often, with a redesign that did not need them). A `DispatchSemaphore` in modern app code is almost always a sign that an async function is being called from a sync context, and the right fix is to make the caller async rather than to block a thread.

### Clang and the toolchain swap

The quiet Snow Leopard bet. Apple moved off GCC to clang/LLVM as the default toolchain for new framework code, with the full developer-facing default following over the next two releases. The decision is not visible at any callsite, but every Swift language feature since 2014, ARC in 2011, modules in 2012, generics specialization, strict concurrency checking, and the entire Swift compiler being written against LLVM IR, all follow from that 2009 architectural choice. If Apple had stayed on GCC, the language Swift inherits would not be the language Swift is.

There is no shipped API to point at here, which is exactly why the move was easy to miss in 2009. The release-notes line was something like "Apple is contributing to clang and LLVM." Sixteen years on, every binary on every Apple platform is compiled by it.

### 64-bit everywhere on the Mac

Snow Leopard rewrote every Mac framework to be 64-bit clean and shipped a 64-bit kernel option. The iPhone stayed 32-bit until the A7 in 2013, so this work did not touch iOS code until later, but the Mac rewrite is the reason the Intel-to-Apple-silicon transition in 2020 went as smoothly as it did. By 2020, every framework had been 64-bit clean for eleven years, and the only architecture-specific code most apps had was Intel intrinsics. The work paid off twice, eleven years apart, and the second payoff is what the 2009 marketing said the release was for.

## What got rewritten

Two patterns from 2009 had to be replaced wholesale rather than extended:

- **Manual block memory management** (`Block_copy`, `Block_release`, `[block copy]` when storing into an ivar) became ARC-managed blocks in 2011 and then Swift closures in 2014. The 2009 model required developers to think about block lifetime separately from object lifetime, with bugs that only manifested at runtime when a stack-allocated block escaped its scope. ARC folded the copy-on-escape rule into the compiler; Swift made it impossible to express the failure case.
- **`SKProductsRequest` plus `SKPaymentQueue` observer** became StoreKit 2 in 2021. The 2009 design was a pre-blocks delegate-and-notification pattern that had been bolted onto async/await semantics with backwards-compatibility shims for a decade. StoreKit 2 is the clean break: typed `Transaction` values, async iteration, no global observer, no `.failed` transaction stuck in the queue across launches. The old API still works, and apps that do not need StoreKit 2 features can stay on it indefinitely.

What did not get rewritten: the `UIApplicationDelegate` lifecycle that push hooks into (still the canonical wake-up surface), the Core Data three-class stack (now wrapped by `NSPersistentCloudKitContainer` and `@Model`, not replaced), `dispatch_get_main_queue()` (still the queue under `MainActor.run`), the HLS `.m3u8` manifest grammar, and the App Store receipt's signed field positions. Modern iOS apps are written against a 2009 substrate with two or three layers of newer syntax above it.

## If you want to read the originals

Same caveats as the {% post_link WWDC-2008-Revisited "2008 post" %}: Apple's developer.apple.com no longer hosts pre-2020 WWDC videos. Session metadata lives at the [nonstrict.eu WWDC Index](https://nonstrict.eu/wwdcindex/wwdc2009/), and the videos themselves are on the [Internet Archive](https://archive.org/search?query=wwdc+2009).

Four sessions in this reading order if you want the same arc as the post:

1. **406** "Programming with Blocks and Grand Central Dispatch" for the Snow Leopard concurrency story
2. **421** "Introduction to Core Data on iPhone" for the persistence framework that became `NSPersistentCloudKitContainer` and `@Model`
3. **120** "Apple Push Notification Service" for the lifecycle wake-up channel
4. **122** "In-App Purchase on iPhone" for the receipt chassis that outlasted three SDKs

Forty to sixty minutes each, 480p H.264, iPhone OS 3.0 or Snow Leopard chrome on the slides. The talks themselves are precise enough that you can map each one onto a method call you wrote this week.
