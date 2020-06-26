{ pkgs, ... }:
let
  jupyterlab = pkgs.mypkgs.jupyterlab.override {
    directory = "${builtins.getEnv "HOME"}/.jupyterlab/";
  };
  # Use package set from 'jupyterlab.pkgs' for consistency with jupyterWith
  python3Env = jupyterlab.pkgs.python3.withPackages
    (ps: with ps; [ black flake8 mypy jupyterlab ]);
in {
  home.packages = [ python3Env ];

  # HACK to set JUPYTER_PATH and JUPYTERLAB in user env
  programs.zsh.envExtra = jupyterlab.env.shellHook;
}