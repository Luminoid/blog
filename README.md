# Luminoid's Blog

Personal tech blog at [blog.luminoid.dev](https://blog.luminoid.dev): iOS and Swift, AI services and LLMs, Mac tooling, web frameworks, and audio internals, plus a WWDC retrospective series and a few cheat sheets.

## Stack

- **Framework**: [Hexo](https://hexo.io/) 8.1.1
- **Theme**: [NexT](https://theme-next.js.org/) 8.27.0 (Pisces scheme)
- **Hosting**: [Cloudflare Pages](https://pages.cloudflare.com/), deployed with Wrangler from a local build
- **Feeds and indexing**: Atom feed at `/atom.xml`, sitemap at `/sitemap.xml`, `robots.txt`, local search index
- **License**: [CC BY-NC-SA 4.0](LICENSE)

## Posts

31 posts across 10 categories: AI, Audio, iOS (including the WWDC retrospective series), Mobile, Mac, Web, Shell, Git, Programming Languages, Static Site Generator.

## Quick Start

```bash
# Install dependencies
npm install

# Local preview (http://localhost:4000)
npm run server

# Create new post
./command.sh new "Post Title"

# Build & deploy
./command.sh deploy "commit message"

# Compress images
./command.sh compress
```

## Project Structure

```
blog/
├── _config.yml              # Hexo config (site metadata, feed, sitemap, search)
├── _config.next.yml         # NexT theme config
├── command.sh               # Deploy/manage script
├── source/
│   ├── _posts/              # Blog posts (Markdown)
│   ├── _data/styles.styl    # Custom styles
│   ├── _headers             # Cloudflare security headers
│   ├── robots.txt           # Crawl rules + sitemap pointer (copied verbatim)
│   ├── about/               # About page
│   ├── images/              # Static images
│   └── downloads/           # Downloadable code examples
├── scaffolds/               # Post templates
├── scripts/
│   └── mermaid-theme.js     # Injects the Mermaid house style (_config.yml mermaid_theme) into every {% mermaid %} block
├── tools/                   # OG image generator
└── docs/                    # Generated output (DO NOT EDIT; gitignored)
```

## Related

- [luminoid.dev](https://luminoid.dev): portfolio and project index
- [LensDB](https://github.com/Luminoid/lens-db), [Echoes](https://github.com/Luminoid/echoes), [Spectral Lab](https://github.com/Luminoid/spectral-lab): the other web projects
- [LumiKit](https://github.com/Luminoid/LumiKit), [Prism](https://github.com/Luminoid/Prism), [Sophon](https://github.com/Luminoid/Sophon), [Monolith](https://github.com/Luminoid/Monolith), [Tethersnap](https://github.com/Luminoid/Tethersnap): the Swift projects the posts draw on

## License

2021 to present, Luminoid. Posts, pages, images, and the code samples under `source/downloads/code` are licensed under [CC BY-NC-SA 4.0](LICENSE).
