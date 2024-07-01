# nixos

## tutorial 

https://www.youtube.com/watch?v=6WLaNIlDW0M&list=PL_WcXIXdDWWpuypAEKzZF2b5PijTluxRG&pp=iAQB

## useful commands

```bash
# update the system with flake current configuration name tcrha-nixos
sudo nixos-rebuild switch --flake .#<config-name> # config-name is the name of the configuration in the flake.nix file
```
