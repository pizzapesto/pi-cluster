#!/bin/bash

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.cf-ddns.env"

# GET zone id
ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$ZONE_NAME" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" | jq -r '.result[0].id')

# GET record id
RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$RECORD_NAME" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" | jq -r '.result[0].id')

# GET current public IP
CURRENT_IP=$(curl -s ifconfig.me)

# GET DNS IP
DNS_IP=$(dig +short "$RECORD_NAME")

if [[ "$CURRENT_IP" == "$DNS_IP" ]]; then
    echo "IP unchanged ($CURRENT_IP), no update needed."
    exit 0
fi

# Update DNS
UPDATE_RESULT=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"$RECORD_NAME\",\"content\":\"$CURRENT_IP\",\"ttl\":120,\"proxied\":false}")

SUCCESS=$(echo "$UPDATE_RESULT" | jq -r '.success')

if [[ "$SUCCESS" == "true" ]]; then
    echo "DNS record updated to $CURRENT_IP"
else
    echo "Failed to update DNS"
    echo "$UPDATE_RESULT"
fi
