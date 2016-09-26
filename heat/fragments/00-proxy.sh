#!/bin/sh

. /etc/sysconfig/heat-params

echo "export http_proxy=${HTTP_PROXY}" >> /etc/default/docker
echo "export https_proxy=${HTTPS_PROXY}" >> /etc/default/docker

service docker restart
