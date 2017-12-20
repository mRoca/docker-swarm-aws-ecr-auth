#!/usr/bin/env sh

_catch() {
    echo "Killing process..."
    [ -z $(jobs -p) ] || kill $(jobs -p)
    exit #$
}

trap _catch INT TERM

if [ ! -e /var/run/docker.sock ]; then
    echo "You must mount the host docker socket as a volume to /var/run/docker.sock"
    exit 1
fi;

if ! docker top shell-aws &>/dev/null; then
    echo "The shell-aws container is not running. Are you on an aws swarm stack manager ?"
    return 2
fi

if ! docker top guide-aws &>/dev/null; then
    echo "The guide-aws container is not running. Are you on an aws swarm stack manager ?"
    return 2
fi

if [ -z "$AWS_REGION" ]; then
    AWS_REGION=$(docker exec guide-aws curl -m5 -sS http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//')
fi

while true; do
    logincmd=$(docker exec guide-aws sh -c "AWS_DEFAULT_REGION=$AWS_REGION aws ecr get-login --no-include-email")
    docker exec shell-aws sh -c "$logincmd"

    services=$(docker service ls --format "{{.Name}} {{.Image}}" | grep "dkr.ecr" | awk '{print $1;}')
    for service in ${services}; do
        docker exec shell-aws docker service update --with-registry-auth --detach=true "$service"
    done;

    sleep 4h &
    wait
done;
