
#!/bin/bash
# Simple IP limit checker for SSH accounts
# Usage: limit_ip <username> <max_ip>

user=$1
max_ip=$2

ips=$(who | grep "$user" | awk '{print $5}' | tr -d '()' | sort -u | wc -l)

if [ "$ips" -gt "$max_ip" ]; then
    # lock account and set expiry to now
    passwd -l $user
    chage -E0 $user
    echo "User $user exceeded IP limit ($ips/$max_ip). Account expired."
fi
