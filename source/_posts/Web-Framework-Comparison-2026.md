---
title: "Every way to build a website in 2026: frameworks, SSGs, and platforms compared"
date: 2026-03-22 12:00:00
categories:
- Web
tags:
- HTML
- Vite
- React
- Next.js
- Vue
- Nuxt
- Angular
- Svelte
- SvelteKit
- Astro
- Remix
- Hugo
- Jekyll
- Hexo
- Eleventy
- Vercel
- Netlify
- Cloudflare
- static-site
---

A detailed comparison of every major way to build a website in 2026 -- from no framework at all, through SPAs and full-stack frameworks, to traditional static site generators, plus where to deploy them.

<!-- more -->

## Glossary

Before diving in, here are the acronyms you'll see throughout this post:

| Acronym | Full name | What it means |
|---------|-----------|---------------|
| **SPA** | Single-Page Application | The browser loads one HTML page; JS handles all navigation and rendering client-side |
| **SSR** | Server-Side Rendering | The server generates HTML on each request, then sends it to the browser |
| **SSG** | Static Site Generation | Pages are pre-built to HTML at build time, then served as static files |
| **ISR** | Incremental Static Regeneration | Static pages that re-generate in the background after a set interval (Next.js concept) |
| **CSR** | Client-Side Rendering | The browser downloads JS, then renders the page entirely in the client |
| **RSC** | React Server Components | React components that run only on the server, shipping zero JS to the client |
| **HMR** | Hot Module Replacement | Code changes appear instantly in the browser during development without a full reload |
| **CDN** | Content Delivery Network | A network of servers worldwide that caches and serves your site from the nearest location |
| **SEO** | Search Engine Optimization | Making your site discoverable by search engines (Google, Bing, etc.) |
| **TTFB** | Time to First Byte | How long until the browser receives the first byte of the response from the server |
| **MDX** | Markdown + JSX | Markdown files that can embed React/JSX components inline |
| **SFC** | Single-File Component | A file containing template, script, and style in one place (used by Vue and Svelte) |
| **JAMstack** | JavaScript, APIs, Markup | Architecture pattern: pre-rendered markup + client-side JS + API calls (no monolithic server) |
| **WAF** | Web Application Firewall | Filters and blocks malicious HTTP traffic before it reaches your site |

## The landscape

The frontend ecosystem has matured significantly. Frameworks have specialized: some optimize for **web applications** (dashboards, SaaS), others for **content sites** (blogs, portfolios, docs), and a few try to do both. Picking the right one depends on what you're building.

This guide covers 15 options across 5 categories:

| Category | Options | Best for |
|----------|---------|----------|
| **No framework** | Plain HTML/CSS/JS, HTML + Vite | Maximum control, tiny sites, learning |
| **Full SPA** | React (Vite), Vue, Svelte, Angular | Interactive apps, dashboards, complex state |
| **Full-stack / Hybrid** | Next.js, Nuxt, SvelteKit, Remix | Apps that need SSR, SEO, API routes |
| **Content-first** | Astro | Modern content sites with component islands |
| **Static site generators** | Hugo, Jekyll, Hexo, Eleventy | Blogs, docs, template-driven content sites |

## Quick comparison

| Option | Language | Rendering | JS shipped | Learning curve | Ecosystem |
|--------|----------|-----------|------------|----------------|-----------|
| **Plain HTML/CSS/JS** | HTML/CSS/JS | Static | Only what you write | Lowest | N/A (web standards) |
| **HTML + Vite** | HTML/CSS/JS/TS | Static | Only what you write | Low | Vite plugins |
| **React + Vite** | JSX/TSX | CSR (SPA) | Full bundle | Medium | Massive |
| **Next.js** | JSX/TSX | SSR/SSG/ISR/CSR | Varies (RSC helps) | High | Very large |
| **Vue** | SFC (.vue) | CSR (SPA) | Full bundle | Low-Medium | Large |
| **Nuxt** | SFC (.vue) | SSR/SSG/CSR | Varies | Medium | Large |
| **Angular** | TypeScript | CSR (SPA) | Full bundle | High | Very large |
| **Svelte** | .svelte | CSR (SPA) | Compiled (small) | Low | Growing |
| **SvelteKit** | .svelte | SSR/SSG/CSR | Compiled (small) | Medium | Growing |
| **Astro** | .astro + any | SSG (+ SSR opt-in) | Zero by default | Low | Moderate |
| **Remix** | JSX/TSX | SSR | Varies | Medium-High | Moderate |
| **Hugo** | Go templates | SSG | Zero by default | Medium | Large |
| **Jekyll** | Liquid/Ruby | SSG | Zero by default | Low-Medium | Large (mature) |
| **Hexo** | EJS/Nunjucks | SSG | Zero by default | Low | Moderate |
| **Eleventy** | Any template lang | SSG | Zero by default | Low-Medium | Moderate |

