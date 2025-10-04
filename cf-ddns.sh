#!/bin/bash -eu

# Dynamic DNS update script for use with Cloudflare's API
# Requires: curl, jq
# Usage: ./cf-ddns.sh FQDN [-4|-6]

# Set API_TOKEN before running.
# FQDN is the full domain name to update, e.g. home.example.com

if [ -z "${API_TOKEN:-}" ]; then
    echo "Please set the API_TOKEN environment variable."
    exit 1
fi

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 FQDN [-4|-6]"
    exit 1
fi

FQDN="$1"

# I love IPv6
IP_VERSION="${2:--6}" # default to IPv6

# ip.me is provided by Proton AG,
# the maker of Proton Mail, VPN, and other privacy-focused services.
if [ "$IP_VERSION" = "-4" ]; then
    ip_address=$(curl -s -4 https://ip.me)
    record_type="A"
else
    ip_address=$(curl -s -6 https://ip.me)
    record_type="AAAA"
fi


# get Account ID from API token to check API token validity
# note: this assumes the token is scoped to a single account
account_id=$(curl -s "https://api.cloudflare.com/client/v4/accounts" \
    -H "Authorization: Bearer $API_TOKEN" \
    | jq -r '.result[0].id')
if [ "$account_id" = "null" ]; then
    echo "Invalid API token"
    exit 1
fi

# get Zone ID from domain name
domain_name="${FQDN#*.}"
zone_id=$(curl -s "https://api.cloudflare.com/client/v4/zones/?name=$domain_name" \
    -H "Authorization: Bearer $API_TOKEN" \
    | jq -r '.result[] | select(.name == "'"$domain_name"'") | .id')
if [ "$zone_id" = "null" ]; then
    echo "Zone not found for $domain_name"
    exit 1
fi

# get DNS record ID from record name and type
record_id=$(curl -s "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?name=$FQDN" \
    -H "Authorization: Bearer $API_TOKEN" \
    | jq -r '.result[] | select(.type == "'"$record_type"'") | .id')
if [ "$record_id" = "null" ]; then
    echo "DNS $record_type record not found for $FQDN"
    exit 1
fi

# update DNS record with new IP address
curl -s "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
    -X PATCH \
    -H "Authorization: Bearer $API_TOKEN" \
    -d '{
        "type": "'"$record_type"'",
        "name": "'"$FQDN"'",
        "content": "'"$ip_address"'",
        "ttl": 3600,
        "proxied": false
    }' | jq
