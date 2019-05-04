#!/bin/bash

# Generate & deploy
commit_message=""
check_commit_msg(){
    if   [ "$*" = "-u" ]; then
        commit_message="post: updated"
    elif [[ "$*" =~ ^(post|theme|config|chore):\ .+$ ]]; then
        commit_message="$*"
    else
        echo "Error! Usage: sh run.sh deploy \"[post|theme|config|chore]: <content>\""
        exit 2
    fi
}

if [ $# -eq 2 ] && ([ $1 = "deploy" ] || [ $1 = "d" ]); then
    check_commit_msg $2

    echo "$ hexo clean"
    hexo clean --config source/_data/next.yml

    echo "$ hexo generate"
    if ! hexo generate --config source/_data/next.yml; then
        echo "Error! hexo generate failed"
        exit 3
    fi

    if [ ! -d "docs" ]; then
        echo "Error! No docs/ folder generated"
        exit 4
    fi

    echo "$ git add"
    git add -A

    echo "$ git commit"
    git commit -m "$commit_message"

    echo "$ git push"
    git push
    exit 0
fi

# Help
b=$(tput bold) # bold
e=$(tput sgr0) # end
if [ $# -eq 1 ] && ([ $1 = "help" ] || [ $1 = "h" ]); then
    echo "run.sh [compress|c]                   Compress PNG images under ${b}source/_posts/*/${e}"
    echo "run.sh [deploy|d] <commit_message>    Generate & deploy site, the format of ${b}<commit_message>${e} is:"
    echo "                                           ${b}[post|theme|config|chore]: <content>${e}"
    echo "run.sh deploy -u                      alias for ${b}run.sh deploy \"post: updated\"${e}"
    echo "run.sh [help|h]                       Display help information"
    echo "run.sh [server|s]                     Start hexo server locally"
    exit 0
fi

# Compress images
if [ $# -eq 1 ] && ([ $1 = "compress" ] || [ $1 = "c" ]); then
    cd source/_posts
    pngquant --ext .png --force 256 */*.png
    echo "PNG images under source/_posts/*/ have been compressed."
    exit 0
fi

# Start hexo server
if [ $# -eq 1 ] && ([ $1 = "server" ] || [ $1 = "s" ]); then
    hexo server --config source/_data/next.yml
    exit 0
fi

# Error
echo "Error! Usage: sh run.sh [compress|deploy <commit_message>|help|server]"
exit 1