---

## No framework

Sometimes the best framework is no framework. Plain HTML, CSS, and JavaScript -- the original web stack -- still works and is often the right call.

### Plain HTML / CSS / JS

No build step, no dependencies, no node_modules. Write files, open in a browser, deploy anywhere.

```
my-site/
├── index.html
├── about.html
├── css/
│   └── styles.css
├── js/
│   └── main.js
└── images/
```

**Strengths:**
- Zero dependencies, zero build time, zero configuration
- Works forever -- no framework to upgrade, no breaking changes
- Fastest possible page loads (nothing between you and the browser)
- Full control over every byte shipped
- Easy to understand for anyone who knows web basics
- Deploy by dragging a folder to Cloudflare Pages, Netlify, or any web server

**Weaknesses:**
- No components -- copy-paste for shared headers/footers (or use `<template>` / Web Components)
- No hot reload (unless you add a live-server tool)
- No TypeScript, no bundling, no tree-shaking
- No image optimization pipeline
- Repetitive for sites with many pages that share layout

**Best for**: Small sites (1-5 pages), prototypes, landing pages, learning web development, sites that need to last decades without maintenance.

---

### HTML + Vite

Take the plain HTML approach but add Vite as a dev server and build tool. You get hot reload, TypeScript, CSS preprocessing, and asset optimization -- without adopting a UI framework.

```bash
npm create vite@latest my-site -- --template vanilla-ts
```

```
my-site/
├── index.html          # Entry point (Vite serves this)
├── about.html
├── src/
│   ├── main.ts         # TypeScript, auto-reloads
│   └── style.css       # PostCSS, autoprefixer, etc.
├── public/             # Static assets (copied as-is)
├── vite.config.ts
└── package.json
```

**Strengths:**
- Hot Module Replacement (HMR) -- instant feedback during development
- TypeScript out of the box
- CSS modules, PostCSS, Sass/Less support (just `npm install`)
- Asset optimization on build (minification, hashing, tree-shaking)
- Multi-page support via `build.rollupOptions.input`
- Still just HTML files -- no framework abstraction

**Weaknesses:**
- Still no component model (shared layout requires manual solutions)
- Adds a build step and `node_modules`
- Multi-page config is manual (list each `.html` in rollup input)
- No routing -- each page is a separate `.html` file

**Best for**: Small-to-medium sites where you want modern tooling (TS, CSS processing, minification) without a framework. Great for portfolios, experiments, and sites with light interactivity.

---

### When to go frameworkless

| Situation | No framework | Framework |
|-----------|:---:|:---:|
| 1-5 static pages | Yes | Overkill |
| Portfolio with 3 sections | Yes (+ Vite) | Optional |
| Blog with 50+ posts | No | SSG or Astro |
| Shared components across pages | Maybe (Web Components) | Yes |
| Complex interactivity (drag-drop, real-time) | No | Yes |
| Team of 3+ developers | Probably not | Yes (consistency) |

---

## Full SPA frameworks

These render entirely in the browser. Great for apps behind a login where SEO doesn't matter. Not ideal for public content sites.

### React (with Vite)

The industry default. React itself is a UI library, not a framework -- you assemble the stack yourself.

**Stack**: React 19 + Vite 6 + React Router + your choice of state management

```bash
npm create vite@latest my-app -- --template react-ts
```

**Strengths:**
- Largest ecosystem: any problem has a library for it
- Huge hiring pool and community knowledge
- React Compiler eliminates manual `useMemo`/`useCallback` optimization
- Server Components available (via Next.js/Remix)

**Weaknesses:**
- Assembly required: routing, state, data fetching, CSS -- all separate decisions
- Virtual DOM overhead (small but real vs compiled frameworks)
- JSX is polarizing -- mixing markup and logic in one file
- `useEffect` footgun -- still the #1 source of React bugs

**Best for**: Teams with React experience building interactive apps (dashboards, admin panels, internal tools).

**Avoid for**: Simple content sites, blogs, portfolios -- you'll ship a full JS runtime for static content.

