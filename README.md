# dotfiles 

Powered by stow and nix.

Currently have all my dotfiles administrable via stow and symlinks for vanilla Ubuntu.

Working through getting a nixOS config up and running with the idea to keep it backwards compatible 
for now.

### installation (stow)

```bash
cd $HOME
git clone git@github.com:thomascrha/dotfiles.git
cd dotfiles 
stow -t $HOME -v -R -d $PWD -S .
```

## nixos

### tutorial 

https://www.youtube.com/watch?v=6WLaNIlDW0M&list=PL_WcXIXdDWWpuypAEKzZF2b5PijTluxRG&pp=iAQB

### up and running 

1. Install nixos via the installer 
2. Install `home-manager`
3. see commands bellow

### useful commands

```bash
# update nixpkgs 
nix flake update

# update nixos 
sudo nixos-rebuild switch --flake .#tcrha-nixos 

# update home-manager 
home-manager switch --flake .#tcrha-home
```
