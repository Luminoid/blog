---
title: Yarn Usage
date: 2017-12-13 00:36:44
updated:
categories:
- Web
- JavaScript
tags: Yarn
keywords: Yarn
---

<!-- TOC -->

## Command
``` bash
yarn list                           # List installed packages
yarn install                        # Install all the dependencies of project; alias: yarn
yarn add <package...>               # Install packages in your dependencies
yarn add <package...> [--dev/-D]    # Install packages in your devDependencies
yarn global add <package...>        # Install packages globally
yarn upgrade [package]              # Upgrade a package
yarn outdated                       # Checks for outdated package dependencies
yarn remove <package...>            # Remove packages
yarn run [script] [<args>]          # Run a defined package script
yarn init                           # Interactively create or update a package.json file
yarn                                # Try Yarn out on your existing npm project
```

<!-- more -->

## CLI Commands Comparison
 npm (v5) | Yarn
--|--
 `npm install` | `yarn install`
 `npm install [package]` | `yarn add [package]`
 `npm install [package] --save-dev` | `yarn add [package] --dev`
 `npm install [package] --global` | `yarn global add [package]`
 `npm update --global` | `yarn global upgrade`
 `npm rebuild` | `yarn install --force`
 `npm uninstall [package]` | `yarn remove [package]`
 `rm -rf node_modules && npm install` | `yarn upgrade`

## Configuration
### `package.json`
- List the packages that your project depends on
- Allow you to specify the versions of a package that your project can use using [semantic versioning rules](https://yarnpkg.com/en/docs/dependency-versions)
- Make your build reproducible, and therefore much easier to share with other developers

### `yarn.lock`
Store exactly which versions of each dependency were installed.