---

### Vue 3

Vue takes an opinionated middle ground: single-file components (`.vue`) with template, script, and style in one file. The Composition API (`ref`, `computed`, `watch`) is now the standard.

```bash
npm create vue@latest
```

**Strengths:**
- Gentler learning curve than React -- clear separation of template/logic/style
- First-party solutions: Vue Router, Pinia (state), Vite (build) -- all official
- Excellent docs (consistently rated best in surveys)
- `<script setup>` syntax is concise and TypeScript-friendly
- Reactivity is fine-grained (no virtual DOM diffing for state updates)

**Weaknesses:**
- Smaller ecosystem than React (fewer third-party libraries)
- Two API styles (Options vs Composition) can confuse beginners reading tutorials
- Less dominant in the US job market (stronger in Asia and Europe)

**Best for**: Solo devs or small teams who want batteries-included without the complexity of React's ecosystem decisions.

---

### Svelte 5

Svelte compiles components at build time into efficient imperative DOM updates. No virtual DOM, no runtime framework code shipped to the browser.

```bash
npx sv create my-app
```

**Strengths:**
- Smallest bundle sizes -- compiled output is vanilla JS
- Runes (`$state`, `$derived`, `$effect`) are intuitive reactivity primitives
- `.svelte` files are clean: HTML + JS + CSS, minimal boilerplate
- Built-in transitions and animations
- Fastest "time to interactive" of any major framework

**Weaknesses:**
- Smallest ecosystem of the three (fewer component libraries, fewer StackOverflow answers)
- Svelte 5 (Runes) is a significant paradigm shift from Svelte 4 -- some churn
- Fewer job listings specifically requesting Svelte
- Some edge cases in TypeScript support

**Best for**: Performance-critical apps, small-to-medium projects, developers who value simplicity and small bundles.

---

### Angular 19

Google's opinionated, batteries-included framework. TypeScript-first, with a full solution for routing, forms, HTTP, testing, and i18n out of the box.

```bash
npm install -g @angular/cli
ng new my-app
```

**Strengths:**
- Complete framework: routing, forms, HTTP client, dependency injection, testing -- all built in
- TypeScript is mandatory, not optional -- enforces type safety across the entire project
- Signals (new reactive primitive) bring fine-grained reactivity, replacing much of RxJS
- Standalone components simplify the module system (NgModules now optional)
- Strong enterprise adoption -- many large companies standardize on Angular
- Excellent CLI (`ng generate`, `ng test`, `ng build`) with schematics for code generation

**Weaknesses:**
- Steepest learning curve of any major framework (dependency injection, decorators, RxJS)
- Verbose compared to React/Vue/Svelte -- more boilerplate for simple tasks
- Large initial bundle size
- Frequent major version releases (every 6 months) with migration effort
- Smaller community mindshare outside enterprise (fewer tutorials, blog posts, indie projects)

**Best for**: Enterprise applications, large teams that benefit from strong conventions, projects where TypeScript-everywhere and built-in tooling outweigh the learning curve.

---

## Full-stack / hybrid frameworks

These add SSR, SSG, API routes, and deployment adapters on top of a UI library.

### Next.js 15

The dominant React meta-framework. Vercel-backed, used by a huge portion of the React ecosystem.

```bash
npx create-next-app@latest
```

**Strengths:**
- Most complete React framework: SSR, SSG, ISR, API routes, middleware, image optimization
- React Server Components (RSC) reduce client-side JS significantly
- App Router with nested layouts and parallel routes
- Excellent Vercel deployment (but works on any Node host, Cloudflare, etc.)
- Massive community, tutorials, and third-party integrations

**Weaknesses:**
- High complexity: App Router vs Pages Router, server vs client components, caching layers
- Vercel-centric defaults (some features work best on Vercel)
- Bundle size can balloon if you're not careful about `"use client"` boundaries
- Frequent breaking changes between major versions
- Caching behavior has been controversial and was reworked in v15

**Best for**: Production web apps that need SEO + interactivity -- e-commerce, SaaS marketing + dashboard, content platforms.

**Avoid for**: Simple static sites (overkill), projects where you want minimal vendor influence.

---

### Nuxt 4

The Vue equivalent of Next.js. Full-stack framework with SSR, SSG, API routes, and auto-imports.

```bash
npx nuxi@latest init my-app
```

