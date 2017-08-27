---
title: Hexo Quick Guide
date: 2017-06-08 11:06:48
categories:
- Web
- Static Site Generator
tags:
- Hexo
keywords:
- Hexo
- guide
---

<!-- toc -->

[Hexo](https://hexo.io)
[hexo-theme-tranquilpeak](https://github.com/LouisBarranqueiro/hexo-theme-tranquilpeak)

## Quick deploy
With Algolia
``` bash
$ hexo new "My New Article"
$ vim source/_posts/My-New-Article.md
$ hexo clean
$ hexo algolia
$ hexo deploy
```
<!-- more -->
Without Algolia
``` bash
$ hexo new "My New Article"
$ vim source/_posts/My-New-Article.md
$ hexo deploy -g
```

## Create
Initializes a website.
``` bash
$ hexo init "My New Website"
```
Create a new article.
``` bash
$ hexo new "My New Article"
```

## Develop
Generate static files and watch file changes.
``` bash
$ hexo generate -w
```
Start a local server.
``` bash
$ hexo server
```
Index posts on Algolia. (This command runs without preceding `hexo generate`)
``` bash
$ hexo algolia
```

## Deploy
Deploys your website.
``` bash
$ hexo deploy
```
