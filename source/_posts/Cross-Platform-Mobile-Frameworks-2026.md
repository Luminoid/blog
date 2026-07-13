---
title: "Cross-platform mobile frameworks in 2026"
date: 2026-06-13 12:00:00
categories:
- Mobile
tags:
- React-Native
- Flutter
- Kotlin-Multiplatform
- Compose-Multiplatform
- .NET-MAUI
- Capacitor
- Ionic
- Expo
- Dart
- SwiftUI
- Jetpack-Compose
- uni-app
- Taro
- Lynx
- HarmonyOS
- WeChat-Mini-Programs
---

Every serious cross-platform mobile framework as of mid-2026 -- React Native, Flutter, Kotlin Multiplatform, .NET MAUI, Capacitor -- with the architecture each one is built around, how that choice plays out across app types, the adoption path, and where each one hurts. Plus a section on China, where WeChat mini-programs make the whole question different and uni-app, not React Native or Flutter, sits on top.

<!-- more -->

## Glossary

| Acronym | Full name | What it means |
|---------|-----------|---------------|
| **RN** | React Native | JS/TypeScript framework that drives real native views |
| **KMP** | Kotlin Multiplatform | Share Kotlin business logic across platforms, keep native UI |
| **CMP** | Compose Multiplatform | JetBrains' shared-UI layer built on KMP |
| **MAUI** | Multi-platform App UI | Microsoft's C# framework, successor to Xamarin.Forms |
| **JSI** | JavaScript Interface | RN's synchronous C++ bridge between JS and native |
| **AOT** | Ahead-of-Time compilation | Compiling to machine code at build time, not at runtime |
| **OEM widget** | Original-equipment widget | A platform's own UI control (`UIButton`, Android `Button`) |
| **OTA** | Over-the-air update | Pushing a code update without an App Store review cycle |
| **FFI** | Foreign Function Interface | Calling native C/C++/Swift directly from another language |
| **EAS** | Expo Application Services | Expo's hosted build and update infrastructure |

## The one axis that explains everything

Strip away the marketing and every cross-platform framework is answering two questions: **how do I put pixels on screen**, and **how do I cross the boundary into platform code** (the camera, the keychain, the GPS, the file system). Pick those two answers and roughly 80% of a framework's tradeoffs fall out automatically. Performance ceiling, native feel, hiring pool, the kind of bug you'll spend a weekend on -- all downstream of those two choices.

There are three pixel strategies and they sort the entire field:

{% mermaid %}
flowchart TD
    Q["How does it draw?"]
    Q --> A["Drive native widgets<br/>(RN, MAUI)"]
    Q --> B["Own the canvas<br/>(Flutter, Compose MP)"]
    Q --> C["Render in a WebView<br/>(Capacitor, Ionic)"]
    Q --> D["Don't draw at all --<br/>share logic only (KMP)"]
    A --> A1["Looks native because it IS native.<br/>Cost lives at the JS to native boundary."]
    B --> B1["Pixel-identical everywhere.<br/>You re-implement platform look + reach<br/>native APIs through channels."]
    C --> C1["Cheapest web-skill reuse.<br/>Weakest at heavy interaction + gestures."]
    D --> D1["Zero boundary cost (compiles to native).<br/>You still write each UI twice."]
{% endmermaid %}

A few principles follow from this that are worth holding in your head before reading any framework's docs:

**The cost is always at the boundary.** React Native's old reputation for jank came from one thing: the original bridge serialized every JS-to-native call into a batched, asynchronous JSON queue. Animations driven from JS dropped frames because the message sat in a queue behind everything else. The New Architecture (JSI plus Fabric, default since RN 0.76) replaced that queue with synchronous C++ calls and killed most of that class of bug. Flutter's boundary is the platform channel, also a serialized message hop -- fine for "fetch a contact," bad for "stream accelerometer data at 120Hz." KMP barely has a boundary because it compiles to a native binary you call like any other library.

**"Native feel" is a spectrum, and your app type sets how much you need.** A settings screen with a list and some toggles touches the boundary almost never. A camera app, a trading app, or a game lives at the boundary every frame. The same framework that's a slam dunk for the first is a fight for the third.

**Adoption is rarely all-or-nothing anymore.** The interesting 2026 story is incremental: bolt one Flutter screen into a native app, share just the networking layer with KMP, wrap an existing web app in Capacitor for a quick store presence. "Rewrite everything in framework X" is a greenfield decision, and greenfield is the rare case.

## Quick comparison

