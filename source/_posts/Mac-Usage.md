---
title: Mac Usage
date: 2018-03-07 00:56:07
updated:
categories: Mac
tags:
- Bash
- Keymap
keywords:
- Preferences
- Bash
---

## Upgrade
``` bash
$ brew update
$ brew upgrade
$ brew cleanup
$ brew prune
$ brew doctor
$ brew cask upgrade
$ npm-check -gu
$ gem update
```

<!-- more -->

## Keyboard Shortcuts
### General
`Shift-Command-[`: Switch to the previous tab
`Shift-Command-]`: Switch to the next tab
`Shift-Command-T`: Reopen the last closed tab

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

## Disk Cleanup
### Xcode
``` bash
~/Library/Developer/Xcode/iOS DeviceSupport
~/Library/Developer/CoreSimulator/Devices
```
