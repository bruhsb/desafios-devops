#!/usr/bin/env bash

sudo yum -y --setopt=tsflags=nodocs update && \
sudo yum -y --setopt=tsflags=nodocs install docker && \
sudo yum clean all

sudo systemctl enable docker
sudo systemctl start docker

sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --reload

sudo docker run -d -p 80:80 centos/httpd
