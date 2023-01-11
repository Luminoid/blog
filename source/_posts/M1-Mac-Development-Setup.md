---
title: M1 Mac Development Setup
date: 2021-11-07 15:15:40
updated:
categories: Mac
tags:
- Package Manager
- Homebrew
- Git
---

## Mac Usage
{% post_link Mac-Usage %}
[Awesome Mac](https://github.com/jaywcjlove/awesome-mac)

## Package Manager
### [Homebrew](https://brew.sh)
#### Installation
``` bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Commands
``` bash
brew install <formula>      # Install formula.
brew install --cask <cask>  # Install cask.
brew update                 # Fetch the newest version of Homebrew and all formulae from GitHub.
brew upgrade                # Upgrade outdated casks and outdated, unpinned formulae.
brew leaves                 # List installed formulae that are not dependencies of another installed formula.
brew tap                    # Tap a formula repository.
brew doctor                 # Check your system for potential problems.
brew cleanup                # Remove stale lock files and outdated downloads for all formulae and casks, and remove old versions of installed formulae.
```

### [npm](https://www.npmjs.com)
#### Installation
``` bash
brew install node
```

### [Yarn](https://yarnpkg.com/)
#### Installation
``` bash
brew install yarn
```

### [CocoaPods](https://cocoapods.org)
#### Installation
``` bash
sudo gem install cocoapods
```

<!-- more -->

## Shell
{% post_link Zsh-Usage %}

## Terminal
### [iTerm2](https://iterm2.com)
#### Installation
``` bash
brew install --cask iterm2
```

#### [iTerm Color Schemes](https://github.com/mbadolato/iTerm2-Color-Schemes)

## Version Control
### Git
#### SSH
[Generating a new SSH key and adding it to the ssh-agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
#### Git GUI
[SourceTree](https://www.sourcetreeapp.com)
``` bash
brew install --cask sourcetree
```

## Languages
### [Python3](https://www.python.org)
#### Installation
``` bash
brew install python3
```

### JavaScript
{% post_link Node-js-Usage %}

### [Java](https://www.oracle.com/java/)
#### Installation
[Java SE Development Kit](https://www.oracle.com/java/technologies/downloads/)
[Java SE Development Kit 8](https://www.oracle.com/java/technologies/downloads/#java8)

### [Scheme](https://racket-lang.org/)
#### Installation
``` bash
brew install --cask racket
```

### [SML](http://www.smlnj.org/)
#### Installation
``` bash
brew install smlnj
```

## Text Editors
### [VSCode](https://code.visualstudio.com)

### [Vim](https://www.vim.org)
#### Installation
``` bash
brew install vim
```

## IDE
### [JetBrains](https://www.jetbrains.com)
[Toolbox](https://www.jetbrains.com/toolbox-app/)

### [Xcode](https://developer.apple.com/xcode/)

## Developer Tools
### [Insomnia](https://insomnia.rest/)
> The open-source, cross-platform API client for GraphQL, REST, and gRPC.

## Tools
### Finder Tools
#### [quick-look-plugins](https://github.com/sindresorhus/quick-look-plugins)
> List of useful Quick Look plugins for developers
``` bash
brew install qlcolorcode qlstephen qlmarkdown quicklook-json betterzip qlimagesize suspicious-package apparency quicklookase qlvideo provisionql quicklook-pat webpquicklook
```

#### [OpenInCode](https://github.com/sozercan/OpenInCode)
> macOS Finder toolbar app to open current folder in Visual Studio Code
``` bash
brew install --cask open-in-code
```

### Menu Bar Tools
#### [Itsycal](https://www.mowglii.com/itsycal/)
> Itsycal is a tiny menu bar calendar.
``` bash
brew install --cask itsycal
```

#### [MenubarX](https://menubarx.app/)
> A powerful menu bar browser

#### [Dozer](https://github.com/Mortennn/Dozer)
> Hide status bar icons on macOS.
```
brew install --cask dozer
```

#### [xbar](https://github.com/matryer/xbar)
> Put the output from any script or program into your macOS Menu Bar (the BitBar reboot)
```
brew install --cask xbar
```

### Screen Saver
- [Aerial](https://aerialscreensaver.github.io)
- [Brooklyn](https://github.com/pedrommcarrasco/Brooklyn)

### [AppCleaner](https://freemacsoft.net/appcleaner/)

### [Maccy](https://github.com/p0deje/Maccy)
#### Installation
``` bash
brew install --cask maccy
```

### [OpenEmu](http://openemu.org/)
> Retro video game emulation for macOS

## Command Line Tools
### [bat](https://github.com/sharkdp/bat)
> A cat(1) clone with syntax highlighting and Git integration.
``` bash
bat <file>
```

### [btop](https://github.com/aristocratos/btop)
> Resource monitor that shows usage and stats for processor, memory, disks, network and processes.

### [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy)
> Good-lookin' diffs with diff-highlight and more.

### [exa](https://the.exa.website)
> A modern replacement for `ls`.

### [fd](https://github.com/sharkdp/fd)
> A simple, fast and user-friendly alternative to `find`
``` bash
fd <pattern>
```

### [ffmpeg](https://www.ffmpeg.org)
> A complete, cross-platform solution to record, convert and stream audio and video.

### [fzf](https://github.com/junegunn/fzf)
> A command-line fuzzy finder
``` bash
fzf
```

### [graphicsmagick](http://www.graphicsmagick.org/)
> Image processing tools collection.

### [htop](https://htop.dev)
> A cross-platform interactive process viewer.

### [httrack](https://www.httrack.com)
> Website copier/offline browser.
``` bash
httrack <URLs>
```

### [mtr](https://www.bitwizard.nl/mtr/)
> mtr combines the functionality of the `traceroute` and `ping` programs in a single network diagnostic tool.

### [navi](https://github.com/denisidoro/navi)
> An interactive cheatsheet tool for the command-line

### [ncdu](https://dev.yorhel.nl/ncdu)
> NCurses Disk Usage.
``` bash
ncdu <dir>
```

### [pandoc](https://pandoc.org/)
> General markup converter.

### [pngquant](https://pngquant.org)
> Lossy PNG compressor
``` bash
pngquant --ext .png --force 256 *.png */*.png
```

### [prettyping](https://denilsonsa.github.io/prettyping/)
> `prettyping` is a wrapper around the standard `ping` tool, making the output prettier, more colorful, more compact, and easier to read.
``` bash
prettyping
```

### [rlwrap](https://github.com/hanslub42/rlwrap)
> `rlwrap` is a 'readline wrapper', a small utility that uses the GNU Readline library to allow the editing of keyboard input for any command.
``` bash 
rlwrap <command>
```

### [the_silver_searcher](https://github.com/ggreer/the_silver_searcher)
> A code searching tool similar to `ack`, with a focus on speed.

### [tig](https://jonas.github.io/tig/)
> Tig is an ncurses-based text-mode interface for git.

### [tldr](https://tldr.sh/)
> Simplified and community-driven man pages
``` bash
tldr <command>
```

### [tree](http://mama.indstate.edu/users/ice/tree/)
> List contents of directories in a tree-like format.
``` bash
tree -L <num> -a
```

### [unrar](https://theunarchiver.com/command-line)
> Command-line unarchiving tools supporting multiple formats

### [xxh](https://github.com/xxh/xxh)
> Bring your favorite shell wherever you go through the ssh.

### [z](https://github.com/rupa/z)
> Tracks your most used directories, based on 'frecency'.
``` bash
z <dir>
```

## Font
``` bash
brew tap homebrew/cask-fonts
```
### [Fira Code](https://github.com/tonsky/FiraCode)
```
brew install --cask font-fira-code
```

### [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)
[Fira Code Nerd Font](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode)
```
brew install --cask font-fira-code-nerd-font
```

### [Font Awesome](https://fontawesome.com)
``` bash
brew install --cask font-fontawesome
```

## Configuration
### Git Config
[diff-so-fancy](https://github.com/so-fancy/diff-so-fancy#with-git)
``` bash
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global interactive.diffFilter "diff-so-fancy --patch"

git config --global color.ui true

git config --global color.diff-highlight.oldNormal    "red bold"
git config --global color.diff-highlight.oldHighlight "red bold 52"
git config --global color.diff-highlight.newNormal    "green bold"
git config --global color.diff-highlight.newHighlight "green bold 22"

git config --global color.diff.meta       "11"
git config --global color.diff.frag       "magenta bold"
git config --global color.diff.func       "146 bold"
git config --global color.diff.commit     "yellow bold"
git config --global color.diff.old        "red bold"
git config --global color.diff.new        "green bold"
git config --global color.diff.whitespace "red reverse"
```
