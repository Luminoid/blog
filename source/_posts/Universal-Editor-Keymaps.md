---
title: Universal Editor Keymaps
date: 2018-03-17 23:25:41
updated:
categories:
- Tool
- Editor
tags:
- VS Code
- Atom
- Xcode
- JetBrains
keywords:
- VS Code
- Atom
- Xcode
- JetBrains
- Editor
- Keymaps
---

This post intended to provide a universal keymaps across different editors and IDEs on Mac.

<!-- more -->

## Keymaps

| Command | Universal Key | VS Code | Atom | Xcode | JetBrains |
| ------- | ------------- | ---- | ------ | ----- | --------- |
| **Edit Text** | | | | | |
| Upper case current text               | `shift-cmd-u`     |   |                   |   | `shift-cmd-u` |
| Lower case current text               | `shift-cmd-l`     |   |                   |   | `shift-cmd-u` |
| **Edit Lines**                        |                   |   |                   |   |               |
| Duplicate lines                       | `cmd-d`           |   |                   |   |               |
| Cut current line; Cut current text    | `cmd-x`           |   |                   | / |               |
| Comment line                          | `cmd-/`           |   |                   |   |               |
| Move line up                          | `alt-shift-up`    |   | `ctrl-cmd-up`     |   |               |
| Move line down                        | `alt-shift-down`  |   | `ctrl-cmd-down`   |   |               |
| **Selection**                         |                   |   |                   |   |               |
| Multi-cursor selection                | `alt-click`       |   | `cmd-alt-click`   | / |               |
| Column selection                      | `alt-drag`        | / |                   |   |               |
| Cursor column select up               | `alt-up`          |   |                   | / | /             |
| Cursor column select down             | `alt-down`        |   |                   | / | /             |
| **Navigation**                        |                   |   |                   |   |               |
| Go to Definition                      | `cmd-click`       |   | /                 |   |               |
| Open Quickly                          | `shift-cmd-o`     |   |                   |   |               |
| Reveal in Project View                | `shift-cmd-j`     |   |                   |   |               |
| **Find**                              |                   |   |                   |   |               |
| Find in the current file              | `cmd-f`           |   |                   |   |               |
| Find in the entire project            | `shift-cmd-f`     |   |                   |   |               |
| Find and replace                      | `cmd-r`           |   | `cmd-f`           | / |               |
| Find next match                       | `cmd-g`           |   |                   |   |               |
| Find previous match                   | `shift-cmd-g`     |   |                   |   |               |
| **View**                              |                   |   |                   |   |               |
| Toggle Command Palette                | `shift-cmd-p`     |   |                   | / | /             |
| Toggle Terminal                       | `` ctrl-` ``      |   |                   | / |               |
| Toggle Sidebar                        | `cmd-\ `          |   |                   |   |               |
| Open User Settings                    | `cmd-,`           |   |                   |   |               |
| **Tab**                               |                   |   |                   |   |               |
| Open new tab                          | `cmd-t`           |   |                   |   | /             |
| Switch to the previous tab            | `shift-cmd-[`     |   |                   |   |               |
| Switch to the next tab                | `shift-cmd-]`     |   |                   |   |               |
| **Plugin**                            |                   |   |                   |   |               |
| Toggle Markdown Preview Enhanced      | `alt-enter`       |   |                   | / | /             |

## Config
### VSCode
**keymap file**:
`~/Library/Application Support/Code/User/keybindings.json`
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
    },
    {
        "key": "shift+cmd+o",
        "command": "workbench.action.quickOpen"
    },
    {
        "key": "cmd+p",
        "command": "-workbench.action.quickOpen"
    }
]
```

