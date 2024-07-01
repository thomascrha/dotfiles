
{
  description = "tcrha main NixOS configuration";
  inputs = 
  {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, home-manager, ... }: 
  {
    nixosConfigurations = {
      tcrha-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./configuration.nix ];
      };
    };

    homeConfigurations = {
      tcrha-nixos = home-manager.lib.homeManagerConfiguration {
	pkgs = nixpkgs.legacyPackages."x86_64-linux";
	modules = [ ./home.nix ];
    };
  };
  };
}
