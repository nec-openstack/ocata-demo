#!/bin/sh

. /etc/sysconfig/heat-params

echo "http_proxy=${HTTP_PROXY}" >> /etc/environment
echo "https_proxy=${HTTPS_PROXY}" >> /etc/environment
echo "HTTP_PROXY=${HTTP_PROXY}" >> /etc/environment
echo "HTTPS_PROXY=${HTTPS_PROXY}" >> /etc/environment
