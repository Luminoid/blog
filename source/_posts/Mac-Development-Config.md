---
title: Mac Development Config
date: 2017-08-08 22:45:55
updated:
categories: Mac
tags:
  - Homebrew
  - Atom
  - Docker
keywords:
  - Homebrew
  - Atom
  - Docker
---

<!-- toc orderedList:0 depthFrom:1 depthTo:6 -->

* [Package Manager](#package-manager)
    * [Homebrew](#homebrewhttpsbrewsh)
        * [Install](#install)
        * [Usage](#usage)
        * [Formula](#formula)
            * [tig](#tighttpsjonasgithubiotig)
            * [tree](#tree)
            * [readline](#readlinehttpcnswwwcnscwrueduphpchetreadlinerltophtml)
            * [rlwrap](#rlwraphttpsgithubcomhanslub42rlwrap)
            * [pngquant](#pngquanthttpspngquantorg)
    * [Homebrew-Cask](#homebrew-caskhttpscaskroomgithubio)
        * [Install](#install-1)
        * [Usage](#usage-1)
* [Terminal](#terminal)
    * [iTerm2](#iterm2httpswwwiterm2com)
    * [oh-my-zsh](#oh-my-zshhttpohmyzsh)
        * [Install](#install-2)
        * [Theme](#theme)
            * [agnoster](#agnosterhttpsgithubcomagnosteragnoster-zsh-theme)
* [Text Editor](#text-editor)
    * [Atom](#atomhttpsatomio)
        * [Usage](#usage-2)
* [IDE](#ide)
    * [Xcode](#xcodehttpsdeveloperapplecomcnxcode)
* [Version Control](#version-control)
    * [Git](#git)
* [Tool](#tool)
    * [Docker](#dockerhttpswwwdockercom)
        * [Install](#install-3)
        * [Cheat Sheet](#cheat-sheet)

<!-- tocstop -->

<!-- more -->

## Package Manager
### [Homebrew](https://brew.sh)
#### Install
``` bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

#### Usage
`brew install wget`: Install formula.
`brew leaves`: Show installed formulae that are  not  dependencies  of  another installed formula.

#### Formula
##### [tig](https://jonas.github.io/tig/)
Tig is an ncurses-based text-mode interface for git.

##### tree
List contents of directories in a tree-like format.

##### [readline](http://cnswww.cns.cwru.edu/php/chet/readline/rltop.html)
The GNU Readline library provides a set of functions for use by applications that allow users to edit command lines as they are typed in.

##### [rlwrap](https://github.com/hanslub42/rlwrap)
rlwrap is a 'readline wrapper', a small utility that uses the GNU readline library to allow the editing of keyboard input for any command.

##### [pngquant](https://pngquant.org)
pngquant is a command-line utility and a library for lossy compression of PNG images.
``` bash
pngquant --ext .png --force 256 *.png */*.png
```

### [Homebrew-Cask](https://caskroom.github.io)
#### Install
``` bash
brew tap caskroom/cask
```

#### Usage
``` bash
brew cask install google-chrome
```

## Terminal
### [iTerm2](https://www.iterm2.com)

### [oh-my-zsh](http://ohmyz.sh)
#### Install
``` bash
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

#### Theme
##### [agnoster](https://github.com/agnoster/agnoster-zsh-theme)

## Text Editor
### [Atom](https://atom.io)
#### Usage
[Atom Usage](https://luminoid.github.io/blog/Tool/Atom-Usage/)

## IDE
### [Xcode](https://developer.apple.com/cn/xcode/)

## Version Control
### Git
[Generating a new SSH key and adding it to the ssh-agent](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)

## Tool
### [Docker](https://www.docker.com)
#### Install
``` bash
brew cask install docker
```

#### Cheat Sheet
https://luminoid.github.io/blog/Tool/Docker-Cheat-Sheet/
