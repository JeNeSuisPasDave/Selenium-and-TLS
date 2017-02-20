# Base images can be found here: https://hub.docker.com/_/alpine/
# Alpine 3.4
#
FROM alpine:3.4

MAINTAINER  Dave Hein <jenesuispasdave@gmail.com>

# To void the cache beyond the base image, change REFRESHED_AT to current time
#
ENV BASE_REFRESHED_AT 2017-02-05T15:28:02-0600

# Update apk package info and upgrade installed packages (base image
# has some packages installed)
#
RUN apk update \
    && apk upgrade

ENV LABEL_DISTRO_AT 2017-02-05T21:18:23-0600
LABEL net.develves.distro="alpine" \
    net.develves.distro-version="alpine 3.4"