**Strengths:**
- Auto-imports: components, composables, and utilities just work without explicit imports
- File-based routing (like Next.js)
- Nitro server engine: deploy to 20+ platforms (Node, Cloudflare, Deno, Vercel, Netlify)
- Built-in `useFetch`/`useAsyncData` for data fetching with SSR hydration
- Module ecosystem (Nuxt Content, Nuxt Image, Nuxt Auth, etc.)

**Weaknesses:**
- "Magic" auto-imports can confuse TypeScript tooling and new developers
- Smaller community than Next.js
- Performance overhead from the module/plugin system
- Breaking changes between Nuxt 2 → 3 → 4 were significant

**Best for**: Vue developers who want a full-stack framework with conventions and deployment flexibility.

---

### SvelteKit

The official Svelte meta-framework. Handles routing, SSR, SSG, and API endpoints.

```bash
npx sv create my-app
# Select SvelteKit when prompted
```

**Strengths:**
- Inherits Svelte's small bundle advantage in a full-stack context
- File-based routing with layouts and loading functions
- `+page.server.ts` / `+server.ts` for backend logic (form actions, API routes)
- Adapter system: deploy to Node, Cloudflare, Vercel, Netlify, static, etc.
- Forms work without JS by default (progressive enhancement)

**Weaknesses:**
- Smallest ecosystem of the meta-frameworks
- Fewer community tutorials than Next.js
- Adapter system still has occasional rough edges

**Best for**: Full-stack apps where performance and bundle size matter.

---

### Remix

A React framework focused on web fundamentals: HTTP, forms, progressive enhancement. Now merged with React Router v7.

```bash
npx create-remix@latest
```

**Strengths:**
- Web-standards-first: uses native `<form>`, `Request`/`Response`, HTTP caching
- Nested routing with parallel data loading (no waterfalls)
- Apps work without JS, then progressively enhance
- Excellent error boundaries and loading states
- Runs on any JS runtime (Node, Deno, Cloudflare Workers, etc.)

**Weaknesses:**
- Smaller community than Next.js
- Merger with React Router v7 caused confusion about identity/direction
- No built-in static site generation (SSR-focused)
- Fewer deployment-specific optimizations compared to Next.js on Vercel

**Best for**: Teams that care about web fundamentals, accessibility, and progressive enhancement.

---

## Content-first framework

### Astro 5

Astro's core idea: ship **zero JavaScript** by default. Interactive components (React, Vue, Svelte, Solid) load only where needed via "islands."

```bash
npm create astro@latest
```

**Strengths:**
- Zero JS by default -- pages are static HTML unless you opt in
- **Islands architecture**: drop in React/Vue/Svelte components only where interactivity is needed
- Content Collections: type-safe markdown/MDX/JSON with schema validation
- Built-in image optimization (`astro:assets`)
- View Transitions API for page transitions without an SPA
- Deploys to Cloudflare, Vercel, Netlify, or any static host

**Weaknesses:**
- Not suited for heavy interactivity -- the island model doesn't scale for complex client state
- Mixing multiple UI frameworks in one project can get confusing
- Younger ecosystem than React/Next.js
- SSR mode is less mature than Next.js

**Best for**: Blogs, portfolios, documentation, marketing sites, landing pages -- any content-heavy site where performance matters.

**Avoid for**: Dashboards, real-time features, or apps with heavy client state.

---

## Static site generators

These take content (Markdown, data files) and templates, and produce plain HTML. No client-side JS runtime, no hydration -- just HTML pages.

### Eleventy (11ty)

A flexible, zero-config Node.js static site generator. No UI framework -- just templates compiled to HTML.

```bash
npm install @11ty/eleventy
npx eleventy --serve
```

**Strengths:**
- Zero client JS (no framework runtime at all)
- Template-language agnostic: Nunjucks, Liquid, Markdown, WebC, and 8 more
- Fast builds (~2s for 1000 pages)
- No lock-in to any UI framework
- Data cascade system for content-heavy sites
- Active development and growing community

**Weaknesses:**
- No component model (templates, not components)
- Adding interactivity requires manual JS (no island system)
- Less polished DX than Astro (no built-in image optimization)
- Fewer themes -- relies on starter projects instead

**Best for**: Developers who want maximum control and minimal abstraction. Great for blogs and docs.

---

### Hugo

The fastest static site generator. Written in Go, single binary, no dependencies.

```bash
brew install hugo
hugo new site my-blog
hugo server  # http://localhost:1313
```

