#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Error! Usage: sh deploy.sh <commit_message> or sh deploy.sh compress"
    exit 1
fi

# Compress image
if [ $1 = "compress" ]; then
    cd source/_posts
    pngquant --ext .png --force 256 */*.png
    echo "PNG images under source/_posts have been compressed."
    exit 0
fi

# Generate & deploy
commit_message=$1

echo "$ hexo clean"
hexo clean --config source/_data/next.yml

echo "$ hexo generate"
if ! hexo generate --config source/_data/next.yml; then
    echo "Error! hexo generate failed"
    exit 2
fi

if [ ! -d "docs" ]; then
    echo "Error! No docs/ folder generated"
    exit 3
fi

echo "$ git add"
git add -A

echo "$ git commit"
git commit -m "$commit_message"

echo "$ git push"
git push
