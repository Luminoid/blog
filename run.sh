#!/bin/bash

# Compress image
if [ $# -eq 1 ] && [ $1 = "compress" ]; then
    cd source/_posts
    pngquant --ext .png --force 256 */*.png
    echo "PNG images under source/_posts/*/ have been compressed."
    exit 0
fi

if [ $# -eq 1 ] && [ $1 = "server" ]; then
    hexo server --config source/_data/next.yml
    exit 0
fi

# Generate & deploy
if [ $# -eq 2 ] && [ $1 = "deploy" ]; then
    commit_message=$2

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
    exit 0
fi

echo "Error! Usage: sh run.sh [compress | server | deploy <commit_message>]"
exit 1
