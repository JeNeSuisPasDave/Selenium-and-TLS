#! /bin/bash
#

# Copyright 2017 David Hein
#
# Licensed under the MIT License. If the LICENSE file is missing, you
# can find the MIT license terms here: https://opensource.org/licenses/MIT

docker-compose --file docker-compose-tests.yaml up --no-build --timeout 2 -d
docker logs --follow helloworld_tester_1
docker-compose --file docker-compose-tests.yaml down
