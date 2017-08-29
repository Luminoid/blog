---
title: Building Hexo Website with Docker
date: 2017-08-22 00:10:13
categories: Docker
tags:
- Hexo
- Docker
keywords:
- Hexo
- Docker
---

<!-- TOC -->

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

RUN apt-get -yqq update
RUN apt-get -yqq install git-core curl
# Install Node.js Using a PPA
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get -yqq install nodejs
RUN apt-get -yqq install build-essential
# Set config to avoid permission issues
RUN npm config set user 0
RUN npm config set unsafe-perm true
RUN npm install -g hexo-cli

VOLUME [ "/data/", "/var/www/html" ]
WORKDIR /data

ENTRYPOINT [ "hexo", "generate" ]
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

RUN apt-get -yqq update
RUN apt-get -yqq install apache2

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
$ cd ~/Documents
$ git clone https://github.com/Luminoid/blog.git
$ docker run -v ~/Documents/blog:/data/ --name luminoid_blog luminoid/hexo
```

### Creating an Apache container
``` sh
$ docker run -d -P --volumes-from luminoid_blog luminoid/apache
```

### Resolving the Apache container’s port
``` sh
$ docker port APACHE_CONTAINER_ID 80
0.0.0.0:32768
```

### Hexo website
The Website can be viewed at `localhost:32768`
