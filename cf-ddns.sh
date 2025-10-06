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
echo "new address: $ip_address"


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

# create a temp file to store JSON responses
tmp_json=$(mktemp)
trap 'rm -f "$tmp_json"' EXIT

# get current DNS records for the FQDN
# store output in a temp file to avoid multiple API calls
curl -s "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?name=$FQDN" \
    -H "Authorization: Bearer $API_TOKEN" > $tmp_json
if [ "$(jq -r '.success' $tmp_json)" != "true" ]; then
    echo "Error fetching DNS records for $FQDN"
    jq .errors $tmp_json
    exit 1
fi

# check if the IP address is already up to date
current_ip_address=$(jq -r '.result[] | select(.type == "'"$record_type"'") | .content' $tmp_json)
echo "current address: $current_ip_address"
if [ "$current_ip_address" = "$ip_address" ]; then
    echo "No update needed for $FQDN ( $current_ip_address )"
    exit 0
fi

record_id=$(jq -r '.result[] | select(.type == "'"$record_type"'") | .id' $tmp_json)
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
    }' > $tmp_json
if [ "$(jq -r '.result.content' $tmp_json)" != "$ip_address" ]; then
    echo "Failed to update DNS record for $FQDN ( $current_ip_address -> $ip_address )"
    exit 1
fi

if [ "$(jq -r '.success' $tmp_json)" != "true" ]; then
    echo "Error updating DNS record for $FQDN ( $current_ip_address -> $ip_address )"
    jq .errors $tmp_json
    exit 1
fi
echo "Updated $FQDN ( $current_ip_address -> $ip_address)"
exit 0
