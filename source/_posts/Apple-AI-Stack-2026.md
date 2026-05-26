---
title: "Apple's AI stack in 2026"
date: 2026-05-25 12:00:00
categories:
- iOS
tags:
- Apple Intelligence
- FoundationModels
- Core ML
- Vision
- Writing Tools
- Genmoji
- MLX
- Private Cloud Compute
- SwiftUI
- on-device
---

A complete map of Apple's AI surface as of May 2026: the design philosophy underneath, the seven layers of framework, the cost model that makes Apple's approach feel different from every other vendor's, and what each piece is actually for when you sit down to ship code.

<!-- more -->

## The position underneath all of it

Apple's AI stack is shaped by one decision, made years before any of the current frameworks shipped: **inference cost belongs to the user's device, not to the developer's credit card**. Every cloud lab in 2026 (OpenAI, Anthropic, Google, xAI, DeepSeek) builds the same way: bigger model, bigger datacenter, the bill goes to the app that calls them, the app passes it on to the user as a subscription or a per-token meter. Apple builds the opposite way: a small model that ships with the OS, runs on the customer's silicon, costs the developer nothing per call, and is therefore allowed to be called freely.

That's not a feature decision. It's the load-bearing constraint that explains everything else.

The 3-billion-parameter on-device model isn't 3B because Apple couldn't have shipped 70B; Apple could ship anything it wants. It's 3B because that's what fits in roughly 1 GB of RAM after 2-bit Quantization-Aware Training (with the embedding table at 4 bits and the KV-cache at 8 bits, plus low-rank adapters to recover quality), leaves room for the rest of the OS to keep running, and stays warm enough that the iPhone doesn't throttle. The figures Apple has published (originally for the WWDC24-era model on iPhone 15 Pro: ~0.6 ms time-to-first-token per prompt token, ~30 tokens/sec) put it firmly in the "feels instant" range; Apple hasn't republished equivalents for the 2025 3B model, but day-to-day latency has improved, not regressed. Once you've made the choice that inference is free, the model has to be small. Once the model is small, knowledge and reasoning go to other places. The whole framework lineup is downstream of that.

What you get in return is a different cost model. You don't budget LLM calls the way you'd budget API tokens. You don't decide whether the feature is "worth a Claude call." You don't put it behind a paywall to amortize OpenAI invoices. You just call the model. The first call has setup cost (asset loading, ~300ms cold), every subsequent call is sub-second, and your monthly bill is zero regardless of how many users you have. The right design instinct is to use the model *more often, in smaller doses*: a summary on every detail-screen open, a classification on every photo import, a structured extraction on every voice memo. The economics encourage you to scatter intelligence across the app rather than concentrate it behind one chat button.

The trade is real. A 3B model doesn't know who won the World Cup last year. It can't write you a working React component. It will not multiply three-digit numbers reliably. You have to design *around* its weaknesses, not despite them, and most of the framework affordances exist to channel its strengths (structured output, classification, summarization, tagging) into the parts of your UI where it can succeed.

The rest of this post is the consequence of that single position, traced through seven layers of framework, three deployment paths, and one architectural escape hatch (Private Cloud Compute) when on-device isn't enough.

## The seven layers, top to bottom

The whole AI stack stratifies cleanly by **abstraction level**. The top layer requires no code at all; the bottom layer is Mac-only research tooling for fine-tuning frontier models. Most apps live in the top three layers; the rest exist to let you escape downward when you need to.

| Layer | Surface | What you write | Where it runs |
|---|---|---|---|
| 1. System Intelligence | Writing Tools, Genmoji, Image Playground | Nothing (`UITextView` gets it for free) | On-device + Private Cloud Compute |
| 2. Foundation Models | `LanguageModelSession`, `@Generable`, `Tool` | A struct + a prompt | On-device 3B LLM |
| 3. ML-powered APIs | Vision, Speech, Natural Language, Translation, Sound | A request + a handler | On-device task models |
| 4. Core ML | `MLModel`, `MLTensor` | A `.mlmodel` file plus the Swift API to invoke it | Auto: CPU / GPU / Neural Engine |
| 5. MPS Graph / BNNS Graph | Custom op graphs | Metal kernels or BNNS nodes | GPU (MPS) or CPU (BNNS) |
| 6. Create ML | Project + dataset, no model architecture work | A `.mlmodel` file you'll ship via Core ML | Trains on Mac, runs on device |
| 7. MLX | Python or Swift API for tensor ops on Apple Silicon | The model itself (training loop, fine-tune, distillation) | Mac (M-series, unified memory) |

Pick a layer by asking one question: *does the abstraction one level up already do what I need?* If yes, you are done. The temptation is always to drop down a layer for "more control"; the right move is usually to stay up.

{% mermaid %}
flowchart TD
    A[I want to add an AI feature]
    A --> B{Text input UI?}
    B -- yes --> B1[Writing Tools / Genmoji<br/>zero code]
    B -- no --> C{Image / camera AI?}
    C -- yes --> C1[Visual Intelligence / Image Playground<br/>zero code]
    C -- no --> D{General LLM task?<br/>summarize, classify, extract, generate}
    D -- yes --> D1[Foundation Models<br/>LanguageModelSession + @Generable]
    D -- no --> E{Task-specific?<br/>OCR, ASR, NER, translation}
    E -- yes --> E1[Vision / Speech /<br/>NaturalLanguage / Translation]
    E -- no --> F{Have your own trained model?}
    F -- yes --> F1[Core ML<br/>via Core ML Tools conversion]
    F -- no --> G{Want to fine-tune a system model?}
    G -- yes --> G1[Create ML]
    G -- no --> H{Want to train / experiment<br/>with frontier-scale LLMs?}
    H -- yes --> H1[MLX on Mac]
    H -- no --> I[Reconsider whether<br/>you need ML at all]
{% endmermaid %}

The decision tree is *not* "pick the most powerful tool." It's "pick the highest-abstraction tool that fits." A `UITextView` that supports Writing Tools without a line of code from you is a better engineering outcome than a custom Foundation Models pipeline that does the same thing more clumsily.

---

## Layer 1: System Intelligence, the layer you don't write

The most consequential AI feature in iOS 26 is the one you don't ship. Drop a `UITextView` or SwiftUI `TextEditor` into your app, and the user gets Writing Tools (proofread, rewrite, summarize, transform to bullets / table / key points) for free. They get Genmoji in any text view that accepts inline images. They get Image Playground integration wherever you accept image input. They get Visual Intelligence on the screenshot button. None of this is code you write. It's code Apple writes inside the standard text and image controls, and that you inherit by using those controls.

This is the layer that proves the philosophy. The most successful AI feature, by surface area shipped to users, was *the absence of a new API*. Apple put the model behind the UI controls developers already use, and the feature shipped to every existing app overnight.

### What it includes

| Feature | Surface | OS minimum | Customization |
|---|---|---|---|
| **Writing Tools** | Any `UITextView` / `NSTextView` / `WKWebView` / SwiftUI `TextEditor` | iOS 18 | `.writingToolsBehavior`, `writingToolsIgnoredRangesIn`, delegate hooks |
| **Genmoji** | Any text view with `supportsAdaptiveImageGlyph = true` | iOS 18 | Round-trips via RTFD; HTML emits `apple-adaptive-glyph` with PNG fallback |
| **Image Playground** | Inline via `ImagePlaygroundSheet`, Messages, Freeform, dedicated app | iOS 18 (Animation / Illustration / Sketch); iOS 26 adds ChatGPT-backed styles including "Any Style" free-form text-prompted images | None for default UI; programmatic via `ImagePlaygroundConcept`. ChatGPT styles require a ChatGPT subscription for heavy use |
| **Visual Intelligence** | Screenshot button → "Search" / "Ask" / app-deep-link | iOS 26 | App Intents schema declares what your app can answer with |
| **Live Translation** | Messages, FaceTime captions, third-party VoIP via `Translation.framework` | iOS 18 (text) / iOS 26 (audio captions) | `TranslationSession`, batch API |

