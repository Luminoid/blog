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

<!-- TOC -->

[Hexo](https://hexo.io)
Theme: [hexo-theme-tranquilpeak](https://github.com/LouisBarranqueiro/hexo-theme-tranquilpeak)

## Quick Deployment
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

## Maintenance
Update outdated npm packages regularly to avoid security vulnerability:
Run `npm-check -u` under both blog directory (`./`) and theme directory (`themes/<your_theme>`).

## Theme
The following are the theme files to be modified for custom configuration, take [tranquilpeak](https://github.com/LouisBarranqueiro/hexo-theme-tranquilpeak/) theme as an example:
```
_config.yml
languages/
```

## Grammar
### Tag Plugins
Use tag plugins to reference images or other assets by relative paths instead of normal markdown syntax, otherwise these assets may be displayed incorrectly.
``` js
{% asset_img example.jpg This is an example image %}
{% asset_img "spaced asset.jpg" "spaced title" %}
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
