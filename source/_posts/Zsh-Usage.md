---
title: Zsh Usage
date: 2021-11-08 01:08:52
categories:
  - Shell
tags:
  - zsh
  - oh-my-zsh
  - powerlevel10k
  - antigen
  - zinit
  - starship
---

A working zsh config from 2021 plus the swap-ins worth making for a 2026 setup.

<!-- more -->

## What's current (2026)

The plugin manager and prompt below still work, but they are no longer the modern default:

- **Plugin manager**: [antigen](https://github.com/zsh-users/antigen) has had no real maintenance since 2018. New setups use [zinit](https://github.com/zdharma-continuum/zinit) (fast, lazy-load, hooks for everything), [znap](https://github.com/marlonrichert/zsh-snap) (smaller surface, faster startup), or oh-my-zsh's built-in plugin loader (no third-party manager needed for the common case).
- **Prompt**: [Powerlevel10k](https://github.com/romkatv/powerlevel10k) still works, but its maintainer paused most active development in 2024. [Starship](https://starship.rs) is the current cross-shell default: one Rust binary, one TOML config, identical prompt under zsh, bash, fish, nu. Old `~/.p10k.zsh` is not portable, so allow some time to recreate the segments worth keeping.
- **CLI replacements**: `bat` for `cat`, `fd` for `find`, `ripgrep` for `grep`, `dust` for `du`, `procs` for `ps`, `zoxide` for `z`/`autojump`. See {% post_link M1-Mac-Development-Setup "Mac development setup" %} for the full list.

Migrate the prompt first; plugins rarely need rewriting when only the manager changes.

## Install oh-my-zsh

[oh-my-zsh](https://ohmyz.sh) is still the easiest base, even if you skip antigen:

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

[Plugins overview](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins-Overview).

## Reference `.zshrc` (2021 setup, oh-my-zsh + antigen + Powerlevel10k)
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
chruby ruby-3.4.2

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