### The customization surface for Writing Tools

You almost never need to customize. When you do, the surface is three knobs:

```swift
// 1. Behavior: opt out entirely, panel only, or default
textView.writingToolsBehavior = .none      // hide it
textView.writingToolsBehavior = .limited   // panel-only, no inline rewrite
textView.writingToolsBehavior = .complete  // default

// 2. Allowed input formats (default = .plainText)
textView.writingToolsAllowedInputOptions = [.plainText, .richText, .table]

// 3. Pause work during a session
extension MyVC: UITextViewDelegate {
    func textViewWritingToolsWillBegin(_ textView: UITextView) {
        iCloudSync.pause()                  // don't sync every intermediate edit
    }

    func textViewWritingToolsDidEnd(_ textView: UITextView) {
        iCloudSync.resume()
    }

    // protect ranges from rewriting (code blocks, quotes, formulas)
    func textView(_ textView: UITextView,
                  writingToolsIgnoredRangesIn enclosingRange: NSRange) -> [NSRange] {
        return rangesOfCodeBlocks(in: textView.textStorage,
                                  within: enclosingRange)
    }
}
```

`WKWebView` automatically ignores `<blockquote>` and `<pre>` for you; the delegate hook above is the UITextView equivalent.

### Genmoji and the `NSAdaptiveImageGlyph` problem

Genmoji aren't Unicode. They're bitmap glyphs (`NSAdaptiveImageGlyph`, a `Data` payload plus alignment metrics and a content description). Storing them is a question your app has to answer:

```swift
// 1. Storage as attributed string round-tripped through RTFD
let rtfd = try textView.textStorage.data(
    from: NSRange(0..<textView.textStorage.length),
    documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd]
)
// store rtfd Data as a Binary attribute in Core Data

// 2. Decomposed storage (string + ranges + image dictionary), keeps text searchable
func decompose(_ attr: NSAttributedString)
    -> (text: String, ranges: [(NSRange, String)], images: [String: Data]) {
    var ranges: [(NSRange, String)] = []
    var images: [String: Data] = [:]
    attr.enumerateAttribute(.adaptiveImageGlyph,
                            in: NSRange(0..<attr.length)) { value, range, _ in
        guard let glyph = value as? NSAdaptiveImageGlyph else { return }
        let id = glyph.contentIdentifier   // stable, dedupes naturally
        ranges.append((range, id))
        if images[id] == nil { images[id] = glyph.imageContent }
    }
    return (attr.string, ranges, images)
}
```

`contentDescription` is the accessibility fallback (and the plain-text export). The RTFD round-trip "just works"; the decomposed form is for apps that want plain-text search or web export.

### Visual Intelligence: the App Intents handshake

This one is genuinely new in iOS 26. Press the screenshot button, drag a region, get a system-wide visual search panel that can deep-link into your app. The handshake is App Intents:

```swift
import AppIntents

// Your app's domain entity, returned to Visual Intelligence as a search result
struct Plant: AppEntity {
    let id: String
    let commonName: String
    let scientificName: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Plant"
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(commonName)", subtitle: "\(scientificName)")
    }
    static let defaultQuery = PlantQuery()
}

// The query Visual Intelligence calls into with the user's selected image
struct PlantVisualSearchQuery: IntentValueQuery {
    func values(for descriptor: SemanticContentDescriptor) async throws -> [Plant] {
        // descriptor.labels: detected category tags from Apple's vision pipeline
        //   (e.g. "houseplant", "succulent", "leaf")
        // descriptor.pixelBuffer: the visual content as a CVReadOnlyPixelBuffer
        //   if you want to run your own classifier
        return try await PlantCatalog.shared.match(
            labels: descriptor.labels,
            image: descriptor.pixelBuffer
        )
    }
}
```

The user takes a screenshot of a plant in someone else's Instagram, hits the visual-search button, picks Plantfolio from the result panel, and lands on the matching plant detail screen. The system has already done one round of visual analysis (`descriptor.labels`) using Apple's own vision pipeline; your code refines that against your catalog. You can optionally run your own classifier on `descriptor.pixelBuffer` if your data warrants it. Your code never owns the camera UI, never owns the result panel, never has to ship the generic plant classifier. You ship the `IntentValueQuery` and the `AppEntity`. The system does the rest.

---

## Layer 2: Foundation Models, the on-device LLM finally available

This is the headline. iOS 26 ships a 3-billion-parameter LLM as part of the OS, and `import FoundationModels` is how third parties get to call it. No API key. No bundle weight. No per-call fee. The same model that powers Writing Tools and Genmoji is the one you can address directly from Swift.

The ergonomic surface area is unusually small for an LLM API. Three call shapes, one macro, one protocol.

### The three-line minimum

```swift
import FoundationModels

let session = LanguageModelSession()
let response = try await session.respond(to: "Name a good trip to Japan.")
print(response.content)   // "Kyoto in autumn: the temple gardens are at peak ..."
```

That's a complete program. The model is already loaded. There's no warm-up step required for the basic case (though `prewarm()` exists when you want to). There's no streaming setup, no tool registration, no instructions. It just answers.

### Guided generation, the feature that replaces JSON parsing

Most LLM API code in 2024-2025 was JSON-prompt-engineering: tell the model "respond as JSON with these fields," parse the string, catch the time it drops a comma, retry with a corrective prompt, ship. Foundation Models replaces all of that with a Swift macro:

```swift
@Generable
struct Itinerary {
    @Guide(description: "A catchy, concise title under 10 words")
    var title: String

    var description: String

    @Guide(.count(3))
    var dayPlans: [DayPlan]

    @Guide(.anyOf(["adventure", "relaxation", "cultural"]))
    var tripType: String
}

@Generable
struct DayPlan {
    var date: String
    @Guide(.maximumCount(5))
    var activities: [String]
}

let session = LanguageModelSession()
let response = try await session.respond(
    to: "Plan a 3-day trip to Kyoto.",
    generating: Itinerary.self
)
let itinerary: Itinerary = response.content   // typed, guaranteed shape
```

The framework constrains the model at the decoding step. The model literally cannot emit output that doesn't match the schema. `dayPlans` will have exactly 3 entries because `.count(3)` is a hard constraint, not a hint. `tripType` will be one of the three values in `.anyOf`. No retry loop, no try-catch around `JSONDecoder`, no "model dropped a comma" bugs.

The `@Generable` macro also synthesizes a `PartiallyGenerated<T>` companion type with every property optional, used for streaming.

### Streaming with the consolidate-pattern

