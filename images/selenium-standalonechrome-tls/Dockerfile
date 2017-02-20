FROM datihein/selenium-nodechrome-3.0.1-ferrium:1.0.0
MAINTAINER Dave Hein <jenesuispasdave@gmail.com>

# Borrowed from: https://github.com/SeleniumHQ/docker-selenium/blob/3.0.1-fermium/StandaloneChrome/Dockerfile

# To void the cache beyond the base image, change REFRESHED_AT to current time
#
ENV BASE_REFRESHED_AT 2017-02-05T21:34:29-0600

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

USER root

# Update CA certificates
#
COPY delme/CA-certs /tmp/delme/CA-certs/
RUN mkdir -p /usr/share/ca-certificates/extra \
    && cp /tmp/delme/CA-certs/*.crt /usr/share/ca-certificates/extra \
    && update-ca-certificates
RUN rm -r /tmp/delme

#====================================
# Scripts to run Selenium Standalone
#====================================
COPY entry_point.sh /opt/bin/entry_point.sh
RUN chmod +x /opt/bin/entry_point.sh

USER seluser

EXPOSE 4444
