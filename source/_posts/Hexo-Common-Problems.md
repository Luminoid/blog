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
  - hexo-algolia
  - hexo-math
  - hexo-toc
---

<!-- toc orderedList:0 depthFrom:1 depthTo:6 -->

* [hexo server not found](#hexo-server-not-found)
* [hexo-algolia 0 posts indexed](#hexo-algoliahttpsgithubcomoncletomhexo-algolia-0-posts-indexed)
* [hexo-math not working](#hexo-mathhttpsgithubcomhexojshexo-math-not-working)
* [hexo-toc generates two tocs](#hexo-tochttpsgithubcombubkoohexo-toc-generates-two-tocs)

<!-- tocstop -->

## hexo server not found
**Problem**: Can't find `hexo server` command.
**Solution**: Extra plugins line in `_config.yml` may cause this problem.

<!-- more -->
## [hexo-algolia](https://github.com/oncletom/hexo-algolia) 0 posts indexed
**Problem**: Run `hexo algolia` but no post collected.
**Solution**: Run `hexo algolia` without `hexo generate`. If already generated, run `hexo clean` to clean generated files.

## [hexo-math](https://github.com/hexojs/hexo-math) not working
**Problem**: MathJax is not rendered
**Solution**: Package hexo-math works by default. Nothing needs to be added in `_config.yml` file. Remove the `math` configuration may solve this problem.

## [hexo-toc](https://github.com/bubkoo/hexo-toc) generates two tocs
**Problem**: Two tocs are generated in one post when only one `<!-- toc -->` is inserted
**Solution**: Some themes have their own toc generator and can detect toc annotation ignoring case. Thus both hexo theme and hexo-toc will generate its own toc. The solution can be either stick to the original toc generator of the theme, or, annotate the code of toc generating in the theme and use the hexo-toc instead.

## Syntax Highlighting
### [highlight.js](https://github.com/isagalaev/highlight.js)
**Problem**: [React JSX support? #494](https://github.com/isagalaev/highlight.js/issues/494)

### [prism](https://github.com/PrismJS/prism)
**Problem**: [Line numbers not the same height as code #1231](https://github.com/PrismJS/prism/issues/1231)
