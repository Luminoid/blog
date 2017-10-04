---
title: Docker Cheat Sheet
date: 2017-10-04 11:49:21
updated:
categories: Service
tags: Docker
keywords:
- Docker
- Cheatsheet
---

## Containers
``` bash
docker build -t="luminoid/my_image" .                   # Build an image from current directory's Dockerfile
docker run username/repository:tag                                            # Run an image from a registry
docker run -p 12345:80 <image_name>                                  # Run an image mapping port 12345 to 80
docker run --name <container_name> -i -t ubuntu /bin/bash                 # Run a command in a new container
docker run --name <container_name> -v "$(pwd)":/data -i -t ubuntu /bin/bash  # Run a container with a volume
docker start -i <container_name>                                    # Start stopped containers interactively
docker stop <container_name>                                                       # Stop running containers
docker ps -a                                            # Show all containers (include the ones not running)
docker rm <container_name>                                                      # Remove specified container
docker rm $(docker ps -a -q)                                                         # Remove all containers
docker images -a                                                                           # Show all images
docker rmi <hash>                                                                   # Remove specified image
docker rmi $(docker images -q)                                                           # Remove all images
```
