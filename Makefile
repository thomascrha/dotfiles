##!/bin/make

default: help
help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

stow: ## Stow dotfiles
	stow --no-folding -t ${HOME} -v -d ${PWD} -S .
	@if [ -n "$(CLEAR)" ]; then \
		echo "clearing"; \
		sudo find ${HOME} -xtype l -delete; \
	fi
	@if [ -n "$(TMUX)" ]; then \
		target="$(TMUX)"; \
		if [ "$$target" != "all" ] && [ "$$target" != "python" ] && \
		   [ "$$target" != "bash" ] && [ "$$target" != "go" ]; then \
			target="all"; \
		fi; \
		$(MAKE) -C ./.config/tmux $$target; \
	fi

unstow: ## Unstow dotfiles
	stow -t ${HOME} -d ${PWD} -D .



