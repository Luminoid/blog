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

This post intended to provide a universal keymaps across different editors and IDEs.

<!-- more -->

## Keymaps
``` bash
'cmd-d'             Duplicate lines
'cmd-x'             Cut current line; Cut current text
'cmd-/'             Comment line

'shift-cmd-u'       Upper case current text
'shift-cmd-l'       Lower case current text

'alt-click'         Multi-cursor selection (VSCode)
'cmd-click'         Multi-cursor selection (Atom)
'alt-drag'          Column selection (Atom)
'alt-up'            Cursor column select up
'alt-down'          Cursor column select down

'alt-shift-up'      Move line up (VSCode)
'alt-shift-down'    Move line down (VSCode)
'ctrl-cmd-up'       Move line up (Atom)
'ctrl-cmd-down'     Move line down (Atom)

'cmd-f'             Search current file
'shift-cmd-f'       Search the entire project
'cmd-r'             Find and replace (VSCode)
'cmd-g'             Find next match
'shift-cmd-g'       Find previous match

'shift-cmd-p'       Toggle Command Palette
'ctrl-`'            Toggle Terminal
'cmd-\ '            Toggle Sidebar
'cmd+,'             Open User Settings

'alt-enter'         Toggle Markdown Preview Enhanced
```

## Config File
### Atom
``` yaml
'atom-text-editor':
  'shift-cmd-u': 'editor:upper-case'
  'shift-cmd-l': 'editor:lower-case'

'atom-workspace atom-text-editor:not([mini])':
  'cmd-d': 'editor:duplicate-lines'
  'alt-enter': 'markdown-preview-enhanced:toggle'
```

### VSCode
``` json
[
    {
        "key": "cmd+\\",
        "command": "workbench.action.toggleSidebarVisibility"
    },
    {
        "key": "cmd+b",
        "command": "-workbench.action.toggleSidebarVisibility"
    },
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
    }
]
```
