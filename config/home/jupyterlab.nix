{ pkgs, ... }:
with { inherit (pkgs.mypkgs) jupyterlab; };
let
  # Use 'jupyterlab.pkgs' to derive Python env; ensures consistency
  # with jupyterWith
  jupyterlabEnv = jupyterlab.pkgs.python3.buildEnv.override {
    extraLibs = [
      (jupyterlab.override {
        directory = "${builtins.getEnv "HOME"}/.jupyterlab/";
      })
    ];
  };
in {
  home.packages = [ jupyterlabEnv ];

  # needed to set JUPYTER_PATH and JUPYTERLAB
  programs.zsh.envExtra = jupyterlab.env.shellHook;
}
