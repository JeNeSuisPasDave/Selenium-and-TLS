#! /bin/sh
#

# Copyright 2017 David Hein
#
# Licensed under the MIT License. If the LICENSE file is missing, you
# can find the MIT license terms here: https://opensource.org/licenses/MIT

DV_SRC_="dv-helloworldtls-src"
SRC_DIR_="/mnt/app/src"
WEBAPP_CONTAINER_NAME_="experiment-helloworld-https-ipv4"
WEBAPP_IMAGE_NAME_="datihein/flask-helloworld:1.0.0"
DV_CERT_="dv-cert-tester-experiment-dev"

docker rm "${WEBAPP_CONTAINER_NAME_}"
docker run -d  \
  --name "${WEBAPP_CONTAINER_NAME_}" \
  --volumes-from "${DV_SRC_}" \
  --volumes-from "${DV_CERT_}" \
  --workdir "${SRC_DIR_}" \
  --expose=443 \
  -p 443:443 \
  "${WEBAPP_IMAGE_NAME_}" \
  "${SRC_DIR_}/doit.sh"
