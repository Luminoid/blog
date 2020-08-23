---
title: Homebrew Usage
date: 2017-12-04 23:55:06
updated:
categories: Mac
tags: 
- Package manager
- Homebrew
---

Official Site: https://brew.sh

## Command
``` bash
brew install <formula>  # Install formula
brew update             # Fetch the newest version of Homebrew and all formulae from GitHub
brew upgrade            # Upgrade all outdated, unpinned packages
brew leaves             # Show installed formulae that are not dependencies of another installed formula
brew tap                # Tap a formula repository
brew doctor             # Check your system for potential problems.
brew cleanup            # Remove stale lock files and outdated downloads for formulae and casks, and remove old versions of installed formulae.
```

<!-- more -->

## Formula
### [autojump](https://github.com/wting/autojump)
> A faster way to navigate your filesystem
``` bash
j <dir>
```

### [automake](https://www.gnu.org/software/automake/)
> Tool for generating GNU Standards-compliant Makefiles

### [autoconf](https://www.gnu.org/software/autoconf/autoconf.html)
> Automatic configure script builder

### [bat](https://github.com/sharkdp/bat)
> Clone of `cat(1)` with syntax highlighting and Git integration
``` bash
bat <file>
```

### [cmake](https://www.cmake.org/)
> Cross-platform make

### [coreutils](https://www.gnu.org/software/coreutils)
> GNU File, Shell, and Text utilities

### [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy)
> Good-lookin' diffs with diff-highlight and more

### [exa](https://the.exa.website)
> Modern replacement for `ls`

### [fd](https://github.com/sharkdp/fd)
> Simple, fast and user-friendly alternative to find
``` bash
fd <pattern>
```

### [ffmpeg](https://www.ffmpeg.org)
> Play, record, convert, and stream audio and video

### [fzf](https://github.com/junegunn/fzf)
> A command-line fuzzy finder
``` bash
fzf
```

### [graphicsmagick](http://www.graphicsmagick.org/)
> Image processing tools collection

### [htop](https://hisham.hm/htop/)
> Improved top (interactive process viewer)

### [httrack](http://www.httrack.com/)
> Website copier/offline browser
``` bash
httrack <URLs>
```

### [mtr](https://www.bitwizard.nl/mtr/)
> `traceroute` and `ping` in a single tool

### [ncdu](https://dev.yorhel.nl/ncdu)
> NCurses Disk Usage

### [pandoc](https://pandoc.org/)
> Swiss-army knife of markup format conversion

### [pinentry](https://www.gnupg.org/related_software/pinentry/)
> Passphrase entry dialog utilizing the Assuan protocol

### [pngquant](https://pngquant.org)
> PNG image optimizing utility
``` bash
pngquant --ext .png --force 256 *.png */*.png
```

### [prettyping](https://denilsonsa.github.io/prettyping/)
> Wrapper to colorize and simplify ping's output
``` bash
prettyping
```

### [rlwrap](https://github.com/hanslub42/rlwrap)
> rlwrap is a 'readline wrapper', a small utility that uses the GNU readline library to allow the editing of keyboard input for any command.

### [scons](https://www.scons.org/)
> Substitute for classic `make` tool with autoconf/automake functionality

### [tesseract](https://github.com/tesseract-ocr/)
> OCR (Optical Character Recognition) engine

### [the_silver_searcher](https://github.com/ggreer/the_silver_searcher)
> A code searching tool similar to `ack`, with a focus on speed.

### [tig](https://jonas.github.io/tig/)
> Text interface for Git repositories

### [tldr](https://tldr.sh/)
> Simplified and community-driven man pages
``` bash
tldr <command>
```

### [tree](http://mama.indstate.edu/users/ice/tree/)
> Display directories as trees (with optional color/HTML output)
``` bash
tree -L <num> -a
```

### [unrar](https://www.rarlab.com/)
> Watch files and take action when they change

## Cask
### [launchrocket](https://github.com/jimbojsb/launchrocket)
> A Mac PrefPane to manage all your Homebrew-installed services
