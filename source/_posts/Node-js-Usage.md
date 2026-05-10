---
title: "Node.js in 2026: pick your stack"
date: 2021-11-07 19:36:53
categories:
  - Web
tags:
  - Node.js
  - npm
  - pnpm
  - Bun
  - Deno
  - fnm
  - mise
  - Volta
  - Corepack
---

The 2021 Node stack was Node + npm + nvm and a third-party tool for everything else. By 2026 every layer has a serious challenger, and Node itself absorbed half of what used to be a separate dependency: test runner, watch mode, dotenv, native TypeScript. This is the snapshot of what to pick and why.

<!-- more -->

## Pick a Node version

Node ships an LTS each October on even-numbered majors. As of May 2026:

| Version | Status | Use it when |
|---|---|---|
| 22 | Maintenance LTS (until Apr 2027) | An existing project that won't budge |
| 24 | Active LTS (until Oct 2026, then Maintenance) | Default for new work |
| 26 | Current (becomes Active LTS Oct 2026) | Trying out features that haven't crystallised |

Default to **24 LTS** for new projects unless a dependency pins something older.

## Version managers

| Tool | Language | Speed | Notes |
|---|---|---|---|
| `n` | shell | medium | Simple, sudo-required, Node-only |
| `nvm` | bash | slow shell startup | What every Stack Overflow answer assumes; sources a long bash script in every shell |
| [`fnm`](https://github.com/Schniz/fnm) | Rust | fast | Drop-in nvm replacement; reads `.nvmrc` and `.node-version` |
| [`volta`](https://volta.sh) | Rust | fast | Project versions baked into `package.json`; release cadence has been quiet |
| [`mise`](https://mise.jdx.dev) | Rust | fast | Polyglot: Node + Python + Ruby + Go in one tool. asdf successor |
| Homebrew (`node@24`) | n/a | n/a | Fine for one global Node, painful for multi-version |

Pick by need:

- One global Node, no project pinning: Homebrew
- Multiple Node versions, only Node: `fnm`
- Multiple runtimes (Node + Python + Ruby + ...): `mise`

`mise` reads `.tool-versions` (asdf format) and `.node-version`, so it inherits whatever pin a project already has. See {% post_link M1-Mac-Development-Setup "Mac development setup" %} for the wider polyglot story.

## Package managers

| Manager | Install | Speed | Disk |
|---|---|---|---|
| npm | bundled | baseline | duplicates per project |
| [pnpm](https://pnpm.io) | `corepack enable` | fast | content-addressable global store (saves GBs across projects) |
| [yarn](https://yarnpkg.com) | `corepack enable` | fast | PnP or `node_modules`. Yarn 4 (berry) is the modern line; Yarn 1.x classic is unmaintained |
| [Bun](https://bun.sh) | `brew install bun` | fastest | global cache |

[**Corepack**](https://nodejs.org/api/corepack.html) ships with Node and pins package-manager versions per project via the `packageManager` field in `package.json`. Enable it once globally; thereafter `pnpm` and `yarn` resolve to whatever each project pins, with no global-version drift across machines.

```bash
corepack enable
# Then in package.json:
# "packageManager": "pnpm@9.13.2"
```

## Runtime alternatives

Node is no longer the only thing that runs `package.json` projects:

- **[Bun](https://bun.sh)** (1.x in 2026): runtime, bundler, test runner, and package manager in one Zig binary. Imports npm packages directly, runs most Node code unchanged. Faster cold start and noticeably faster `bun install`. Production-ready for backend services and CLIs; some native modules still flake on edge cases.
- **[Deno](https://deno.com)** (2.x): runs npm packages through `npm:` specifiers and ships a stable Node compatibility layer. Tighter security model (explicit `--allow-net`, `--allow-read`). Worth picking for first-class TypeScript and a smaller install surface.
- **Node.js** stays the safest default for libraries that depend on Node-specific behaviour. The 24 LTS feature gap with Bun/Deno has narrowed: test runner, watch mode, dotenv, and TypeScript all ship in stock Node now.

## Modern Node.js (24 LTS)

What no longer needs a third-party dependency:

```bash
# Watch mode (re-run on file change)
node --watch app.js

# Test runner
node --test
node --test --watch test/

# Dotenv
node --env-file=.env app.js

# TypeScript: type-stripping is default in 23.6+; transform (enums, namespaces)
# is still flag-gated through 24.
node app.ts
node --experimental-transform-types app.ts
```

A test, written against `node:test`:

```js
import { test } from 'node:test';
import assert from 'node:assert/strict';

test('addition', () => {
  assert.equal(1 + 1, 2);
});
```

`node --test` finds it without config, tsconfig, or babel preset.

## Modules: ESM is the default

`package.json` decides module resolution; `"type": "module"` makes the whole project ESM:

```json
{
  "type": "module"
}
```

| Extension | Behavior |
|---|---|
| `.mjs` | Always ESM |
| `.cjs` | Always CommonJS |
| `.js` | Follows the nearest `"type"` field |

ESM features worth using day-to-day:

- Top-level `await` (no IIFE wrapper around async startup)
- `import.meta.url` and `import.meta.dirname` replace `__dirname`
- `require(esm)` works synchronously in Node 22+ behind a flag, default-on in 24

## Cheat sheet

```bash
# REPL
node

# Run with watch + dotenv + TypeScript in one go
node --watch --env-file=.env app.ts

# List downloaded versions
n               # interactive picker
fnm list
mise list node

# Install latest LTS
sudo n lts
fnm install --lts
mise use -g node@lts

# Bump dependencies
npx npm-check-updates -u   # write package.json
npm install                # resolve
pnpm update --latest --interactive   # pnpm equivalent
```
