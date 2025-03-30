#!/bin/bash

export ADDR_LIST_FILE="cloudflare_ipaddr_ranges.txt"

# operation
if [ "$1" = "open" ]; then
    command="allow"
elif [ "$1" = "close" ]; then
    command="delete allow"
else
    echo "Usage: $0 open|close"
    exit 1
fi

if [ "$2" = "--dry" ]; then
    flag="--dry"
fi

# first, use current directory. second, use script directory.
if [ -f "./$ADDR_LIST_FILE" ]; then
    ADDR_LIST_PATH="./$ADDR_LIST_FILE"
elif [ -f "$(dirname "$0")/$ADDR_LIST_FILE" ]; then
    ADDR_LIST_PATH="$(dirname "$0")/$ADDR_LIST_FILE"
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
    if [ "${network:0:1}" = "#" ]; then
        continue
    fi
    # open or close port 443 for the cloudflare network
    if [ "$command" = "allow" ]; then
        echo "> opening port 443 for $network ..."
    else
        echo "> closing port 443 for $network ..."
    fi
    # dry run?
    if [ "$flag" = "--dry" ]; then
        echo "ufw $command proto tcp from $network to any port 443"
    else
        ufw $command proto tcp from "$network" to any port 443
    fi
done

ufw status verbose | grep "443" | grep "ALLOW" | grep -v "any" | sort -u
echo "Done."
echo ""

systemctl status ufw
