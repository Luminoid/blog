---
title: Git Hooks
date: 2018-03-21 13:58:12
updated:
categories:
- Tool
- Git
tags: Git
keywords:
- Git
- Hooks
- npm
---

## Run npm scripts automatically before git commit
Run `sh deploy.sh` once to deploy the self-organized `hooks` folder, so that the hooks can be added to the version control system.
`./deploy.sh`
``` bash
#!/bin/bash

configure_hooks(){
    git config core.hooksPath || git config core.hooksPath ./chore/hooks
    chmod -R +x ./chore/hooks
}

echo '==> Configuring hooks'
configure_hooks
```

The hooks under the `hooks` folder will be triggered automatically.
`./chore/hooks/pre-commit`
``` bash
unset GIT_DIR  # important

cd path/to/work
echo '==> Building project'
if ! npm run build; then
    echo "==> Error: npm run build failed"
    exit 1
fi
git add dist
```
