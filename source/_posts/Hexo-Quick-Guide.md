---
title: Hexo Quick Guide
date: 2022-02-21 23:36:21
categories:
  - Web
  - Static Site Generator
tags:
  - Hexo
  - NexT
  - hexo-theme-next
  - Cloudflare Pages
---

A short working reference for the Hexo + NexT setup that powers this blog.

<!-- more -->

- **Hexo**: 8.1.1 ([hexo.io](https://hexo.io/))
- **Theme**: [NexT](https://theme-next.js.org/) 8.27.0 ([GitHub](https://github.com/next-theme/hexo-theme-next))

## Workflow

```bash
hexo new "My New Article"     # scaffold source/_posts/My-New-Article.md
# Edit the post
hexo clean
hexo generate
```

For pushing to Cloudflare Pages with Git auto-deploy, see {% post_link Deploy-Static-Site-to-Cloudflare-Pages "Deploy a Static Site to Cloudflare Pages" %}. Local generate + manual `wrangler pages deploy` works the same way against the `public/` (or `docs/`) output.

## Maintenance

```bash
ncu -u            # bump versions in package.json
npm install       # resolve
```

## Configuration

Site config lives in `_config.yml`. The values worth knowing:

- `permalink: :title/`: clean URLs without dates
- `index_generator.order_by: -updated`: sort the home feed by updated time, descending
- `updated_option: 'mtime'`: when `updated:` is empty in front matter, fall back to file mtime, so a rewrite floats to the top without manually timestamping

## Theme: NexT

- [Site](https://theme-next.js.org/) / [GitHub](https://github.com/next-theme/hexo-theme-next) / [Docs](https://theme-next.js.org/docs/)
- Theme config: `./_config.next.yml` (overrides `node_modules/hexo-theme-next/_config.yml`)

### Config priority (high to low)

1. `theme_config` block in `_config.yml`
2. `_config.[theme].yml` (e.g. `_config.next.yml`)
3. `_config.yml` inside the theme directory

### Highlight previews

[NexT highlight theme picker](https://theme-next.js.org/highlight/).

### Legacy repos (do not use)

- `iissnan/hexo-theme-next` (original, abandoned)
- `theme-next/hexo-theme-next` (intermediate fork, abandoned)

## Tag plugins

[Hexo's tag plugins](https://hexo.io/docs/tag-plugins) handle the parts plain markdown can't.

### Cross-link another post

```liquid
{% post_link filename "Display text" %}
```

**Don't** wrap a `post_link` tag in a markdown link: `[label]({% post_link filename %})` does not work, because `post_link` outputs a full `<a>` element rather than a URL. Use the standalone form above with display text.

### Include source code

Reads from `code_dir` (default `source/downloads/code/`):

```liquid
{% include_code [title] [lang:language] [from:line] [to:line] path/to/file %}
```

Broken in Hexo 7.2.0 onward (8.1.1 still affected). The path-traversal hardening in [PR #5251](https://github.com/hexojs/hexo/pull/5251) replaced the direct filesystem read with a `Page.findOne({ source })` lookup, which only resolves files Hexo has registered as pages. Files that Hexo treats as static assets (any extension without a registered renderer, e.g. `.c`, `.swift`, `.cpp`, `.scala`) are never in the Page model, so the tag silently returns nothing for them. `.js` happens to render because Hexo classifies it as a renderable page. Tracking issue: [hexojs/hexo#5486](https://github.com/hexojs/hexo/issues/5486). Proposed fix introducing a separate Code model: [hexojs/hexo#5633](https://github.com/hexojs/hexo/pull/5633), open since Feb 2025.

Until that lands, fall back to a plain fenced code block for everything that isn't `.js`.

### Reference assets

```liquid
{% asset_path filename %}
{% asset_img [class] slug [width] [height] [title] [alt] %}
{% asset_link filename "title" %}
```

Asset folders live alongside the post: a same-name folder under `source/_posts/` is auto-discovered when `post_asset_folder: true` is set in `_config.yml`.
