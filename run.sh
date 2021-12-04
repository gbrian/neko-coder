docker run -it $@ \
  -v $PWD/..:/home/coder/github \
  -p "${PORT_PREFIX}80:8080" \
  -p "${PORT_PREFIX}90:8090" \
  -p "${PORT_PREFIX}000-${PORT_PREFIX}100:52000-52100/udp" \
  -u "$(id -u):$(id -g)" \
  -e "DOCKER_USER=$USER" \
  -e "PASSWORD=neko-coder" \
  neko-coder:latest
