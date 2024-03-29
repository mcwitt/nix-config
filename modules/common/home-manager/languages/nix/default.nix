{ config, lib, pkgs, ... }:
with lib;
let cfg = config.languages.nix;
in
{
  options.languages.nix.enable = mkEnableOption "Nix language environment";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cachix
      nil
      niv
      nix-info
      nix-prefetch-git
      nix-prefetch-github
      nixpkgs-fmt
    ];

    programs.emacs.init.usePackage = {

      eglot.hook = [ "(nix-mode . eglot-ensure)" ];

      nix-mode = {
        enable = true;
        bindLocal.nix-mode-map = {
          "C-c C-z" = "nix-repl-show";
        };
      };

      project.config = ''
        (add-to-list 'my/project-root-markers "flake.nix")
      '';

      subword.hook = [ "(nix-mode . subword-mode)" ];
    };

    programs.neovim.plugins = [ pkgs.vimPlugins.vim-nix ];
  };
}
