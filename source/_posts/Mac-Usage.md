---
title: Mac Usage
date: 2022-02-28 14:19:45
categories:
  - Mac
tags:
  - Finder
  - Homebrew
  - shortcuts
---

Shortcuts and commands that earn their keep on a daily-driver Mac.

<!-- more -->

## Upgrading and Checking Packages

```bash
# `bubu` is a personal alias: brew update && brew outdated && brew upgrade && brew cleanup
bubu
brew doctor

ncu -g       # check global npm packages for newer versions
npm doctor

gem update
gem cleanup
```

For machine reproducibility (declarative install list), see Brewfile in {% post_link M1-Mac-Development-Setup "Mac development setup" %}.

## CLI Utilities

```bash
pbcopy < file.txt              # pipe stdin to clipboard
pbpaste > file.txt             # pipe clipboard to stdout
say "build finished"           # speak text aloud
caffeinate -i make release     # keep Mac awake while a command runs
screencapture -i clip.png      # interactive region capture
sips -Z 1024 in.png --out out.png  # resize, keeping aspect ratio
mdls -name kMDItemKind file    # Spotlight metadata for any file
```

## Keyboard Shortcuts
[Mac keyboard shortcuts](https://support.apple.com/en-us/HT201236)

### Common Shortcuts

| Shortcut | Action |
|---|---|
| `⌘,` | Open preferences for the front app |
| `⇧⌘T` | Reopen the last closed tab |
| `⇧⌘[` / `⇧⌘]` | Previous / next tab |
| `⌃⌘F` | Toggle full screen |
| `⌘W` / `⌥⌘W` | Close window / close all windows |
| `⌃⌘Q` | Lock screen immediately |
| `⌘⇧3` / `⌘⇧4` / `⌘⇧5` | Full / region / capture overlay |

### Finder

| Shortcut | Action |
|---|---|
| `⇧⌘.` | Toggle show hidden files |
| `⌘↑` / `⌘↓` | Parent folder / open selection |
| `⌘⇧G` | Go to folder by path |
| `⌘⌥V` | Move (cut/paste) after `⌘C` |
| Space | Quick Look preview |

### System Sliders (open the right pane fast)

`⌥` plus any media key opens the matching System Settings pane. Add `⇧` to step in finer increments:

| Shortcut | Action |
|---|---|
| `⌥`-Volume | Open Sound settings |
| `⌥⇧`-Volume | Adjust volume in smaller steps |
| `⌥`-Brightness | Open Displays settings |
| `⌥⇧`-Brightness | Adjust brightness in smaller steps |

### Text Editing

`⌃A`, `⌃E`, `⌃K`, `⌃Y` work in any standard text field, since AppKit borrows Emacs bindings.

| Shortcut | Action |
|---|---|
| `⌥←` / `⌥→` | Jump by word |
| `⌥⌫` | Delete previous word |
| `⌃A` / `⌃E` | Start / end of line |
| `⌃K` | Kill from cursor to end of line |
| `⌃Y` | Yank (paste killed text) |
| `fn fn` | Dictation (toggle in Keyboard settings) |
