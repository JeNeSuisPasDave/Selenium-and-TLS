#! /bin/bash
#

# Copyright 2017 David Hein
#
# Licensed under the MIT License. If the LICENSE file is missing, you
# can find the MIT license terms here: https://opensource.org/licenses/MIT

# Arguments:
#
#    $1: The image name suffix. Required. (e.g. 'rootCAs'.)
#    $2: A root CA certificate path. Required
#    $3: File name (sans suffix) for the root CA cert on the data
#        volume. Required
#    $4...: Pairs of root CA cert file paths and file names (patterned after
#           $2 and $3), as many as desired. Optional.
#

# capture the script context
#
# Script name ...
#
SCRIPTNAME_="$0"

# ... get the directory holding this script
# (method from: http://stackoverflow.com/a/12694189/1392864)
#
SCRIPTDIR_="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPTDIR_" ]]; then
  SCRIPTDIR_="$PWD"
fi

# Load the bash functions that support data volume synchronization via rsync
#
. "${SCRIPTDIR_}/dv-sync.src"

# main
#
IGNORE_TIMES_DURING_RSYNC_=1
IN_CAS_=()
OUT_NAMES_=()
ARGS_=( "$@" )
LIMIT_=${#ARGS_[@]}
for ((i=1; i < LIMIT_ ; i=i+2))
do
  j=i+1
  if (( j >= LIMIT_ )); then
    echo "ERROR: CA file path unpaired with new file name"
    exit 2
  fi
  CA_PATH_="${ARGS_[$i]}"
  CA_NAME_="${ARGS_[$j]}"
  if [ ! -f "${CA_PATH_}" ]; then
    echo "ERROR: root CA file not found: ${CA_PATH_}"
    exit 2
  fi
  IN_CAS_=( "${IN_CAS_[@]}" "${CA_PATH_}" )
  OUT_NAMES_=( "${OUT_NAMES_[@]}" "${CA_NAME_}" )
done
if (( 0 == ${#IN_CAS_[@]} )); then
  echo "ERROR: expected at least one root CA file"
  exit 2
fi
DV_SUFFIX_="$1"

# initialization
#
CERT_DV_NAME_="dv-cert-${DV_SUFFIX_}"
RSYNC_IMAGE_NAME_="datihein/rsync-alpine"
HOST_WK_DIR_="/delme"
DKR_MACHINE_="dev-dkr"
IP_=$( docker-machine ip ${DKR_MACHINE_} )

# Create the Docker VM working directory if necessary
#
docker_host_workdir_exists "${DKR_MACHINE_}" "${HOST_WK_DIR_}/rootCAs"
rc_=$?
if (( 0 != $rc_ )); then
  if (( 2 == $rc_ )); then
    exit 2
  fi
  docker_host_create_workdir "${DKR_MACHINE_}" "${HOST_WK_DIR_}/rootCAs"
fi

# Create the data volume container, if necessary
#
data_volume_exists "${CERT_DV_NAME_}"
rc_=$?
if (( 0 != $rc_ )); then
  if (( 2 == $rc_ )); then
    exit 2
  fi
  create_data_volume_container "${RSYNC_IMAGE_NAME_}" "${CERT_DV_NAME_}" "/mnt/rootCAs"
fi

# Update the host working directory
#
TD_=$(mktemp -d "${TMPDIR}$(basename 0).XXXXXXXXXXXX")
trap "rm -rf $TD_" EXIT
RCAS_="${TD_}/mnt/rootCAs"
mkdir -p "${RCAS_}"
for ((i=0; i < ${#IN_CAS_[@]}; ++i))
do
  CA_PATH_="${IN_CAS_[$i]}"
  CA_NAME_="${OUT_NAMES_[$i]}"
  openssl x509 -outform pem -in "${CA_PATH_}" -out "${RCAS_}/${CA_NAME_}.crt"
done
rsync_src_to_workdir "${DKR_MACHINE_}" "${IP_}" \
  "${RCAS_}" "${HOST_WK_DIR_}/mnt" \
  "${IGNORE_TIMES_DURING_RSYNC_}"

# Update the data volume container
#
rsync_workdir_to_dv "${CERT_DV_NAME_}" "${HOST_WK_DIR_}" \
  "${RSYNC_IMAGE_NAME_}" "${HOST_WK_DIR_}/mnt" "/" \
  "${IGNORE_TIMES_DURING_RSYNC_}"

# Remove the host working directory
#
docker_host_remove_workdir "${DKR_MACHINE_}" "${HOST_WK_DIR_}/mnt"
