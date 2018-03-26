---
title: Using static site generator with Github Pages
date: 2017-08-27 20:02:59
updated:
categories:
  - Web
  - Static Site Generator
tags:
  - Github
keywords:
  - static site generator
  - Github Pages
  - master
  - gh-pages
---

<!-- toc orderedList:0 depthFrom:1 depthTo:6 -->

* [Using `gh-pages` branch](#using-gh-pages-branch)
    * [Advantage](#advantage)
    * [Disadvantage](#disadvantage)
* [Using `master` brunch and `gh-pages` branch](#using-master-brunch-and-gh-pages-branch)
    * [Advantage](#advantage-1)
    * [Disadvantage](#disadvantage-1)
* [Using `master` brunch and `/docs` folder](#using-master-brunch-and-docs-folder)
    * [Advantage](#advantage-2)
    * [Disadvantage](#disadvantage-2)

<!-- tocstop -->

<!-- excerpt -->

<!-- TOC -->

There are three ways to deploy static site on Github Pages as follows. I tend to use the third scheme myself. The related Github documentation can be found [here](https://help.github.com/articles/configuring-a-publishing-source-for-github-pages/).

## Using `gh-pages` branch
Simply deploy website content on `gh-pages` branch and maintain code locally.
### Advantage
This is the easiest way because many static site generators have build-in `deploy` command. Users would only need to setup the deployment configuration once and run `deploy` command every time after the modification.
### Disadvantage
Only website content is under the version control. The code that generates the website content is maintained locally.

## Using `master` brunch and `gh-pages` branch
Deploy code on `master` brunch and website content on `gh-pages` branch. An npm package [gh-pages](https://www.npmjs.com/package/gh-pages) helps doing this.
### Advantage
Both website content and code is under its own version control system.
### Disadvantage
Users have to run command of both static site generator and git every time after the modification.

## Using `master` brunch and `/docs` folder
### Advantage
Users will only need to run command of git, and GitHub Pages will automatically read everything under the `docs/` folder to publish the site.
### Disadvantage
In the field of version control, users can only have the benefit of git. The version control capability of the static site generator is ignored. I personally recommend this way because the version control capability of the static site generator is not that important in most circumstances.
