#!/bin/bash
set -e

#clear existing containers
podman rm -f mariadb flask-app nginx-proxy || true
#network check and create if not exists
podman network exists webapp || podman network create webapp
#build flask-app image
podman build -t flask-app:latest ~/flask-app
#start mariadb container
podman run -d \
  --name mariadb \
  --network webapp \
  -e MYSQL_ROOT_PASSWORD=Service123 \
  -e MYSQL_DATABASE=appdb \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=Service123 \
  -v mariadb-data:/var/lib/mysql:Z \
  docker.io/library/mariadb:10.11
#wait for mariadb to start
until podman exec mariadb mysqladmin ping -h"localhost" --silent; do
    echo "Waiting for mariadb to start..."
    sleep 2
done
#start flask-app container
podman run -d \
  --name flask-app \
  --network webapp \
  -e DB_HOST=mariadb \
  -e DB_USER=appuser \
  -e DB_PASSWORD=Service123 \
  -e DB_NAME=appdb \
  flask-app:latest
#start nginx-proxy container
podman run -d \
  --name nginx-proxy \
  --network webapp \
  -p 8080:8080 \
  -v /home/piggypie/nginx-proxy/myapp.conf:/etc/nginx/conf.d/myapp.conf:ro,Z \
  docker.io/library/nginx:alpine
#wait for nginx-proxy to start
until podman exec nginx-proxy curl -s http://localhost:8080; do
    echo "Waiting for nginx-proxy to start..."
    sleep 2
done
#curl to test functionality
curl http://localhost:8080