---
title: Mac Usage
date: 2018-03-07 00:56:07
updated:
categories: Mac
tags:
- Bash
- Keymap
---

## Upgrade
``` bash
$ bubu  # brew update && brew outdated && brew upgrade && brew cleanup
$ brew cask upgrade
$ brew doctor
$ npm-check -gu
$ npm doctor
$ gem update
$ gem cleanup
```

<!-- more -->

## Keyboard Shortcuts
### Common shortcuts
`Command-,`: Open preferences for the front app

### Finder and system shortcuts
`Shift-Command-T`: Reopen the last closed tab
`Shift-Command-[`: Switch to the previous tab
`Shift-Command-]`: Switch to the next tab

### Document shortcuts
`Option–Left`: Move the insertion point to the beginning of the previous word
`Option–Right`: Move the insertion point to the end of the next word
`Option-Delete`: Delete the word to the left of the insertion point
`Control-A`: Move to the beginning of the line or paragraph
`Control-E`: Move to the end of a line or paragraph

## Preferences
### Manage Login Items
System Preferences -> Users & Groups -> Login Items

## System
### Open Apps From the Unidentified Developers
Location: System Preferences -> Security & Privacy -> General -> Choose “Anywhere”
``` bash
$ sudo spctl --master-disable
```

### External Monitor: force RGB mode instead of YCbCr
[patch-edid.rb](https://gist.github.com/adaugherity/7435890)

## Directories
### Xcode
Simulator devices data: `~/Library/Developer/CoreSimulator/Devices`

iOS DeviceSupport [(resource)](https://github.com/iGhibli/iOS-DeviceSupport): `/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport`

## Disk Cleanup
### Xcode
``` bash
~/Library/Developer/Xcode/iOS DeviceSupport
~/Library/Developer/CoreSimulator/Devices
```

## iOS
### Back up iOS Devices to an External Drive
``` bash
$ ln -s /Volumes/<External>/<iOS_Backups> ~/Library/Application\ Support/MobileSync/Backup
```
