#!/bin/bash
# This script allows you to save and create the pane configuration of your
# current tmux window
set -x

FILE=''
READ=0
OPT=0
TMUX=tmux-next

function usage() {
  echo "This script allows you to:"
  echo "- dump the pane configuration into a file this way:"
  echo "  $1 -o pane.conf"
  echo "- create panes according to a previously dumped configuration"
  echo "  $1 -r pane.conf"
}

while getopts "o:r:" option; do
  case $option in
    o)
      OPT=1
      FILE=$OPTARG
      ;;
    r)
      OPT=1
      READ=1
      FILE=$OPTARG
      ;;
    \?)
      usage $0
      exit 1
      ;;
    :)
      echo "Error: Option -$OPTARG requires an argument." >&2
      usage $0
      exit 1
      ;;
  esac
done

if [ $OPT -ne 1 ]
then
  usage $0
  exit 1
fi

function create_panes() {
  previous_top=0
  previous_left=0
  while read -r line
  do
    arrIN=(${line// / })
    if [ $previous_top != ${arrIN[0]} ]
    then
      echo "will create vertical pane with line ${arrIN[0]}"
      $TMUX split-window -v -l ${arrIN[0]}
    elif [ $previous_left != ${arrIN[1]} ]
    then
      echo "will create horizontal pane with line ${arrIN[1]}"
      $TMUX split-window -h -l ${arrIN[1]}
    fi
    previous_top=${arrIN[0]}
    previous_left=${arrIN[1]}
  done < $1
}

if [ $READ -eq 1 ]
then
  create_panes $FILE
else
  write_panes $FILE
fi
