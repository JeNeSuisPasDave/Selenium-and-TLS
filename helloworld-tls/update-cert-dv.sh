#! /bin/bash
#

# Copyright 2017 David Hein
#
# Licensed under the MIT License. If the LICENSE file is missing, you
# can find the MIT license terms here: https://opensource.org/licenses/MIT

# Locate the container data volume update script
#
UTIL_DIR_=$( dirname "${PWD}" )
UTIL_DIR_="${UTIL_DIR_}/util"
if [ ! -f "${UTIL_DIR_}/update-cert-dv.sh" ]; then
  MSG_="ERROR: could not locate 'update-cert-dv.sh'"
  MSG_="${MSG_} in '${UTIL_DIR_}'."
  echo "${MSG_}"
  exit 2
fi

# Establish the data volume container for the server certificate
#
"${UTIL_DIR_}/update-cert-dv.sh" \
  "tester-experiment-dev" \
  "/mnt/experiment" \
  "../certs/root_ca_2017/rootCAcert.pem" \
  "../certs/certs/tester.experiment.dev/private/certkey.pem" \
  "../certs/certs/tester.experiment.dev/cert.pem"
