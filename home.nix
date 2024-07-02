{ config, pkgs, ... }:

{
  home.username = "tcrha";
  home.homeDirectory = "/home/tcrha";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".zshrc".source = ./.zshrc;
    ".zimrc".source = ./.zimrc;
    ".p10k.zsh".source = ./.p10k.zsh;
    ".config/nvim".source = ./.config/nvim;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.zsh.enable = true;
  programs.home-manager.enable = true;
}
