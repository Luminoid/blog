---
title: WWDC Note
date: 2018-09-17 15:38:53
updated:
categories: Apple
tags: 
keywords: WWDC
---

## Design
### WWDC18, Session 210: Introducing Dark Mode
- Design Considerations
    - Colors
    - Vibrancy
    - Glyphs
- Advanced Dark Mode
    - Replace static colors, images, materials
        - System Colors
        - Asset Catalog Colors
    - `NSAppearance`
    - `NSVisualEffectView` and vibrant blending

## Frameworks
### WWDC18, Session 221: Textkit Best Practices
Choosing the Right Control
{% asset_img ChoosingTheRightControl "Choosing the Right Control" %}

Layout process: Attribute Fixing -> Glyph Generation -> Glyph Layout -> Display

### WWDC15, Session 201: iOS Accessibility
- `UIAccessibility`

<!-- more -->

## Developer Tools
### WWDC18, Session 223: Embracing Algorithms
[Swift Standard Library](https://developer.apple.com/documentation/swift/swift_standard_library)

### WWDC18, Session 228: What's New in Energy Debugging
- What Consumes Energy
    - Processing: Workload-dependent
    - Networking: Traffic-dependent
    - Location: Accuracy, frequency-dependent
    - Graphics: Complexity-dependent
- Optimize Energy Consumption
    - Foreground: Focus on providing value to the user
        - Do work when requested
        - Minimize complex UI
    - Background: Focus on minimizing workload
        - Coalesce tasks
        - End tasks quickly

### WWDC18, Session 405: Measuring Performance Using Logging
``` swift
let refreshLog = OSLog(subsystem: "com.example.your-app", category: "RefreshOperations")

let spidForRefresh = OSSignpostID(log: refreshLog)
os_signpost(.begin, log: refreshLog, name: "Refresh Panel", signpostID: spidForRefresh)

for element in panel.elements {
    let spid = OSSignpostID(log: refreshLog, object: element)
    os_signpost(.begin, log: refreshLog, name: "Fetch Asset", signpostID: spid)
    fetchAssetAsync(for: element) {
        os_signpost(.end, log: refreshLog, name: "Fetch Asset", signpostID: spid)
    }
}
notifyWhenDone {
    os_signpost(.end, log: refreshLog, name: "Refresh Panel", signpostID: spidForRefresh)
}
```

### WWDC18, Session 407: Practical Approaches to Great App Performance
- Common Solutions
    - Defer
    - Batch
    - Share results
    - Fewer views
    - Direct observation
    - Prefer records to dictionaries

### WWDC18, Session 412: Advanced Debugging with Xcode and LLDB
#### Advanced Debugging Tips and Tricks
- Configure behaviors to dedicate a tab for debugging
- LLDB expressions can modify program state
- Use auto-continuing breakpoints with debugger commands to inject code live
- Create dependent breakpoints using `breakpoint set --one-shot true`
- `po $arg1` (`$arg2`, etc) in assembly frames to print function arguments
- Skip lines of code by dragging Instruction Pointer or `thread jump --by 1`
- Pause when variables are modified by using watchpoints
- Evaluate Obj-C code in Swift frames with `expression -l objc -O -- <expr>`
    - Get UIView's view hierarchy: ``expression -l objc -O -- [`self.view` recursiveDescription]``
    - Get debug description of a memory address: `expression -l objc -O -- <address>`
- Flush view changes to the screen using `expression CATransaction.flush()`
- Add custom LLDB commands using aliases and scripts. Alias examples:
    - `command alias poc expression -l objc -O --`
    - `command alias 🚽 expression -l objc -- (void)[CATransaction flush]`

#### View Debugging Tips
- Reveal in Debug Navigator
- View clipped content
- Auto Layout debugging
- Access object pointers (copy casted expressions)
- Creation backtraces in the inspector
- Debug description in the inspector
- ⌘-click-through for selection


### WWDC18, Session 414: Understanding Crashes and Crash Logs
- [Understanding and Analyzing Application Crash Reports](https://developer.apple.com/library/archive/technotes/tn2151/_index.html)

### WWDC18, Session 416: iOS Memory Deep Dive
- Image-rendering formats: Use `UIGraphicsImageRenderer` instead of `UIGraphicsBeginImageContextWithOptions`
- Downsampling: Use `ImageIO` instead of `UIImage`

### WWDC17, Session 406: Finding Bugs Using Xcode Runtime Tools
- Main Thread Checker
- Address Sanitizer
- Thread Sanitizer
- Undefined Behavior Sanitizer

### WWDC17, Session 409: What's New in Testing
- Async Testing: `XCTWaiter` and `XCTestExpectation`
- Snapshot performance optimization: `firstMatch`
- `XCTActivity`, `XCTAttachment` and `XCUIScreenshotProviding`

### WWDC17, Session 414: Engineering for Testability
- Testable
    - Protocols and parameterization
    - Separating logic and effects
- Scalable(UI tests)
    - Abstracting UI element queries
    - Creating objects and utility functions
    - Utilizing keyboard shortcuts

### WWDC16, Session 409: Advanced Testing and Continuous Integration
#### Testing Overview
##### XCTest
Testing framework
Compile: `.m`, `.swift` => `UI.xctest`, `Unit.xctest`

##### Xcode
Test harness
- Author tests
- Execute tests
- Review reports

##### Xcode Server
Continuous Integration
- Schedules bot runs
- Generates reports
- Sends notifications

##### xcodebuild
Command line tool
- Used by Xcode Server
- Build and execute tests
- For custom CI systems

#### Testing Concepts
##### Compilation
- `.xctest`
- `.app`

##### Hosting
| Unit Tests                                | UI Tests                                  |
|-------------------------------------------|-------------------------------------------|
| Direct access to host app data and APIs   | Uses Accessibility to access target app   |
| All tests run in single app launch        | Tests launch app for every test case      |

##### Observation
`XCTestObservation` Protocol

#### New Features
- Xcode
    - Crash Log Gathering
- Xcode Server
    - Advanced Triggers
    - Issue Tracking and Blame
    - Configurable Integration User

### WWDC15, Session 406: UI Testing in Xcode
- Core Technologies: XCTest + Accessibility
- UI recording

### WWDC15, Session 410: Continuous Integration and Code Coverage in Xcode
- Xcode Server: Scheme, Bot, Integration
