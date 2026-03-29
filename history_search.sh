#!/bin/bash -eux

search_path=

ic=""
script_name=${0##*/}
if [ "$script_name" = "hhi" ]; then
    ic="--ignore-case"
fi

sort -u $ic ~/workspace/var/command-history/* ~/.zsh_history | grep --color -E $ic $1
