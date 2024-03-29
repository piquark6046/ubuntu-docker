ARG  UBUNTU_VERSION=latest
FROM ubuntu:${UBUNTU_VERSION}

USER root

RUN apt update && apt upgrade -y && apt install -y sudo adduser
# Create account and switch
RUN adduser --disabled-password --gecos '' -u 1000 container
RUN adduser container sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER root

# Install packages with root
WORKDIR /
COPY init.sh /init.sh
RUN chmod +x /init.sh && bash /init.sh
RUN rm /init.sh

# Install packages with rootless
USER root
COPY init_container.sh /home/container/init_container.sh
RUN chown container /home/container/init_container.sh
USER container
RUN chmod +x /home/container/init_container.sh && bash /home/container/init_container.sh
RUN rm /home/container/init_container.sh

# Docker rootless
RUN dockerd-rootless-setuptool.sh install
RUN echo 'export PATH=/usr/bin:$PATH' > /home/container/.bashrc
RUN echo 'export DOCKER_HOST=unix:///run/user/1000/docker.sock' > /home/container/.bashrc