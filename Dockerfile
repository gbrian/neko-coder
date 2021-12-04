#FROM codercom/code-server as coder
FROM m1k1o/neko:latest

RUN apt-get update \
 && apt-get install -y \
    curl \
    dumb-init \
    zsh \
    htop \
    locales \
    man \
    nano \
    git \
    procps \
    openssh-client \
    sudo \
    vim.tiny \
    lsb-release \
  && rm -rf /var/lib/apt/lists/*

# https://wiki.debian.org/Locale#Manually
RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
  && locale-gen
ENV LANG=en_US.UTF-8

RUN adduser --gecos '' --disabled-password coder && \
  echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

ENV ARCHITECTURE=amd64 
# ARCHITECTURE="$(dpkg --print-architecture)"

RUN ARCH="$ARCHITECTURE" && \
    curl -fsSL "https://github.com/boxboat/fixuid/releases/download/v0.5/fixuid-0.5-linux-$ARCH.tar.gz" | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml


# COPY release-packages/code-server*.deb /tmp/
RUN curl -fsSL "https://github.com/cdr/code-server/releases/download/v3.12.0/code-server_3.12.0_$ARCHITECTURE.deb" \
    > "/tmp/code-server${ARCHITECTURE}.deb"
RUN dpkg -i /tmp/code-server*${ARCHITECTURE}.deb && rm /tmp/code-server*.deb

EXPOSE 8090
# This way, if someone sets $DOCKER_USER, docker-exec will still work as
# the uid will remain the same. note: only relevant if -u isn't passed to
# docker-run.

# coder supervisor
COPY --chown=coder coder_init.sh /usr/bin/coder_init.sh
RUN chmod +x /usr/bin/coder_init.sh
COPY --chown=neko supervisord.conf /etc/neko/supervisord/neko-coder.conf

#USER neko