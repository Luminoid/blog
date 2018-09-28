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
### WWDC15, Session 201: iOS Accessibility
- `UIAccessibility`

<!-- more -->

## Developer Tools
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

### WWDC18, Session 414: Understanding Crashes and Crash Logs
- [Understanding and Analyzing Application Crash Reports](https://developer.apple.com/library/archive/technotes/tn2151/_index.html)

### WWDC18, Session 416: iOS Memory Deep Dive
- Image-rendering formats: Use `UIGraphicsImageRenderer` instead of `UIGraphicsBeginImageContextWithOptions`
- Downsampling: Use `ImageIO` instead of `UIImage`

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
