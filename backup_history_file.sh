#!/bin/bash

# 84600 = 1 day * 7 = 1 week
BACKUP_PERIOD=604800
HOST_NAME=$(hostname -s)
DEST_PATH=$HOME/workspace/var/shell_histories
INDICATOR_FILE=$DEST_PATH/_${HOST_NAME}_latest_backup_timestamp

RED=$'\e[31m'
GREEN=$'\e[32m'
LIGHT_BLUE=$'\e[34m'
RESET=$'\e[0m'

ok()    { echo "${LIGHT_BLUE}$*${RESET}"; }
error() { echo "${RED}$*${RESET}"; }

backup_history_file() {
    if [ ! -d $DEST_PATH ]; then
        error "[✖] History file backup failed! (destination path not found)"
        exit 1
    fi
    backup_file_name=${HOST_NAME}_$(date +'%Y%m%d')

    cp -n $HOME/.zsh_history $DEST_PATH/$backup_file_name
    gzip -f $DEST_PATH/$backup_file_name
    if [ $? -ne 0 ]; then
        error "[✖] History file backup failed! (gzip failed)"
        exit 1
    fi
    ok "[✔] History file backup completed."
    echo "$(date +'%s') $(date +'%y-%m-%d %H:%M:%S')" > $INDICATOR_FILE
}

if [ -f $INDICATOR_FILE ]; then
    latest_timestamp=$(cat $INDICATOR_FILE | awk {'print $1'})
    current_timestamp=$(date +'%s')
    diff=$(($current_timestamp - $latest_timestamp))
    if [ $diff -gt $BACKUP_PERIOD ]; then
        backup_history_file
    fi
else
    backup_history_file
fi

