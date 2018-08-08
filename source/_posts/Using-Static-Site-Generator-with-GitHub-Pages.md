---
title: Using static site generator with GitHub Pages
date: 2017-08-27 20:02:59
updated:
categories:
- Web
- Static Site Generator
tags:
- GitHub
keywords:
- static site generator
- GitHub Pages
- master
- gh-pages
---

There are three ways to deploy static site on GitHub Pages as follows. I tend to use the third scheme myself. The related GitHub documentation can be found [here](https://help.github.com/articles/configuring-a-publishing-source-for-github-pages/).

## Using `gh-pages` branch
Simply deploy website content on `gh-pages` branch and maintain code locally.
### Advantage
This is the easiest way because many static site generators have build-in `deploy` command. Users would only need to setup the deployment configuration once and run `deploy` command every time after the modification. An npm package [gh-pages](https://www.npmjs.com/package/gh-pages) helps doing this, if there is no built-in `deploy` command.
### Disadvantage
Only website content is under the version control. The code that generates the website content is maintained locally.

<!-- more -->

## Using `master` brunch and `gh-pages` branch
Deploy code on `master` brunch and website content on `gh-pages` branch.
### Advantage
Both website content and code is under its own version control system.
### Disadvantage
Users have to run commands of both static site generator and git every time after the modification.

## Using `master` brunch and `/docs` folder
### Advantage
Users will only need to run commands of git, and GitHub Pages will automatically read everything under the `docs/` folder to publish the site.
### Disadvantage
In the field of version control, users can only have the benefit of git. The version control capability of the static site generator is ignored. I personally recommend this way because the version control capability of the static site generator is not that important in most circumstances.
