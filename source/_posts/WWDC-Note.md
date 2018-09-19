---
title: WWDC Note
date: 2018-09-17 15:38:53
updated:
categories: Apple
tags: 
keywords: WWDC
---

## DeveloperTools
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

<!-- more -->

### WWDC17, Session 409: What's New in Testing
- Async Testing: `XCTWaiter` and `XCTestExpectation`
- Snapshot performance optimization: `firstMatch`
- `XCTActivity`, `XCTAttachment` and `XCUIScreenshotProviding`

### WWDC15, Session 406: UI Testing in Xcode
- Core Technologies: XCTest + Accessibility
- UI recording
