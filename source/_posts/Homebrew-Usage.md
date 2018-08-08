---
title: Homebrew Usage
date: 2017-12-04 23:55:06
updated:
categories: Mac
tags: 
- Package manager
- Homebrew
keywords: Homebrew
---

Official Site: https://brew.sh

## Command
``` bash
brew install <formula>  # Install formula
brew update             # Fetch latest version of Homebrew and all formulae
brew upgrade            # Upgrade all outdated, unpinned packages
brew leaves             # Show installed formulae that are not dependencies of another installed formula
brew tap                # Tap a new formula repository from GitHub, or list existing taps
brew doctor             # Audit your installation for common issues
brew cleanup            # Uninstall unused and old versions of packages
brew prune              # Remove dead links
```

<!-- more -->

## Formula
### [vim](www.vim.org/)
Vim is a highly configurable text editor built to make creating and changing any kind of text very efficient.

### [mysql](https://www.mysql.com)
MySQL is the world's most popular open source database.

### [tig](https://jonas.github.io/tig)
Tig is an ncurses-based text-mode interface for git.
``` bash
tig
```

### [autojump](https://github.com/wting/autojump)
A faster way to navigate your filesystem
``` bash
j <dir>
```

### [tree](http://brewformulas.org/Tree)
List contents of directories in a tree-like format.
``` bash
tree
```

### [pngquant](https://pngquant.org)
pngquant is a command-line utility and a library for lossy compression of PNG images.
``` bash
pngquant --ext .png --force 256 *.png */*.png
```

### [ffmpeg](https://www.ffmpeg.org)
A complete, cross-platform solution to record, convert and stream audio and video.

### [imagemagick](https://www.imagemagick.org/)
ImageMagick is a software suite to create, edit, compose, or convert bitmap images.

### [launchrocket](https://github.com/jimbojsb/launchrocket)
A Mac PrefPane to manage all your Homebrew-installed services.

### [wget](https://www.gnu.org/software/wget/)
GNU Wget is a free software package for retrieving files using HTTP, HTTPS, FTP and FTPS the most widely-used Internet protocols.

### [readline](https://tiswww.case.edu/php/chet/readline/rltop.html)
The GNU Readline library provides a set of functions for use by applications that allow users to edit command lines as they are typed in.

### [rlwrap](https://github.com/hanslub42/rlwrap)
rlwrap is a 'readline wrapper', a small utility that uses the GNU readline library to allow the editing of keyboard input for any command.

### [automake](https://www.gnu.org/software/automake/)
Automake is a tool for automatically generating `Makefile.in` files compliant with the GNU Coding Standards.

### [autoconf](https://www.gnu.org/software/autoconf/autoconf.html)
Autoconf is an extensible package of M4 macros that produce shell scripts to automatically configure software source code packages.