**Strengths:**
- Blazing fast builds -- 10,000 pages in under 1 second
- Single binary, no Node.js/Ruby/Python required
- Built-in image processing, i18n, taxonomies, menus
- Large theme ecosystem (300+ themes)
- Shortcodes for reusable content snippets
- Built-in asset pipeline (Sass, PostCSS, JS bundling)

**Weaknesses:**
- Go template syntax is unfamiliar and verbose (`{{ .Params.title }}`, `{{ range }}`, `{{ with }}`)
- Debugging template errors is painful (cryptic error messages)
- Adding interactivity requires manual JS -- no component system
- Theme customization can be awkward (override files by path)
- Opinionated content organization (sections, bundles) has a learning curve

**Best for**: High-volume blogs and docs sites where build speed matters. Technical users comfortable with Go templates.

---

### Jekyll

The original static site generator (2008). Ruby-based, powers GitHub Pages natively.

```bash
gem install jekyll bundler
jekyll new my-blog
bundle exec jekyll serve  # http://localhost:4000
```

**Strengths:**
- GitHub Pages integration -- push and it builds automatically, no CI needed
- Mature ecosystem: hundreds of themes and plugins
- Liquid templates are simple and readable
- Great for developer blogs (Markdown + front matter)
- Extensive documentation and community answers

**Weaknesses:**
- Ruby dependency -- `gem install`, `bundler`, version management
- Slow builds (10x-100x slower than Hugo for large sites)
- Development has slowed significantly (fewer updates in recent years)
- No built-in asset pipeline (need plugins for Sass, image optimization)
- GitHub Pages restricts which plugins you can use (unless you build locally)

**Best for**: GitHub-hosted blogs and project documentation. Developers who want zero-config deployment via GitHub Pages.

---

### Hexo

A Node.js-based SSG popular in the Asian developer community. Markdown-focused with a plugin ecosystem.

```bash
npm install -g hexo-cli
hexo init my-blog
hexo server  # http://localhost:4000
```

**Strengths:**
- Node.js ecosystem -- familiar tooling for JS developers
- Fast (faster than Jekyll, slower than Hugo)
- NexT theme is excellent and highly configurable
- Good i18n support
- Plugin system for search, SEO, feeds, analytics
- Simple deploy commands (`hexo deploy`)

**Weaknesses:**
- Smaller community than Hugo/Jekyll in the English-speaking world
- Fewer themes than Hugo
- EJS/Nunjucks templates are less modern than component-based alternatives
- No built-in image optimization
- Plugin quality varies

**Best for**: Node.js developers who want a simple, Markdown-based blog with good theme support.

{% note info %}
**Full disclosure**: This blog runs on Hexo 8.1.1 + NexT 8.27.0, deployed to Cloudflare Pages.
{% endnote %}

---

### SSG comparison

| Feature | Hugo | Jekyll | Hexo | Eleventy |
|---------|------|--------|------|----------|
| **Language** | Go | Ruby | Node.js | Node.js |
| **Build speed (1000 pages)** | <1s | ~30s | ~5s | ~2s |
| **Template engine** | Go templates | Liquid | EJS/Nunjucks | Any (11 options) |
| **Install** | Single binary | `gem install` | `npm install` | `npm install` |
| **GitHub Pages native** | No | Yes | No | No |
| **Component model** | No (partials) | No (includes) | No (partials) | No (shortcodes/WebC) |
| **Image optimization** | Built-in | Plugin | Plugin | Plugin |
| **i18n** | Built-in | Plugin | Built-in | Manual |
| **Themes** | 300+ | 500+ | 100+ | Starter projects |
| **Active development** | Very active | Slow | Moderate | Active |

### When to pick an SSG over Astro

- **Eleventy**: You want template flexibility without a framework, and don't need islands
- **Hugo**: You need sub-second builds for thousands of pages, or you don't want Node.js
- **Jekyll**: You want free GitHub Pages hosting with zero CI configuration
- **Hexo**: You're in the Node.js ecosystem and want a blog framework with good themes

**Astro** offers the best DX for new content sites in 2026 (components, TypeScript, content collections, image optimization). But SSGs are battle-tested and have no plans of going away -- pick whichever matches your workflow.

---

## Deployment platforms

Frameworks produce output. Deployment platforms host it. These are the three major players for frontend deployment -- all offer generous free tiers.

### Vercel

The company behind Next.js. Optimized for frontend frameworks with serverless functions at the edge.

**Free tier**: 100 GB bandwidth, 100 GB-hours serverless, unlimited static sites, automatic HTTPS