| Framework | Language | Draws with | Native feel | Perf ceiling | Best team fit | Maturity |
|-----------|----------|-----------|-------------|--------------|---------------|----------|
| **React Native** | TypeScript | Native widgets (Fabric) | High | High | Web/JS shops, product teams | Very mature |
| **Flutter** | Dart | Own engine (Impeller) | High but uniform | Very high | Design-led, single codebase | Very mature |
| **Kotlin Multiplatform** | Kotlin | Native UI (you write it) | Perfect (it's native) | Native | Existing native iOS+Android teams | Mature, fast-growing |
| **Compose Multiplatform** | Kotlin | Own engine (Skia on iOS) | High but uniform | High | Android-led teams going cross | iOS stable since May 2025 |
| **.NET MAUI** | C# | Native widgets (handlers) | Medium-high | Medium | Microsoft/enterprise shops | Mature (Xamarin lineage) |
| **Capacitor / Ionic** | TS + web | WebView | Low-medium | Low-medium | Web teams, content apps | Mature |

What follows is the design behind each, then where it pays off and where it bites.

## React Native (with Expo)

**The design.** Your TypeScript runs in a JS engine (Hermes, RN's own, which pre-compiles to bytecode and starts fast). The engine doesn't talk to native through a message queue anymore -- under the New Architecture it holds a JSI handle, a direct synchronous C++ pointer into native land. When you render a `<View>`, the Fabric renderer mounts a real `UIView` on iOS and a real `android.view.View` on Android. Layout is computed by Yoga, a C++ flexbox engine shared across platforms, on its own thread. So you get three threads doing distinct jobs: JS runs your logic, the shadow thread does layout, the main thread does the actual native drawing. The thing on screen is genuinely a native view; you're just driving it from JavaScript. As of RN 0.82 the New Architecture is the only runtime, and 0.84 began deleting the legacy code outright, so this is simply how React Native works now, not a flag you flip; current stable is 0.86, and Hermes V1 has been the default engine since 0.84.

Expo is the part that changed RN from "assemble it yourself" into a real platform. EAS Build compiles in the cloud, EAS Update ships OTA JS patches without a review cycle, Expo Router gives you file-based navigation, and config plugins let you reach into native build settings without ejecting. By 2026 "bare" React Native (no Expo) is the unusual choice, not the default. One 2026 wrinkle to plan around: the Expo Go sandbox app has been stuck in Apple's review queue since May 2026 and Expo now frames it as a learning tool, so real projects should standardize on development builds from day one.

**Strengths:**
- The largest ecosystem and hiring pool of any option, by a wide margin. Whatever you need, a library exists.
- Web-skill reuse is real -- a React web team is productive in days, and a lot of non-UI code (validation, state, API clients) moves over unchanged.
- OTA updates via EAS sidestep the review queue for JS-only fixes. For a bug-fix-heavy product that alone justifies the choice.
- The rendered result is native widgets, so accessibility, text selection, and platform behaviors mostly come for free.

**Weaknesses:**
- The boundary still exists. Anything that needs per-frame data crossing into JS (complex gesture choreography, a live order book, audio visualization) wants a native module written in Swift/Kotlin/C++. You don't escape native; you defer it.
- Dependency drift is a tax. A native module that hasn't kept up with the New Architecture can block a whole upgrade, and RN upgrades have historically been the worst day of the quarter (the community's "Upgrade Helper" exists for a reason).
- You're assembling a stack: navigation, state, data fetching, and styling are all separate decisions, the same as React on web.

**Best for:** consumer product apps, social, content, fintech front-ends, anything where iteration speed and a deep talent pool matter more than squeezing the last millisecond. Shopify (Shopify Mobile and POS, both migrated to the New Architecture in 2025), Coinbase, and Microsoft (parts of Office) ship it in production. Microsoft's Windows 11 shell leaned on RN too, but the company said at Build 2026 it's rewriting those shell surfaces in native WinUI, a useful reminder that even a flagship adopter drops the abstraction once a surface gets performance-critical enough. Instagram and Discord are often cited but overstated: Instagram adopted RN only partially back in 2016, and Discord ran it on iOS while keeping Android native, so neither is the clean both-platforms example people assume.

**Avoid for:** apps that are mostly a custom rendering surface (games, pro camera, heavy real-time visualization). You'd write so much native that the JS layer stops earning its place.

## Flutter

**The design.** Flutter makes the opposite bet from React Native: it doesn't touch the platform's widgets at all. Your Dart code compiles AOT to native ARM machine code, and the app ships with its own rendering engine. That engine, Impeller (the iOS default since 3.10 in 2023 and the Android default since the 3.27 release in late 2024; Skia is fully gone on iOS and being torn out of the remaining Android path), rasterizes every pixel and hands it to Metal or Vulkan directly. Your UI is a tree of widgets that desugars into elements and then render objects; Flutter composites the whole frame itself and paints it onto a single texture. The OS sees one canvas. There is no `UIButton` under your button -- there's a Flutter-drawn thing that looks like one.

That's the source of both its superpower and its tax. The superpower: pixel-identical output on every device and OS version, 60/120fps because nothing crosses a boundary to draw, and a hot-reload loop that remains one of the fastest around (it reached Flutter web experimentally in 3.32 and by default in 3.35). Flutter ships on a quarterly cadence now; 3.44 in May 2026 made Swift Package Manager the default for iOS and macOS, a migration with a hard deadline behind it, since the CocoaPods registry goes read-only in December 2026. The tax: when iOS ships a new system control or a subtle scroll-physics change, you wait for the Flutter team to re-implement it, and reaching a native API means a platform channel (a serialized message hop) or an FFI call.

**Strengths:**
- The most consistent UI across the device matrix. If you've ever burned a sprint on an Android OEM rendering a list differently, this is the relief.
- Genuinely high performance for animation-heavy and custom UI, because drawing never leaves the engine.
- One language, one toolchain, one widget set -- the least context-switching of any cross-platform option.
- Reaches beyond mobile (desktop, web, embedded, now TVs via LG's webOS Flutter SDK) from the same codebase more credibly than the others.

**Weaknesses:**
- It re-implements the platform rather than using it, so brand-new OS UI affordances lag, and "it should feel exactly like a native app to a power user" is achievable but takes deliberate work.
- Dart is a smaller hiring pool than TypeScript or Kotlin, and it's a language people learn for Flutter specifically rather than bringing with them.
- Native interop (channels/FFI) is the rough edge -- comfortable for occasional calls, awkward for high-frequency native data.
- There's a recurring strategic worry about Google's long-term commitment. Google cut staff from the Flutter and Dart teams in April 2024, then reaffirmed support at I/O 2025 and again at I/O 2026, where it put monthly active Flutter developers around 1.5 million (up roughly 50% year over year); Google's own showcase lists Google Pay, Ads, and NotebookLM among its Flutter apps. The same I/O also handed stewardship of Flutter's desktop targets to Canonical. Read all of it as a shift from expansion to maintenance, not abandonment, but it shows up in every architecture review regardless.

**Best for:** design-led apps with a strong custom visual identity, apps that must look identical everywhere, MVPs that need to move fast with a small team. BMW, Alibaba, and a long tail of startups ship it.

**Avoid for:** apps whose value is deep platform integration (a widget-and-Live-Activity-heavy iOS app), or teams that already have separate strong native iOS and Android groups -- Flutter asks them to abandon what they're good at.

## Kotlin Multiplatform (and Compose Multiplatform)

**The design.** KMP is the odd one out, and that's exactly why it has so much momentum in established native shops: Google made it a first-class Android option at I/O 2024 and extended core Jetpack libraries (Room, DataStore, ViewModel) to it through 2025. It doesn't try to draw a cross-platform UI at all (by default). You write your business logic once in Kotlin -- networking, data models, validation, persistence, the state machine of your app -- and the Kotlin/Native compiler (LLVM under the hood) turns it into a real `.framework` for iOS and ordinary bytecode for Android. On the iOS side you call that shared code from Swift through an auto-generated Objective-C-compatible framework: low overhead, not literally zero (a Kotlin `String` gets marshalled across the Obj-C layer), but nothing like a serialized async bridge. Then you build the UI twice: SwiftUI/UIKit on iOS, Jetpack Compose on Android. The user gets a 100% native UI because it is one.

Compose Multiplatform is the optional second layer: JetBrains' port of Jetpack Compose that also renders on iOS (via a Skia canvas, so on iOS it behaves more like Flutter -- own-the-canvas). CMP for iOS has been stable since May 2025 (the 1.8.0 release) and has kept a quarterly clip since; 1.11 in May 2026 turned on concurrent rendering on iOS by default, while the web target is still beta. You can now slide the dial anywhere from "share only the data layer" to "share the entire app including UI," picking per screen.

**Strengths:**
- Incremental by nature. You can adopt it for one shared module inside two existing native apps without rewriting either UI. No other framework lets you start this small.
- The shared code is genuinely native on each side -- no JS runtime, no async bridge, no perf cliff. The logic layer carries almost no tax.
- It keeps your native teams doing native UI, which is where platform fidelity, accessibility, and new-OS-feature adoption are easiest.
- Kotlin is a pleasant, modern language with a large Android-rooted talent pool.

**Weaknesses:**
- Default KMP doesn't save you any UI work -- you still write SwiftUI and Compose separately. The savings are in logic, not screens. Teams expecting "write once" are surprised.
- The iOS-from-Kotlin developer experience, while much improved, is still less polished than Swift-native (debugging into the Kotlin framework, Swift-to-Kotlin interop ergonomics). JetBrains' Swift export, which binds Kotlin directly to idiomatic Swift and skips the Objective-C layer, reached alpha in Kotlin 2.4.0 (June 2026) and is how JetBrains intends to close this gap; the same release lets Kotlin/Native consume Swift packages as dependencies.
- Compose Multiplatform on iOS is young relative to Flutter; the ecosystem of iOS-aware widgets is thinner.
- Tooling and library maturity vary by target; you'll occasionally hit a library that's Android-only.

**Best for:** companies that already ship separate, healthy native iOS and Android apps and want to stop writing the same networking/business logic twice. McDonald's, Forbes, Philips, Google's Workspace (Docs) apps, and -- in the most-cited case study -- Netflix's Prodicle use it precisely this way: share the engine, keep the cockpit native. JetBrains' KotlinConf'26 keynote claimed adoption doubled year over year, with PayPal, Booking.com, Sony, and Duolingo now running it in production.

**Avoid for:** a solo developer or tiny team building greenfield who wants one person to ship both platforms from one UI codebase. That's the Flutter/RN sweet spot, not KMP's.

## .NET MAUI

**The design.** MAUI is the Xamarin lineage, modernized. You write C# against a single cross-platform control set; at runtime a *handler* maps each abstract control to the real native widget (a MAUI `Button` becomes a `UIButton` or an Android `MaterialButton`). The handler architecture is the cleaned-up successor to Xamarin.Forms' renderers, with less ceremony and better performance. Your C# runs on the .NET runtime on each platform, and a single project file targets iOS, Android, macOS (via Mac Catalyst), and Windows. As of late 2025 it rides on .NET 10, with an asterisk worth reading twice: .NET 10 is a three-year LTS, but MAUI 10 itself is only supported until May 2027, roughly 18 months, because MAUI is guaranteed just six months past its successor. .NET 11 (November 2026) swaps Mono for CoreCLR as the runtime underneath.

The strategy here is the same as React Native's -- drive native widgets -- but expressed in C# for shops whose center of gravity is the Microsoft stack and whose backend is already .NET.

**Strengths:**
- If your backend, your tooling, and your developers are already C#/.NET, the end-to-end story is hard to beat: shared models, shared validation, one language from database to button.
- Native widgets via handlers, so reasonable platform fidelity out of the box.
- First-party Windows and macOS targets, which the JS/Dart options treat as second-class.
- Strong tooling in Visual Studio, mature debugging.

**Weaknesses:**
- Smallest mobile community of the serious options. Outside enterprise, third-party libraries and Stack Overflow answers thin out fast.
- The Xamarin-to-MAUI transition was rocky, and the framework spent its early releases stabilizing; some of that reputation lingers.
- Commitment signals wobble. Microsoft's May 2025 layoffs hit known MAUI team members, the per-major support window is short (see above), and every "is MAUI safe" thread now recommends the same two hedges: Uno Platform and Avalonia, C# frameworks that render their own pixels, Flutter-style. If you're in the .NET lane, evaluate all three, not just the Microsoft-branded one.
- Less of a draw for consumer apps where iteration speed and a deep mobile-specialist hiring pool matter.

**Best for:** enterprise and line-of-business apps inside Microsoft-stack organizations, especially when Windows is a real target. Internal tools, field-service apps, B2B.

**Avoid for:** consumer apps that live or die on polish and where you need to hire mobile specialists quickly -- the talent pool skews backend/.NET, not mobile-native.

## Capacitor and Ionic

**The design.** This is the WebView strategy. Your app is a web app -- React, Vue, Angular, or plain HTML/CSS -- running inside a `WKWebView` (iOS) or Android `WebView`, wrapped in a native shell. Capacitor (the modern successor to Cordova, from the Ionic team) is the bridge: a plugin layer that exposes device APIs (camera, geolocation, filesystem, push) to your JavaScript. Ionic is the optional UI kit that styles your web components to look iOS-ish or Android-ish. Capacitor 8 (December 2025, which made Swift Package Manager the default for new iOS projects) is the current stable line; Capacitor 9, in alpha since May 2026, makes the old Cordova compatibility layer optional. Either way it wraps any web framework, not just Ionic. One ownership note for anyone leaning on the commercial layer: Ionic has been part of OutSystems since 2022, and in February 2025 it discontinued all commercial products, including Appflow, its hosted build-and-OTA service, which runs only through the end of 2027. The open-source framework and Capacitor continue; live-update infrastructure is now yours to self-host or buy from a third party.

The honest framing: this is the cheapest possible reuse of an existing web app and web team, at the cost of the WebView being a glass floor you can't see through. Heavy gestures, complex lists, and frame-perfect animation are the WebView's known weak spots.

**Strengths:**
- Maximum reuse: an existing web app can become a store-listed app in days, sharing essentially all code with the website.
- Web team ships mobile with no new language.
- Capacitor plugins cover the common device APIs cleanly, and writing your own native plugin is straightforward when you need one.

**Weaknesses:**
- It's a WebView. Scroll performance, large lists, and rich gestures hit the ceiling that web-on-mobile has always had.
- "Feels like a web page in an app" is the default outcome unless you invest real effort, and some users notice.
- App Store review occasionally scrutinizes thin web wrappers; you want genuine native capability, not just a bookmarked site.

**Best for:** content apps, internal tools, MVPs, and any product where a web app already exists and "good enough native presence, fast" beats "best-in-class feel." Many marketing-led and content-heavy apps are quietly Capacitor.

**Avoid for:** anything interaction-heavy: games, camera apps, trading apps, social feeds with rich gestures. The WebView floor is real and you'll spend the savings fighting it.

## Same problem, different app: how the choice actually changes

A framework is only good or bad relative to what you're shipping. Here's how the field reshuffles by app type, which is the comparison that actually matters in an architecture review.

### Content and CRUD apps (news, productivity, social feeds, e-commerce)

This is the broad center where every option works and the decision is about team and ecosystem, not capability. The app is screens, lists, forms, and network calls; the boundary is touched rarely.

- **Default winner: React Native + Expo**, because OTA updates and the hiring pool dominate when the app itself isn't technically exotic.
- **Strong alternative: Flutter**, if you want one codebase and a distinctive look without per-platform UI work.
- **If a web app already exists: Capacitor** is the pragmatic fast path.

### Fintech and trading apps (real-time data, charts, security)

Three hard constraints collide: a high-frequency market-data feed, GPU-smooth candlestick charts, and serious security (key storage, signing, anti-tamper). The pattern that wins is **hybrid**: a cross-platform shell over native modules for the hard parts. Be careful with the "every exchange uses React Native" claim, though. Coinbase is the one big exchange that publicly documented a full move to React Native; most others keep their stack private, and the public signals from some (Binance looks native) point the other way. So the lesson is the *architecture*, not a head-count: a cross-platform shell for the routine screens, native for the order book and the keys.

The defining decision is *where the WebSocket firehose lives*. You do not push raw order-book ticks across the JS boundary -- a native module holds the socket and the book, coalesces updates to ~10-30/sec, and hands a compact snapshot to JS. Charts go to the TradingView mobile SDK or a custom Metal/Skia renderer, never pure JS.

- **React Native** for the shell, with native TurboModules for the socket and key management. The documented shape (Coinbase).
- **Fully native + Kotlin Multiplatform** for the shared logic if chart fidelity and latency are the top priority and the team is native-strong. This is the highest-ceiling option.
- **Avoid Capacitor here outright.** A WebView holding a live order book is the wrong tool, and the security story is weaker.

### Camera, media, and AR apps

The app *is* the boundary -- every frame is native capture, native GPU, native ML. Cross-platform UI buys you the settings screens and the gallery, not the viewfinder.

- **Native** for the capture pipeline is non-negotiable; **KMP** to share the non-camera logic if you want cross-platform.
- **Flutter** can host the UI with the camera as a platform view, but you're writing the hard 80% natively regardless.
- **React Native** same story: a native module does the real work.

### Games and heavy real-time graphics

None of the app frameworks above are the answer. This is **Unity**, **Godot**, or a Lua-scripted engine like **Defold** for 2D. The "cross-platform" question has a completely different stack here, and reaching for Flutter or RN means re-implementing a game engine badly.

### Enterprise and internal line-of-business

Talent and backend alignment outweigh polish.

- **.NET MAUI** if the shop is Microsoft-stack and Windows is a target.
- **React Native** if the team is web-leaning.
- **Capacitor** if there's an existing web app and the bar is "functional, not beautiful."

### Apps defined by deep platform integration (widgets, watch, Live Activities, App Intents)

The more an app's value lives in iOS-specific surfaces (home-screen widgets, Live Activities, Siri intents, a watchOS companion), the less a cross-platform UI layer helps, because those surfaces are native-only anyway.

- **KMP** shines: share the data layer, build every native surface natively.
- **Flutter/RN** force you into native modules for each surface, eroding the "one codebase" promise screen by screen.

## The China answer is a different question entirely

Everything above answers one question: "iOS plus Android from one codebase." If you're building for the Chinese market, that's the wrong question, and the global leaderboard barely applies. The platform a Chinese consumer product most needs to ship on isn't iOS or Android. It's WeChat.

WeChat Mini Programs (小程序) are the forcing function. WeChat is at 1.43 billion monthly users (Q1 2026 earnings), and its mini-programs reach roughly 970 million of them monthly (QuestMobile, Q1 2026) across several million mini-programs. Be careful with the daily-active numbers floating around: the big ones (~800 million) count every platform's mini-programs combined, not WeChat's alone. A mini-program installs nothing, lives inside the super-app, and is for a huge class of products (e-commerce, tools, content, O2O) the *primary* distribution channel, with the native app as the secondary surface. Alipay, Douyin (Chinese TikTok), Baidu, and QQ all run their own competing mini-program platforms on top of that.

The June 2026 WeChat update pushed the model further: the new in-app AI assistant can invoke mini-programs directly from a voice or chat command (hail a ride, order food, track a package), with Meituan, Didi, and Ctrip among the first wired in. Mini-programs are becoming the action layer for WeChat's agent, which makes the channel more central, not less.

Here's the catch that reshapes the whole stack: **none of the global frameworks compile to WeChat mini-programs.** React Native, Flutter, MAUI, and Capacitor all target iOS and Android. Mini-programs run a constrained, sandboxed web-like runtime (WXML/WXSS plus JS on a dual-thread model) that you reach only through frameworks built for it. So the valuable "write once" axis in China isn't iOS plus Android. It's *mini-programs plus H5 plus iOS plus Android (plus, increasingly, HarmonyOS)*, and a whole category of China-native frameworks exists to hit it.

**The most popular cross-platform framework in China is uni-app, not React Native or Flutter.** A caveat on that claim: China has no independent market-share survey the way Stack Overflow covers the West (those surveys don't even register uni-app or Taro). The ranking rests on ecosystem scale and consistent practitioner consensus, not a clean percentage. With that said, the gap is not subtle.

### uni-app (DCloud) -- the default

Vue-based. One codebase compiles to WeChat, Alipay, Baidu, Douyin, QQ, and Lark mini-programs, plus H5, iOS, Android, and HarmonyOS NEXT. DCloud's own figures put it around 9 million developers reaching on the order of 1.2 billion monthly active users. For any product whose main entry point is a mini-program, it's the consensus pick: the most mature conditional-compilation and per-platform compatibility handling of the bunch.

The 2025 evolution worth knowing is **uni-app x**, a separate native-compiling track. It uses UTS (a TypeScript dialect that compiles to Kotlin on Android and Swift on iOS) and UVue, so unlike the older WebView-based path there's no JS engine and no WebView at runtime. It compiles to native at build time for near-native performance, and it's DCloud's spearhead for HarmonyOS. That directly answers the old knock on uni-app, that the WebView app path couldn't match Flutter or native on performance.

### Taro (JD) -- the React-flavored alternative

React syntax instead of Vue (it also supports Vue and others). Targets the same spread of mini-programs plus H5 and React Native. It's the natural choice when a team already lives in React rather than Vue. Positioning between the two in Chinese selection guides is consistent: uni-app for the broadest mini-program compatibility at the lowest per-platform cost, Taro when you want the React ecosystem and an RN escape hatch.

### Lynx (ByteDance) -- the new, globally relevant one

This is the China framework with real international buzz, because it's pitched squarely as a React Native challenger. ByteDance open-sourced Lynx in March 2025 after using it inside TikTok and Douyin (search, Studio, Shop, LIVE). The architecture is the interesting part:

- **Dual-threaded**: a UI thread for rendering and high-priority work, a separate background thread for app logic, so the first frame paints almost immediately instead of waiting on the JS layer the way RN's old bridge did.
- **PrimJS**: ByteDance's own JS engine, built on QuickJS, driving the UI thread.
- **Rspeedy**: a Rust-based bundler built on Rspack. That's the "Rust tooling" angle.
- **Framework-agnostic**: it ships ReactLynx, but ByteDance says non-React frameworks already carry roughly half of internal usage, a deliberate contrast to RN's React lock-in, and it uses real CSS.

Be honest about maturity, though. Adoption outside ByteDance is still thin and the third-party library ecosystem is sparse, even as the platform list has grown quickly: HarmonyOS support landed around Lynx 3.4 and desktop macOS/Windows in 3.7, so the old "mobile plus web only" knock no longer holds. It's a watch-closely, not a bet-the-client-project, as of 2026.

### Flutter and React Native in China

Flutter is the strongest *true-native-app* cross-platform framework in China, living alongside the mini-program tools rather than competing with them. Alibaba's Xianyu (闲鱼) was the flagship early adopter and open-sourced influential tooling like FlutterBoost (hybrid native-plus-Flutter routing); Tencent and ByteDance both run Flutter at scale. One myth to retire: the "Xianyu is abandoning Flutter" story is from April 2021, and the team denied it at the time (they stayed "Dart First"). Don't recycle it as current news.

React Native is present but secondary and losing mindshare. Meituan (美团) is the most-documented Chinese RN shop. The trend, though, is teams drifting toward uni-app or Taro for anything mini-program-adjacent and toward Flutter for performance-sensitive native apps, with Lynx now pulling at the RN base from inside ByteDance.

### HarmonyOS makes it a three-OS problem

HarmonyOS NEXT (launched late 2024) dropped Android app compatibility entirely; HarmonyOS 6 shipped in October 2025 (public rollout from late November), 6.1 followed in spring 2026, and Huawei unveiled HarmonyOS 7 with a developer beta at HDC in June 2026. The install base is past the curiosity stage: Huawei's HDC 2026 numbers put HarmonyOS 6 above 66 million devices and the catalog above 400,000 apps and meta-services. Apps must be rebuilt natively in ArkTS/ArkUI. For the Chinese market that quietly turns "cross-platform" into iOS plus Android plus HarmonyOS, a third native target that doesn't exist in the global conversation. The frameworks that already target it (uni-app x, Taro, plus community ports of RN and Flutter) gain a real edge, because the alternative is maintaining a third codebase. Tencent's newer **Kuikly** framework leans into exactly this: it's Kotlin-Multiplatform-based, open-sourced in April 2025, claims one codebase for six targets including HarmonyOS and mini-programs (several still beta), and already runs in QQ, QQ Music, and Tencent News. Tencent's older **Hippy** (Vue/React syntax, native rendering) is the mature workhorse across QQ, Tencent Video, and QQ Music.

### The China picture in one table

| Lane | Frameworks | Why |
|------|-----------|-----|
| **Mini-program first, multi-end** | **uni-app** (#1, Vue), **Taro** (React) | The only ones that compile to WeChat/Alipay/Douyin mini-programs |
| **High-performance native app** | **Flutter** (strongest), RN (older), **Lynx** (ByteDance's 2025 challenger) | True native rendering for app-store apps |
| **Vendor super-app stacks** | Tencent **Hippy** (mature), **Kuikly** (new, KMP, 6-platform incl. HarmonyOS) | Built and used inside the big platforms |

Bottom line for anyone shipping into China: pick the lane before the framework. If mini-programs are a channel, and for most consumer products they are, reach for uni-app (or Taro if you're a React shop). Flutter is the answer for a high-end native app. The global names you'd default to in the West are, at best, half of the China answer.

## How to adopt: the path matters more than the pick

The framework choice gets the attention; the adoption path is what actually determines whether the project succeeds. Two situations, very different playbooks.

### Greenfield (new app, no existing code)

This is the only place "pick one and go all-in" is the right move. Decide on the team axis first:

{% mermaid %}
flowchart TD
    Start["Greenfield mobile app"] --> Team{"What's the team?"}
    Team -->|"Web / JS / TS"| RN["React Native + Expo"]
    Team -->|"Small team, design-led,<br/>want one codebase"| FL["Flutter"]
    Team -->|"Existing native iOS + Android"| K{"Need shared UI too?"}
    Team -->|"Microsoft / .NET shop"| MAUI[".NET MAUI"]
    Team -->|"Existing web app, ship fast"| CAP["Capacitor"]
    K -->|"No, just logic"| KMP["KMP, native UI"]
    K -->|"Yes"| CMP["Compose Multiplatform"]
    RN --> Check{"App type exotic?<br/>(camera, trading, game)"}
    FL --> Check
    Check -->|"Yes"| Hybrid["Plan native modules<br/>from day one"]
    Check -->|"No"| Go["Ship it"]
{% endmermaid %}

The trap to avoid in greenfield: choosing the framework before you've characterized the app's boundary load. If the app is a camera or a trading front-end, write the native module plan *first*, then pick the shell to wrap it. Picking the shell first and discovering the boundary problem in month three is the classic way these projects derail.

### Brownfield (existing native app, want cross-platform)

Do not rewrite. The mature 2026 approach is incremental, and each framework supports a different flavor of it:

- **Kotlin Multiplatform** is the gentlest entry. Extract one module -- say, the networking and model layer -- into shared Kotlin, wire it into both existing native apps, ship. The UI never changes, the risk is contained to one layer, and you can stop or expand based on how it goes. This is why KMP adoption is climbing so steadily: the first step is small and reversible.
- **Flutter** supports add-to-app: embed a single Flutter screen or flow into your existing native app via a `FlutterEngine`. Good for a self-contained new feature (an onboarding flow, a new section) without committing the whole app.
- **React Native** has the same brownfield embedding story (RN was literally born inside the native Facebook app as one screen). Add it for a feature, expand if it earns its place.
- **Capacitor** is all-or-nothing for the UI -- it's a WebView shell -- so brownfield adoption usually means "the web app becomes the mobile app," not "one screen."

A concrete migration shape that works: start with KMP for the logic layer (lowest risk, immediate dedup of business code), and only later decide whether to also share UI via Compose Multiplatform once the team trusts the toolchain. You get value at step one and keep the option to go further.

### Reading the team signal

The honest predictor of success isn't the framework's benchmark numbers, it's whether the framework matches the team you have:

- A React/web team forced onto Flutter will be slow and unhappy for a quarter. The reverse is equally true.
- Two strong, separate native teams handed Flutter will resist it, correctly, because it asks them to throw away their edge. Hand them KMP instead.
- A backend-heavy .NET org will out-ship everyone on MAUI and struggle on anything else.

## The cross-cutting scorecard

| Concern | React Native | Flutter | KMP | MAUI | Capacitor |
|---------|-------------|---------|-----|------|-----------|
| **Learning curve** | Low (if you know React) | Medium (Dart + widgets) | Medium (logic only) / High (CMP) | Low (if you know C#) | Lowest (it's web) |
| **UI consistency across OS** | Good | Best | Native per-platform | Good | Good (it's web) |
| **Native fidelity / new-OS features** | Good | Lags slightly | Perfect | Good | Weak |
| **Raw performance ceiling** | High | Very high | Native | Medium | Low-medium |
| **Boundary cost (native interop)** | Low (New Arch) | Medium (channels) | Minimal (compiled) | Low | Medium |
| **Hiring pool** | Largest | Medium | Growing | .NET-centric | Web-large |
| **OTA updates** | Yes (EAS) | Limited | N/A (native) | No | Yes (self-host / 3rd-party) |
| **Incremental adoption** | Yes (per screen) | Yes (add-to-app) | Yes (per module) | Hard | No (whole UI) |
| **Code sharing scope** | UI + logic | UI + logic | Logic (+ UI via CMP) | UI + logic | UI + logic |
| **Best brownfield story** | Screen embed | Screen embed | **Module extract** | Weak | Whole-app |

## The treadmill: versions, cadence, and support windows (July 2026)

A framework isn't a one-time pick, it's a subscription. Cadence sets how often the upgrade tax comes due, the support window sets how long you can legally stand still, and the steward column is the name to watch for commitment wobbles.

| Framework | Stable (Jul 2026) | Cadence | You can stand still for | Steered by |
|-----------|-------------------|---------|-------------------------|-----------|
| **React Native** | 0.86 | ~every 2 months | Newest 3 minors get fixes (~6 months) | Meta, with Expo + Callstack/Microsoft |
| **Flutter** | 3.44 | Quarterly | Current stable only (hotfixes) | Google; desktop stewarded by Canonical |
| **KMP / CMP** | Kotlin 2.4.0, CMP 1.11 | 2-3 releases/yr each | 18-month security support (new in Kotlin 2.4) | JetBrains + Google |
| **.NET MAUI** | MAUI 10 on .NET 10 | Annual (November) | ~18 months per major; MAUI 10 ends May 2027 | Microsoft |
| **Capacitor** | 8 (9 in alpha) | ~Annual major | Previous major keeps getting fixes ~a year | OutSystems (Ionic team) |

Two readings of that table matter more than the cells. React Native's window looks brutal, but in practice most teams ride Expo SDK releases and the upgrade pain lives there, not in raw RN minors; Expo is even experimenting with making in-between RN releases optional upgrades. And MAUI's row is the outlier: pinned to a three-year LTS runtime yet supported for half that. That asymmetry belongs in the decision, not in a footnote you find in year two.

## What I'd actually reach for

There's no framework that wins outright, but the choices aren't a toss-up either. The decision compresses to a few honest rules:

- **You have a web team and a normal product app:** React Native with Expo. The ecosystem and OTA updates win, and "normal product app" describes most apps.
- **Small team, design-driven, want one codebase and a distinct look:** Flutter. Accept that deep iOS-surface integration will cost you native modules.
- **You already ship two healthy native apps and you're tired of writing the networking layer twice:** Kotlin Multiplatform. Share the engine, keep the native cockpits. Add Compose Multiplatform later if and only if the team wants shared UI too.
- **Microsoft shop with a Windows target:** MAUI, and you'll be glad the backend and the app speak the same language.
- **There's already a web app and you need a store presence next week:** Capacitor, eyes open about the WebView ceiling.
- **It's a game, a pro camera, or a trading front-end:** stop looking at app frameworks. Use a game engine, or go native with KMP-shared logic and a thin hybrid shell.
- **You're shipping into China:** the leaderboard changes. If WeChat mini-programs are a channel (they usually are), reach for uni-app or Taro before any of the global names. The China section above is the real answer.

The mistake that costs the most isn't picking the "wrong" framework from this list. It's picking any of them before you've named what your app does at the native boundary, and before you've looked honestly at the team you're handing it to. Get those two right and most of these frameworks will carry you fine. Get them wrong and the best framework on paper becomes the project you rewrite in eighteen months.
