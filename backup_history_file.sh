#!/bin/bash -eu

# 84600 = 1 day * 7 = 1 week
BACKUP_PERIOD=604800
HOST_NAME=$(hostname -s)
DEST_PATH=$HOME/workspace/var/share/shell_histories
INDICATOR_FILE=$DEST_PATH/_${HOST_NAME}_latest_backup_timestamp

backup_history_file() {
    if [ ! -d $DEST_PATH ]; then
        echo "[FAILED] Backup path had some problems."
        exit 1
    fi
    backup_file_name=${HOST_NAME}_$(date +'%Y%m%d')

    cp -n $HOME/.zsh_history $DEST_PATH/$backup_file_name
    echo "\033[36mBackued up history file.\e[m"
    echo $"$(date +'%s') $(date +'%y-%m-%d %H:%M:%S')" > $INDICATOR_FILE
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

