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

### autojump
A faster way to navigate your filesystem
``` bash
j foo
```

<!-- more -->

### git
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

## Custom Plugins
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-completions](https://github.com/zsh-users/zsh-completions)

## Notice
Escape the `^` in command like `git reset HEAD^` in zsh.
``` bash
git reset HEAD\^
```

## .zshrc
``` bash
######################## Theme ########################

POWERLEVEL9K_INSTALLATION_PATH=$ANTIGEN_BUNDLES/bhilburn/powerlevel9k
POWERLEVEL9K_MODE=nerdfont-complete
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status context dir dir_writable rbenv vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(root_indicator background_jobs time)
POWERLEVEL9K_STATUS_VERBOSE=false
POWERLEVEL9K_SHORTEN_DIR_LENGTH=4
POWERLEVEL9K_DIR_WRITABLE_FORBIDDEN_FOREGROUND="white"
POWERLEVEL9K_VCS_GIT_GITHUB_ICON='\uf09b'
# POWERLEVEL9K_SHOW_CHANGESET=true
# POWERLEVEL9K_CHANGESET_HASH_LENGTH=6
POWERLEVEL9K_TIME_FORMAT="%D{%H:%M}"

DEFAULT_USER=$USER

######################## Antigen ########################

source /usr/local/share/antigen/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh)
antigen bundle colored-man-pages
antigen bundle extract
antigen bundle autojump
antigen bundle git
antigen bundle npm
antigen bundle gem
antigen bundle brew
antigen bundle osx
antigen bundle pod

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# Fish-like auto suggestions
antigen bundle zsh-users/zsh-autosuggestions

# Extra zsh completions
antigen bundle zsh-users/zsh-completions

# Load the theme.
antigen theme bhilburn/powerlevel9k powerlevel9k

# Tell Antigen that you're done.
antigen apply

######################## User Configuration ########################

export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin"

# list
alias ls='ls -hFG'
alias tree='tree -C -I node_modules'
alias l='exa -aghlF --git'
alias ltree='exa -ghlFT --git -I=node_modules'

# ncdu
alias ncdu="ncdu --color dark -rr -x"
alias ncdu-exclude="ncdu --color dark -rr -x --exclude .git --exclude node_modules"

# fzf
alias preview="fzf --preview 'bat --color \"always\" {} || tree -C {}'"
export FZF_DEFAULT_COMMAND='fd'                                     # Set fd as the default source for fzf
export FZF_DEFAULT_OPTS="--bind='ctrl-o:execute(code {})+abort'"    # Use ctrl+o to open the selected file in VS Code

## Command history
### fh - repeat history
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

## Homebrew
### Install (one or multiple) selected application(s)
### using "brew search" as source input
### mnemonic [B]rew [I]nstall [P]lugin
bip() {
  local inst=$(brew search | fzf -m)

  if [[ $inst ]]; then
    for prog in $(echo $inst);
    do; brew install $prog; done;
  fi
}
```
