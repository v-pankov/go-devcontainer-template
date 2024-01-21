FROM mcr.microsoft.com/devcontainers/go:1.21

#
## Setup foundation.
#

# install apt-uptils upfront so consecutive installs pass without warnings
RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends \
        apt-utils

# install basic tools
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        bash-completion \
        build-essential

# install protocol-buffers tools
#   * clang-format is needed for vscode protobuf extension
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends \
        protobuf-compiler \
        clang-format

# install vscode-server
#   * it will be installed by DevContainers extenstion but it will take longer
RUN wget -O- https://aka.ms/install-vscode-server/setup.sh | sh

# install docker tools without daemon
#   * host docker socket will be mounted
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends \
        docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin && \
    groupadd -f docker && usermod -aG docker vscode && newgrp docker

#
## Setup user.
#

# Rename vscode user so it could be used in goland too.
# Why rename instead of create new:
#   * docker user must have same UID and GID as host user
#   * most of the time host user has UID=1000 and GID=1000
#   * vscode user has UID=1000 and GID=1000 so they are taken
ARG USERNAME=devel
RUN usermod --login ${USERNAME} --move-home --home /home/${USERNAME} vscode && \
    groupmod --new-name ${USERNAME} vscode

# grant user sudo rights to do installs in container
#   * mostly to do chown on bind mounted volumes
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y sudo && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# setup go variables
#  * GODIR will be mounted as separate volume so go packages won't be loaded
#    on every devcontainer rebuild.
ARG GODIR=/home/${USERNAME}/.go
ENV GOBIN=${GODIR}/bin
ENV GOCACHE=${GODIR}/cache
ENV GOMODCACHE=${GODIR}/modcache
ENV GOPATH=${GODIR}/path

# reflect go variables changes in path varable
ENV PATH="${PATH}:${GOBIN}"
ENV PATH="${PATH}:${GOPATH}/bin"

#
## Copy docker context.
#

COPY devcontainer /devcontainer/
RUN chmod +x /devcontainer/setup.sh

#
## Switch to non root user.
#

USER ${USERNAME}
