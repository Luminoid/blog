---
title: iOS Basic Concepts
date: 2018-06-17 14:37:21
updated:
categories: iOS
tags:
---

## Responder Chain
{% asset_img ResponderChain.png "Responder Chain" %}

<!-- more -->

## iOS Device Display Summary
[PaintCode](https://www.paintcodeapp.com/news/ultimate-guide-to-iphone-resolutions)
[iOSRes](http://iosres.com/)

| Device | UIKit Size (Points) | Rendered Pixels | UIKit Scale factor | Physical Pixels | Native Scale factor | Size(Diagonal) | PPI | Associated Devices |
|---|---|---|---|---|---|---|---|---|
| iPhone X<span style="font-variant-caps: all-small-caps">S</span> Max | 414 x 896 | 1242 x 2688 | 3.0 | 1242 x 2688 | 3.0 | 6.5 inch | 458 | |
| iPhone X<span style="font-variant-caps: all-small-caps">S</span> | 375 x 812 | 1125 x 2436 | 3.0 | 1125 x 2436 | 3.0 | 5.8 inch | 458 | iPhone X |
| iPhone X<span style="font-variant-caps: all-small-caps">R</span> | 414 x 896 | 828 x 1792 | 2.0 | 828 x 1792 | 2.0 | 6.1 inch | 326 | |
| iPhone 8 Plus | 414 x 736 | 1242 × 2208 | 3.0 | 1080 x 1920 | 2.608 | 5.5 inch | 401 | iPhone 6 Plus, iPhone 6s Plus, iPhone 7 Plus |
| iPhone 8 | 375 x 667 | 750 x 1334 | 2.0 | 750 x 1334 | 2.0 | 4.7 inch | 326 | iPhone 6, iPhone 6s, iPhone 7 |
| iPhone SE | 320 x 568 | 640 x 1136 | 2.0 | 640 x 1136 | 2.0 | 4 inch | 326 | iPhone 5, 5C, 5S, iPod Touch 5g |
| iPad Pro (12.9-inch) | 1024 x 1366 | 2048 x 2732 | 2.0 | 2048 x 2732 | 2.0 | 12.9 inch | 264 | 12.9-inch iPad Pro |
| iPad Pro (10.5-inch) | 834 x 1112 | 1668 x 2224 | 2.0 | 1668 x 2224 | 2.0 | 10.5 inch | 264 | |
| iPad Air | 768 x 1024 | 1536 x 2048 | 2.0 | 1536 x 2048 | 2.0 | 9.7 inch | 264 | iPad 3, iPad 4, iPad Air, iPad Air 2, 9.7-inch iPad Pro |
| iPad Mini | 768 x 1024 | 1536 x 2048 | 2.0 | 1536 x 2048 | 2.0 | 7.9 inch | 326 | iPad Mini 2, iPad Mini 3, iPad Mini 4 |


