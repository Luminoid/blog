---
title: Zsh Usage
date: 2021-11-08 01:08:52
updated:
categories: Shell
tags:
- zsh
- oh-my-zsh
- powerlevel10k
- antigen
---

## [oh-my-zsh](https://ohmyz.sh)
### Installation
``` bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Theme
[powerlevel10k](https://github.com/romkatv/powerlevel10k)

## Plugins
[Oh My Zsh Plugins](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins-Overview)

## Plugin Manager
### [antigen](https://github.com/zsh-users/antigen)

<!-- more -->

## .zshrc
``` bash
######################## Powerlevel10k ########################
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


######################## Antigen ########################

source /opt/homebrew/share/antigen/antigen.zsh
source $HOMEBREW_PREFIX/opt/chruby/share/chruby/chruby.sh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh)
antigen bundle colored-man-pages
antigen bundle extract
antigen bundle history
antigen bundle z
antigen bundle git
antigen bundle npm
antigen bundle gem
antigen bundle python
antigen bundle brew
antigen bundle osx
antigen bundle pod

# Fish shell like syntax highlighting for Zsh.
antigen bundle zsh-users/zsh-syntax-highlighting

# Fish-like autosuggestions for zsh
antigen bundle zsh-users/zsh-autosuggestions

# Additional completion definitions for Zsh.
antigen bundle zsh-users/zsh-completions

# Load the theme.
antigen theme romkatv/powerlevel10k

# Tell Antigen that you're done.
antigen apply

######################## User Configuration ########################

# list
alias ls='ls -hFG'
alias tree='tree -C -I node_modules'
alias l='eza -aghlF --git --icons'
alias ltree='eza -ghlTF --git -I=node_modules'

# ncdu
alias ncdu="ncdu --color dark -r -x"
alias ncdu-exclude="ncdu --color dark -r -x --exclude .git --exclude node_modules"
```
