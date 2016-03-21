# Version: 0.0.1
FROM ubuntu:14.04
MAINTAINER cnio "it@wem.me"
RUN apt-get update
RUN apt-get install -y nginx
RUN echo "hi,Im in your container"

EXPOSE 80