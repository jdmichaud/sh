#!/bin/bash
#set -x

VOLUMEOPTIONSET=0
# By default no options, empty string will be concatenated to the command
X11OPTIONS=""
# Declare an array
declare -a VOLUMES_PARAM

# For the options, re-build the -v options
function generate_volume_options() {
  for VOLUME in "${VOLUMES_PARAM[@]}"
  do
    VOLUMEOPTIONS+=" -v $VOLUME"
  done
  echo $VOLUMEOPTIONS
}

while getopts "Xv:" option; do
  case $option in
    X)
      # The following options:
      # --net=host
      # -e DISPLAY
      # -v /home/jedi/.Xauthority:/home/jedi/.Xauthority
      # are necessary to run X11 applications
      X11OPTIONS="--net=host -e DISPLAY -v /home/jedi/.Xauthority:/home/jedi/.Xauthority"
      ;;
    v)
      VOLUMEOPTIONSET=1
      VOLUMES_PARAM+=($OPTARG)
      ;;
    \?)
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Get rid of the option and keep $1 as the image name
shift $((OPTIND - 1))

if [ $# -lt 1 ]
then
  echo "Error: You must provide the image name"
  echo "usage:  ./devprompt.sh image-name"
  echo "usage: to enable X11"
  echo "usage:  ./devprompt.sh -X image-name"
  echo "usage: to add volumes"
  echo "usage:  ./devprompt.sh -v /opt -v /home/jedi/test:/test image-name"
  exit 1
else
  DOCKER_IMAGE=$1
fi

function get_container_id() {
  docker ps -a | grep $DOCKER_IMAGE | awk '{ print $1 }'
}

# Look for a running container
if [[ $(docker ps | awk '{ print $2 }' | grep $DOCKER_IMAGE) ]]; then
  # Attach to container
  echo "Creating new shell in currently running $(get_container_id)..."
  docker exec -i -t $(get_container_id) bash --login
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
      if [ $VOLUMEOPTIONSET -eq 0 ]
      then
        echo "Error: This container does not exists. Need to provide volume parameters"
        echo "usage: ./devprompt.sh -v /path/to/ggrep:/path/to/ggrep image-name"
        exit 1
      fi
      # Start an container from it
      echo "Creating container from $DOCKER_IMAGE..."
      echo "docker run -it $X11OPTIONS $(generate_volume_options) $DOCKER_IMAGE bash --login"
      docker run -it $X11OPTIONS $(generate_volume_options) $DOCKER_IMAGE bash --login
    else
      echo "Error: No docker image called $DOCKER_IMAGE"
      echo "Create a docker image using the Dockerfile and launch this devprompt"
      echo "usage: docker build -t $DOCKER_IMAGE . && ./devprompt.sh $DOCKER_IMAGE $PATH_TO_LOAD"
      exit 1
    fi
  fi
fi
