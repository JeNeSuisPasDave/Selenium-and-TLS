FROM datihein/selenium-base-3.0.1-ferrium:1.0.0
MAINTAINER Dave Hein <jenesuispasdave@gmail.com>

# Borrowed from: https://github.com/SeleniumHQ/docker-selenium/blob/3.0.1-fermium/NodeBase/Dockerfile

# To void the cache beyond the base image, change REFRESHED_AT to current time
#
ENV BASE_REFRESHED_AT 2017-02-05T21:27:21-0600

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

# --- the borrowed script ----

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

#==============
# VNC and Xvfb
#==============
RUN apt-get update -qqy \
  && apt-get -qqy install \
    xvfb \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#==============================
# Scripts to run Selenium Node
#==============================
COPY \
  entry_point.sh \
  functions.sh \
    /opt/bin/
RUN chmod +x /opt/bin/entry_point.sh

#============================
# Some configuration options
#============================
ENV SCREEN_WIDTH 1360
ENV SCREEN_HEIGHT 1020
ENV SCREEN_DEPTH 24
ENV DISPLAY :99.0

USER seluser

CMD ["/opt/bin/entry_point.sh"]
