#! /bin/bash
#

# Copyright 2017 David Hein
#
# Licensed under the MIT License. If the LICENSE file is missing, you
# can find the MIT license terms here: https://opensource.org/licenses/MIT

# Update the 'dv-helloworldtls-src' with the latest application source code
#

# Specify the container name and mount point
#
DV_SRC_="dv-helloworldtls-src"
MNT_SRC_="/mnt/app/src"

# Locate the container data volume creation script
#
UTIL_DIR_=$( dirname "${PWD}" )
UTIL_DIR_="${UTIL_DIR_}/util"
if [ ! -f "${UTIL_DIR_}/create-dv-container.sh" ]; then
  MSG_="ERROR: could not locate 'create-dv-container.sh'"
  MSG_="${MSG_} in '${UTIL_DIR_}'."
  echo "${MSG_}"
  exit 2
fi

# Create or update the container data volume
#
"${UTIL_DIR_}/create-dv-container.sh" \
  "${DV_SRC_}" "${PWD}/src" "${MNT_SRC_}"
if (( 0 != $? )); then
  echo "ERROR: could not create or update the container data volume."
  exit 2
fi
