FROM datihein/flask-helloworld:1.0.0

MAINTAINER  Dave Hein <jenesuispasdave@gmail.com>

# To void the cache beyond the base image, change REFRESHED_AT to current time
#
ENV BASE_REFRESHED_AT 2017-02-12T14:27:51-0600

ENV INSTALL_FLASK_AT 2017-02-12T14:27:55-0600
COPY requirements.txt /tmp/delme/
RUN pip install -r /tmp/delme/requirements.txt \
  && rm -r /tmp/delme

ENV LABEL_IMAGE_AT 2017-02-12T14:28:00-0600
LABEL net.develves.test="true"
