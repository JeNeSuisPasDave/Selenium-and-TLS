#! /bin/bash
#

function do_it() {
  docker build \
    --tag datihein/flask-0.11.1:latest \
    --tag datihein/flask-0.11.1:1.0.0 .
}

do_it
rc_=$?

exit $rc_
