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
		sudo fd --follow --type symlink -H . ${HOME} -X rm -rf; \
	fi
	./decrypt.sh

unstow: ## Unstow dotfiles
	stow -t ${HOME} -d ${PWD} -D .



