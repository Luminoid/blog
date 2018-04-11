---
title: Mac Development Config
date: 2017-08-08 22:45:55
updated:
categories: Mac
tags:
  - Homebrew
  - zsh
  - Atom
  - Docker
keywords:
  - Homebrew
  - zsh
  - Atom
  - Docker
---

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [Package Manager](#package-manager)
	* [Homebrew](#homebrewhttpsbrewsh)
		* [Install](#install)
		* [Usage](#usage)
	* [Homebrew-Cask](#homebrew-caskhttpscaskroomgithubio)
		* [Install](#install-1)
		* [Usage](#usage-1)
	* [npm](#npmhttpswwwnpmjscom)
		* [Install](#install-2)
		* [Usage](#usage-2)
	* [Yarn](#yarnhttpsyarnpkgcom)
		* [Install](#install-3)
		* [Usage](#usage-3)
* [Terminal](#terminal)
	* [iTerm2](#iterm2httpswwwiterm2com)
	* [oh-my-zsh](#oh-my-zshhttpohmyzsh)
		* [Install](#install-4)
		* [Theme](#theme)
			* [agnoster](#agnosterhttpsgithubcomagnosteragnoster-zsh-theme)
		* [.zshrc](#zshrc)
* [Version Control](#version-control)
	* [Git](#git)
		* [Usage](#usage-4)
		* [SSH](#ssh)
		* [Git GUI](#git-gui)
* [Language](#language)
	* [Python3](#python3httpswwwpythonorg)
		* [Install](#install-5)
	* [JavaScript](#javascript)
* [Text Editor](#text-editor)
	* [Atom](#atomhttpsatomio)
		* [Usage](#usage-5)
	* [VSCode](#vscodehttpscodevisualstudiocom)
		* [Usage](#usage-6)
	* [Vim](#vimwwwvimorg)
		* [.vimrc](#vimrc)
* [IDE](#ide)
	* [Xcode](#xcodehttpsdeveloperapplecomcnxcode)
* [Tool](#tool)
	* [Docker](#dockerhttpswwwdockercom)
		* [Install](#install-6)
		* [Usage](#usage-7)
* [Browser](#browser)

<!-- /code_chunk_output -->

<!-- excerpt -->

<!-- TOC -->

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

### [Yarn](https://yarnpkg.com/)
#### Install
``` bash
brew install yarn
```

#### Usage
{% post_link Yarn-Usage %}

## Terminal
### [iTerm2](https://www.iterm2.com)

### [oh-my-zsh](http://ohmyz.sh)
#### Install
``` bash
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

#### Theme
##### [agnoster](https://github.com/agnoster/agnoster-zsh-theme)

#### .zshrc
``` bash
# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

DEFAULT_USER="Luminoid"

# Theme           ~/.oh-my-zsh/themes/
ZSH_THEME="agnoster"

# Plugins         ~/.oh-my-zsh/plugins/
# Custom plugins  ~/.oh-my-zsh/custom/plugins/
plugins=(git brew node npm osx colored-man-pages zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration
export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin"

# LSCOLORS
export LSCOLORS="exfxcxdxbxexexabagacad"
alias ls='ls -hG'
alias l='ls -ahlF'

# This source command must be at the end of ~/.zshrc
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```

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

## Text Editor
### [Atom](https://atom.io)
#### Usage
{% post_link Atom-Usage %}

### [VSCode](https://code.visualstudio.com)
#### Usage
{% post_link VS-Code-Usage %}

### [Vim](www.vim.org/)
#### .vimrc
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

## IDE
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
