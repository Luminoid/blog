---
title: Git Hooks
date: 2018-03-21 13:58:12
updated:
categories:
- Git
---

## Run npm scripts automatically before git commit
Run `sh deploy.sh` once to deploy the self-organized `hooks` folder, so that the hooks can be added to the version control system.
``` bash ./deploy.sh
#!/bin/bash

configure_hooks(){
    git config core.hooksPath || git config core.hooksPath ./chore/hooks
    chmod -R +x ./chore/hooks
}

echo '==> Configuring hooks'
configure_hooks
```

The hooks under the `hooks` folder will be triggered automatically.
``` bash ./chore/hooks/pre-commit
unset GIT_DIR  # important

cd path/to/work
echo '==> Building project'
if ! npm run build; then
    echo "==> Error: npm run build failed"
    exit 1
fi
git add dist
```
