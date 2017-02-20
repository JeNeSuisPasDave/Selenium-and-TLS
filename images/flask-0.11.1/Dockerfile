FROM datihein/python-3.5.2:1.0.1

MAINTAINER  Dave Hein <jenesuispasdave@gmail.com>

# To void the cache beyond the base image, change REFRESHED_AT to current time
#
ENV BASE_REFRESHED_AT 2017-02-05T15:28:02-0600

ENV INSTALL_FLASK_AT 2017-02-08T21:29:07-0600
COPY requirements.txt /tmp/delme/
RUN pip install -r /tmp/delme/requirements.txt \
  && rm -r /tmp/delme

ENV LABEL_IMAGE_AT 2017-02-05T21:18:23-0600
LABEL net.develves.flask="0.11.1"
