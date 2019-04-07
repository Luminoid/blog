---
title: Web Development on iOS
date: 2019-02-27 17:51:52
updated:
categories: 
- iOS
tags:
keywords:
---

## Scroll
### `isScrollEnabled`
In html, if content width is wider than its parent container, the content is scrollable.
However, if set `isScrollEnabled` to `false` in native:
``` Swift
wkWebView.scrollView.isScrollEnabled = false
```
the container will need another wrapper to implement scrolling.

### `-webkit-overflow-scrolling`
if set `-webkit-overflow-scrolling` to `touch` in CSS, device will use momentum-based scrolling for a given element.
``` CSS
-webkit-overflow-scrolling: touch;
```
The native will treat this element as a `UIScrollView`, which will come with some default features, like scroll indicator.