**Strengths:**
- Best-in-class Next.js support (unsurprisingly) -- zero-config deployment
- Preview deployments on every PR (unique URL per commit)
- Edge Functions and Serverless Functions built in
- Analytics and Web Vitals monitoring
- Global CDN with smart caching
- Works with any framework (not just Next.js) -- Astro, SvelteKit, Nuxt, etc.

**Weaknesses:**
- Generous free tier, but costs scale quickly at production traffic
- Some Next.js features work best (or only) on Vercel
- Vendor lock-in concern for Next.js-specific features (ISR, middleware)
- No free plan for team collaboration (Pro required)

**Best for**: Next.js projects, teams that want the smoothest deploy-preview-ship workflow.

---

### Netlify

The pioneer of the "git push to deploy" workflow. Framework-agnostic with a strong focus on developer experience.

**Free tier**: 100 GB bandwidth, 300 build minutes/month, 125K serverless invocations, 1 concurrent build

**Strengths:**
- Framework-agnostic -- works equally well with any SSG or framework
- Netlify Functions (serverless), Edge Functions, Forms, Identity (auth)
- Split testing (A/B) and branch deploys built in
- `netlify.toml` for declarative configuration (redirects, headers, build settings)
- Large plugin ecosystem
- Netlify CMS / Decap CMS integration for content editing

**Weaknesses:**
- Build times can be slow (1 concurrent build on free tier)
- Pricing jumps are steep (free → $19/member/month)
- Some edge cases with framework-specific adapters
- Analytics are a paid add-on

**Best for**: Static sites and JAMstack projects across any framework. Teams that want built-in forms, auth, and serverless without configuring separate services.

---

### Cloudflare Pages

Static site hosting on Cloudflare's global network. Tightly integrated with Cloudflare Workers for serverless compute.

**Free tier**: Unlimited bandwidth, 500 builds/month, 1 concurrent build, unlimited sites

**Strengths:**
- **Unlimited bandwidth on free tier** -- the most generous free plan
- Cloudflare's global network (300+ cities) -- excellent TTFB worldwide
- Workers integration for serverless compute (100K requests/day free)
- `_headers` and `_redirects` files for configuration
- Git integration (GitHub/GitLab) or direct upload via Wrangler CLI
- KV, D1 (SQLite), R2 (object storage) available alongside Pages
- DDoS protection and WAF included

**Weaknesses:**
- Fewer built-in developer features than Vercel/Netlify (no preview comments, no built-in forms)
- Framework adapter support is good but sometimes lags behind Vercel
- Dashboard UX is less polished for frontend-specific workflows
- Build environment is more limited (fewer pre-installed tools)
- Worker/Pages Functions have different APIs than Node.js (Web Standards-based)

**Best for**: Static sites that need global performance and unlimited bandwidth. Projects already using Cloudflare for DNS/CDN. Cost-conscious teams.

---

### Platform comparison

| Feature | Vercel | Netlify | Cloudflare Pages |
|---------|--------|---------|-----------------|
| **Free bandwidth** | 100 GB/mo | 100 GB/mo | Unlimited |
| **Free builds** | 6,000 min/mo | 300 min/mo | 500 builds/mo |
| **Preview deploys** | Yes (every commit) | Yes (every commit) | Yes (every commit) |
| **Serverless** | Edge + Serverless | Functions + Edge | Workers (edge) |
| **Global CDN** | Yes | Yes | Yes (300+ cities) |
| **Custom domains** | Yes | Yes | Yes |
| **HTTPS** | Automatic | Automatic | Automatic |
| **Framework support** | Best for Next.js | Framework-agnostic | Good (adapters) |
| **Paid tier starts at** | $20/user/mo | $19/member/mo | $5/mo (Workers Paid) |
| **Best integration** | Next.js | JAMstack, CMS | Cloudflare ecosystem |

### Which platform to pick

- **Already using Cloudflare DNS?** → Cloudflare Pages (unified dashboard, unlimited bandwidth)
- **Building with Next.js?** → Vercel (best Next.js experience)
- **Need built-in forms, auth, CMS?** → Netlify (batteries included)
- **Cost-sensitive?** → Cloudflare Pages (unlimited bandwidth free tier)
- **Don't care / just want it to work?** → Any of the three -- they all handle static sites perfectly

{% note info %}
**You're not locked in.** All three platforms deploy from a Git repo. Switching between them is usually a 10-minute configuration change, not a rewrite. Pick one, start building, and migrate later if needed.
{% endnote %}

