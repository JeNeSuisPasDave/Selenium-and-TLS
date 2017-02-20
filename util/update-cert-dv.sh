#! /bin/bash
#

# Copyright 2017 David Hein
#
# Licensed under the MIT License. If the LICENSE file is missing, you
# can find the MIT license terms here: https://opensource.org/licenses/MIT

# Arguments:
#
#    $1: The image name suffix. Required. FQDN with dashs (e.g. www-google-com).
#    $2: Parent directory path of the mount point into which the certs will
#        be copied
#    $3: The certificate private key file path. Required.
#    $4: The certificate file path. Required.

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
FQDN_SUFFIX_=""
PARENT_PATH_=""
CA_CERT_PATH_=""
CERT_KEY_PATH_=""
CERT_PATH_=""
if (( 5 == $# )); then
  FQDN_SUFFIX_="$1"
  PARENT_PATH_="$2"
  CA_CERT_PATH_="$3"
  if [[ ! -f "${CA_CERT_PATH_}" ]]; then
    echo "ERROR: '${SCRIPTNAME_}' argument 2; file does not exist"
    exit 2
  fi
  CERT_KEY_PATH_="$4"
  if [[ ! -f "${CERT_KEY_PATH_}" ]]; then
    echo "ERROR: '${SCRIPTNAME_}' argument 3; file does not exist"
    exit 2
  fi
  CERT_PATH_="$5"
  if [[ ! -f "${CERT_PATH_}" ]]; then
    echo "ERROR: '${SCRIPTNAME_}' argument 4; file does not exist"
    exit 2
  fi
else
  echo "ERROR: '${SCRIPTNAME_}' expected five arguments; got $#"
  exit 2
fi

# initialization
#
CERT_DV_NAME_="dv-cert-${FQDN_SUFFIX_}"
RSYNC_IMAGE_NAME_="datihein/rsync:1.0.0"
HOST_WK_DIR_="/delme"
DKR_MACHINE_="dev-dkr"
IP_=$( docker-machine ip ${DKR_MACHINE_} )

# Create the Docker VM working directory if necessary
#
docker_host_workdir_exists "${DKR_MACHINE_}" "${HOST_WK_DIR_}/tls"
rc_=$?
if (( 0 != $rc_ )); then
  if (( 2 == $rc_ )); then
    exit 2
  fi
  docker_host_create_workdir "${DKR_MACHINE_}" "${HOST_WK_DIR_}/tls"
fi

# Create the data volume container, if necessary
#
data_volume_exists "${CERT_DV_NAME_}"
rc_=$?
if (( 0 != $rc_ )); then
  if (( 2 == $rc_ )); then
    exit 2
  fi
  create_data_volume_container \
    "${RSYNC_IMAGE_NAME_}" "${CERT_DV_NAME_}" "${PARENT_PATH_}/tls"
fi

# Update the host working directory
#
cat "${CERT_PATH_}" "${CA_CERT_PATH_}"  > .delme-chained-cert.pem
rsync_src_to_workdir "${DKR_MACHINE_}" "${IP_}" \
  ".delme-chained-cert.pem" "${HOST_WK_DIR_}/tls/cert.pem" \
  "${IGNORE_TIMES_DURING_RSYNC_}"
rm .delme-chained-cert.pem
rsync_src_to_workdir "${DKR_MACHINE_}" "${IP_}" \
  "${CERT_KEY_PATH_}" "${HOST_WK_DIR_}/tls/certkey.pem" \
  "${IGNORE_TIMES_DURING_RSYNC_}"

# Update the data volume container
#
rsync_workdir_to_dv "${CERT_DV_NAME_}" "${HOST_WK_DIR_}" \
  "${RSYNC_IMAGE_NAME_}" "${HOST_WK_DIR_}/tls" "${PARENT_PATH_}/" \
  "${IGNORE_TIMES_DURING_RSYNC_}"

# Remove the host working directory
#
docker_host_remove_workdir "${DKR_MACHINE_}" "${HOST_WK_DIR_}/tls"
