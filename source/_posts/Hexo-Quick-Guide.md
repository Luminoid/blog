---
title: Hexo Quick Guide
date: 2017-06-08 11:06:48
updated:
categories:
- Web
- Static Site Generator
tags:
- Hexo
keywords:
- Hexo
- guide
- Algolia
---

[Hexo](https://hexo.io)
Theme: [hexo-theme-next](https://github.com/theme-next/hexo-theme-next)

## Quick Deployment
Hexo recommended way
``` bash
$ hexo new "My New Article"
$ vim source/_posts/My-New-Article.md
$ hexo clean
$ hexo deploy -g
```

<!-- more -->

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

With Algolia and hexo deployment
``` bash
$ hexo new "My New Article"
$ vim source/_posts/My-New-Article.md
$ hexo clean
$ hexo algolia
$ hexo deploy
```

## Maintenance
Update outdated npm packages regularly to avoid security vulnerability:
Run `npm-check -u` under blog directory (`./`).

## Theme
The following are the theme files to be modified for custom configuration, take [tranquilpeak](https://github.com/LouisBarranqueiro/hexo-theme-tranquilpeak/) theme as an example:
```
_config.yml
languages/
```

## Usage
### Commands
Initializes a website.
``` bash
$ hexo init "My New Website"
```
Create a new article.
``` bash
$ hexo new "My New Article"
```

Generate static files and watch file changes.
``` bash
$ hexo generate -w
```
Start a local server.
``` bash
$ hexo server
```
List all routes.
``` bash
$ hexo list <type>
```
Index posts on Algolia. (This command runs without preceding `hexo generate`)
``` bash
$ hexo algolia
```

### Tag Plugins
Use tag plugins to reference images or other assets by relative paths instead of normal markdown syntax, otherwise these assets may be displayed incorrectly.
#### Code Block
```
{% codeblock [title] [lang:language] [url] [link text] [additional options] %}
code snippet
{% endcodeblock %}
```
Or
``` 
``` [language] [title] [url] [link text] code snippet ``` 
```

#### Include Code
Inserts code snippets in `source/downloads/code` folder. The folder location can be specified through the `code_dir` option in the config.
```
{% include_code [title] [lang:language] [from:line] [to:line] path/to/file %}
```

#### Include Posts
```
{% post_link filename [title] [escape] %}
```

#### Include Assets
``` js
{% asset_img example.jpg This is an example image %}
{% asset_img "spaced asset.jpg" "spaced title" %}
```

### Deployment
Deploys your website.
``` bash
$ hexo deploy
```
Set the `public_dir` in `_config.yml` from `public` to `docs` if you want the GitHub Pages site built from the `/docs` folder in the master branch. More info [here](https://help.github.com/articles/configuring-a-publishing-source-for-github-pages/).

Ref: https://hexo.io/docs/github-pages

### Syntax Highlighting
http://prismjs.com/#languages-list
