---
title: oh-my-zsh Usage
date: 2018-08-01 08:54:47
updated:
categories: Tool
tags: 
- oh-my-zsh
keywords: 
- oh-my-zsh
- powerlevel9k
- antigen
---

## Theme
### [powerlevel9k](https://github.com/bhilburn/powerlevel9k)

## Plugin Manager
### [antigen](https://github.com/zsh-users/antigen)
#### Install
``` bash
brew install antigen
```

## Plugins
[Plugins Overview](https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins-Overview)

### extract
Extract archive files
``` bash
extract <filename>
```

<!-- more -->

### git
View the following file to check the git-related `alias`
``` bash
vim ~/.antigen/bundles/robbyrussell/oh-my-zsh/plugins/git/git.plugin.zsh
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

## Custom Plugins
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-completions](https://github.com/zsh-users/zsh-completions)

## Notice
Escape the `^` in command like `git reset HEAD^` in zsh.
``` bash
git reset HEAD\^
```
