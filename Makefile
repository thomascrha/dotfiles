#!/bin/make

default: help
help:
        @echo "Usage: make [target]"
        @echo "Targets:"
        @awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

stow:
	stow --no-folding -t ${HOME} -v -R -d ${PWD} -S .

clean-stow:
	stow -t ${HOME} -d ${PWD} -D .

nixos: nix-flake-update nixos-rebuild home-manager

home-manager:
	home-manager switch --flake '.#tcrha-nixos'

nixos-rebuild:
	sudo nixos-rebuild switch --flake '.#tcrha-nixos'

nix-flake-update:
	nix flake update

