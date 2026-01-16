---
title: Hexo Quick Guide
date: 2022-02-21 23:36:21
updated:
categories:
- Web
- Static Site Generator
tags:
- Hexo
- NexT
- hexo-theme-next
---

Official Site: https://hexo.io/
Version: 8.1.0

## Workflow
With Git deployment
``` bash
$ hexo new "My New Article"
# Edit source/_posts/My-New-Article.md
$ hexo clean
$ hexo generate
$ git add -A
$ git commit -m <msg>
$ git push
```

## Maintenance
Update outdated npm packages:

Using npm: With `npm-check-updates`. Run the following commands under the blog directory (`./`).
``` shell
$ ncu -u
$ npm install
```

## Configuration
Site config is stored in `./_config.yml`

<!-- more -->

## Theme
### Configuration
Alternation Priority (From high to low):
- `theme_config` in site’s primary configuration file
- `_config.[theme].yml` file
- `_config.yml` file under the theme directory

### [NexT](https://theme-next.js.org/)
[GitHub](https://github.com/next-theme/hexo-theme-next)
[Documentation](https://theme-next.js.org/)
Version: 8.27.0

#### Configuration
NexT theme config is stored in `./_config.next.yml` & `node_modules/hexo-theme-next/_config.yml`

#### Code Highlight Theme
[NexT Highlight Theme Preview](https://theme-next.js.org/highlight/)

#### Legacy Repositories
- https://github.com/iissnan/hexo-theme-next
- https://github.com/theme-next/hexo-theme-next

## Usage
### [Tag Plugins](https://hexo.io/docs/tag-plugins)
> Referencing images or other assets using normal markdown syntax and relative paths may lead to incorrect display on archive or index pages. Plugins have been created by the community to address this issue in Hexo 2.

#### Include Code
{% note warning %}
#### Warning
`include_code` only works with `.js` files in Hexo 8.1.0, seems like a bug
{% endnote %}
``` liquid
{% include_code [title] [lang:language] [from:line] [to:line] path/to/file %}
```

#### Include Posts
``` liquid
{% post_link filename [title] [escape] %}
```

#### Include Assets
``` liquid
{% asset_path filename %}
{% asset_img [class names] slug [width] [height] [title text [alt text]] %}
{% asset_link filename [title] [escape] %}
```
