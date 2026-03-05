#!/bin/sh

# Liste with cat 
# OLD_IFS=$IFS
# IFS='
# ' 
# for user in $(cat /etc/passwd); do
#     uid=$(echo "$user" | cut -d':' -f 3)
#     if [ "$uid" -gt 100 ] 2>/dev/null; then
#         echo "$user" | cut -d':' -f 1
#     fi
# done
# IFS=$OLD_IFS

awk -F: '$3 > 100 { print $1 }' /etc/passwd
