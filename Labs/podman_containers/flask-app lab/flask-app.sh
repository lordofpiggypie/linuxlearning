podman run -d \
  --name flask-app \
  --network webapp \
  -e DB_HOST=mariadb \
  -e DB_USER=appuser \
  -e DB_PASSWORD=Service123 \
  -e DB_NAME=appdb \
  flask-app:latest