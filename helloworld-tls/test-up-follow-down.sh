#! /bin/bash
#
docker-compose --file docker-compose-tests.yaml up --no-build --timeout 2 -d
docker logs --follow helloworldtls_tester_1
docker-compose --file docker-compose-tests.yaml down