---

## Head-to-head: common scenarios

### "I'm building a portfolio site"

| Option | Fit | Why |
|--------|-----|-----|
| **Astro** | Best | Zero JS, content collections for projects/albums, image optimization |
| **HTML + Vite** | Great | Maximum control, no abstraction, modern tooling |
| **Plain HTML/CSS** | Good | If it's 3-5 pages with no build step needed |
| **Hugo** | Good | Fast builds, good themes, no Node.js |
| **Next.js** | Overkill | You'd ship React runtime for mostly static pages |

### "I'm building a SaaS dashboard"

| Option | Fit | Why |
|--------|-----|-----|
| **Next.js** | Best | SSR for auth pages, RSC for data-heavy views, API routes |
| **Angular** | Great | Enterprise-grade, built-in everything, strong typing |
| **Remix** | Great | Web-standards approach, excellent data loading |
| **SvelteKit** | Great | Smallest bundles, fast interactions |
| **Astro** | Poor | Not designed for heavy interactivity |

### "I'm building an e-commerce site"

| Option | Fit | Why |
|--------|-----|-----|
| **Next.js** | Best | ISR for product pages, SSR for cart/checkout, image optimization |
| **Nuxt** | Great | Same capabilities, Vue ecosystem |
| **Remix** | Great | Progressive enhancement means checkout works without JS |
| **SvelteKit** | Good | Fast, but fewer e-commerce integrations |

### "I'm building a blog"

| Option | Fit | Why |
|--------|-----|-----|
| **Astro** | Best | Content collections, MDX, zero JS, image optimization |
| **Hugo** | Great | Fastest builds, single binary, good for large blogs |
| **Eleventy** | Great | Simpler, template-based, fast builds |
| **Hexo** | Good | Proven, good themes (NexT), Node.js ecosystem |
| **Jekyll** | Good | Free GitHub Pages hosting, zero CI config |
| **Next.js** | Overkill | Unless your blog has significant interactive features |

### "I just need a landing page"

| Option | Fit | Why |
|--------|-----|-----|
| **Plain HTML/CSS** | Best | One page, no dependencies, deploy in seconds |
| **HTML + Vite** | Great | If you want TypeScript or CSS preprocessing |
| **Astro** | Good | If it might grow into a multi-page site |
| **Any framework** | Overkill | Don't ship 50KB+ of JS for a landing page |

---

## Performance comparison

Ballpark figures from Lighthouse testing on a minimal starter project:

| Option | Lighthouse score | JS bundle (hello world) | Build time (1000 pages) | TTFB (static) |
|--------|-----------------|------------------------|------------------------|----------------|
| **Plain HTML** | 100 | 0 KB | 0s (no build) | ~20ms |
| **Hugo** | 100 | 0 KB | <1s | ~20ms |
| **Astro** | 100 | 0 KB | ~3s | ~20ms |
| **Eleventy** | 100 | 0 KB | ~2s | ~20ms |
| **Jekyll** | 100 | 0 KB | ~30s | ~20ms |
| **Hexo** | 100 | 0 KB | ~5s | ~20ms |
| **SvelteKit** | 95-100 | ~15 KB | ~5s | ~30ms |
| **Remix** | 90-98 | ~50 KB | N/A (SSR) | ~40ms |
| **Next.js** | 85-98 | ~80 KB | ~8s | ~35ms |
| **Nuxt** | 85-95 | ~70 KB | ~7s | ~35ms |
| **React + Vite** | 80-95 | ~45 KB | N/A (SPA) | ~20ms |
| **Vue + Vite** | 80-95 | ~35 KB | N/A (SPA) | ~20ms |
| **Angular** | 80-90 | ~55 KB | N/A (SPA) | ~20ms |

{% note info %}
Real-world performance depends heavily on what you build, how you configure it, and your deployment target. Always measure your own app.
{% endnote %}

---

## Developer experience

| Framework | TypeScript | Hot reload | IDE support | Docs quality | CLI tooling |
|-----------|-----------|-----------|-------------|--------------|-------------|
| **React + Vite** | Excellent | Fast (Vite) | Excellent | Good (fragmented) | Good |
| **Angular** | Excellent | Fast (esbuild) | Excellent | Very good | Excellent (ng CLI) |
| **Next.js** | Excellent | Fast (Turbopack) | Excellent | Very good | Excellent |
| **Vue** | Very good | Fast (Vite) | Very good | Excellent | Good |
| **Nuxt** | Very good | Fast (Vite) | Good | Very good | Excellent (nuxi) |
| **Svelte** | Good | Fast (Vite) | Good | Very good | Good (sv) |
| **SvelteKit** | Good | Fast (Vite) | Good | Very good | Good |
| **Astro** | Very good | Fast (Vite) | Good | Excellent | Excellent |
| **Remix** | Excellent | Fast (Vite) | Excellent | Good | Good |

