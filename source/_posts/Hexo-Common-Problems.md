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


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [hexo server not found](#hexo-server-not-found)
* [hexo-algolia 0 posts indexed](#hexo-algoliahttpsgithubcomoncletomhexo-algolia-0-posts-indexed)
* [hexo-math not working](#hexo-mathhttpsgithubcomhexojshexo-math-not-working)
* [hexo-toc generating two tocs](#hexo-tochttpsgithubcombubkoohexo-toc-generating-two-tocs)
* [hexo-all-minifier removing useful html annotation](#hexo-all-minifierhttpsgithubcomchenzhutianhexo-all-minifier-removing-useful-html-annotation)
* [Syntax Highlighting](#syntax-highlighting)
	* [highlight.js](#highlightjshttpsgithubcomisagalaevhighlightjs)
	* [prism](#prismhttpsgithubcomprismjsprism)

<!-- /code_chunk_output -->

<!-- excerpt -->

<!-- TOC -->

## hexo server not found
**Problem**: Can't find `hexo server` command.
**Solution**: Extra plugins line in `_config.yml` may cause this problem.

## [hexo-algolia](https://github.com/oncletom/hexo-algolia) 0 posts indexed
**Problem**: Run `hexo algolia` but no post collected.
**Solution**: Run `hexo algolia` without `hexo generate`. If already generated, run `hexo clean` to clean generated files.

## [hexo-math](https://github.com/hexojs/hexo-math) not working
**Problem**: MathJax is not rendered
**Solution**: Package hexo-math works by default. Nothing needs to be added in `_config.yml` file. Remove the `math` configuration may solve this problem.

## [hexo-toc](https://github.com/bubkoo/hexo-toc) generating two tocs
**Problem**: Two tocs are generated in one post when only one `<!-- toc -->` is inserted
**Solution**: Some themes have their own toc generator and can detect toc annotation ignoring case. Thus both hexo theme and hexo-toc will generate its own toc. The solution can be either stick to the original toc generator of the theme, or, annotate the code of toc generating in the theme and use the hexo-toc instead.

## [hexo-all-minifier](https://github.com/chenzhutian/hexo-all-minifier) removing useful html annotation
**Problem**: HTML annotation like `<!-- TOC -->` and `<!-- excerpt -->` (used in hexo theme [tranquilpeak](https://github.com/LouisBarranqueiro/hexo-theme-tranquilpeak)) would be removed after running [hexo-html-minifier](https://github.com/hexojs/hexo-html-minifier).
**Solution**: modify `index.js` file in `hexo-all-minifier` package and change `ignoreCustomComments` attribute (line 13) into the following:
``` js
ignoreCustomComments: [/^\s*(toc|more|excerpt)\s*$/i],
```

## Syntax Highlighting
### [highlight.js](https://github.com/isagalaev/highlight.js)
**Problem**:
[React JSX support? #494](https://github.com/isagalaev/highlight.js/issues/494)

### [prism](https://github.com/PrismJS/prism)
**Problem**:
[Line numbers not the same height as code #1231](https://github.com/PrismJS/prism/issues/1231)
[Line number may be misplaced when additional themes is used #24](https://github.com/ele828/hexo-prism-plugin/issues/24)
