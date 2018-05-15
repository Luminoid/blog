---
title: CocoaPods Usage
date: 2018-05-15 00:08:05
updated:
categories:
- iOS
tags:
- CocoaPods
keywords:
- CocoaPods
---

Official Site: https://cocoapods.org

## Adding Pods to an Xcode project
**Create a Podfile**
``` bash
$ pod init
```
or
``` bash
$ touch Podfile
```

**Podfile**
``` bash
platform :ios, '9.0'
use_frameworks!

target 'MyApp' do
  pod 'AFNetworking', '~> 2.6'
  pod 'ORStackView', '~> 3.0'
  pod 'SwiftyJSON', '~> 2.3'
end
```

**Install project dependencies**
``` bash
$ pod install
```

**Open `MyApp.xcworkspace` to work**

<!-- more -->

## Command
``` bash
cat Podfile.lock    # List installed pods
pod install         # Install project dependencies according to versions from a Podfile.lock
pod outdated        # Show outdated project dependencies
pod update          # Update outdated project dependencies and create new Podfile.lock
pod search          # Search for pods
```

## Updating CocoaPods
``` bash
gem install cocoapods
```
