#!/bin/bash
if  [ "$#" -ne 2 ]; then
	echo "usage : $0 {registry-data dir path} {registry endpoint}"
	echo "example : $0 /root/registry-data 10.4.0.30:5000"
	exit 0
fi

home_dir=$1
registry_port=$(echo $2 | cut -d':' -f2)

docker load -i docker-registry.tar

#start install registry
docker run -it -d -p$registry_port:5000 registry
