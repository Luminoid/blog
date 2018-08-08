---
title: Mac Usage
date: 2018-03-07 00:56:07
updated:
categories: Mac
tags:
  - Bash
keywords:
  - Preferences
  - Bash
---

## Preferences
### Manage Login Items
System Preferences -> Users & Groups -> Login Items

## System
### Open Apps From the Unidentified Developers
Location: System Preferences -> Security & Privacy -> General -> Choose “Anywhere”
``` bash
$ sudo spctl --master-disable
```

<!-- more -->

## Maintenance
``` bash
$ brew update
$ brew upgrade
$ brew cleanup
$ brew prune
$ brew doctor
$ npm-check -gu
```

## Directories
### Xcode
Simulator devices data: `~/Library/Developer/CoreSimulator/Devices`

## Disk Cleanup
### Xcode
``` bash
~/Library/Developer/Xcode/iOS DeviceSupport
~/Library/Developer/CoreSimulator/Devices
```