---

## Deployment targets

| Option | Static hosting | Cloudflare Pages | Vercel | Netlify | Node server | Edge runtime |
|--------|---------------|-----------------|--------|---------|-------------|-------------|
| **Plain HTML** | Yes | Yes | Yes | Yes | N/A | N/A |
| **HTML + Vite** | Yes (build) | Yes | Yes | Yes | N/A | N/A |
| **React + Vite** | Yes | Yes | Yes | Yes | N/A | N/A |
| **Next.js** | SSG only | Yes (adapter) | Best | Yes | Yes | Yes |
| **Angular** | Yes | Yes | Yes | Yes | N/A | N/A |
| **Vue + Vite** | Yes | Yes | Yes | Yes | N/A | N/A |
| **Nuxt** | SSG + SSR | Yes (Nitro) | Yes | Yes | Yes | Yes |
| **SvelteKit** | SSG + SSR | Yes (adapter) | Yes | Yes | Yes | Yes |
| **Astro** | SSG + SSR | Yes (adapter) | Yes | Yes | Yes | Yes |
| **Remix** | No (SSR) | Yes (adapter) | Yes | Yes | Yes | Yes |
| **Hugo** | Yes | Yes | Yes | Yes | N/A | N/A |
| **Jekyll** | Yes | Yes (build) | Yes | Yes | N/A | N/A |
| **Hexo** | Yes | Yes | Yes | Yes | N/A | N/A |
| **Eleventy** | Yes | Yes | Yes | Yes | N/A | N/A |

---

## Decision flowchart

1. **How many pages?**
   - 1-3 pages, no blog → **Plain HTML/CSS** or **HTML + Vite**
   - More → continue

2. **Is it mostly static content?** (blog, portfolio, docs, marketing)
   - Yes, and I want components/TypeScript → **Astro**
   - Yes, and I want the fastest builds → **Hugo**
   - Yes, and I want free GitHub Pages hosting → **Jekyll**
   - Yes, and I want maximum simplicity → **Eleventy** or **Hexo**
   - No → continue

3. **Do you need server-side rendering?** (SEO, auth, dynamic data)
   - No → Pick your preferred SPA: **React + Vite**, **Vue**, **Svelte**, or **Angular**
   - Yes → continue

4. **Which UI library does your team know?**
   - React → **Next.js** (full-featured) or **Remix** (web-standards-focused)
   - Vue → **Nuxt**
   - Svelte → **SvelteKit**
   - No preference → **SvelteKit** (smallest learning surface) or **Next.js** (largest ecosystem)

5. **Where to deploy?**
   - Unlimited free bandwidth → **Cloudflare Pages**
   - Best Next.js experience → **Vercel**
   - Built-in forms/auth/CMS → **Netlify**
   - Any static host → All three work fine

---

## Summary

There is no single best option -- only the best option for your project:

- **Plain HTML/CSS**: When you need 1-3 pages and zero complexity
- **HTML + Vite**: When you want modern tooling without a framework
- **Astro**: When content is king and you want components + TypeScript
- **Hugo**: When you need the fastest builds for large content sites
- **Hexo / Jekyll**: When you want a proven blog framework with good themes
- **Next.js**: When you need everything and have React experience
- **SvelteKit**: When you want the best performance-to-complexity ratio
- **Remix**: When you care deeply about web standards and progressive enhancement
- **Nuxt**: When you're in the Vue ecosystem and need full-stack
- **Angular**: When your team needs strong conventions and enterprise-grade tooling
- **React + Vite**: When you're building a pure client-side interactive app
- **Vue / Svelte**: When you want a simpler SPA alternative to React

And for hosting: **Cloudflare Pages** for free bandwidth, **Vercel** for Next.js, **Netlify** for batteries-included features. All three are excellent -- you can switch between them in minutes.

Pick based on what you're building, not what's trending. A portfolio on plain HTML will always load faster than one on Next.js -- not because Next.js is bad, but because simpler tools are better for simpler problems.
