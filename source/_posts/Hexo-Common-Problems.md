---
title: Hexo Common Problems
date: 2017-06-08 20:25:08
updated:
categories:
  - Web
  - Static Site Generator
tags:
  - Hexo
keywords:
  - Hexo
  - server
  - Algolia
  - hexo-math
---

<!-- toc -->

## hexo server not found
**Problem**: Can't find `hexo server` command.
**Solution**: Extra plugins line in `_config.yml` may cause this problem.

<!-- more -->
## hexo algolia 0 posts indexed
**Problem**: Run `hexo algolia` but no post collected.
**Solution**: Run `hexo algolia` without `hexo generate`. If already generated, run `hexo clean` to clean generated files.

## hexo-math not working
**Problem**: MathJax is not rendered
**Solution**: Package hexo-math works by default. Nothing needs to be added in `_config.yml` file. Remove the `math` configuration may solve this problem.
