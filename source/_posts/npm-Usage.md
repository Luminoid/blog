---
title: npm Usage
date: 2018-01-02 22:34:49
updated:
categories:
- Web
- JavaScript
tags: npm
keywords: npm
---

[Official Site](https://www.npmjs.com)

## Command
``` bash
npm ls                              # List packages installed in the current project
npm list -g --depth=0               # List globally installed packages
npm search                          # Search for packages; aliases: npm s
npm install                         # Install all modules listed as dependencies in package.json
npm install <package>               # Install a local package, and the package will appear in your dependencies by default; alias: npm i
npm install <package> --save-dev    # Package will appear in your devDependencies; alias: npm i -D
npm install -g <package>            # Install a global package
npm update                          # Update local packages to the latest version (specified by the tag config)
npm update -g <package>             # Update a global package
npm outdated                        # Check for outdated packages
npm outdated -g --depth=0           # Check for global outdated packages
npm uninstall <package>             # Remove a local package
npm uninstall <package> --save      # Remove a package from the dependencies in package.json
npm uninstall -g <package>          # Remove a global package
npm docs                            # Docs for a package in a web browser maybe
npm run <command> [-- <args>...]    # Run arbitrary package scripts
npm start [-- <args>...]            # Start a package
npm shrinkwrap                      # Lock down dependency versions for publication
npm doctor                          # Check your environments
```
**Development**
``` bash
npm init                            # Interactively create a package.json file
npm edit <package>                  # Edit an installed package
npm config list                     # Show all the config settings
npm config set key value            # Sets the config key to the value
```

## Package
### [npm-check](https://github.com/dylang/npm-check)
Check for outdated, incorrect, and unused dependencies.
#### command
``` bash
npm-check           # See what can be updated, what isn't being used
npm-check ../foo    # Check another path
npm-check -u        # Interactive update
npm-check -g        # Look at global modules
npm-check -gu       # Update globally installed modules by picking which ones to upgrade
```
