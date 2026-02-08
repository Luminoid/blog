---
title: Node.js Usage
date: 2021-11-07 19:36:53
categories: 
- Web
- JavaScript
tags: 
- Node.js
- n
---

Quick reference for Node.js version management and usage.

## Usage
Start REPL.
``` bash
node
```

Check currently supported ES6 features.
``` bash
node --v8-options | grep harmony
```

## Version Management
### [n](https://github.com/tj/n)
#### Installation
``` bash
brew install n
```

#### Usage
``` bash
n               # Display downloaded Node.js versions and install selection
sudo n latest   # Install the latest Node.js release (downloading if necessary)
sudo n lts      # Install the latest LTS Node.js release (downloading if necessary)
```

## Package Manager
[npm-check-updates](https://www.npmjs.com/package/npm-check-updates)
