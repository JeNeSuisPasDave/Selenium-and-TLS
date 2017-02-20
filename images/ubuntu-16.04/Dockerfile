# Base images can be found here: https://hub.docker.com/_/ubuntu/
# Ubuntu 16.04 LTS (Xenial Xerus)
#
FROM ubuntu:16.04

MAINTAINER  Dave Hein <jenesuispasdave@gmail.com>

# To void the cache beyond the base image, change REFRESHED_AT to current time
#
ENV BASE_REFRESHED_AT 2017-02-05T15:09:17-0600

# Setting this environment variable prevents errors during package installs
# that look like:
#
# debconf: unable to initialize frontend: Dialog
# debconf: (TERM is not set, so the dialog frontend is not usable.)
# debconf: falling back to frontend: Readline
#
# As per: http://stackoverflow.com/a/35976127/1392864
#
ARG DEBIAN_FRONTEND=noninteractive

# Update apt package info and upgrade installed packages (base image
# has some packages installed)
#
RUN apt-get update && apt-get -y upgrade

ENV LABEL_DISTRO_AT 2017-02-05T21:18:10-0600
LABEL net.develves.distro="ubuntu" \
    net.develves.distro-version="ubuntu 16.04"
