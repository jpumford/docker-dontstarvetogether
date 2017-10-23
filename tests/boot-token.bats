#!/usr/bin/env bash

# test the proper persistence of the token
@test "token is stored" {
	# create container
	container=$(docker run -d -e TOKEN="token" dstacademy/dontstarvetogether:local)
	sleep 1

	# test stored token
	[[ $(docker exec "${container}" cat /var/lib/dsta/cluster/cluster_token.txt) = "token" ]]

	# destroy container
	docker rm -f "${container}"
}

# test the existence of the token after a container restart
@test "token gets persisted between runs" {
	# create container
	container=$(docker run -d -e TOKEN="token" dstacademy/dontstarvetogether:local)
	sleep 1

	# get token
	token=$(docker exec "${container}" cat /var/lib/dsta/cluster/cluster_token.txt)

	# restart container
	docker restart "${container}"

	# test stored token
	[[ $(docker exec "${container}" cat /var/lib/dsta/cluster/cluster_token.txt) = "${token}" ]]

	# destroy container
	docker rm -f "${container}"
}
