#!/bin/bash -eu

# Dynamic DNS update script for use with Cloudflare's API
# Requires: curl, jq
# Usage: ./ddns.sh FQDN [IP address]

# Set API_TOKEN before running.
# FQDN is the full domain name to update, e.g. home.example.com

if [ -z "${API_TOKEN:-}" ]; then
    echo "Please set the API_TOKEN environment variable."
    exit 1
fi

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 FQDN [IP address]"
    exit 1
fi

FQDN="$1"
IP_ADDR="${2:-}"

# I love IPv6 
# but if you want IPv4, change this to "4"
ip_version="6"

# ip.me is provided by Proton AG,
# the maker of Proton Mail, VPN, and other privacy-focused services.
if [ -n "$IP_ADDR" ]; then
    echo $IP_ADDR | grep -q ":"
    if [ $? -ne 0 ]; then
        ip_record_type="A"
    else
        ip_record_type="AAAA"
    fi
else
    if [ "$ip_version" = "4" ]; then
        IP_ADDR=$(curl --silent -4 https://ip.me)
        ip_record_type="A"
    else
        IP_ADDR=$(curl --silent -6 https://ip.me)
        ip_record_type="AAAA"
    fi
fi


# get Account ID from API token
# note: this assumes the token is scoped to a single account
account_id=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/accounts" \
    -H "Authorization: Bearer $API_TOKEN" \
    | jq -r '.result[0].id')
if [ "$account_id" = "null" ]; then
    echo "Invalid API token"
    exit 1
fi

# get Zone ID from domain name
domain_name="${FQDN#*.}"
zone_id=$(curl --silent "https://api.cloudflare.com/client/v4/zones/?name=$domain_name" \
    -H "Authorization: Bearer $API_TOKEN" \
    | jq -r '.result[0].id')
if [ "$zone_id" = "null" ]; then
    echo "Zone not found for $domain_name"
    exit 1
fi

# get DNS record ID from record name
record_id=$(curl --silent "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?name=$FQDN" \
    -H "Authorization: Bearer $API_TOKEN" \
    | jq -r '.result[0].id')

if [ "$record_id" = "null" ]; then
    echo "DNS record not found for $FQDN"
    exit 1
fi

update DNS record with new IP address
curl --silent "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
-X PATCH \
-H "Authorization: Bearer $API_TOKEN" \
-d '{
        "type": "'"$ip_record_type"'",
        "name": "'"$FQDN"'",
        "content": "'"$IP_ADDR"'",
        "ttl": 3600,
        "proxied": false
}' | jq
