#! /bin/sh
#

# Copyright 2017 David Hein
#
# Licensed under the MIT License. If the LICENSE file is missing, you
# can find the MIT license terms here: https://opensource.org/licenses/MIT

DV_SRC_="dv-helloworld-src"
SRC_DIR_="/mnt/app/src"
WEBAPP_CONTAINER_NAME_="experiment-helloworld-http-ipv4"
WEBAPP_IMAGE_NAME_="datihein/flask-helloworld:1.0.0"

docker rm "${WEBAPP_CONTAINER_NAME_}"
docker run -d  \
  --name "${WEBAPP_CONTAINER_NAME_}" \
  --volumes-from "${DV_SRC_}" \
  --workdir "${SRC_DIR_}" \
  --expose=80 \
  -p 80:80 \
  "${WEBAPP_IMAGE_NAME_}" \
  "${SRC_DIR_}/doit.sh"
