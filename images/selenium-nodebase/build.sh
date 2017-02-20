#! /bin/bash
#

function do_it() {
  docker build \
    --tag datihein/selenium-nodebase-3.0.1-ferrium:latest \
    --tag datihein/selenium-nodebase-3.0.1-ferrium:1.0.0 \
    .
}

do_it
rc_=$?

exit $rc_
