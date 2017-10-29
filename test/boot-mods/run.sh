#!/usr/bin/env bash

clean() {
	rm -f $aux $aux2 $modoverrides1 $modoverrides2 $modoverrides3
	if [ -n "`docker ps -qf id=$container_id`" ]; then
		docker rm -fv $container_id > /dev/null
	fi
}
trap clean EXIT

aux=`mktemp`
aux2=`mktemp`
modoverrides1=`mktemp`
modoverrides2=`mktemp`
modoverrides3=`mktemp`

cat <<- EOF > $modoverrides1
return {
  ["workshop-foo"] = { enabled = true },
}
EOF
cat <<- EOF > $modoverrides2
return {
  ["workshop-foo"] = { enabled = true },
  ["workshop-bar"] = { enabled = true },
}
EOF
echo "xyz" > $modoverrides3

container_id=`docker run -d -e MODS="foo" $1 dst-server start --update=none || exit 1`
sleep 2
docker cp $container_id:/var/lib/dsta/cluster/shard/modoverrides.lua $aux || exit 1
diff $modoverrides1 $aux || exit 1
docker rm -fv $container_id > /dev/null

container_id=`docker run -d -e MODS="foo,bar" $1 dst-server start --update=none || exit 1`
sleep 2
docker cp $container_id:/var/lib/dsta/cluster/shard/modoverrides.lua $aux || exit 1
diff $modoverrides2 $aux || exit 1
docker rm -fv $container_id > /dev/null

container_id=`docker run -d -e MODS="foo,bar" -e MODS_OVERRIDES="xyz" $1 dst-server start --update=none || exit 1`
sleep 2
docker cp $container_id:/var/lib/dsta/cluster/shard/modoverrides.lua $aux || exit 1
diff $modoverrides3 $aux || exit 1
docker rm -fv $container_id > /dev/null

container_id=`docker run -d $1 -e MODS_OVERRIDES="xyz" dst-server start --update=none || exit 1`
sleep 2
docker cp $container_id:/var/lib/dsta/cluster/shard/modoverrides.lua $aux 2> /dev/null && exit 1
docker rm -fv $container_id > /dev/null

container_id=`docker run -d $1 dst-server start --update=none || exit 1`
sleep 2
docker cp $container_id:/var/lib/dsta/cluster/shard/modoverrides.lua $aux 2> /dev/null && exit 1
docker rm -fv $container_id > /dev/null
