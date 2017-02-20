#! /bin/bash
#

function do_it() {
  docker build \
    --tag datihein/flask-helloworld:latest \
    --tag datihein/flask-helloworld:1.0.0 .
}

do_it
rc_=$?

exit $rc_
