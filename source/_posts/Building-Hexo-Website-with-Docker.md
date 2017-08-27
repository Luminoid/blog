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

## The hexo base image
### Create hexo Dockerfile
``` sh
$ mkdir hexo
$ cd hexo
$ vim Dockerfile
```

### hexo Dockerfile Content
``` sh
FROM ubuntu:14.04
MAINTAINER luminoid
ENV REFRESHED_AT 2017-08-22

RUN apt -yqq update
RUN apt -yqq install git-core curl
# Install Node.js Using a PPA
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt -yqq install nodejs
RUN apt -yqq install build-essential
RUN npm install -g hexo-cli

VOLUME /data
VOLUME /var/www/html
WORKDIR /data
```
<!-- more -->

### Building hexo base image
``` sh
docker build -t luminoid/hexo .
```

## The Apache image
### Create Apache Dockerfile
``` sh
$ mkdir apache
$ cd apache
$ vim Dockerfile
```

### Apache Dockerfile Content
``` sh
FROM ubuntu:14.04
MAINTAINER luminoid
ENV REFRESHED_AT 2017-08-22
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
RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR EXPOSE 80
ENTRYPOINT [ "/usr/sbin/apache2" ]
CMD ["-D", "FOREGROUND"]
```

### Building Apache image
``` sh
docker build -t luminoid/apache .
```

## Launching hexo site
### Creating a hexo container


