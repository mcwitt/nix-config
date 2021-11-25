{ lib, config, pkgs, ... }:
with lib;
let cfg = config.languages.python;
in
{
  options.languages.python = {
    enable = mkEnableOption "Python language environment";

    globalPackages = mkOption {
      default = self: [ ];
      type = hm.types.selectorFunction;
      defaultText = "pypkgs: []";
      example = literalExample "pypkgs: with pypkgs; [ black pandas requests ]";
      description = ''
        Packages to install globally.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      let pythonEnv = pkgs.python3.withPackages (ps: cfg.globalPackages ps);
      in [ pythonEnv ];

    programs.emacs.init.usePackage = {

      anaconda-mode = {
        enable = true;
        hook = [
          "(python-mode . anaconda-mode)"
          "(python-mode . anaconda-eldoc-mode)"
        ];
      };

      company-anaconda = {
        enable = true;
        config = ''
          (add-to-list 'company-backends
                       '(company-anaconda :with company-capf))
        '';
      };

      dap-python.enable = true;

      lsp-pyright = {
        enable = true;
        hook = [
          ''
            (python-mode . (lambda ()
                              (require 'lsp-pyright)
                              (lsp-deferred)))
          ''
        ];
      };

      python-mode = {
        enable = true;
        mode = [ ''"\\.py\\'"'' ];
      };

      pyvenv = {
        enable = true;
        command = [ "pyvenv-activate" ];
      };
    };

    programs.jupyterlab.kernels = [
      (ks: ks.iPythonWith {
        name = "python";
        packages = cfg.globalPackages;
      })
    ];

    programs.vscode = mkIf (!pkgs.stdenv.isDarwin) {
      extensions = with pkgs.vscode-extensions; [
        ms-python.python
        ms-python.vscode-pylance
      ];
      userSettings.python.languageServer = "Pylance";
    };
  };
}
