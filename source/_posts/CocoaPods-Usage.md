---
title: CocoaPods Usage
date: 2018-05-15 00:08:05
updated:
categories:
- iOS
tags:
- Package manager
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

## Podfile
``` ruby
pod 'Texture'             # Use the latest version of a Pod
pod 'Texture', '0.1'      # Freeze to a specific version of a Pod
pod 'Texture', '>= 0.1'   # Version 0.1 and any higher version
pod 'Texture', '~> 0.1'   # Version 0.1 and the versions up to 1.0, not including 1.0 and higher
pod 'Texture', '~> 0.1.2' # Version 0.1.2 and the versions up to 0.2, not including 0.2 and higher

pod 'Alamofire', :path => '~/Documents/Alamofire' # Use the Pod from a local folder
```

## Updating CocoaPods
``` bash
gem install cocoapods
```
