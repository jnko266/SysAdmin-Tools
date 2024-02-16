#!/bin/bash

# Initialize a flag to track if any rule has been updated
RULE_UPDATED=0

# Specify an external DNS server
EXTERNAL_DNS_SERVER="1.1.1.1"

# Process each UFW rule
IFS=$'\n'
UFW_RULES=( $(sudo ufw status numbered | grep 'AUTO_UPDATE:' | tac) )
for RULE in "${UFW_RULES[@]}"; do
    RULE_NUM=$(echo "$RULE" | awk -F '[][]' '{print $2}')
    COMMENT=$(echo "$RULE" | grep -oP '#\s*\K.*')

    # Extract DNS record directly using regex
    DNS_RECORD=$(echo "$COMMENT" | grep -oP 'AUTO_UPDATE:\K[^;)]+')

    # Proceed if DNS record is found
    if [ -n "$DNS_RECORD" ]; then
        NEW_IP=$(dig @$EXTERNAL_DNS_SERVER +short $DNS_RECORD)
        NEW_IP=$(echo "$NEW_IP" | grep -oP '(\d{1,3}\.){3}\d{1,3}' | head -1)

        # Proceed if IP is found (i.e. $NEW_IP is not empty or blank)
        if [ -n "$NEW_IP" ]; then
            # Extract the current IP from the rule
            CURRENT_IP=$(echo "$RULE" | grep -oP '(\d{1,3}\.){3}\d{1,3}' | head -1)

            # Compare and update the rule if IPs are different
            if [ "$CURRENT_IP" != "$NEW_IP" ]; then
                # Set the flag to indicate a rule has been updated
                RULE_UPDATED=1

                echo "$(date '+%Y-%m-%d %H:%M:%S') - Rule '$RULE' needs updating, because IP has changed (from '$CURRENT_IP' to '$NEW_IP')"

                # Extract the port and protocol from the rule
                PORT=$(echo "$RULE" | grep -oP '\d+(?=/|\s|$)' | head -1)
                PROTOCOL=$(echo "$RULE" | grep -oP '\/\K\w+')

                # Construct the UFW allow command
                UFW_ALLOW_CMD="sudo ufw allow from $NEW_IP to any port $PORT"
                if [ -n "$PROTOCOL" ]; then
                    UFW_ALLOW_CMD+=" proto $PROTOCOL"
                fi
                UFW_ALLOW_CMD+=" comment \"$COMMENT\""

                echo "  $(date '+%Y-%m-%d %H:%M:%S') - New rule: $UFW_ALLOW_CMD"

                # Execute the UFW allow command
                eval $UFW_ALLOW_CMD

                # Remove the old rule
                sudo ufw --force delete $RULE_NUM
            fi
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') - DNS record '$DNS_RECORD' could not be resolved, skipping rule '$RULE'"
            continue
        fi
    fi
done

# Reload UFW if any rule has been updated
if [ $RULE_UPDATED -eq 1 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Reloading UFW"
    sudo ufw reload
fi