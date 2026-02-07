#!/bin/bash
for USER in $(ls /etc/limit-ip 2>/dev/null); do
    /usr/bin/bash /usr/local/bin/limit-ip.sh $USER
done
