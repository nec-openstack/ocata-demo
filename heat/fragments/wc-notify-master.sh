#!/bin/sh

. /etc/sysconfig/heat-params

# until curl -sf "http://127.0.0.1:8080/healthz"; do
#     echo "Waiting for Kubernetes API..."
#     sleep 5
# done
$WAIT_CURL --data-binary '{"status": "SUCCESS"}'
