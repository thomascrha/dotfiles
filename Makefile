all:
	stow --no-folding -t ${HOME} -v -R -d ${PWD} -S .

clean:
	stow -t ${HOME} -d ${PWD} -D .

nixos: nix-flake-update nixos-rebuild home-manager

home-manager: flakes system
	home-manager switch --flake '.#tcrha-nixos'

nixos-rebuild:
	sudo nixos-rebuild switch --flake '.#tcrha-nixos'

nix-flake-update:
	nix flake update

