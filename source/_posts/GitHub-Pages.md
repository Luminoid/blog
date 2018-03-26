---
title: GitHub Pages
date: 2018-03-26 19:43:48
updated:
categories: Tool
tags: GitHub
keywords:
- GitHub Pages
- React
---

<!-- TOC -->

## Deploy React App on GitHub Pages from the Scratch
[create-react-app Doc](https://github.com/facebook/create-react-app/blob/master/packages/react-scripts/template/README.md)
[GitHub Pages Doc](https://pages.github.com)

### Environment Configuration
``` bash
$ yarn global add create-react-app
```

### Initialize a React App
``` bash
$ create-react-app <project-name>
$ cd <project-name>
# Edit...
```

<!-- more -->

### WebStorm Configuration
``` bash
$ yarn add react-scripts
```

### Local Configuration
Deploy the app on a GitHub Project Site

**Step 1: Add `homepage` to `package.json`**
In `package.json`:
``` bash
"homepage": "https://username.github.io/reponame",
```

**Step 2: Install `gh-pages`**
``` bash
$ yarn add gh-pages
```
Add `predeploy` and `deploy` scripts to `package.json`
In `package.json`:
``` bash
"scripts": {
  "predeploy": "npm run build",
  "deploy": "gh-pages -d build",
  "start": "react-scripts start",
  ...
}
```

**Step 3: Deploy the site**
Run `deploy` script to deploy the site every time
``` bash
yarn run deploy
```

### Git Repo Configuration
**Step 1: Create a new repository**

**Step 2: Push the local App to the Git repo**
``` bash
git init
git add -A
git commit -m "Initial commit"
git remote add origin <git_url>
git push -u origin master
```

**Step 3: Use `gh-pages` branch to build the GitHub Pages**

### App Deployment
``` bash
yarn run deploy
git add -A
git commit -m <msg>
git push
```
