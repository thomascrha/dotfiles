# nixos

## tutorial 

https://www.youtube.com/watch?v=6WLaNIlDW0M&list=PL_WcXIXdDWWpuypAEKzZF2b5PijTluxRG&pp=iAQB

## useful commands

```bash
# update nixpkgs 
nix flake update

# update nixos 
sudo nixos-rebuild switch --flake .#tcrha-nixos 

# update home-manager 
home-manager switch --flake .#tcrha-home
```
