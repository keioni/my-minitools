#!/bin/bash

LENGTH=${1:-16}

while true; do
    PASSWORD=$(cat /dev/urandom | LANG=C tr -dc 'A-Za-z0-9' | head -c "$LENGTH")
    echo $PASSWORD | perl -lne 'exit 1 unless (/[A-Z]/ && /[a-z]/ && /[0-9]/)'
    if [ $? -eq 0 ]; then
        echo "Generated password: $PASSWORD"
        break
    else
        echo "Password does not meet criteria, generating a new one..."
        sleep 0.1s
    fi
done
