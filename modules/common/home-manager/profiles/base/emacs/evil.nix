{ config, lib, ... }:
with lib;
let usePackageCfg = config.programs.emacs.init.usePackage;
in
{
  programs.emacs.init.usePackage = {
    evil = {
      enable = true;
      init = ''
        (setq evil-want-C-u-scroll t)
        (setq evil-want-integration t)
        (setq evil-want-keybinding nil)
        (setq evil-respect-visual-line-mode t)
        (setq evil-undo-system 'undo-tree)
      '';
      config = "(evil-mode)";
    };

    evil-collection = {
      enable = true;
      after = [ "evil" ];
      config = "(evil-collection-init)";
    };

    evil-escape = {
      enable = true;
      after = [ "evil" ];
      init = ''(setq-default evil-escape-key-sequence "fd")'';
      config = "(evil-escape-mode)";
    };

    evil-magit = {
      enable = usePackageCfg.evil.enable;
      after = [ "evil" "magit" ];
    };

    evil-smartparens = {
      enable = true;
      after = [ "evil" "smartparens" ];
      hook = [ "(smartparens-enabled . evil-smartparens-mode)" ];
    };

    evil-surround = {
      enable = true;
      after = [ "evil" ];
      config = "(global-evil-surround-mode)";
    };

    kubernetes-evil = {
      enable = usePackageCfg.kubernetes.enable;
      after = [ "kubernetes" "evil" ];
    };

    org-agenda.bindLocal.org-agenda-mode-map = {
      "j" = "evil-next-line";
      "k" = "evil-previous-line";
      "C-u" = "evil-scroll-page-up";
      "C-d" = "evil-scroll-page-down";
      "C-w h" = "evil-window-left";
      "C-w l" = "evil-window-right";
    };

    org-evil = {
      enable = true;
      hook = [ "(org-mode . org-evil-mode)" ];
    };

    treemacs-evil = {
      enable = usePackageCfg.treemacs.enable;
      after = [ "treemacs" "evil" ];
    };
  };
}
