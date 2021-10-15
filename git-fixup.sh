#!/bin/sh
git commit --fixup=$1 && GIT_SEQUENCE_EDITOR=cat git rebase --interactive --autosquash $1~1
