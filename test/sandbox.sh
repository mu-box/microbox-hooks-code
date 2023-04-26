#!/bin/bash
#
# Launch a container and console into it

test_dir="$(dirname $(readlink -f $BASH_SOURCE))"
payload_dir="$(readlink -f ${test_dir}/payloads)"
util_dir="$(readlink -f ${test_dir}/util)"
hookit_dir="$(readlink -f ${test_dir}/../src)"

# source the mist helpers
. ${util_dir}/mist.sh

# source the logvac helpers
. ${util_dir}/logvac.sh

# source the warehouse helpers
. ${util_dir}/warehouse.sh

# source the unfs helpers
. ${util_dir}/unfs.sh

# spawn a mist
echo "Launching a mist container..."
start_mist

# spawn a logvac
echo "Launching a logvac container..."
start_logvac

# spawn a warehouse
echo "Launching a warehouse container..."
start_warehouse

# spawn a unfs component
echo "Launching a unfs container..."
start_unfs

# start a container for a sandbox
echo "Launching a sandbox container..."
docker run \
  --name=sandbox \
  -d \
  --privileged \
  --net=microbox \
  --ip=192.168.0.55 \
  --volume=${hookit_dir}/:/opt/microbox/hooks \
  --volume=${payload_dir}/:/payloads \
  mubox/code:v1

# hop into the sandbox
echo "Consoling into the sandbox..."
docker exec -it sandbox bash

# remove the sandbox
echo "Destroying the sandbox container..."
docker stop sandbox
docker rm sandbox

# remove the unfs
echo "Destroying the unfs containe..."
stop_unfs

# remove the warehouse
echo "Destroying the warehouse container..."
stop_warehouse

# remove the logvac
echo "Destroying the logvac container..."
stop_logvac

# remove the mist
echo "Destroying the mist container..."
stop_mist

echo "Bye."
