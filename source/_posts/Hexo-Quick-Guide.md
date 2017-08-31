---
title: Hexo Quick Guide
date: 2017-06-08 11:06:48
updated:
categories:
  - Web
  - Static Site Generator
tags:
  - Hexo
  - Github
keywords:
  - Hexo
  - guide
  - Algolia
  - Github
---

<!-- toc -->

[Hexo](https://hexo.io)
Theme: [hexo-theme-tranquilpeak](https://github.com/LouisBarranqueiro/hexo-theme-tranquilpeak)

## Quick deployment
With Algolia and git deployment
``` bash
$ hexo new "My New Article"
$ vim source/_posts/My-New-Article.md
$ hexo clean
$ hexo algolia
$ git add -A
$ git commit -m <msg>
$ git push
```

<!-- more -->
With Algolia and hexo deployment
``` bash
$ hexo new "My New Article"
$ vim source/_posts/My-New-Article.md
$ hexo clean
$ hexo algolia
$ hexo deploy
```

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
Set the `public_dir` in `_config.yml` from `public` to `docs` if you want the GitHub Pages site built from the `/docs` folder in the master branch. More info [here](https://help.github.com/articles/configuring-a-publishing-source-for-github-pages/).
