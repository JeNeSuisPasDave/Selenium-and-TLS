#! /bin/bash
#

# Copyright 2017 David Hein
#
# Licensed under the MIT License. If the LICENSE file is missing, you
# can find the MIT license terms here: https://opensource.org/licenses/MIT

# Arguments:
#
#    $1: The data volume container name (e.g. dv-example-src). Required.
#    $2: The local source directory (e.g. ${TMPDIR}/mnt/src). Required.
#    $3: The mount point directory (e.g. /mnt/src). Required.
#    $4: "update" to transfer only changed files and directories. If not
#        supplied then existing files and directories are overwritten or
#        removed. Optional.
#
#    NOTE: base directory (least significant directory) of source and
#          mount point must be identical.
#
# Config:
#
# These environment variables provide some configuration items. If not present
# then default values will be used:
#
#   DOCKER_MACHINE   Use "none" if running directly on the Docker host.
#                    Otherwise this is the VM hostname of the Docker host
#                    accessible vi 'docker-machine' the the client 'docker'
#                    commands. Default is "dev-dkr"
#
#   DOCKER_MACHINE_WKDIR  The directory on the Docker host into which files
#                         can be transferred from the client host. Ignored
#                         if DOCKER_MACHINE is "none". Default is "/xyzzy".
#
#   RSYNC_IMAGE_NAME  The name of a Docker container image that has `rsync`
#                     installed. Defaults to "datihein/rsync:1.0.0"
#
# Dependecies:
#
#   * requires /bin/bash (not /bin/sh or /bin/ash)
#   * requires sed
#   * requires the 'dv-sync.src' to be in the same directory as this script.
#   * Requires rsync to be installed on the local machine.
#   * Requires docker or docker-machine to be installed on the local machine.
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

# Capture and validate config
#
DKR_MACHINE_="dev-dkr"
if [ -n "${DOCKER_MACHINE}" ]; then
  DKR_MACHINE_="${DOCKER_MACHINE}"
fi
HOST_WK_DIR_="/xyzzy"
if [ -n "${DOCKER_MACHINE_WKDIR}" ]; then
  HOST_WK_DIR_="${DOCKER_MACHINE_WKDIR}"
fi
RSYNC_IMAGE_="datihein/rsync:1.0.0"
if [ -n "${RSYNC_IMAGE_NAME}" ]; then
  RSYNC_IMAGE_="${RSYNC_IMAGE_NAME}"
fi

RESULT_=""
if [ "none" != "${DKR_MACHINE_}" ]; then
  RESULT_=$( docker-machine ls --format='{{.Name}}' )
  RESULT_=$( echo "$RESULT_" | grep ^${DKR_MACHINE_}$ )
  if (( 0 != $? )); then
    echo "ERROR: '${DKR_MACHINE_}' is not an extant docker machine"
    exit 2
  fi
fi

CMD_="docker images ${RSYNC_IMAGE_}"
CMD_="${CMD_} --format='{{.Repository}}:{{.Tag}}'"
RESULT_=$( ${CMD_} )
RESULT_=$( echo "${RESULT_}" | wc -w | sed -e 's/^ *//' -e 's/ *$//' )
if (( 0 == $RESULT_ )); then
  echo "ERROR: '${RSYNC_IMAGE_}' is not an extant container image"
  exit 2
fi

# Capture and validate args
#
IGNORE_TIMES_DURING_RSYNC_=1
DV_NAME_=""
SRC_DIR_=""
MNT_DIR_=""
if (( 4 == $# )); then
  DV_NAME_="$1"
  SRC_DIR_="$2"
  MNT_DIR_="$3"
  if [ "update" != "$4" ]; then
    echo "ERROR: argument 4 must be 'update' or must not be supplied."
    exit 2
  fi
  IGNORE_TIMES_DURING_RSYNC_=0
elif (( 3 == $# )); then
  DV_NAME_="$1"
  SRC_DIR_="$2"
  MNT_DIR_="$3"
else
  echo "ERROR: '${SCRIPTNAME_}' expected three or four arguments; got $#"
  exit 2
fi
if [ ! -d "${SRC_DIR_}" ]; then
  echo "ERROR: argument 2, '${SRC_DIR_}', does not exist or is not a directory"
  exit 2
fi
SRC_BASE_=$( basename "${SRC_DIR_}" )
MNT_BASE_=$( basename "${MNT_DIR_}" )
if [[ "${SRC_BASE_}" -ne "${MNT_BASE_}" ]]; then
  MSG_="ERROR: the directories in arguments 2 and 3"
  MSG_="${MSG_} must have the same rightmost folder name"
  echo "${MSG_}"
  exit 2
fi
SRC_ROOT_=$( dirname "${SRC_DIR_}" )
MNT_ROOT_=$( dirname "${MNT_DIR_}" )

# initialization
#
IP_=""
if [ "none" != "${DKR_MACHINE_}" ]; then
  IP_=$( docker-machine ip ${DKR_MACHINE_} )
fi

# Create the Docker VM working directory if necessary
#
if [ "none" != "${HOST_WK_DIR_}" ]; then
  docker_host_workdir_exists "${DKR_MACHINE_}" "${HOST_WK_DIR_}"
  rc_=$?
  if (( 0 != $rc_ )); then
    if (( 2 == $rc_ )); then
      exit 2
    fi
    docker_host_create_workdir "${DKR_MACHINE_}" "${HOST_WK_DIR_}"
  fi
  trap \
    "docker_host_remove_workdir \"${DKR_MACHINE_}\" \"${HOST_WK_DIR_}\"" EXIT
  if [ "/" != "${MNT_ROOT_}" ]; then
    docker_host_workdir_exists "${DKR_MACHINE_}" "${HOST_WK_DIR_}${MNT_ROOT_}"
    rc_=$?
    if (( 0 != $rc_ )); then
      if (( 2 == $rc_ )); then
        exit 2
      fi
      docker_host_create_workdir "${DKR_MACHINE_}" "${HOST_WK_DIR_}${MNT_ROOT_}"
    fi
  fi
fi

# Create the data volume container, if necessary
#
data_volume_exists "${DV_NAME_}"
rc_=$?
if (( 0 != $rc_ )); then
  if (( 2 == $rc_ )); then
    exit 2
  fi
  create_data_volume_container "${RSYNC_IMAGE_}" "${DV_NAME_}" "${MNT_DIR_}"
fi

# Update the host working directory
#
if [ "none" != "${HOST_WK_DIR_}" ]; then
  rsync_src_to_workdir "${DKR_MACHINE_}" "${IP_}" \
    "${SRC_DIR_}" "${HOST_WK_DIR_}${MNT_ROOT_}" \
    "${IGNORE_TIMES_DURING_RSYNC_}"
fi

# Upate the data volume container
#
if [ "none" != "${HOST_WK_DIR_}" ]; then
  rsync_workdir_to_dv "${DV_NAME_}" "${HOST_WK_DIR_}" \
    "${RSYNC_IMAGE_}" "${HOST_WK_DIR_}${MNT_DIR_}" "${MNT_ROOT_}" \
    "${IGNORE_TIMES_DURING_RSYNC_}"
else
  rsync_workdir_to_dv "${DV_NAME_}" "${SRC_DIR_}" \
    "${RSYNC_IMAGE_}" "${SRC_DIR_}" "${MNT_ROOT_}" \
    "${IGNORE_TIMES_DURING_RSYNC_}"
fi

# Remove the host working directory
#
# NOTE: this is handled by the 'trap ... EXIT' statement above.
