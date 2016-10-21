#!/bin/bash
#set -x

if [ $# -lt 1 ]
then
  echo "Error: Need at least one parameter"
  echo "usage: ./devprompt.sh container-name [/path/to/ggrep]"
  exit 1
fi

DOCKER_IMAGE=$1
PATH_TO_LOAD=$2

function get_container_id() {
  docker ps -a | grep $DOCKER_IMAGE | awk '{ print $1 }'
}

# Look for a running container
if [[ $(docker ps | awk '{ print $2 }' | grep $DOCKER_IMAGE) ]]; then
  # Attach to container
  echo "Creating new shell in currently running $(get_container_id)..."
  docker exec -i -t $(get_container_id) /bin/bash
else
  # Look for a stopped container
  if [[ $(docker ps -a | awk '{ print $2 }' | grep $DOCKER_IMAGE) ]]; then
    # Start it and attach to it
    echo "Starting and attaching to existing $(get_container_id)..."
    docker start $(get_container_id)
    docker attach $(get_container_id)
  else
    # Look for an image
    if [[ $(docker images | grep $DOCKER_IMAGE) ]]; then
      # Check the numner of parameters
      if [ $# -ne 2 ]
      then
        echo "Error: This container does not exists. Need two parameters to create a container"
        echo "usage: ./devprompt.sh container-name /path/to/ggrep"
        exit 1
      fi
      # Start an container from it
      echo "Creating container from $DOCKER_IMAGE..."
      docker run -it -v $PATH_TO_LOAD:/home/jedi/ggrep $DOCKER_IMAGE bash
    else
      echo "Error: No docker image called $DOCKER_IMAGE"
      echo "Create a docker image using the Dockerfile and launch this devprompt"
      echo "usage: docker build -t $DOCKER_IMAGE . && ./devprompt.sh $DOCKER_IMAGE $PATH_TO_LOAD"
      exit 1
    fi
  fi
fi
