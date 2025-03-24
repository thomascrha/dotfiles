##!/bin/make

default: help
help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

stow: ## Stow dotfiles
	stow --no-folding -t ${HOME} -v -R -d ${PWD} -S .
	sudo fd -t l . ${HOME} | xargs -I{} sh -c 'test ! -e "$(readlink -f "{}")" && rm "{}"'
	./decrypt.sh

unstow: ## Unstow dotfiles
	stow -t ${HOME} -d ${PWD} -D .



