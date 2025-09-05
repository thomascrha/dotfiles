#!/bin/sh

podman build -t neovim:latest \
    --build-arg "UID=$(id -u)" \
    --build-arg "GID=$(id -g)" \
    --build-arg "USER=$(id -un)" \
    .

podman run -ti --rmi \
    --name neovim-container \
    neovim:latest
