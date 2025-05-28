podman run -d \
  --name mariadb \
  --network webapp \
  -e MYSQL_ROOT_PASSWORD=my-secret-pw \
  -e MYSQL_DATABASE=appdb \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=apppass \
  -v mariadb-data:/var/lib/mysql:Z \
  docker.io/library/mariadb:10.11