### Atom
**keymap file**:
`~/.atom/keymap.cson`
``` yaml
'atom-text-editor':
  'shift-cmd-u': 'editor:upper-case'
  'shift-cmd-l': 'editor:lower-case'

'atom-workspace atom-text-editor:not([mini])':
  'cmd-d': 'editor:duplicate-lines'
  'alt-enter': 'markdown-preview-enhanced:toggle'

'body':
  'cmd-t': 'application:new-file'

'.platform-darwin':
  'shift-cmd-o': 'fuzzy-finder:toggle-file-finder'

'.platform-darwin atom-text-editor':
  'shift-cmd-j': 'tree-view:reveal-active-file'
```
**plugin**:
- [Hyperclick](https://atom.io/packages/hyperclick)
- [sublime-style-column-selection](https://atom.io/packages/Sublime-Style-Column-Selection)
- [multi-cursor](https://atom.io/packages/multi-cursor)

### Xcode
**keymap file**:
`~/Library/Developer/Xcode/UserData/KeyBindings/Custom.idekeybindings`
``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Menu Key Bindings</key>
    <dict>
        <key>Key Bindings</key>
        <array>
            <dict>
                <key>Action</key>
                <string>buildForTestActiveRunContext:</string>
                <key>Alternate</key>
                <string>NO</string>
                <key>CommandID</key>
                <string>Xcode.IDEKit.CmdDefinition.BuildForTest</string>
                <key>Group</key>
                <string>Product Menu</string>
                <key>GroupID</key>
                <string>Xcode.IDEKit.MenuDefinition.Main</string>
                <key>GroupedAlternate</key>
                <string>NO</string>
                <key>Navigation</key>
                <string>NO</string>
                <key>Parent Title</key>
                <string>Build For</string>
                <key>Title</key>
                <string>Testing</string>
            </dict>
            <dict>
                <key>Action</key>
                <string>duplicate:</string>
                <key>Alternate</key>
                <string>NO</string>
                <key>CommandID</key>
                <string>Xcode.IDEKit.CmdDefinition.Duplicate</string>
                <key>Group</key>
                <string>Edit Menu</string>
                <key>GroupID</key>
                <string>Xcode.IDEKit.MenuDefinition.Main</string>
                <key>GroupedAlternate</key>
                <string>NO</string>
                <key>Navigation</key>
                <string>NO</string>
                <key>Title</key>
                <string>Duplicate</string>
            </dict>
            <dict>
                <key>Action</key>
                <string>jumpToSelection:</string>
                <key>Alternate</key>
                <string>NO</string>
                <key>CommandID</key>
                <string>Xcode.IDEKit.CmdDefinition.JumpToSelection</string>
                <key>Group</key>
                <string>Navigate Menu</string>
                <key>GroupID</key>
                <string>Xcode.IDEKit.MenuDefinition.Main</string>
                <key>GroupedAlternate</key>
                <string>NO</string>
                <key>Navigation</key>
                <string>YES</string>
                <key>Title</key>
                <string>Jump to Selection</string>
            </dict>
            <dict>
                <key>Action</key>
                <string>toggleNavigatorsVisibility:</string>
                <key>Alternate</key>
                <string>NO</string>
                <key>CommandID</key>
                <string>Xcode.IDEKit.CmdDefinition.NavigatorsToggleVisibility</string>
                <key>Group</key>
                <string>View Menu</string>
                <key>GroupID</key>
                <string>Xcode.IDEKit.MenuDefinition.Main</string>
                <key>GroupedAlternate</key>
                <string>NO</string>
                <key>Keyboard Shortcut</key>
                <string>@\\</string>
                <key>Navigation</key>
                <string>NO</string>
                <key>Parent Title</key>
                <string>Navigators</string>
                <key>Title</key>
                <string>Show Navigator</string>
            </dict>
            <dict>
                <key>Action</key>
                <string>toggleBreakpointAtCurrentLine:</string>
                <key>Alternate</key>
                <string>NO</string>
                <key>CommandID</key>
                <string>Xcode.IDEKit.CmdDefinition.ToggleBreakpointAtCurrentLine</string>
                <key>Group</key>
                <string>Debug Menu</string>
                <key>GroupID</key>
                <string>Xcode.IDEKit.MenuDefinition.Main</string>
                <key>GroupedAlternate</key>
                <string>NO</string>
                <key>Navigation</key>
                <string>NO</string>
                <key>Parent Title</key>
                <string>Breakpoints</string>
                <key>Title</key>
                <string>Add Breakpoint at Current Line</string>
            </dict>
            <dict>
                <key>Action</key>
                <string>moveCurrentLineDown:</string>
                <key>Alternate</key>
                <string>NO</string>
                <key>CommandGroupID</key>
                <string>Xcode.IDESourceEditor.CmdDefinition.MoveLineDown</string>
                <key>CommandID</key>
                <string>Xcode.IDESourceEditor.CmdDefinition.MoveLineDown</string>
                <key>Group</key>
                <string>Editor Menu for Asset Catalog Comparison</string>
                <key>GroupID</key>
                <string>Xcode.IDESourceCodeComparisonEditor.MenuDefinition.Editor</string>
                <key>GroupedAlternate</key>
                <string>NO</string>
                <key>Keyboard Shortcut</key>
                <string>~$</string>
                <key>Navigation</key>
                <string>NO</string>
                <key>Parent Title</key>
                <string>Structure</string>
                <key>Title</key>
                <string>Move Line Down</string>
            </dict>
            <dict>
                <key>Action</key>
                <string>moveCurrentLineDown:</string>
                <key>Alternate</key>
                <string>NO</string>
                <key>CommandGroupID</key>
                <string>Xcode.IDESourceEditor.CmdDefinition.MoveLineDown</string>
                <key>CommandID</key>
                <string>Xcode.IDESourceEditor.CmdDefinition.MoveLineDown</string>
                <key>Group</key>
                <string>Editor Menu for Playground</string>
                <key>GroupID</key>
                <string>Xcode.IDEPegasusPlaygroundEditor.MenuDefinition.Editor</string>
                <key>GroupedAlternate</key>
                <string>NO</string>
                <key>Keyboard Shortcut</key>
                <string>~$</string>
                <key>Navigation</key>
                <string>NO</string>
                <key>Parent Title</key>
                <string>Structure</string>
                <key>Title</key>
                <string>Move Line Down</string>
            </dict>
            <dict>
                <key>Action</key>
                <string>moveCurrentLineDown:</string>
                <key>Alternate</key>
                <string>NO</string>
                <key>CommandGroupID</key>
                <string>Xcode.IDESourceEditor.CmdDefinition.MoveLineDown</string>
                <key>CommandID</key>
                <string>Xcode.IDESourceEditor.CmdDefinition.MoveLineDown</string>
                <key>Group</key>
                <string>Editor Menu for Source Code</string>
                <key>GroupID</key>
                <string>Xcode.IDEPegasusSourceEditor.MenuDefinition.Editor</string>
                <key>GroupedAlternate</key>
                <string>NO</string>
                <key>Keyboard Shortcut</key>
                <string>~$</string>
                <key>Navigation</key>
                <string>NO</string>
                <key>Parent Title</key>
                <string>Structure</string>
                <key>Title</key>
                <string>Move Line Down</string>
            </dict>
            <dict>
                <key>Action</key>
                <string>moveCurrentLineDown:</string>
                <key>Alternate</key>
                <string>NO</string>
                <key>CommandGroupID</key>
                <string>Xcode.IDESourceEditor.CmdDefinition.MoveLineDown</string>
                <key>CommandID</key>
                <string>Xcode.IDESourceEditor.CmdDefinition.MoveLineDown</string>
                <key>Group</key>
                <string>Editor Menu for Source Code Comparison</string>
                <key>GroupID</key>
                <string>Xcode.IDESourceCodeComparisonEditor.MenuDefinition.Editor</string>
                <key>GroupedAlternate</key>
                <string>NO</string>
                <key>Keyboard Shortcut</key>
                <string>~$</string>
                <key>Navigation</key>
                <string>NO</string>
                <key>Parent Title</key>
                <string>Structure</string>
                <key>Title</key>
                <string>Move Line Down</string>
            </dict>
            <dict>
                <key>Action</key>
                <string>moveCurrentLineUp:</string>
                <key>Alternate</key>
                <string>NO</string>
                <key>CommandGroupID</key>
                <string>Xcode.IDESourceEditor.CmdDefinition.MoveLineUp</string>
                <key>CommandID</key>
                <string>Xcode.IDESourceEditor.CmdDefinition.MoveLineUp</string>
                <key>Group</key>
                <string>Editor Menu for Asset Catalog Comparison</string>
                <key>GroupID</key>
                <string>Xcode.IDESourceCodeComparisonEditor.MenuDefinition.Editor</string>
                <key>GroupedAlternate</key>
                <string>NO</string>
                <key>Keyboard Shortcut</key>
                <string>~$</string>
                <key>Navigation</key>
                <string>NO</string>
                <key>Parent Title</key>
                <string>Structure</string>
                <key>Title</key>
                <string>Move Line Up</string>
            </dict>
            <dict>
                <key>Action</key>
                <string>moveCurrentLineUp:</string>
                <key>Alternate</key>
                <string>NO</string>
                <key>CommandGroupID</key>
                <string>Xcode.IDESourceEditor.CmdDefinition.MoveLineUp</string>
                <key>CommandID</key>
                <string>Xcode.IDESourceEditor.CmdDefinition.MoveLineUp</string>
                <key>Group</key>
                <string>Editor Menu for Playground</string>
                <key>GroupID</key>
                <string>Xcode.IDEPegasusPlaygroundEditor.MenuDefinition.Editor</string>
                <key>GroupedAlternate</key>
                <string>NO</string>
                <key>Keyboard Shortcut</key>
                <string>~$</string>
                <key>Navigation</key>
                <string>NO</string>
                <key>Parent Title</key>
                <string>Structure</string>
                <key>Title</key>
                <string>Move Line Up</string>
            </dict>
            <dict>
                <key>Action</key>
                <string>moveCurrentLineUp:</string>
                <key>Alternate</key>
                <string>NO</string>
                <key>CommandGroupID</key>
                <string>Xcode.IDESourceEditor.CmdDefinition.MoveLineUp</string>
                <key>CommandID</key>
                <string>Xcode.IDESourceEditor.CmdDefinition.MoveLineUp</string>
                <key>Group</key>
                <string>Editor Menu for Source Code</string>
                <key>GroupID</key>
                <string>Xcode.IDEPegasusSourceEditor.MenuDefinition.Editor</string>
                <key>GroupedAlternate</key>
                <string>NO</string>
                <key>Keyboard Shortcut</key>
                <string>~$</string>
                <key>Navigation</key>
                <string>NO</string>
                <key>Parent Title</key>
                <string>Structure</string>
                <key>Title</key>
                <string>Move Line Up</string>
            </dict>
            <dict>
                <key>Action</key>
                <string>moveCurrentLineUp:</string>
                <key>Alternate</key>
                <string>NO</string>
                <key>CommandGroupID</key>
                <string>Xcode.IDESourceEditor.CmdDefinition.MoveLineUp</string>
                <key>CommandID</key>
                <string>Xcode.IDESourceEditor.CmdDefinition.MoveLineUp</string>
                <key>Group</key>
                <string>Editor Menu for Source Code Comparison</string>
                <key>GroupID</key>
                <string>Xcode.IDESourceCodeComparisonEditor.MenuDefinition.Editor</string>
                <key>GroupedAlternate</key>
                <string>NO</string>
                <key>Keyboard Shortcut</key>
                <string>~$</string>
                <key>Navigation</key>
                <string>NO</string>
                <key>Parent Title</key>
                <string>Structure</string>
                <key>Title</key>
                <string>Move Line Up</string>
            </dict>
        </array>
        <key>Version</key>
        <integer>3</integer>
    </dict>
    <key>Text Key Bindings</key>
    <dict>
        <key>Key Bindings</key>
        <dict>
            <key></key>
            <array>
                <string>moveParagraphBackwardAndModifySelection:</string>
                <string>moveParagraphForwardAndModifySelection:</string>
            </array>
            <key>$@L</key>
            <string>lowercaseWord:</string>
            <key>$@U</key>
            <string>uppercaseWord:</string>
            <key>@d</key>
            <array>
                <string>selectLine:</string>
                <string>copy:</string>
                <string>moveToBeginningOfLine:</string>
                <string>paste:</string>
            </array>
        </dict>
        <key>Version</key>
        <integer>3</integer>
    </dict>
</dict>
</plist>

```

Add Custom Command in KeyBinding file.
` /Applications/Xcode.app/Contents/Frameworks/IDEKit.framework/Versions/A/Resources/IDETextKeyBindingSet.plist`
``` xml
<dict>
    ...
    <key>Custom</key>
    <dict>
        <key>Duplicate Lines</key>
        <string>selectLine:, copy:, moveToBeginningOfLine:, paste:</string>
    </dict>
</dict>
```

### JetBrains
**keymap file**:
`~/Library/Preferences/WebStorm<xx>/keymaps/Custom.xml`
``` xml
<keymap version="1" name="Custom" parent="Mac OS X 10.5+">
  <action id="ActivateTerminalToolWindow">
    <keyboard-shortcut first-keystroke="alt f12" />
    <keyboard-shortcut first-keystroke="ctrl back_quote" />
  </action>
  <action id="HideSideWindows">
    <keyboard-shortcut first-keystroke="meta back_slash" />
  </action>
  <action id="QuickChangeScheme" />
  <action id="SelectIn">
    <keyboard-shortcut first-keystroke="alt f1" />
    <keyboard-shortcut first-keystroke="shift meta j" />
  </action>
</keymap>
```
