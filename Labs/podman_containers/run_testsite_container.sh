#!/bin/bash

CONTAINER_NAME=secure-nginx-testsite

podman run -d \
  --name $CONNECTION_NAME \
  -p 8443:8443 \
  -v /srv/testsite:/usr/share/nginx/html:ro,z \
  -v /srv/conf/nginx.conf:/etc/nginx/nginx.conf:ro,z \
  -v /srv/testsite-ssl:/etc/nginx/certs:ro,z \
  nginx:alpine
