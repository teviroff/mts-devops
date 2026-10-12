#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <service>"
    exit 1
fi

SERVICE_NAME=$1
SERVICE_STATUS=$(systemctl is-active "$SERVICE_NAME" 2>&1)

if [ "$SERVICE_STATUS" != "active" ]; then
    echo "Service \`$SERVICE_NAME\` is inactive, last logs:"
    journalctl -u "$SERVICE_NAME" -n 10 --no-pager
else
    echo "Service \`$SERVICE_NAME\` is active"
fi

ERROR_COUNT=$(journalctl --since "1 hour ago" --no-pager 2> /dev/null \
    | grep -i "error" \
    | awk '
        BEGIN { count = 0 }
        { count++ }
        END { print count }
    ')

if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "System log contains $ERROR_COUNT error(s) reported in last 60 minutes"
fi
