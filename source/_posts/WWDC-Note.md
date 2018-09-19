---
title: WWDC Note
date: 2018-09-17 15:38:53
updated:
categories: Apple
tags: 
keywords: WWDC
---

## WWDC 2018
### Session 405: Measuring Performance Using Logging
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

### Session 414: Understanding Crashes and Crash Logs
- [Understanding and Analyzing Application Crash Reports](https://developer.apple.com/library/archive/technotes/tn2151/_index.html)

### Session 416: iOS Memory Deep Dive
- Image-rendering formats: Use `UIGraphicsImageRenderer` instead of `UIGraphicsBeginImageContextWithOptions`
- Downsampling: Use `ImageIO` instead of `UIImage`

## WWDC 2015
### Session 406: UI Testing in Xcode
- XCTest + Accessibility
