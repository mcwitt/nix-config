{ config, pkgs, ... }:
let homeDir = builtins.getEnv "HOME";
in {
  imports = [ ../../home.nix ];

  # HACK fix for darwin/fish PATH ordering; see https://github.com/LnL7/nix-darwin/issues/122
  programs.fish.shellInit = ''
    for p in /run/current-system/sw/bin ${homeDir}/.nix-profile/bin
        if not contains $p $fish_user_paths
            set -g fish_user_paths $p $fish_user_paths
        end
    end
  '';

  programs.git.ignores = pkgs.mypkgs.gitignore.ghGitIgnoreLines "Global/macOS";

  programs.password-store.package =
    pkgs.pass.withExtensions (exts: [ exts.pass-update ]);
}
