---
title: Universal Editor Keymaps
date: 2018-03-17 23:25:41
updated:
categories:
- Tool
- Editor
tags:
keywords:
- Editor
- Keymaps
---

This post intended to provide a universal keymaps across different editors and IDEs on Mac.

<!-- more -->

## Keymaps

| Command | Universal Key | VSCode | Atom | Xcode | JetBrains |
| ------- | ------------- | ---- | ------ | ----- | --------- |
| **Edit Text** | | | | | |
| Upper case current text               | `shift-cmd-u`     |   |                   | | |
| Lower case current text               | `shift-cmd-l`     |   |                   | | |
| **Edit Lines**                        |                   |   |                   | | |
| Duplicate lines                       | `cmd-d`           |   |                   | | |
| Cut current line; Cut current text    | `cmd-x`           |   |                   | / | |
| Comment line                          | `cmd-/`           |   |                   | | |
| Move line up                          | `alt-shift-up`    |   | `ctrl-cmd-up`     | | |
| Move line down                        | `alt-shift-down`  |   | `ctrl-cmd-down`   | | |
| **Selection**                         |                   |   |                   | | |
| Multi-cursor selection                | `alt-click`       |   | `cmd-alt-click`   | | |
| Column selection                      | `alt-drag`        | / |                   | | |
| Cursor column select up               | `alt-up`          |   |                   | | |
| Cursor column select down             | `alt-down`        |   |                   | | |
| **Navigation**                        |                   |   |                   | | |
| Go to Definition                      | `cmd-click`       |   | /                 | | |
| Reveal in Project View                | `shift-cmd-j`     |   |                   | | |
| **Find**                              |                   |   |                   | | |
| Find in the current file              | `cmd-f`           |   |                   | | |
| Find in the entire project            | `shift-cmd-f`     |   |                   | | |
| Find and replace                      | `cmd-r`           |   | `cmd-f`           | | |
| Find next match                       | `cmd-g`           |   |                   | | |
| Find previous match                   | `shift-cmd-g`     |   |                   | | |
| **View**                              |                   |   |                   | | |
| Toggle Command Palette                | `shift-cmd-p`     |   |                   | | |
| Toggle Terminal                       | `` ctrl-` ``      |   |                   | | |
| Toggle Sidebar                        | `cmd-\ `          |   |                   | | |
| Open User Settings                    | `cmd-,`           |   |                   | | |
| **Tab**                               |                   |   |                   | | |
| Open new tab                          | `cmd-t`           |   |                   | | |
| Switch to the previous tab            | `shift-cmd-[`     |   |                   | | |
| Switch to the next tab                | `shift-cmd-]`     |   |                   | | |
| **Plugin**                            |                   |   |                   | | |
| Toggle Markdown Preview Enhanced      | `alt-enter`       |   |                   | | |

## Config File
### Atom
**keymap file**: `~/.atom/keymap.cson`
``` yaml
'atom-text-editor':
  'shift-cmd-u': 'editor:upper-case'
  'shift-cmd-l': 'editor:lower-case'

'atom-workspace atom-text-editor:not([mini])':
  'cmd-d': 'editor:duplicate-lines'
  'alt-enter': 'markdown-preview-enhanced:toggle'

'body':
  'cmd-t': 'application:new-file'

'.platform-darwin atom-text-editor':
  'shift-cmd-j': 'tree-view:reveal-active-file'
```
**plugin**:
- [Hyperclick](https://atom.io/packages/hyperclick)
- [sublime-style-column-selection](https://atom.io/packages/Sublime-Style-Column-Selection)
- [multi-cursor](https://atom.io/packages/multi-cursor)

### VSCode
**keymap file**: `~/Library/Application Support/Code/User/keybindings.json`
``` json
[
    {
        "key": "cmd+d",
        "command": "editor.action.copyLinesDownAction",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "shift+alt+down",
        "command": "-editor.action.copyLinesDownAction",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "cmd+e",
        "command": "-actions.find"
    },
    {
        "key": "shift+f3",
        "command": "-editor.action.previousMatchFindAction",
        "when": "editorFocus"
    },
    {
        "key": "f3",
        "command": "-editor.action.nextMatchFindAction",
        "when": "editorFocus"
    },
    {
        "key": "cmd+r",
        "command": "editor.action.startFindReplaceAction"
    },
    {
        "key": "alt+cmd+f",
        "command": "-editor.action.startFindReplaceAction"
    },
    {
        "key": "shift+cmd+u",
        "command": "editor.action.transformToUppercase"
    },
    {
        "key": "shift+cmd+l",
        "command": "editor.action.transformToLowercase"
    },
    {
        "key": "alt+down",
        "command": "cursorColumnSelectDown",
        "when": "editorTextFocus"
    },
    {
        "key": "shift+alt+cmd+down",
        "command": "-cursorColumnSelectDown",
        "when": "editorTextFocus"
    },
    {
        "key": "shift+alt+cmd+down",
        "command": "-cursorColumnSelectDown",
        "when": "editorTextFocus"
    },
    {
        "key": "alt+up",
        "command": "cursorColumnSelectUp",
        "when": "editorTextFocus"
    },
    {
        "key": "shift+alt+cmd+up",
        "command": "-cursorColumnSelectUp",
        "when": "editorTextFocus"
    },
    {
        "key": "shift+alt+up",
        "command": "editor.action.moveLinesUpAction",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "alt+up",
        "command": "-editor.action.moveLinesUpAction",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "shift+alt+down",
        "command": "editor.action.moveLinesDownAction",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "alt+down",
        "command": "-editor.action.moveLinesDownAction",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "alt+enter",
        "command": "markdown-preview-enhanced.openPreview",
        "when": "editorLangId == 'markdown'"
    },
    {
        "key": "cmd+k v",
        "command": "-markdown-preview-enhanced.openPreview",
        "when": "editorLangId == 'markdown'"
    },
    {
        "key": "cmd+t",
        "command": "workbench.action.files.newUntitledFile"
    },
    {
        "key": "cmd+n",
        "command": "-workbench.action.files.newUntitledFile"
    },
    {
        "key": "cmd+\\",
        "command": "workbench.action.toggleSidebarVisibility"
    },
    {
        "key": "cmd+b",
        "command": "-workbench.action.toggleSidebarVisibility"
    },
    {
        "key": "shift+cmd+j",
        "command": "workbench.files.action.showActiveFileInExplorer"
    }
]
```

### Xcode
``` xml
<key>Custom</key>
<dict>
    <key>Duplicate Lines</key>
    <string>selectLine:, copy:, moveToBeginningOfLine:, paste:<string>
</dict>
```
