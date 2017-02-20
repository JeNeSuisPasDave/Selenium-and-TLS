#! /bin/bash
#

function do_it() {
  docker build \
    --tag datihein/ubuntu-16.04:latest \
    --tag datihein/ubuntu-16.04:1.0.0 .
}

do_it
rc_=$?

exit $rc_