```swift
@Observable
final class ItineraryPlanner {
    var itinerary: Itinerary?
    private let session: LanguageModelSession

    init() { session = LanguageModelSession() }

    func generate() async throws {
        let stream = session.streamResponse(
            to: "Plan a 3-day Kyoto trip.",
            generating: Itinerary.self
        )
        for try await partial in stream {
            self.itinerary = consolidate(partial)   // carry forward previous values
        }
    }

    // critical pattern: nil incoming values should NOT erase prior render
    private func consolidate(_ p: Itinerary.PartiallyGenerated) -> Itinerary {
        Itinerary(
            title:       p.title       ?? itinerary?.title       ?? "",
            description: p.description ?? itinerary?.description ?? "",
            dayPlans:    p.dayPlans    ?? itinerary?.dayPlans    ?? [],
            tripType:    p.tripType    ?? itinerary?.tripType    ?? "adventure"
        )
    }
}
```

The consolidate-pattern is the one piece of streaming UI code you have to write right. The `PartiallyGenerated` snapshot's properties are all `Optional`; an incoming `nil` means "this property hasn't been produced in this chunk yet," not "this property is empty." If you blindly assign `partial.title` to your state, every chunk that doesn't include the title erases it. You carry forward the previous snapshot's value for any nil, and only the *non-nil* incoming values overwrite.

A useful corollary: **property order in `@Generable` structs determines streaming order**. Declare quick-resolving fields first (id, name, summary), large arrays and long bodies last. The UI fills in roughly in property order, so a well-ordered struct gives you a polished "header populates instantly, list streams in below" effect for free.

### Tool calling: the model is the orchestrator

Tool calling reverses the usual control flow. You don't write `if user_wants_weather: call_weather()`. You register a `Tool` with the session, and the model decides when (and whether) to call it.

```swift
import WeatherKit
import CoreLocation

struct GetWeatherTool: Tool {
    let name = "getWeather"
    let description = "Retrieve the current weather for a city."

    @Generable
    struct Arguments {
        @Guide(description: "City name")
        var city: String
    }

    func call(arguments: Arguments) async throws -> ToolOutput {
        let place = try await CLGeocoder()
            .geocodeAddressString(arguments.city)
            .first!
            .location!
        let weather = try await WeatherService.shared.weather(for: place)
        let tempF = weather.currentWeather.temperature
            .converted(to: .fahrenheit)
            .value
        return ToolOutput(GeneratedContent(properties: ["temperatureF": tempF]))
    }
}

let session = LanguageModelSession(
    tools: [GetWeatherTool()],
    instructions: "Help the user with weather forecasts."
)

let r = try await session.respond(to: "What's the temperature in Cupertino?")
print(r.content)   // "It's 71°F in Cupertino right now."
```

What happens in that single `respond(to:)` call: the model parses the user prompt, decides the question requires the weather tool, generates `Arguments(city: "Cupertino")`, the framework invokes `call(arguments:)`, the result is fed back into the model, the model composes the natural-language reply. All of that in one call. You wrote a Swift function and a description; the model handled orchestration.

A few non-obvious rules that fall out of the design:

- **Tool calls can run in parallel.** If the model needs weather *and* a calendar lookup, it can issue both tools at once. Make `call(arguments:)` thread-safe. If it hits a shared resource (your Core Data stack, a file handle), wrap with an actor or a serial queue. Repository singletons that already serialize their writes are fine; ad hoc shared state isn't.
- **Tools should be cheap and idempotent.** The model may call the same tool multiple times in one response (`tool → reason → tool again`). Don't assume one call per turn.
- **Validate inputs inside `call(arguments:)`.** The model can hallucinate argument values. The `@Generable Arguments` macro constrains the shape; it doesn't constrain semantics. `city: "Cupertino"` is a valid string and an invalid CLGeocoder query, both. Your code is the one that finds out.
- **Stateful tools are classes; stateless tools are structs.** A `struct` `Tool` resets per call. A `final class Tool` retains state for the session lifetime, which is what you want for things like "don't suggest the same NPC twice" or "remember which contacts we've already looked up."

### Availability gating: the part you cannot skip

Apple Intelligence is not available everywhere. Mainland China still doesn't have it for users as of May 2026: Apple accidentally rolled it out in late March 2026, the Chinese government hadn't authorized the release, and the features were pulled almost immediately. Apple and Alibaba have submitted the co-developed Qwen-backed integration for regulatory approval and are waiting. Older devices don't have it at all (iPhone 15 Pro / Pro Max and all iPhone 16 models; iPad mini A17 Pro and M1+ iPads; M1+ Macs). Apple Watch is a partial story: Series 6 and later paired with a supported iPhone gets the *relayed* features (handoff to the phone's model), but on-watch AI features (Live Translation on-wrist, etc.) require Series 9, Series 10, or Ultra 2. Users can opt out in Settings. Some locales are supported by the system model but not all of Apple Intelligence; some are supported for English input but not the user's chosen UI language.

The framework surfaces every one of these conditions through a single property:

```swift
struct AIBadge: View {
    var body: some View {
        switch SystemLanguageModel.default.availability {
        case .available:
            Label("AI on", systemImage: "sparkles")
        case .unavailable(.deviceNotEligible):
            EmptyView()                          // hardware too old, hide entirely
        case .unavailable(.appleIntelligenceNotEnabled):
            Label("Enable Apple Intelligence in Settings", systemImage: "gear")
        case .unavailable(.modelNotReady):
            ProgressView("Model loading…")       // first run, model downloading
        case .unavailable(let reason):
            Label("AI unavailable: \(reason)", systemImage: "sparkles.slash")
                .foregroundStyle(.secondary)
        }
    }
}
```

The wrong pattern is "AI is unavailable, so hide the whole feature and pretend it never existed." The right pattern is the graceful fallback: show the non-AI version of the screen, the way the screen worked before AI shipped. The note still saves; the auto-generated title above it falls back to the first line. The inbox still lists every message; the smart-reply chips are just absent. AI is an enhancement, not a precondition.

For testing, Xcode's scheme editor has a Foundation Models Availability Override (Run → Scheme → Options → Foundation Models Availability) that simulates each `.unavailable(reason)` without owning a non-AI device.

### Language support is its own gate

```swift
let supported = SystemLanguageModel.default.supportedLanguages
guard supported.contains(Locale.current.language) else {
    showLanguageNotSupportedFallback()
    return
}
```

iOS 26.1 (November 2025) ships Foundation Models in **16 languages** (English, Danish, Dutch, French, German, Italian, Norwegian, Portuguese, Spanish, Swedish, Turkish, Chinese Simplified, Chinese Traditional, Japanese, Korean, Vietnamese), spread across **23 locales** when you count regional variants (en-US vs en-GB, pt-PT vs pt-BR, etc.). If your user is on a locale outside the list, `.unsupportedLanguageOrLocale` is the error you'll see at the `respond(to:)` site, but pre-checking `supportedLanguages` lets you avoid showing a button that's going to fail.

### The context window, which is smaller than you'd guess

The on-device model has a **4096-token context window**. That number didn't change with iOS 26.1, won't change with 26.2 or 26.4, and is what you design around. As of iOS 26.4, `SystemLanguageModel.default.contextSize` (returns the available budget) and `tokenCount(for:)` (measures a string) let you size requests dynamically; before 26.4 you hardcoded the limit.

What spends tokens, in order of how easy it is to forget:

| Source | Counts toward 4096 |
|---|---|
| `instructions:` | Yes, every turn |
| User prompt | Yes |
| Schema description for `@Generable` (when not suppressed) | Yes |
| Previous turns in the same session's transcript | Yes |
| Tool definitions (name, description, argument schema) | Yes, every turn the tool is registered |
| Tool outputs | Yes |
| Model's own previous responses in the transcript | Yes |

