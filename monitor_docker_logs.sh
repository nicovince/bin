#!/usr/bin/env bash

SCRIPTNAME="$(basename "$0")"
usage()
{
    echo -e "${SCRIPTNAME} - Monitor docker logs of a container"
    echo -e ""
    echo -e "Show logs of container, if container is not up, wait for it to start until timeout expires."
    echo -e ""
    echo "Usage: ${SCRIPTNAME} <container_id>"
}

PARAMS=""
while [ $# -gt 0 ]; do
    case $1 in
        -h|--help)
            usage
            exit
            ;;
        *)
            PARAMS="${PARAMS} ${1}"
            ;;
    esac
    shift
done
eval set -- "${PARAMS}"
CONTAINER_ID="$1"

is_container_running()
{
    container_id="$1"
    docker ps -q --no-trunc | grep -q "$container_id"
    return $?
}

inspect_logs()
{
    container_id="$1"
    docker logs --follow --timestamps "$container_id"
}

current_epoch()
{
    date +%s
}

container_down_epoch=$(current_epoch)
# Retry every 5 seconds until the container is running
# If the container is not up after 30 seconds, exits with an error
while [ true ]; do
    now=$(current_epoch)
    # if difference between now and container_down_epoch is greater than 30 seconds
    if [ $((now - container_down_epoch)) -gt 30 ]; then
        echo "Container did not start in 30 seconds. Exiting..."
        exit 1
    fi
    if is_container_running "$CONTAINER_ID"; then
        inspect_logs "$CONTAINER_ID"
        container_down_epoch=$(current_epoch)
        echo "Waiting for container to start..."
    fi
    sleep 5
done
