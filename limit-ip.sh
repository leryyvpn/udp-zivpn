#!/bin/bash
USER=$1
LIMIT=$(cat /etc/limit-ip/$USER 2>/dev/null)
[ -z "$LIMIT" ] && exit 0

IP_LOGIN=$(who | awk '{print $5}' | tr -d '()' | grep -v ':' | sort | uniq)
TOTAL_IP=$(echo "$IP_LOGIN" | wc -l)

if [ "$TOTAL_IP" -gt "$LIMIT" ]; then
    pkill -u $USER
    passwd -l $USER >/dev/null 2>&1
    echo "$(date) - $USER BLOCKED (IP > $LIMIT)" >> /var/log/limit-ip.log
fi
