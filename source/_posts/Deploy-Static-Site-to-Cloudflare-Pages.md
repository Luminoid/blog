---
title: Deploy a Static Site to Cloudflare Pages with GitHub Auto-Deploy
date: 2026-03-07 22:00:00
categories:
- Web
tags:
- Cloudflare
- GitHub
- static-site
---

How to set up a zero-config deployment pipeline: push to GitHub, site updates automatically on Cloudflare Pages with a custom domain.

<!-- more -->

## Why Cloudflare Pages

The three big static hosts in 2026 are Cloudflare Pages, Netlify, and Vercel. They all do auto-deploy from Git, custom domains, automatic SSL, and PR previews. The honest comparison:

| | Cloudflare Pages | Netlify | Vercel |
|---|---|---|---|
| Free tier bandwidth | **Unlimited** | 100 GB / mo | 100 GB / mo |
| Free tier builds | 500 / mo | 300 build min / mo | 6,000 build min / mo |
| Overage charges | **None on Free; bandwidth still free on paid** | Bandwidth $55/100 GB | Bandwidth $40/100 GB |
| Cold-build speed | Slower (minute-class) | Fast | Fast |
| Edge network | 300+ POPs | ~6 regions + global edge | ~30 regions |
| Best at | Cheap fan-out, surprise traffic | Form/auth integrations | Next.js |

If a single post catches fire on Hacker News, Pages charges $0; Netlify or Vercel can charge real money. The tradeoff is slower cold builds and fewer one-click integrations. For static sites and small SSGs, Pages is the safe default.

## What You Need

- A GitHub account
- A Cloudflare account (free plan works)
- A domain managed by Cloudflare DNS
- A static site (plain HTML/CSS/JS, no build step required)

## 1. Push Your Site to GitHub

```bash
cd ~/Projects/my-site
git init
git add .
git commit -m "Initial commit"
gh repo create my-site --public --source=. --push
```

If you don't have the `gh` CLI, create the repo on GitHub manually and push:

```bash
git remote add origin git@github.com:YOUR_USERNAME/my-site.git
git branch -M main
git push -u origin main
```

## 2. Create a Cloudflare Pages Project

1. Go to **Cloudflare Dashboard**
2. Navigate to **Workers & Pages**
3. Click **Create** > **Pages** > **Connect to Git**
4. Select your GitHub account and the repository
5. Set the production branch to `main`

### Build Settings

For a plain static site (no framework, no bundler):

| Setting | Value |
|---------|-------|
| Build command | *(leave blank)* |
| Build output directory | `/` |

If your site uses a framework:

| Framework | Build command | Output directory |
|-----------|--------------|-----------------|
| Hugo | `hugo` | `public` |
| Hexo | `hexo generate` | `public` |
| Astro | `npm run build` | `dist` |
| SvelteKit (static adapter) | `npm run build` | `build` |
| Eleventy | `npx eleventy` | `_site` |
| Next.js (static export, Next 14+) | `next build` (with `output: 'export'` in `next.config.js`) | `out` |
| Vite | `npm run build` | `dist` |

Click **Save and Deploy**. Cloudflare builds and deploys immediately.

Your site is now live at `my-site.pages.dev`.

## 3. Add a Custom Domain

1. In your Pages project, go to **Custom domains**
2. Click **Set up a custom domain**
3. Enter your subdomain (e.g., `app.example.com`)
4. Cloudflare automatically creates the DNS record:

| Type | Name | Content |
|------|------|---------|
| CNAME | `app` | `my-site.pages.dev` |

SSL is provisioned automatically. The domain is usually active within seconds since DNS is already on Cloudflare.

## 4. Daily Workflow

That's it. From now on, every push to `main` triggers an automatic deploy:

```bash
# Edit your files
vim index.html

# Push
git add -A
git commit -m "update feature"
git push

# Site updates in ~30 seconds at your custom domain
```

No deploy commands. No CI config files. No build scripts.

## Alternative: Manual Deploy with Wrangler

If you prefer not to connect GitHub (or need to deploy from a different source), you can use the Wrangler CLI:

```bash
# Install wrangler (one-time)
npm install -g wrangler

# Create the project (one-time)
npx wrangler pages project create my-site --production-branch main

# Deploy (every time)
npx wrangler pages deploy . --project-name my-site
```

This uploads the current directory directly. No Git integration: you run the command manually each time.

**Note:** Projects created via `wrangler` cannot be connected to GitHub after the fact. If you want auto-deploy, delete the project in the dashboard and recreate it through the UI with Git connected.

## .gitignore

For a static site deployed to Cloudflare Pages:

```
.DS_Store
Thumbs.db
*.swp
*.swo
*~
.wrangler/
node_modules/
```

`.wrangler/` contains local deploy cache from the Wrangler CLI. `node_modules/` in case you install wrangler locally.

## Summary

| Step | Action | Frequency |
|------|--------|-----------|
| Create GitHub repo | `gh repo create` | Once |
| Connect to Cloudflare Pages | Dashboard UI | Once |
| Add custom domain | Dashboard > Custom domains | Once |
| Deploy | `git push` | Every change |

Total setup time: ~5 minutes. Zero ongoing maintenance.
