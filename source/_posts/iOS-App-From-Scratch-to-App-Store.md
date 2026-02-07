---
title: iOS Development Resources From Scratch to App Store
date: 2026-01-15 23:46:41
updated:
categories: iOS
tags:
- fastlane
---

## Setup
Remove storyboard: [Link](https://sarunw.com/posts/how-to-create-new-xcode-project-without-storyboard/#xcode-11)
[gitignore](https://github.com/github/gitignore/blob/main/Swift.gitignore)

## Package
### Package Manager
[SPM](https://www.swift.org/package-manager/)
Organize, manage, and edit Swift packages.

[Mint](https://github.com/yonaskolb/Mint)
A package manager that installs and runs Swift command line tool packages.

### Common Packages
[SnapKit](https://github.com/SnapKit/SnapKit)
> A Swift Autolayout DSL for iOS & OS X

[Kingfisher](https://github.com/onevcat/Kingfisher)
> A lightweight, pure-Swift library for downloading and caching images from the web.

[RxSwift](https://github.com/ReactiveX/RxSwift)
> Reactive Programming in Swift

[R.swift](https://github.com/mac-cain13/R.swift)
> Strong typed, autocompleted resources like images, fonts and segues in Swift projects

[Lottie](https://github.com/airbnb/lottie-ios)
> An iOS library to natively render After Effects vector animations

Issue: https://github.com/mac-cain13/R.swift/issues/815
Solution: Use Run Script + Mint, instead of plugin product (RswiftGenerateInternalResources) for generating code.

## Tools
### UI
[Lookin](https://github.com/QMUI/LookinServer/)
> You can inspect and modify views in iOS app via Lookin, just like UI Inspector in Xcode, or another app called Reveal.

[Lottie JSON Editor](https://lottiefiles.github.io/lottie-docs/playground/json_editor/)
Lottie edit and preview

### Code
[SwiftLint](https://github.com/realm/SwiftLint)
> A tool to enforce Swift style and conventions.

[SwiftFormat](https://github.com/nicklockwood/SwiftFormat)
> SwiftFormat is a code library and command-line tool for reformatting Swift code on macOS, Linux or Windows.

### Build
[Xcode-Build-Server](https://github.com/SolaWing/xcode-build-server)
> This repo aims to integrate xcode with sourcekit-lsp and support all the languages (swift, c, cpp, objc, objcpp) xcode supports, so I can develop iOS with my favorate editor.

[xcbeautify](https://github.com/cpisciotta/xcbeautify)
> `xcbeautify` is a little beautifier tool for `xcodebuild`.

<!-- more -->

## Design
[Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/guidelines/overview/)

## Coding Style
[Trim trailing spaces in Xcode](https://stackoverflow.com/questions/1390329/trim-trailing-spaces-in-xcode)

## Git
[Commit messages convention](https://www.conventionalcommits.org/en/v1.0.0/)

Add tags to build
``` bash
git tag v1.2.0  # Version 1.2.0
git tag b10     # Build 10
```

## Distribution
### [fastlane](https://docs.fastlane.tools/)
- [App iconset generation](https://github.com/fastlane-community/fastlane-plugin-appicon)
- [fastlane with SwiftLint](https://docs.fastlane.tools/actions/swiftlint/)

Change version code, then `fastlane beta`
``` bash
bundle exec fastlane beta
bundle exec fastlane generate_icon
bundle exec fastlane validate
``` 

#### Fastfile
``` Ruby
default_platform(:ios)

# Mac Catalyst lanes (root-level: same app, macOS variant)
desc "Build Mac Catalyst version of the app"
lane :catalyst do
  Dir.chdir("..") do
    sh("python3 Scripts/analyze_localization.py")
  end

  build_app(
    scheme: "ProjectName",
    clean: true,
    destination: "generic/platform=macOS",
    skip_package_ipa: true,
    export_method: "app-store",
    catalyst_platform: "macos",
    output_directory: "./build/Catalyst",
    xcargs: "ONLY_ACTIVE_ARCH=YES -skipPackagePluginValidation"
  )
end

platform :ios do
  desc "Push a new beta build to TestFlight"
  lane :beta do
    # Change to project root for scripts
    Dir.chdir("..") do
      # Check localization completeness
      sh("python3 Scripts/analyze_localization.py")
    end
    
    # Increment build number
    # increment_build_number(xcodeproj: "ProjectName.xcodeproj")
    
    # Build and upload
    # Use export_method: "app-store" for TestFlight
    # With automatic signing, Xcode will automatically use/create the App Store distribution profile
    # Note: Make sure you've opened the project in Xcode at least once so it can download
    # the App Store distribution provisioning profile from your Apple Developer account
    build_app(
      scheme: "ProjectName",
      export_method: "app-store"
    )
    # upload_to_testflight
  end

  desc "Generate app icon from source image"
  lane :generate_icon do
    appicon(
      appicon_image_file: 'fastlane/metadata/app_icon.png',
      appicon_devices: %i[ipad iphone ios_marketing],
      appicon_path: 'ProjectName/Assets.xcassets'
    )
  end

  desc "Run pre-build validations"
  lane :validate do
    # Change to project root for scripts
    Dir.chdir("..") do
      sh("python3 Scripts/analyze_localization.py")
    end
  end
end
```

### Apple
- [Preparing your app for distribution](https://developer.apple.com/documentation/xcode/preparing-your-app-for-distribution)
- [Distributing your app for beta testing and releases](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)

### App Store Preview Images
- https://www.figma.com/community/device-mockups/iphone
- https://www.figma.com/community/file/1227376606592772837

## Useful Links
### Apple
App Store Connect: https://appstoreconnect.apple.com/
Developer Account: https://developer.apple.com/account
iCloud Dashboard: https://developer.apple.com/icloud/dashboards/

### Articles
View App data: https://developer.apple.com/forums/thread/21660
Disable dark mode: https://sarunw.com/posts/how-to-disable-dark-mode-in-ios/
Hit-Testing: https://smnh.me/hit-testing-in-ios
Use Cursor for iOS development: https://dimillian.medium.com/how-to-use-cursor-for-ios-development-54b912c23941
