#!/bin/bash

# Install the apt deps
sudo apt update && sudo apt upgrade -y && sudo apt install --no-recomends -y \
    git \
    curl \
    wget \
    vim \
    zsh \
    tmux \
    neofetch \
    btop

# Install pacstall
# Install docker
# Install extensions
# Setup dotfiles
