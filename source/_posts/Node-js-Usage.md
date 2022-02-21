---
title: Node.js Usage
date: 2021-11-07 19:36:53
updated:
categories: 
- Web
- JavaScript
tags: 
- Node.js
- n
---

## Usage
Start REPL.
``` bash
node
```

Check current supported ES6 features.
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