A long instructions block plus a chatty multi-turn session plus three registered tools can spend half your window before the user has typed a word. When you hit `.exceededContextWindowSize`, the recovery is to build a new session with a *condensed* transcript:

```swift
func newSession(from previous: LanguageModelSession) -> LanguageModelSession {
    let entries = previous.transcript.entries
    var condensed = [Transcript.Entry]()
    if let first = entries.first { condensed.append(first) }   // keep instructions
    if entries.count > 1, let last = entries.last { condensed.append(last) }
    return LanguageModelSession(transcript: Transcript(entries: condensed))
}
```

You can also skip the schema in the prompt with `.includeSchemaInPrompt(false)` when (a) it's a follow-up on the same session (the model already saw the schema once) or (b) your `instructions:` already includes a concrete example struct. Each is worth a few hundred tokens on a non-trivial type.

### What it cannot do

The hardest-earned rules for FoundationModels come from the things it's *not*:

- **Not a code generator.** Don't ask it to write a Vue component or refactor a Python module. The 3B model is too small to track long-range syntactic context. Use the cloud labs (or, for Apple-platform coding assistance, Xcode 26's built-in ChatGPT / Claude / local-model integration which is a separate layer entirely).
- **Not a knowledge oracle.** Don't ask "who won the World Series" or "what's the capital of South Sudan." The training cutoff is fixed at ship and the model can hallucinate confidently. Use tool calling to fetch facts from authoritative sources; never trust the model's recall.
- **Not a multi-step reasoner.** Chain-of-thought-style problems (long arithmetic, multi-hop logic, planning across many constraints) are weak. Either decompose into smaller per-step calls, or use a Private Cloud Compute path, or punt to a cloud model. The on-device model is for *understanding and shaping text*, not for reasoning over it.
- **Not for high-stakes decisions.** Always show outputs as suggestions, not facts. Bake "review before saving" into any UI that surfaces model output as something the user will act on.

### Use the specialized adapters when they fit

For narrow tasks Apple ships pre-tuned adapters that are smaller and faster than the general model:

```swift
@Generable
struct ActionsAndEmotions {
    @Guide(.maximumCount(3)) var actions: [String]
    @Guide(.maximumCount(3)) var emotions: [String]
}

let session = LanguageModelSession(
    model: SystemLanguageModel(useCase: .contentTagging),
    instructions: "Tag the most important actions and emotions."
)

let r = try await session.respond(
    to: largeUserText,
    generating: ActionsAndEmotions.self
)
```

`useCase: .contentTagging` is the public adapter as of iOS 26. More adapters are expected in subsequent releases. The pattern is: if your task is "extract structured tags or labels from text," reach for the content-tagging adapter instead of the general model. It's the same API surface; the model under the hood is smaller and tuned for the task.

### Performance: what to know before the first ship

- **Cold start (asset load) is the dominant first-call latency.** ~300-500ms on iPhone 15 Pro for the first inference of an app session. Subsequent inferences are sub-second.
- **`prewarm()` collapses the first-call cliff.** Call it after a user gesture that indicates intent (button hover, sheet about to present, screen-tap that leads to a generation). Don't `prewarm()` at app launch; the cost is real and the cache won't survive long.
- **The Instruments AI template** ships its own track: Asset Loading, Inference, Tool Calling, Token Counts. First-call latency is almost always Asset Loading, not the inference itself. The fix is `prewarm()`, not "make the prompt shorter."
- **`.greedy` sampling makes outputs deterministic** for a given OS version, which is what you want for snapshot tests and "the same plant gets the same caption" UX. Default is random sampling; deterministic is opt-in via `GenerationOptions(sampling: .greedy)`.

### One more architectural rule

Don't call the model from inside a list cell's `body`. Every recompose triggers a generate. Hoist the call to an `@Observable` view-model on the parent, generate once, pass the result down.

---

## Layer 3: ML-powered domain APIs, the task-specific layer

Foundation Models is the right tool for general LLM tasks. For *task-specific* AI (OCR, ASR, named entity recognition, translation, audio classification), Apple ships dedicated frameworks that pre-date the Foundation Models reveal by years, and they're still the right answer. The model behind each is smaller, faster, and more accurate for its task than what you'd get prompting an LLM to do the same job.

| Framework | What it does | The signature API in iOS 26 |
|---|---|---|
| **Vision** | Faces, text, barcodes, body pose, hand pose, document layout (new), aesthetics score, lens smudge detection (new) | `RecognizeDocumentsRequest`, `DetectLensSmudgeRequest` (Swift-only, no `VN` prefix) |
| **Speech** | Speech-to-text | `SpeechAnalyzer` (new, long-form / noisy); `SFSpeechRecognizer` for short dictation |
| **NaturalLanguage** | Language ID, NER, POS tagging, sentence/word tokenization, custom word taggers (via Create ML) | `NLTagger`, `NLLanguageRecognizer` |
| **Translation** | On-device multilingual text translation | `TranslationSession`, batch API |
| **Sound Analysis** | Audio category classification (sirens, alarms, baby cries, music) | `SNClassifySoundRequest` |

### Vision's new document recognition

`RecognizeDocumentsRequest` is iOS 26's biggest Vision upgrade. It's structured, not text-only, and it's part of the new Swift-only Vision API surface (no `VN` prefix; the legacy `VN*` types still exist alongside it):

```swift
import Vision

let request = RecognizeDocumentsRequest()
let observations = try await request.perform(on: pageURL)

guard let document = observations.first else { return }
for paragraph in document.paragraphs {
    for line in paragraph.lines {
        print(line.text, "at", line.boundingBox)
    }
}
for table in document.tables {
    for row in table.rows {
        let cells = row.cells.map(\.text)
        print(cells.joined(separator: " | "))
    }
}
```

The pre-2026 way (`VNRecognizeTextRequest`) gave you a list of text lines and bounding boxes. You then had to write the layout-reconstruction logic yourself, which is the hard part. The new request gives you paragraphs, columns, tables, and reading order out of the box. Anyone shipping receipt-scanning or document-import features should already be migrating.

### SpeechAnalyzer for long-form audio

```swift
import Speech

let analyzer = SpeechAnalyzer()
let buffer = loadAudioBuffer(from: meetingURL)
try await analyzer.process(buffer)
let transcript = analyzer.transcript
```

The legacy `SFSpeechRecognizer` is still around for short-form dictation, but for anything longer than ~60 seconds (lectures, voice memos, podcast notes, meeting recordings), `SpeechAnalyzer` is the right call. Same engine that powers iOS 26's call transcription and FaceTime live captions, exposed as a public API. Noisy and distant audio handle dramatically better.

### Translation as a framework, not an API call

The Translation framework is the answer to "I want to translate user content without shipping my own translation pipeline." It bundles on-device translation models for the supported language pairs, with optional fallback to Apple's cloud (you don't need to ship any keys). The translation sheet (`.translationPresentation`) shipped back in iOS 17.4; iOS 18 added the programmatic `TranslationSession` / batch API for bulk operations:

```swift
import Translation

struct PlantNotesView: View {
    @State private var translation: TranslationSession.Configuration?
    let note: String

    var body: some View {
        VStack {
            Text(note)
            Button("Translate") {
                translation = .init(target: Locale.Language(identifier: "ja"))
            }
        }
        .translationPresentation(isPresented: .constant(translation != nil),
                                  text: note,
                                  source: nil,
                                  target: .init(identifier: "ja"))
    }
}
```

