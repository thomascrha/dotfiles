##!/bin/make

default: help
help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

stow: ## Stow dotfiles
	stow --no-folding -t ${HOME} -v -d ${PWD} -S .
	@if [ ! -z "$(CLEAR)" ]; then \
		echo "clearing"; \
		sudo find ${HOME} -xtype l -delete; \
		# sudo fd --follow --type symlink -H . ${HOME} -X rm -rf; \
	fi
	@if [ ! -z "$(WSL_DISTRO_NAME)" ]; then \
		echo "WSL detected, running wezdows install script"; \
		./scripts/install-wezdows.sh; \
	fi
	./decrypt.sh

unstow: ## Unstow dotfiles
	stow -t ${HOME} -d ${PWD} -D .



