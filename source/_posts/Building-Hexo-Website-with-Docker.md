---
title: Building Hexo Website with Docker
date: 2017-08-22 00:10:13
categories: Docker
tags:
- Docker
- Hexo
- Apache
- Ubuntu
keywords:
- Docker
- Hexo
- Apache
- Ubuntu
---

<!-- TOC -->
This is a portable and generic way to build Hexo Website with Docker.
## The Hexo base image
### Creating Hexo Dockerfile
``` sh
$ mkdir hexo
$ cd hexo
$ vim Dockerfile
```

### Hexo Dockerfile Content
``` sh
FROM ubuntu:14.04
MAINTAINER luminoid
ENV REFRESHED_AT 2017-08-28

# Install Hexo
RUN apt-get update -yqq \
  && apt-get install -yqq curl git-core \
  # Install Node.js Using a PPA
  && curl -sL https://deb.nodesource.com/setup_7.x | bash - \
  && apt-get install -yqq nodejs build-essential \
  # Set config to avoid permission issues
  && npm config set user 0 \
  && npm config set unsafe-perm true \
  && npm install -g hexo-cli

# Clone blog
WORKDIR /data
RUN git clone https://github.com/Luminoid/blog.git

# Install blog dependencies
WORKDIR /data/blog
RUN npm install \
  && npm install prompt --save \
  && npm install jquery --save

RUN mkdir -p /var/www/html/ \
  && cp -r /data/blog/docs/* /var/www/html/
VOLUME [ "/data/blog", "/var/www/html" ]
```
<!-- more -->

### Building Hexo base image
``` sh
$ docker build -t luminoid/hexo .
```

## The Apache image
### Creating Apache Dockerfile
``` sh
$ mkdir apache
$ cd apache
$ vim Dockerfile
```

### Apache Dockerfile Content
``` sh
FROM ubuntu:14.04
MAINTAINER luminoid
ENV REFRESHED_AT 2017-08-28

RUN apt-get update -yqq \
  && apt-get install -yqq apache2

VOLUME [ "/var/www/html" ]
WORKDIR /var/www/html

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2

RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR

EXPOSE 80

ENTRYPOINT [ "/usr/sbin/apache2" ]
CMD ["-D", "FOREGROUND"]
```

### Building Apache image
``` sh
$ docker build -t luminoid/apache .
$ docker images # list images
```

## Launching hexo site
### Creating a Hexo container
``` sh
$ docker run --name luminoid_blog luminoid/hexo
```

### Creating an Apache container
``` sh
$ docker run -d -P --name blog_server --volumes-from luminoid_blog luminoid/apache
APACHE_CONTAINER_ID
```

### Resolving the Apache container’s port
``` sh
$ docker port APACHE_CONTAINER_ID 80
0.0.0.0:32768
```

### Hexo website
The Website can be viewed at `http://localhost:32768`

### Updating Hexo website
Restart the Hexo container and the website will be updated.
``` sh
docker start luminoid_blog
```
### Backing up the Hexo volume
``` sh
docker run --rm --volumes-from luminoid_blog -v $(pwd):/backup ubuntu tar cvf /backup/luminoid_blog_backup.tar /var/www/html
```