The framework handles language detection, on-device fallback, model download (with a system-managed UX), and per-pair quality. You don't budget translation calls the way you'd budget Google Translate API charges. You translate when you want to.

---

## Layer 4: Core ML, the layer for your own models

Core ML is where you go when none of the higher layers know how to do the thing you need. Pre-trained model from PyTorch / TensorFlow / JAX, convert to `.mlmodel` via Core ML Tools, ship in your bundle, load via Swift API. The runtime auto-routes ops across CPU / GPU / Neural Engine. You don't pin manually; the system decides.

```swift
import CoreML

let config = MLModelConfiguration()
config.computeUnits = .all   // CPU + GPU + Neural Engine; default

let model = try MyClassifier(configuration: config)
let prediction = try model.prediction(input: input)
print(prediction.label, prediction.labelProbability)
```

Xcode 26 ships a model architecture visualizer (the graph view) and a performance inspector (per-op latency, placement on CPU vs GPU vs ANE). Both replace the old "build it, measure it on device, hope" loop with something you can use during model development.

The cross-cutting decision: **Core ML for inference on shipped apps; everything else (MPS Graph, BNNS Graph, MLX) is for cases Core ML cannot serve well**.

| You need | Core ML | MPS Graph | BNNS Graph | MLX |
|---|---|---|---|---|
| Shipping inference of a fixed model | ✓ | | | |
| Combining ML ops with Metal rendering in one pass | | ✓ | | |
| Real-time CPU inference (audio, strict latency) | | | ✓ | |
| Fine-tuning frontier-scale LLMs on a Mac | | | | ✓ |
| Research on Apple Silicon with unified memory | | | | ✓ |

`MLTensor` (the iOS 18+ tensor type) is the right surface for ML inputs and outputs in Swift code; the old `MLMultiArray` is alive but feels dated by comparison. KV-cache management for sequence models, multi-function model files (one bundle, several inference paths), and quantization-aware loading are all built in.

---

## Layer 5: MPS Graph and BNNS Graph, the GPU and CPU primitives

When Core ML's automatic routing isn't enough (typically because you want to interleave ML with custom rendering, or because latency requirements rule out the ANE round-trip), you drop one layer further. **MPS Graph** for GPU work; **BNNS Graph** for CPU work.

The everyday app doesn't go here. The cases that do:

- **Audio synthesis with neural effects**: `BNNS Graph` because the audio thread cannot tolerate the variable latency of the Neural Engine.
- **Neural rendering**: `MPS Graph` because you want the inference output to feed straight into a Metal shader without copying buffers across compute boundaries.
- **Custom op fusion**: both, when you have a specific computation graph and Core ML's general-purpose scheduler isn't getting you the throughput you need.

iOS 26 ships `BNNSGraphBuilder` (build CPU op graphs with a builder pattern instead of constructing each op manually) and Metal 4's neural rendering support (run inference inside Metal shaders). Neither layer is something a typical app reaches; both are essential if you're the small number of apps that need them.

---

## Layer 6: Create ML, the system-models-plus-your-data layer

Create ML is "fine-tune a system model with your dataset, ship the result as a Core ML model." It's a Mac app, not a Swift API. You bring training data; it produces an `.mlmodel`.

| Template | What it gives you |
|---|---|
| Image classification | A Vision-compatible image classifier |
| Object detection | A Vision-compatible object detector |
| Style transfer | A Core ML image style-transfer model |
| Sound classification | A Sound Analysis-compatible audio classifier |
| Word tagger | A custom NLTagger for entity recognition in your domain |
| Time series | Forecasting + classification (new in 2024) |
| Object tracking (visionOS) | A 6DoF object tracker for AR scenes |

The trade-off: Create ML constrains the architecture; you don't get to design the network. In exchange, you don't need to know what a residual block is. The output ships through Core ML, so the deployment path is unchanged from any other Core ML model.

It's the right tool for "the system Vision classifier knows about plants but not specifically *my* user's photo style," "the default NLTagger doesn't recognize species names," "I want a custom audio classifier for bird calls." It's the wrong tool for "I want to train a transformer from scratch"; that's MLX.

---

## Layer 7: MLX, the research layer

MLX is the Apple Silicon equivalent of PyTorch or JAX. Built around unified memory (no `.to(device)` calls; tensors live everywhere the CPU and GPU can see them), distributed across multiple M-series Macs, Python-first with Swift / C++ / Rust bindings. It's not for shipping mobile inference; it's for *training and fine-tuning models on a Mac*.

Three workflows, in roughly increasing investment:

```bash
# 1. Run a community-quantized model from Hugging Face
mlx_lm.generate --model "mlx-community/Mistral-7B-Instruct-v0.3-4bit" \
                --prompt "Write a quicksort in Swift"

# 2. Quantize a HuggingFace model yourself, mixed precision
python -c "
from mlx_lm.convert import convert
def mixed(layer_path, layer, model_config):
    if 'lm_head' in layer_path or 'embed_tokens' in layer_path:
        return {'bits': 6, 'group_size': 64}
    return {'bits': 4, 'group_size': 64} if hasattr(layer, 'to_quantized') else False
convert('mistralai/Mistral-7B-Instruct-v0.3', './local-mistral-mixed', True, mixed)
"

# 3. LoRA fine-tune on your data, then fuse adapters back into the base
mlx_lm.lora --model "mlx-community/Mistral-7B-Instruct-v0.3-4bit" \
            --train --data ./my-data --iters 300 --batch-size 16
mlx_lm.fuse --model "./local-mistral" --adapter-path "adapters" \
            --save-path "fused-mistral"
```

