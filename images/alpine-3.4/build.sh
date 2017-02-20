#! /bin/bash
#

function do_it() {
  docker build \
    --tag datihein/alpine-3.4:latest \
    --tag datihein/alpine-3.4:1.0.0 .
}

do_it
rc_=$?

exit $rc_
