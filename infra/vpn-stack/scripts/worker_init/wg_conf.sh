#!/bin/bash
set -euo pipefail

source .env.bash
API_URL=$API_URL
CF_ACCESS_CLIENT_ID=$CF_ACCESS_CLIENT_ID
CF_ACCESS_CLIENT_SECRET=$CF_ACCESS_CLIENT_SECRET

ACCESS=$(curl -sS "$API_URL/api/session" \
 -H "CF-Access-Client-Id: ${CF_ACCESS_CLIENT_ID}" \
 -H "CF-Access-Client-Secret: ${CF_ACCESS_CLIENT_SECRET}")

if [[ "$ACCESS" == *'"authenticated":true'* ]]; then

    names=$(curl -sS "$API_URL/api/wireguard/client" \
        -H "CF-Access-Client-Id: ${CF_ACCESS_CLIENT_ID}" \
        -H "CF-Access-Client-Secret: ${CF_ACCESS_CLIENT_SECRET}" )
    
    ordered_nums=$(
    echo "$names" \
    | jq -r '.[].name
            | select(startswith("Worker-"))
            | sub("Worker-";"")
            | tonumber' \
    | sort -n \
    )
    
    new_num=1

    for x in $ordered_nums; do
        if [ "$x" -eq "$new_num" ]; then
            new_num=$((new_num + 1))
        fi
    done

    new_name="Worker-$new_num"

    echo "New Worker: $new_name"

    curl -sS -X POST "$API_URL/api/wireguard/client" \
        -H "CF-Access-Client-Id: ${CF_ACCESS_CLIENT_ID}" \
        -H "CF-Access-Client-Secret: ${CF_ACCESS_CLIENT_SECRET}" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"$new_name\"}" \
        > /dev/null

    names=$(curl -sS "$API_URL/api/wireguard/client" \
        -H "CF-Access-Client-Id: ${CF_ACCESS_CLIENT_ID}" \
        -H "CF-Access-Client-Secret: ${CF_ACCESS_CLIENT_SECRET}" )

    worker_id=$(echo $names | jq -r --arg n "$new_name" '.[] | select(.name == $n) | .id')    
    
    config=$(curl -sS "$API_URL/api/wireguard/client/$worker_id/configuration" \
        -H "CF-Access-Client-Id: ${CF_ACCESS_CLIENT_ID}" \
        -H "CF-Access-Client-Secret: ${CF_ACCESS_CLIENT_SECRET}")
    echo "$config" | sed '/^DNS/d'

else 
    echo "Not Authenticated. | Message: $ACCESS" 
fi