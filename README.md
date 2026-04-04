# Luminoid's Blog

Personal tech blog at [blog.luminoid.dev](https://blog.luminoid.dev).

## Stack

- **Framework**: [Hexo](https://hexo.io/) 8.1.1
- **Theme**: [NexT](https://theme-next.js.org/) 8.27.0 (Pisces scheme)
- **Hosting**: [Cloudflare Pages](https://pages.cloudflare.com/)
- **License**: [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)

## Posts

14 posts across 8 categories: AI, Web, iOS, Mac, Shell, Git, Programming Languages, Static Site Generator.

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
├── _config.yml              # Hexo config
├── _config.next.yml         # NexT theme config
├── command.sh               # Deploy/manage script
├── source/
│   ├── _posts/              # Blog posts (Markdown)
│   ├── _data/styles.styl    # Custom styles
│   ├── _headers             # Cloudflare security headers
│   ├── about/               # About page
│   ├── images/              # Static images
│   └── downloads/           # Downloadable code examples
├── scaffolds/               # Post templates
├── tools/                   # OG image generator
└── docs/                    # Generated output (DO NOT EDIT)
```

## Copyright

2021 - present Luminoid. Content licensed under CC BY-NC-SA 4.0.
