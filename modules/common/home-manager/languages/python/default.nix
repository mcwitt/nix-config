{ lib, config, pkgs, ... }:
with lib;
let cfg = config.languages.python;
in
{
  options.languages.python.enable =
    mkEnableOption "Python language environment";

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [ black mypy ] ++ (with python3Packages; [ flake8 virtualenv ]);

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
        config = "(add-to-list 'company-backends 'company-anaconda)";
      };

      dap-python.enable = true;

      format-all = {
        hook = [ "(python-mode . format-all-mode)" ];
        config = ''
          (add-to-list 'format-all-formatters '("Python" black))
        '';
      };

      pyvenv.enable = true;
    };
  };
}
