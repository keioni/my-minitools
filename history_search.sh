#!/bin/bash -eu

search_path="~/workspace/var/command-history/* ~/.zsh_history"

ic=""
if [ $(basename $0) = "hhi" ]; then
    ic="--ignore-case"
fi

sort -u $ic $search_path | grep --color -E $ic $1
