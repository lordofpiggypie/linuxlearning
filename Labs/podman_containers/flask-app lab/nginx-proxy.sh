podman run -d \
  --name nginx-proxy \
  --network webapp \
  -p 8080:8080 \
  -v /home/piggypie/nginx-proxy/myapp.conf:/etc/nginx/conf.d/myapp.conf:ro,Z \
  docker.io/library/nginx:alpine