{ config, lib, pkgs, ... }:
with lib;
let cfg = config.languages.scala;
in
{
  options.languages.scala.enable = mkEnableOption "Scala language environment";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ ammonite metals sbt scalafmt ];

    programs.emacs.init.usePackage = {

      ammonite-term-repl = {
        enable = true;
        after = [ "scala-mode" ];
        hook = [
          ''
            (scala-mode . (lambda ()
                            (ammonite-term-repl-minor-mode t)))
          ''
        ];
      };

      fira-code-mode.hook = [ "scala-mode" ];

      lsp-metals = {
        enable = true;
        hook = [ "(scala-mode . lsp-deferred)" ];
      };

      ob-ammonite = {
        enable = true;
        after = [ "org" ];
      };

      sbt-mode = {
        enable = true;
        command = [ "sbt-start" "sbt-command" ];
        config = ''
          ;; WORKAROUND: allows using SPACE when in the minibuffer
          (substitute-key-definition
           'minibuffer-complete-word
           'self-insert-command
           minibuffer-local-completion-map)
        '';
      };

      scala-mode = {
        enable = true;
        mode = [ ''"\\.s\\(c\\|cala\\|bt\\)\\'"'' ];
      };

      subword.hook = [ "(scala-mode . subword-mode)" ];
    };

    programs.vscode = {
      extensions = with pkgs.vscode-extensions; [
        scala-lang.scala
        scalameta.metals
      ];
    };
  };
}
