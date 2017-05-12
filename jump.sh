#!/bin/bash
# This script shall be run with source (or .) otherwise the folder change
# will have not effect ot your sshell
# http://ascii-table.com/ansi-escape-sequences.php

DB_NAME='/tmp/jump.db'

function usage() {
  echo "usage: . jump.sh"
  echo "Display the list of bookmark for selection"
  echo "Use j/k to select, enter to change path, any other key to exit"
  echo "To save the current working directory in the bookmark:"
  echo " . jump.sh save"
}

function init() {
  # Hide the cursor
  printf "\033[?25l"

  # Show cursor on exit
  trap 'printf "\033[?25h"' EXIT INT QUIT TERM
}

function display_menu() {
  local selected
  local index
  selected=$1

  index=0
  # Loop through the db
  for line in `cat ${DB_NAME}`
  do
    # If on selected item, turn on reverse video
    if [[ $index -eq $selected ]]
    then
      printf "\033[7m"
    fi
    # Print the current line
    echo $line
    # If on selected item, turn off reverse video
    if [[ $index -eq $selected ]]
    then
      printf "\033[0m"
    fi
    let "index += 1"
  done
  # Restore cursor position
  printf "\r"
  printf "\033[${maxindex}A"
}

function select_bookmark() {
  local maxindex
  local selected
  maxindex=`wc -l ${DB_NAME} | awk '{ print $1 }'`
  selected=0

  init

  while true
  do
    display_menu $selected
    # Read input from user
    read -s -n 1 input
    # Read the three following characters with timeout, to catch arrows and
    # some other special keys
    read -sN1 -t 0.0001 k1
    read -sN1 -t 0.0001 k2
    read -sN1 -t 0.0001 k3
    input+=${k1}${k2}${k3}

    case $input in
      'j'|$'\e[A'|$'\e0A')
        if [[ $selected -gt 0 ]]
        then
          let "selected -= 1"
        fi
        ;;
      'k'|$'\e[B'|$'\e0B')
        if [[ $selected -lt $((maxindex-1)) ]]
        then
          let "selected += 1"
        fi
        ;;
      '')
        folder=`head -n $((selected+1)) ${DB_NAME} | tail -n 1`
        cd $folder
        # The following is a fallback to *) It does not break the case.
        ;&
      *)
        # Clear lines
        for i in $(seq 1 $maxindex)
        do
          printf "\r"
          printf "\033[K\n"
        done
        # go back to the initial position
        printf "\r"
        printf "\033[${maxindex}A"
        # Show cursor
        printf "\033[?25h"
        return 0
        ;;
    esac
  done
}

function save() {
  echo ${PWD} | cat >> ${DB_NAME}
}

################################################################################
# main
################################################################################

if [[ $1 == "save" ]]
then
  save
  return 0
elif [[ $# != 0 ]]
then
  usage
  return 1
fi

select_bookmark
