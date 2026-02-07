#!/bin/bash
echo "User Terblokir (Limit IP):"
grep BLOCKED /var/log/limit-ip.log 2>/dev/null | awk '{print $4}' | sort | uniq
