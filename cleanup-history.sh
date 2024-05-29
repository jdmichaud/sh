#!/usr/bin/env bash

# https://stackoverflow.com/a/28845565/2603925

# Stop on error
set -e

if [ $# -ne 2 ]
then
  echo "error: incorrect number of argument"
  echo "usage: $0 <old-author> <new-author>"
  exit 1
fi

AUTHOR_TO_REMOVE=$1
NEW_AUTHOR=$2

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
# As commit id change every loop, we need to rerun git log. The first git log
# is only here to loop the proper number of times.
for DUMMY in $(git log --author=${AUTHOR_TO_REMOVE} --oneline | cut -c -7 | tac)
do
  COMMITID=$(git log --author=${AUTHOR_TO_REMOVE} --oneline | cut -c -7 | tail -n 1)
  git checkout ${COMMITID} > /dev/null 2>&1
  NEW_COMMITID=$(git commit --amend --no-edit --author "$2" | head -n 1 | sed -e 's/\[detached HEAD \([[:alnum:]]*\)\].*/\1/')
  echo ${COMMITID} '->' ${NEW_COMMITID}
  git checkout ${CURRENT_BRANCH} > /dev/null 2>&1
  git replace ${COMMITID} ${NEW_COMMITID}
  FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -- --all
  git replace -d ${COMMITID}
  git for-each-ref --format="%(refname)" refs/original/ | xargs --max-args=1 --no-run-if-empty git update-ref -d
done

