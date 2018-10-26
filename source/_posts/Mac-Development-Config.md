---
title: Mac Development Config
date: 2017-08-08 22:45:55
updated:
categories: Mac
tags:
keywords:
- Homebrew
- npm
- Yarn
- CocoaPods
- oh-my-zsh
- Git
- Atom
- VS Code
- Docker
---

## Mac Usage
{% post_link Mac-Usage %}

## Package Manager
### [Homebrew](https://brew.sh)
#### Install
``` bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

#### Usage
{% post_link Homebrew-Usage %}

### [Homebrew-Cask](https://caskroom.github.io)
#### Install
``` bash
brew tap caskroom/cask
```

#### Usage
``` bash
brew cask install google-chrome
```

### [npm](https://www.npmjs.com)
#### Install
``` bash
brew install node
```

#### Usage
{% post_link npm-Usage %}

<!-- more -->

### [Yarn](https://yarnpkg.com/)
#### Install
``` bash
brew install yarn
```

#### Usage
{% post_link Yarn-Usage %}

### [CocoaPods](https://cocoapods.org)
#### Install
``` bash
sudo gem install cocoapods
```

#### Usage
{% post_link CocoaPods-Usage %}

## Shell
### [oh-my-zsh](http://ohmyz.sh)
#### Install
``` bash
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

#### Usage
{% post_link oh-my-zsh-Usage %}

## Terminal
### [iTerm2](https://www.iterm2.com)

## Version Control
### Git
#### Usage
{% post_link Git-Amateur-Guide %}

#### SSH
[Generating a new SSH key and adding it to the ssh-agent](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)
#### Git GUI
[SourceTree](https://www.sourcetreeapp.com)

## Language
### [Python3](https://www.python.org)
#### Install
``` bash
brew install python3
```

### JavaScript
Run `node` to toggle ES REPL.
Run `node --v8-options | grep harmony` to check current supported ES6 features.

## Version Manager
### [n](https://www.npmjs.com/package/n)
#### Install
``` bash
brew install n
```

#### Usage
``` bash
sudo n latest   # Use or install the latest official release
sudo n lts      # Use or install the latest LTS official release
```

## Text Editor
### [Atom](https://atom.io)
#### Usage
{% post_link Atom-Usage %}

### [VSCode](https://code.visualstudio.com)
#### Usage
{% post_link VS-Code-Usage %}

### [Vim](www.vim.org/)
#### Install
``` bash
brew install vim
```

## IDE
### [JetBrains](https://www.jetbrains.com/)
[Toolbox](https://www.jetbrains.com/toolbox/app/)

### [Xcode](https://developer.apple.com/cn/xcode/)

## Tool
### [Docker](https://www.docker.com)
#### Install
``` bash
brew cask install docker
```

#### Usage
{% post_link Docker-Cheat-Sheet %}

## Browser
{% post_link Browser-Enhancement %}

## System Enhancement
### [quick-look-plugins](https://github.com/sindresorhus/quick-look-plugins)
#### Install
``` bash
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlimagesize webpquicklook suspicious-package quicklookase qlvideo
```

### [Alfred](https://www.alfredapp.com/)
#### Workflows
- https://www.alfredapp.com/workflows/
- http://www.packal.org/
- https://github.com/zenorocha/alfred-workflows
- http://www.alfredworkflow.com/

### [Dozer](https://github.com/Mortennn/Dozer)
Hide MacOS menubar items.

### [FiScript](https://github.com/Mortennn/FiScript)
Execute custom scripts from the MacOS context menu (CTRL+click) in Finder.

### [OpenInCode](https://github.com/sozercan/OpenInCode)
macOS Finder toolbar app to open current folder in Visual Studio Code

## Font
### [Fira Code](https://github.com/tonsky/FiraCode)
#### Install
``` bash
brew tap caskroom/fonts
brew cask install font-fira-code font-firacode-nerd-font
```

## Quick Configuration
### Package Manager
``` bash
brew install antigen autojump automake bat cmake diff-so-fancy exa fd ffmpeg fzf gdb git git-lfs graphicsmagick highlight htop hunspell librsvg mtr mysql nasm ncdu openvpn pandoc phantomjs pinentry pngquant prettyping r rlwrap scons sqlmap swiftlint tesseract the_silver_searcher tig tldr tmux tree unrar vim watchman wget yarn
brew tap caskroom/cask
brew tap caskroom/fonts
brew cask install font-fira-code font-firacode-nerd-font font-hack-nerd-font launchrocket qlcolorcode qlimagesize qlmarkdown qlstephen qlvideo  quicklook-json quicklookase suspicious-package webpquicklook
npm install -g npm-check
sudo gem install cocoapods
```

### Git Config
``` bash
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global color.ui true

git config --global color.diff.meta       "yellow"
git config --global color.diff.frag       "magenta bold"
git config --global color.diff.commit     "yellow bold"
git config --global color.diff.old        "red bold"
git config --global color.diff.new        "green bold"
git config --global color.diff.whitespace "red reverse"
```

### .zshrc
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

# npm
export PATH="$HOME/.npm-packages/bin:$PATH"

# gem
export GEM_HOME="$HOME/.gem"
export PATH="$GEM_HOME/bin:$PATH"

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

### .vimrc
``` vim
" Vundle
" ---------------------------------------------------------------
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'tpope/vim-fugitive'
" vim-airline
" ---------------------------------------------------------------
Plugin 'vim-airline/vim-airline'
let g:airline_theme="molokai"
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1

Plugin 'vim-airline/vim-airline-themes'
Plugin 'vim-syntastic/syntastic'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" VIM user interface
" ---------------------------------------------------------------
set number "Always show line number
set ruler  "Always show current position

" Color Scheme
" ---------------------------------------------------------------
syntax enable
let g:neodark#use_256color = 1 " default: 0
let g:neodark#terminal_transparent = 1 " default: 0
colorscheme neodark

" Mouth
" ---------------------------------------------------------------
set mouse=a

" Tab
" ---------------------------------------------------------------
set expandtab "Use spaces instead of tabs
set tabstop=4 "1 tab == 4 spaces
set softtabstop=4
set smartindent shiftwidth=4 "Auto indent
```