The Swift surface (`MLXLMCommon`, `MLXLLM`) exists but is research-oriented. Memory budgets are real (a 7B 4-bit model is ~3.5 GB resident; an iPhone won't ship it without grief). The realistic target hardware is M-series Mac with 16 GB+ unified memory; M4 iPads and 8GB+ iPhones can technically run smaller models, but it's not where the framework wants to live.

**Don't ship third-party LLMs in iOS apps.** App Store policy on model size, energy, and consistency makes it impractical, and Foundation Models is the answer for shipped on-device LLM features anyway. MLX is for:

- Prompt iteration on a Mac before committing to FoundationModels `instructions:` (faster than the simulator round-trip)
- Running larger reference models locally to *compare against* FoundationModels output quality
- Internal Mac tools that don't have App Store constraints
- Workspace experimentation that may inform future product direction

---

## Private Cloud Compute: the escape hatch

The 4096-token context, the 3B-parameter size, the "not for code or reasoning" constraints: these are all on-device limits. Apple's answer to "what if the request actually needs a larger model" is **Private Cloud Compute**, an Apple-Silicon-based cloud architecture designed to keep the privacy model intact across the device-to-server boundary.

The mechanism, in a one-screen summary:

1. **The device decides whether to escalate.** Writing Tools, Image Playground, and Siri all have heuristics for "this request needs a bigger model." Foundation Models does *not* automatically escalate; PCC is invoked by Apple's own surfaces, not by your `LanguageModelSession`.
2. **Request payload is end-to-end encrypted to a specific node.** The device chooses an attested PCC node, encrypts the payload to that node's key, and routes through a privacy relay that hides the user's IP from Apple.
3. **The node runs Apple's hardened OS.** No interactive shell, no persistent storage of user data, no admin override, no log retention for content.
4. **The transcript and the result are signed and returned.** The node has no way to associate the request with the user (the relay handles that part) and no way to keep the data after the response is sent.
5. **The code running on every PCC node is publicly auditable.** Apple publishes the build (firmware + OS + the AI stack) in an append-only transparency log; researchers can verify what was deployed and run the same images themselves.

The architecture solves four threats: a compromised individual node can't target a user (because of the relay), a compromised employee can't see content (no privileged access), a compromised admin tool can't read traffic (statelessness + attestation), and a future code change can't silently weaken privacy (the transparency log makes any deviation observable).

The developer-facing affordance is limited. Writing Tools may invoke PCC for the "rewrite in a more professional tone" rewrite when on-device falls short, but your app doesn't choose. Foundation Models stays on-device. The only direct PCC-aware surface for third parties as of May 2026 is **Apple Intelligence with ChatGPT integration**, where requests the user approves can be routed to OpenAI's servers (a separate trust boundary from PCC, with explicit user consent). For the cases where you actually want a larger model under your own control, the answer remains "call a cloud lab from your backend," with all the usual cost and privacy implications.

---

## How the pieces fit together for a real feature

Take a feature you might actually ship: *"Summarize this week's pet care log."* Three lines of UI, model output. Which layers do you reach for?

```
Input:   [SymptomLog] from Core Data, 30-50 entries, ~3000 words
Output:  3 bullet points highlighting concerns + 1 sentence on overall trend
Surface: Detail screen, top of the screen, refreshes when log updates
Constraint: must work offline, must not cost per call, must be private
```

The shape of the answer:

```swift
import FoundationModels

@Generable
struct WeeklyDigest {
    @Guide(.count(3))
    @Guide(description: "Specific concerns from the week, each one sentence")
    var concerns: [String]

    @Guide(description: "One-sentence overall trend assessment")
    var trend: String
}

@MainActor
@Observable
final class WeeklyDigestViewModel {
    var digest: WeeklyDigest?
    var availability: SystemLanguageModel.Availability = .checking
    private var session: LanguageModelSession?

    func load(for pet: Pet) async {
        availability = SystemLanguageModel.default.availability
        guard case .available = availability else { return }

        let logs = pet.symptomLogs(within: .lastWeek)
        let session = LanguageModelSession(instructions: {
            "You are a veterinary care assistant."
            "Highlight notable patterns from this pet's care log."
            "Use plain, non-alarmist language."
        })
        self.session = session
        try? await session.prewarm()

        let prompt = logs.map { "\($0.date): \($0.notes)" }.joined(separator: "\n")
        do {
            let response = try await session.respond(
                to: prompt,
                generating: WeeklyDigest.self,
                options: GenerationOptions(sampling: .greedy)   // same week → same digest
            )
            digest = response.content
        } catch LanguageModelSession.Error.guardrailViolation {
            // surface as "summary unavailable for this content"
            digest = nil
        } catch {
            digest = nil
        }
    }
}
```

In view code:

```swift
struct PetDetailView: View {
    @State private var vm = WeeklyDigestViewModel()
    let pet: Pet

    var body: some View {
        VStack {
            switch vm.availability {
            case .available:
                if let d = vm.digest {
                    DigestCard(digest: d)
                } else {
                    ProgressView()
                }
            case .unavailable:
                EmptyView()                  // fall back gracefully
            case .checking:
                ProgressView()
            }

            SymptomLogList(pet: pet)
        }
        .task { await vm.load(for: pet) }
    }
}
```

What the layers gave us:

- **Layer 2 (Foundation Models)** does the actual work. Guided generation gives us a typed `WeeklyDigest` with no JSON parsing. `.greedy` sampling makes the digest stable across reloads of the same week (the user doesn't see the bullets reshuffle every time they tap into the screen).
- **Layer 1 (System Intelligence)** is implicit: the `SymptomLogList`'s underlying `UITextView` notes editor gets Writing Tools, Genmoji, and Visual Intelligence for free.
- **Availability gating** keeps the feature out of users' faces when AI isn't available; the rest of the screen still works.

What we didn't have to do:

- Train a model
- Pay for a model
- Ship a model
- Parse JSON
- Retry on bad output
- Wait for a network round-trip
- Handle authentication
- Manage API keys

The whole thing is ~50 lines of Swift, runs entirely on the user's device, and costs us nothing per call.

---

## State of the union: where Apple sits, May 2026

The strategic position is now coherent in a way it wasn't even nine months ago.

### What Apple has

- **A 3B on-device model** in every iPhone 15 Pro and later, every M1+ iPad and Mac. Free for users, free for developers, private by design.
- **A framework that makes the model addressable from Swift** with the smallest API surface of any major LLM SDK (one session type, one macro, one tool protocol).
- **System Intelligence features that ship to every app** that uses standard text and image controls, with no developer code.
- **Private Cloud Compute** for cases where on-device falls short, with verifiable transparency that no cloud-only lab matches.
- **A clear regional rollout** for 16 languages across 23 locales as of iOS 26.1; eight new languages (including Traditional Chinese) added in November 2025.
- **Real shipped apps** using Foundation Models: Day One (journaling prompts), Stoic (mood-based reflection prompts), Stuff (natural-language to-do parsing), AllTrails (offline hike suggestions), SmartGym (workout-routine generation with reasoning), SwingVision (tennis/pickleball video analysis feedback).

### What Apple doesn't have

- **A frontier model.** The 3B can't compete with GPT-5.5 or Claude Opus 4.7 or Gemini 3.1 Pro on hard tasks. Apple Intelligence's larger server model on Private Cloud Compute uses a Parallel-Track Mixture-of-Experts (PT-MoE) transformer that's competitive with mid-size cloud models but doesn't claim the frontier. It's the model Apple's own surfaces (Writing Tools rewrites, complex Siri) escalate to; third parties calling `LanguageModelSession` stay on the 3B on-device.
- **Mainland China availability for users.** The Alibaba Qwen integration was announced in early 2025 and quietly turned on for a few hours in late March 2026 before being pulled pending Chinese regulatory approval. As of May 2026, devices set to a mainland China region still don't get Apple Intelligence in production.
- **Cloud-scale reasoning.** For multi-step planning, code generation at length, or knowledge-heavy queries, Apple's stack defers to the cloud labs (ChatGPT integration in Siri / Writing Tools, or your own backend integration).
- **Direct developer access to PCC.** Foundation Models is on-device only. If you want a larger model under privacy guarantees, you currently have to call out to a separate provider.

### The trade-off, summarized

| Dimension | Cloud labs (OpenAI / Anthropic / Google) | Apple |
|---|---|---|
| Model size | 100B-2T+ parameters | 3B on-device, mid-size on PCC |
| Latency | Network round-trip (100s of ms minimum) | First call ~300-500ms cold; subsequent sub-second |
| Cost | $0.05-30 per million tokens | $0 per call |
| Privacy | Provider sees the request | On-device or PCC (Apple can't see) |
| Offline | No | Yes |
| Knowledge | Up to recent training cutoff, sometimes with retrieval | None to speak of; use tools for facts |
| Reasoning | Strong; chain-of-thought, tools, multi-step | Weak; one-shot summarization, classification, extraction |
| Code generation | Strong | Avoid |
| Multilingual | Excellent | 16 languages / 23 locales |
| Customization | Prompts; some fine-tuning APIs | Specialized adapters; no general fine-tuning yet |
| App Store eligibility | Yes (your responsibility) | Yes (free, native) |

The pattern in the table isn't "cloud labs are better." It's "they make different trades." Apple's model is *strictly worse* on raw capability and *strictly better* on cost, latency, privacy, and offline. If your feature lives in the half of the diagram where capability isn't the bottleneck, Apple wins by default. If it lives in the other half, you call out to a cloud lab, and you can usually do both inside the same app.

---

## Deep thoughts: the design philosophy underneath

The narrow technical view of Foundation Models is "Apple shipped a small LLM and a framework for it." The wider view is that the framework is a *complete bet on a different model of how AI fits into a consumer device*, and the bet has a few specific structural choices that don't appear in any of the cloud labs' SDKs.

### 1. The model is part of the OS, not part of the app

Cloud labs ship models as services: you authenticate, you POST a request, you pay per call. Apple ships the model the same way it ships `UIKit`: preinstalled, versioned with the OS, callable for free, updated through the system. The consequences:

- **No bundle weight.** Adding AI features to your app doesn't increase the download size.
- **No version skew.** Every user on iOS 26.1 has the same model. You don't have a 1% tail of users running last year's weights.
- **The model updates through the OS.** Apple ships a new model version with iOS 26.2; every user gets it overnight; your code keeps running unchanged. The deterministic `.greedy` sampling guarantee says "same prompt → same output *per OS version*," with the explicit caveat that updates can change outputs. That's a different contract from cloud services where the model can change under you without notice.
- **No authentication, no API keys, no rate limits.** The model is a syscall, not a service.

### 2. Structured output is the type system, not a regex

The `@Generable` macro is the single most consequential design choice in the framework. It's not a convenience; it's a different *category* of API. Every other LLM SDK in 2026 treats structured output as a post-processing problem: you prompt the model to emit JSON, you parse it, you handle the times it lies about the schema. `@Generable` makes structure a *generation-time constraint*: the model literally cannot produce output that doesn't match the schema, because the framework intercepts the decoding step and forbids non-conforming tokens.

The implications stack:

- **The whole class of "model emitted bad JSON" bugs disappears.** Not "becomes rarer." Disappears.
- **Tests can assert on shape without flake.** A snapshot test of a `WeeklyDigest` output is meaningful because `WeeklyDigest` is the contract; the model can't violate it.
- **Streaming has a well-typed companion.** `PartiallyGenerated<T>` is generated by the macro; you don't write it.
- **The API surface stays small.** You don't need separate codepaths for "JSON mode" and "text mode." There's `respond(to:)` (text) and `respond(to:generating:)` (typed), and the latter subsumes the former.

The pattern generalizes well beyond Apple's framework. The right LLM API isn't "give me text and I'll parse it." It's "give me a value of this Swift type." Eight months from now expect the cloud labs to follow.

### 3. Tools as control flow, not as plug-ins

Tool calling in Foundation Models is presented as an inversion: the model is the orchestrator; your code provides the leaves. You don't write `if intent == .weather: callWeatherAPI()`. You register `GetWeatherTool` and a description, and let the model decide.

This sounds like a small ergonomic change. It's not. It's the same shift that ARC made for memory management in 2011: a category of decision that used to live in your code now lives in the runtime, and the right abstraction is to stop branching and start declaring. Once you accept that the model is doing the routing, the code patterns simplify dramatically: you write the *capabilities*, not the *flow*.

### 4. Availability is a UI state, not an exception

The `SystemLanguageModel.default.availability` property is the most under-discussed part of the framework. It's not a boolean. It's an enum with several `.unavailable(reason)` cases (device-not-eligible, intelligence-disabled, model-loading, language-unsupported, region-restricted), and the framework's contract is that your UI handles them as *first-class states*, not as exceptions.

The contrast with cloud APIs is sharp. When OpenAI is down, your app shows an error. When the user is rate-limited, your app shows an error. When the user is in a country OpenAI doesn't serve, your app shows an error. Apple's framework treats every "AI isn't available right now" condition as a UI state the screen has to handle gracefully, usually by *just being the non-AI version of the screen*. The note still saves; the auto-title just falls back to the first line.

This is exactly the right model. AI is an enhancement; the underlying screen has to work without it. Building that assumption into the API surface (rather than leaving it as an afterthought in your error handler) is the framework saying: degrade well, by default, every time.

### 5. The four-thousand-token window is a feature, not a bug

The instinct on first hearing "4096 tokens" is to be disappointed. GPT-5.5 is at 1M; Claude Opus 4.7 has 1M standard; even DeepSeek V4-Flash has 1M. Why is Apple's window two orders of magnitude smaller?

Because the window is sized for *the device*, not for the impressive headline number. A 4096-token context fits in working memory without paging. It runs cool. It doesn't drain the battery. It returns in sub-second time. A 1M-token on-device window on an iPhone would be a thermal disaster and a battery-life regression, and Apple knew that, so they didn't ship it.

The deeper point: the right context size depends on what the model is *for*. Foundation Models is for short summarization, classification, extraction, structured generation, short conversational turns. Every one of those tasks fits in 4096 tokens with room to spare. The cases that don't fit (long-document Q&A, code-base navigation, multi-turn agents with rich tool histories) are the cases the model wasn't designed for in the first place, and the right answer is "use a different model" (Private Cloud Compute, or a cloud lab, depending on the privacy budget).

A small window forces you to design tighter prompts, shorter instructions, leaner tool descriptions, and condensed transcripts. Every one of those is good engineering. The window is shaping the rest of the design in a way that makes the apps better.

### 6. The economic model changes the design instinct

The most subtle consequence of the "inference is free" position is *where* AI shows up in your UI. With pay-per-token APIs, AI gravitates to one or two prominent surfaces: the chat button, the search bar, the export button. Anywhere you can amortize the call against a deliberate user action.

When inference is free, the gravity reverses. AI scatters into the background: a summary above every detail screen, a classification on every photo import, a suggested tag on every voice memo, a one-sentence digest on every weekly view. The app becomes *quietly intelligent* in a way that pay-per-token apps cannot afford to be. Most users won't notice individual AI features; they'll notice that "the app just kind of gets it" everywhere.

The instinct to absorb is: **AI under Apple's cost model is closer to syntax highlighting than to a paid feature**. You don't gate it. You don't put it behind a paywall. You don't budget it. You use it everywhere it makes a small thing slightly better, and the cumulative effect is the value.

### 7. Privacy as architecture, not as policy

Most companies "doing AI privately" are doing it as a *policy claim*: we promise we won't read your data, our terms of service forbid us from training on it, we have SOC 2 compliance. Apple is doing it as an *architectural claim*: the data physically cannot leave the device, or when it does (PCC), the code path is publicly auditable and the nodes are designed to be incapable of retaining content.

This is the same distinction the company drew with iMessage end-to-end encryption a decade ago: not "we promise not to read your messages," but "we've designed the system such that we are not able to read your messages, and you can verify the design." It's a stronger claim. Reading the Private Cloud Compute security writeup is the closest thing in 2026 to reading the original iMessage E2EE design. It's a serious engineering document, not a marketing one.

For developers building privacy-sensitive products (healthcare, finance, journaling, anything dealing with children's data), this is the only platform-AI story that doesn't require a separate compliance conversation. It also gives you marketing copy you can actually back up: "AI features in this app run entirely on your device" is a statement Apple's framework makes true, not one you have to qualify.

### 8. The system intelligence layer is the real win

The framework attention goes to Foundation Models, fair, because that's the developer-visible piece. But the AI surface with the broadest *reach* in iOS 26 is the one developers don't write: Writing Tools in every text view, Genmoji in every notes app, Visual Intelligence that can deep-link into any app via App Intents. Quality varies. Proofread is genuinely useful; the rewrite-as-friendly/professional styles flatten voice and tend to add throat-clearing. Genmoji is novelty-grade, heavily used for a week after launch and then occasional. Visual Intelligence's payoff depends on third-party App Intent adoption that mostly hasn't happened yet, so today it's mostly "search the web" / "ask ChatGPT." None of these are individually beloved. The point isn't the polish of any one feature; it's the deployment model. Apple made every existing iOS app AI-capable overnight without asking a single developer to ship an update.

This is a different model of "deploying AI to your users." Cloud labs see AI deployment as an SDK problem: ship a smarter app, write better prompts, integrate cleaner. Apple sees it as a *UI control* problem: put the AI behind `UITextView` and `UIImageView` and `PHPickerViewController`, and AI shows up wherever those controls already are. The Foundation Models framework is the developer-facing API for the cases where the system layer doesn't cover what you need; in practice, it covers more than you'd expect.

The corollary for app design: **audit your standard controls before reaching for a custom AI implementation**. If your "notes" field is a `UITextView`, Writing Tools is already there. If your "tags" picker accepts emoji, Genmoji is already there. If your detail view can be deep-linked, Visual Intelligence is one App Intent away. You probably ship more AI than you think you do.

---

## The corrections file: things that look true but aren't

Three claims that get repeated in the AI press that the framework's documentation contradicts.

- **"Foundation Models is just Apple's wrapper around an LLM, like Anthropic's SDK."** No. The structured generation contract (`@Generable` constraining decoding), the system-level model lifecycle (no auth, no keys, OS-versioned), and the on-device hard constraint make this a categorically different kind of SDK. The closest analogy isn't another LLM wrapper; it's `UIKit` (system-shipped, system-versioned, free, ergonomic, opinionated).
- **"Apple Intelligence and Foundation Models are the same thing."** Apple Intelligence is the brand; Foundation Models is one of several frameworks underneath it. Writing Tools, Image Playground, Visual Intelligence, and Live Translation are *also* Apple Intelligence features; they have nothing to do with Foundation Models' API surface. Use brand names in marketing, framework names in code.
- **"The on-device model can be replaced with a cloud model via configuration."** No. Foundation Models is on-device, period. Private Cloud Compute is invoked by Apple's first-party surfaces (Siri, Writing Tools), not by third-party `LanguageModelSession` calls. If you want a cloud model from your app, you call a cloud lab from your backend; the privacy boundary is on you.

---

## What's coming

A few signals from May 2026 worth tracking:

- **iOS 26.1** (November 2025) added eight new languages, bringing the supported list to 16 (23 locales). Traditional Chinese is among the new arrivals; the Alibaba Qwen integration for mainland China users was briefly switched on in late March 2026 then pulled pending regulatory approval.
- **iOS 26.4** (RC at time of writing) adds `SystemLanguageModel.contextSize` and `tokenCount(for:)` for token bookkeeping, both marked `@backDeployed` so they're available on all iOS versions that support the framework. Reports suggest more pre-tuned specialized adapters (beyond `.contentTagging`) are in flight for 26.x point releases: extraction, sentiment, intent classification are the candidates.
- **iOS 27 will open third-party AI defaults**: users will be able to set Anthropic Claude or Google Gemini as the cloud fallback for Apple Intelligence features (Writing Tools, Image Playground), instead of being locked to OpenAI ChatGPT. This is the first real crack in the ChatGPT-exclusive partnership announced at WWDC24.
- **iOS 27 image models** are reportedly getting a major quality bump for Genmoji and Image Playground; a separate rumor has Google's Nano Banana as a candidate for boosting Image Playground specifically, though no source names it as the iOS 27 default-AI selection.
- **Server-side foundation model upgrades**, the one Apple deploys to PCC, use the PT-MoE architecture and are expected to track mid-tier frontier capabilities more closely than the on-device side can. PCC's hardened-OS design is what makes that scalable without recompromising the privacy story.
- **WWDC 2026** is the next big disclosure point. The shape of the bet is set; the surface area will grow.

The framework as it stands is unusually complete for a v1. It's a small API, with a clear philosophy, that handles the common cases gracefully and degrades well when the assumptions don't hold. The cost model is the one developers haven't had access to before. The right move is to start using it now and let the apps reshape around what *quietly intelligent* looks like.

Sources:
- [Apple's Foundation Models framework unlocks new intelligent app experiences (Apple Newsroom, Sept 2025)](https://www.apple.com/newsroom/2025/09/apples-foundation-models-framework-unlocks-new-intelligent-app-experiences/)
- [Foundation Models (Apple Developer Documentation)](https://developer.apple.com/documentation/FoundationModels)
- [Apple Intelligence Foundation Language Models Tech Report 2025](https://machinelearning.apple.com/research/apple-foundation-models-tech-report-2025)
- [Updates to Apple's On-Device and Server Foundation Language Models (Apple Machine Learning Research)](https://machinelearning.apple.com/research/apple-foundation-models-2025-updates)
- [TN3193: Managing the on-device foundation model's context window](https://developer.apple.com/documentation/technotes/tn3193-managing-the-on-device-foundation-model-s-context-window)
- [Apple Intelligence (Apple Developer)](https://developer.apple.com/apple-intelligence/)
- [Visual Intelligence: Integrating your app with visual intelligence (Apple Developer)](https://developer.apple.com/documentation/VisualIntelligence/integrating-your-app-with-visual-intelligence)
- [Private Cloud Compute: A new frontier for AI privacy in the cloud (Apple Security Research)](https://security.apple.com/blog/private-cloud-compute/)
- [Apple Intelligence expands to new languages including Traditional Chinese (Apple, November 2025)](https://www.apple.com/hk/en/newsroom/2025/11/apple-intelligence-expands-to-new-languages-including-traditional-chinese/)
- [iOS 26.1 brings Apple Intelligence to eight new languages (9to5Mac, November 2025)](https://9to5mac.com/2025/11/11/ios-26-1-brings-apple-intelligence-to-these-eight-new-languages/)
- [How to get Apple Intelligence (Apple Support)](https://support.apple.com/en-us/121115)
- [Apple Improves Context Window Management for its Foundation Models (InfoQ, March 2026)](https://www.infoq.com/news/2026/03/apple-foundation-models-context/)
- [Apple Intelligence accidentally rolled out in China (AppleInsider, March 2026)](https://appleinsider.com/articles/26/03/30/apple-intelligence-finally-rolls-out-in-china)
- [iOS 27 will let you pick Claude or Gemini instead of ChatGPT for Apple Intelligence (MacRumors, May 2026)](https://www.macrumors.com/2026/05/05/ios-27-third-party-chatbots-apple-intelligence/)
- [Apple Intelligence image models to get major visual upgrades in iOS 27 (9to5Mac, May 2026)](https://9to5mac.com/2026/05/24/apple-image-playground-and-gemoji-to-get-major-visual-improvements/)
- [How developers are using Apple's local AI models with iOS 26 (TechCrunch, October 2025)](https://techcrunch.com/2025/10/03/how-developers-are-using-apples-local-ai-models-with-ios-26/)
