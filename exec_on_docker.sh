#!/bin/bash
# Execute a command inside a docker container once a container with the matching Image Name is up

# Wait until docker ps show a container with the matching Image
# return the container ID
wait_container_image()
{
    local image="$1"
    while true; do
        container_id=$(docker ps --filter "ancestor=$image" --format "{{.ID}}")
        if [ -n "$container_id" ]; then
            echo "$container_id"
            return 0
        fi
        sleep 1
    done
}

execute_command_in_container()
{
    local container_id="$1"
    shift
    local command="$@"
    docker exec -it "$container_id" $command
}

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <image_name> <command>"
    exit 1
fi
image_name="$1"
shift
command="$@"
container_id=$(wait_container_image "$image_name")
execute_command_in_container "$container_id" "$command"
