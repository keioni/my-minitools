#!/bin/bash

export ADDR_LIST_FILE="cloudflare_ipv4.txt"

# operation
if [ "$1" eq "open" ]; then
    command="allow"
elif [ "$1" eq "close" ]; then
    command="deny"
else
    echo "Usage: $0 open|close"
    exit 1
fi

# first, use current directory. second, use script directory.
if [ -f "./cloudflare_ipv4.txt" ]; then
    ADDR_LIST_PATH="./cloudflare_ipv4.txt"
elif [ -f "$(dirname "$0")/cloudflare_ipv4.txt" ]; then
    ADDR_LIST_PATH="$(dirname "$0")/cloudflare_ipv4.txt"
else
    echo "Cloudflare IPv4 list not found. "
    echo "Download from: https://www.cloudflare.com/ips-v4/"
    exit 1
fi


for network in $(cat $ADDR_LIST_PATH); do

    # Skip empty lines and comments
    if [ ! -n "$network" ]; then
        continue
    fi

    # Skip comments    
    if [ "${network:0:1}" eq "#" ]; then
        continue
    fi

    # open or close port 443 for the cloudflare network
    if [ "$command" eq "allow" ]; then
        echo "> opening port 443 for $network ..."
        ufw allow proto tcp from "$network" to any port 443
    else
        echo "> closing port 443 for $network ..."
        ufw delete allow proto tcp from "$network" to any port 443
    fi

done
