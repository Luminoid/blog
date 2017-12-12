---
title: Homebrew Usage
date: 2017-12-04 23:55:06
updated:
categories: Mac
tags: Homebrew
keywords: Homebrew
---


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [Command](#command)
* [Formula](#formula)
	* [vim](#vimwwwvimorg)
	* [mysql](#mysqlhttpswwwmysqlcom)
	* [wget](#wgethttpswwwgnuorgsoftwarewget)
	* [automake](#automakehttpswwwgnuorgsoftwareautomake)
	* [autoconf](#autoconfhttpswwwgnuorgsoftwareautoconfautoconfhtml)
	* [tig](#tighttpsjonasgithubiotig)
	* [tree](#treehttpbrewformulasorgtree)
	* [imagemagick](#imagemagickhttpswwwimagemagickorg)
	* [readline](#readlinehttpstiswwwcaseeduphpchetreadlinerltophtml)
	* [rlwrap](#rlwraphttpsgithubcomhanslub42rlwrap)
	* [pngquant](#pngquanthttpspngquantorg)
	* [ffmpeg](#ffmpeghttpswwwffmpegorg)
	* [launchrocket](#launchrockethttpsgithubcomjimbojsblaunchrocket)

<!-- /code_chunk_output -->

<!-- more -->

## Command
`brew install wget`: Install formula.
`brew leaves`: Show installed formulae that are not  dependencies of another installed formula.

## Formula
### [vim](www.vim.org/)
Vim is a highly configurable text editor built to make creating and changing any kind of text very efficient.

### [mysql](https://www.mysql.com)
MySQL is the world's most popular open source database.

### [wget](https://www.gnu.org/software/wget/)
GNU Wget is a free software package for retrieving files using HTTP, HTTPS, FTP and FTPS the most widely-used Internet protocols.

### [automake](https://www.gnu.org/software/automake/)
Automake is a tool for automatically generating `Makefile.in` files compliant with the GNU Coding Standards.

### [autoconf](https://www.gnu.org/software/autoconf/autoconf.html)
Autoconf is an extensible package of M4 macros that produce shell scripts to automatically configure software source code packages.

### [tig](https://jonas.github.io/tig)
Tig is an ncurses-based text-mode interface for git.

### [tree](http://brewformulas.org/Tree)
List contents of directories in a tree-like format.

### [imagemagick](https://www.imagemagick.org/)
ImageMagick is a software suite to create, edit, compose, or convert bitmap images.

### [readline](https://tiswww.case.edu/php/chet/readline/rltop.html)
The GNU Readline library provides a set of functions for use by applications that allow users to edit command lines as they are typed in.

### [rlwrap](https://github.com/hanslub42/rlwrap)
rlwrap is a 'readline wrapper', a small utility that uses the GNU readline library to allow the editing of keyboard input for any command.

### [pngquant](https://pngquant.org)
pngquant is a command-line utility and a library for lossy compression of PNG images.
``` sh
pngquant --ext .png --force 256 *.png */*.png
```

### [ffmpeg](https://www.ffmpeg.org)
A complete, cross-platform solution to record, convert and stream audio and video.

### [launchrocket](https://github.com/jimbojsb/launchrocket)
A Mac PrefPane to manage all your Homebrew-installed services.
