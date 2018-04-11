---
title: Mac Usage
date: 2018-03-07 00:56:07
updated:
categories: Mac
tags:
  - bash
keywords:
  - Preferences
  - bash
---

<!-- TOC -->

## Preferences
### Manage Login Items
System Preferences -> Users & Groups -> Login Items

<!-- more -->

## Commands
### System
#### Open Apps From the Unidentified Developers
Location: System Preferences -> Security & Privacy -> General -> Choose “Anywhere”
``` bash
$ sudo spctl --master-disable
```

### oh-my-zsh
Escape the `^` in command like `git reset HEAD^` in zsh.
``` bash
git reset HEAD\^
```

#### Git
View the following file to check the git-related `alias`
``` bash
vim ~/.oh-my-zsh/plugins/git/git.plugin.zsh
```
Some common `alias`
``` bash
alias g='git'

alias gsb='git status -sb'

alias glg='git log --stat'
alias glgg='git log --graph'
alias glo='git log --oneline --decorate'
alias glola="git log --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"
alias gloga='git log --oneline --decorate --graph --all'

alias ga='git add'
alias gaa='git add --all'

alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gca='git commit -v -a'
alias gcam='git commit -a -m'
alias gcmsg='git commit -m'

alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'

alias gd='git diff'

alias gb='git branch'

alias gco='git checkout'
alias gcb='git checkout -b'

alias gm='git merge'

alias grb='git rebase'

alias gf='git fetch'
alias gfa='git fetch --all --prune'

alias gl='git pull'

alias gp='git push'
alias gpsup='git push --set-upstream origin $(git_current_branch)'
```

## Directories
### Xcode
Simulator devices data: `~/Library/Developer/CoreSimulator/Devices`
