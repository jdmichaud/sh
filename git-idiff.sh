#!/bin/bash
# This script display the git diff of a particular file in a git repo.
# Using > and < you can move up and down the commit list.
# Very buggy especially due to the use of a paged by git diff.

# Stop on failure
set -e

if [ "$#" -ne 1 ];
then
    echo "Illegal number of parameters"
    echo "usage: git idiff filename"
    exit
fi

IFS=$'\n'       # make newlines the only separator
FILENAME=$1

commits=($(git log --follow --oneline -- $FILENAME))
number_of_commits=${#commits[@]}

get_sha() {
  echo ${commits[$1]} | cut -c -7
}

get_comment() {
  echo ${commits[$1]} | cut -c 8-
}

display_diff() {
  current_sha=`echo ${commits[$1]} | cut -c -7`
  current_comment=`echo ${commits[$1]} | cut -c 8-`
  previous_index=`expr $1 + 1`
  previous_sha=`echo ${commits[$previous_index]} | cut -c -7`
  previous_comment=`echo ${commits[$previous_index]} | cut -c 8-`

  git diff -r $current_sha -r $previous_sha --follow -- $FILENAME
}

index=0
go_up() {
  if [ $index -gt 0 ];
  then
    index=`expr $index - 1`
  fi
}

go_down() {
  if [ $index -lt $number_of_commits ];
  then
    index=`expr $index + 1`
  fi
}

while [ : ]
do
  clear
  next=`expr $index + 1`
  echo "`get_sha $index` `get_comment $index` -> `get_sha $next` `get_comment $next`"
  display_diff $index $FILENAME
  read -n 1 key
  case "$key" in
      '<') go_up;;
      '>') go_down;;
      'q') exit;;
  esac
done
