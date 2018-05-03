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

This article mainly focuses on the problems encountered in theme [tranquilpeak](https://github.com/LouisBarranqueiro/hexo-theme-tranquilpeak).

## Command
### hexo server not found
**Problem**: Can't find `hexo server` command.

**Solution**: Extra plugins line in `_config.yml` may cause this problem.

<!-- more -->

## Plugin
### [hexo-algolia](https://github.com/oncletom/hexo-algolia) 0 posts indexed
**Problem**: Run `hexo algolia` but no post collected.

**Solution**: Run `hexo algolia` without `hexo generate`. If already generated, run `hexo clean` to clean generated files.

### [hexo-math](https://github.com/hexojs/hexo-math) not working
**Problem**: MathJax is not rendered.

**Solution**: Package hexo-math works by default. Nothing needs to be added in `_config.yml` file. Remove the `math` configuration may solve this problem.

### [hexo-toc](https://github.com/bubkoo/hexo-toc) generating two tocs
**Problem**: Two tocs are generated in one post when only one `<!-- toc -->` is inserted

**Solution**: Some themes have their own toc generator and can detect toc annotation ignoring case. Thus both hexo theme and hexo-toc will generate its own toc. The solution can be either stick to the original toc generator of the theme, or, annotate the code of toc generating in the theme and use the hexo-toc instead.

### [hexo-all-minifier](https://github.com/chenzhutian/hexo-all-minifier) removing useful html annotation
**Problem**: HTML annotation like `<!-- TOC -->` and `<!-- excerpt -->` (used in hexo theme [tranquilpeak](https://github.com/LouisBarranqueiro/hexo-theme-tranquilpeak)) would be removed after running [hexo-html-minifier](https://github.com/hexojs/hexo-html-minifier).

**Solution**: Modify `index.js` file in `hexo-all-minifier` package and change `ignoreCustomComments` attribute (line 13) into the following:
``` js
ignoreCustomComments: [/^\s*(toc|more|excerpt)\s*$/i],
```

## Tool
### [Gitment](https://github.com/imsun/gitment) validation failed
**Problem**: Unable to initialize gitment comment. The issue API returns 422 status code.

**Solution**: This may be caused by the length of id exceeding the maximum length. Change the `id` to `page.title` will solve this problem. (In tranquilpeak, the Gitment id is configured in `themes/tranquilpeak/layout/_partial/script.ejs`)
``` js
new Gitment({
    id: '<%= page.title %>',
    // Other attributes
}).render('gitment');
```

## Syntax Highlighting
### [highlight.js](https://github.com/isagalaev/highlight.js)
**Problem**: [React JSX support? #494](https://github.com/isagalaev/highlight.js/issues/494)

### [prism](https://github.com/PrismJS/prism)
**Problem**: [Line number may be misplaced when additional theme is used #24](https://github.com/ele828/hexo-prism-plugin/issues/24)

**Solution**: The css selector `.tag` is used in both prismjs and tranquilpeak css files. Remove the `.tag` in the theme `style-<hash>.min.css` file may solve this problem. Let the `a.tag` do the selection.
`themes/tranquilpeak/source/assets/css/style-1udptkpril81ozu8ifd8zpujn7ipu7lefxsiu5gxx0dpnzntdx6dusvki3ao.min.css`
``` css
.tag,a.tag{display:inline-block;background:#fff;
```
