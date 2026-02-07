#!/bin/bash
USER=$1
LIMIT=$(cat /etc/limit-ip/$USER 2>/dev/null)
[ -z "$LIMIT" ] && exit 0

BOT_CONFIG="/etc/zivpn/bot_config.sh"
IP_LOGIN=$(who | awk '{print $5}' | tr -d '()' | grep -v ':' | sort | uniq)
TOTAL_IP=$(echo "$IP_LOGIN" | wc -l)

if [ "$TOTAL_IP" -gt "$LIMIT" ]; then
    pkill -u $USER
    passwd -l $USER >/dev/null 2>&1
    echo "$(date) - $USER BLOCKED (IP > $LIMIT)" >> /var/log/limit-ip.log

    if [ -f "$BOT_CONFIG" ]; then
        source "$BOT_CONFIG"
        if [ -n "$BOT_TOKEN" ] && [ -n "$CHAT_ID" ]; then
            MSG="🚫 <b>LIMIT IP BLOCKED</b>%0AUser: <code>$USER</code>%0AIP Login: $TOTAL_IP / Limit: $LIMIT"
            curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"               -d "chat_id=${CHAT_ID}"               -d "text=${MSG}"               -d "parse_mode=HTML" > /dev/null
        fi
    fi
fi
