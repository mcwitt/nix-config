{ config, lib, pkgs, ... }:
with lib;
let usePackageCfg = config.programs.emacs.init.usePackage;
in
{
  programs.emacs.init = {
    prelude = ''
      (defvar org-notes-directory (file-name-as-directory "~/src/org-notes/"))
      (defvar org-notes-gtd-directory (file-name-as-directory (concat org-notes-directory "gtd")))
      (defvar org-notes-gtd-inbox-file (concat org-notes-gtd-directory "inbox.org"))
      (defvar org-notes-gtd-projects-file (concat org-notes-gtd-directory "gtd.org"))
      (defvar org-notes-gtd-habits-file (concat org-notes-gtd-directory "habits.org"))
      (defvar org-notes-gtd-someday-file (concat org-notes-gtd-directory "someday.org"))
      (defvar org-notes-flashcards-file (concat org-notes-gtd-directory "flash-cards.org"))
      (defvar org-notes-bookmarks-file (concat org-notes-directory "bookmarks.org"))
      (defvar org-notes-journal-file (concat org-notes-directory "journal.org"))
      (defvar org-notes-notes-directory (concat org-notes-directory (file-name-as-directory "notes")))
      (defvar org-notes-references-directory (concat org-notes-directory (file-name-as-directory "references")))

      (defun org-notes-display-bookmarks-in-side-window ()
        "Display org-notes bookmarks file in a side window."
        (interactive)
        (select-window
         (display-buffer-in-side-window
          (find-file-noselect org-notes-bookmarks-file) nil)))

      (defun org-notes-open-journal ()
        "Open org-notes journal file."
        (interactive)
        (find-file org-notes-journal-file))

      (defun org-notes-gtd-open-projects ()
        "Open org-notes gtd projects file."
        (interactive)
        (find-file org-notes-gtd-projects-file))

      (defun org-notes-maybe-sync ()
        "Sync org notes if the current buffer is visiting an org file in the org-notes directory."
        (when (and (derived-mode-p 'org-mode)
                   (string-prefix-p (expand-file-name org-notes-directory)
                                    (buffer-file-name)))
          (org-notes-sync)))

      (defun org-notes-sync ()
        "Sync org notes repo with upstream."
        (interactive)
        (let ((default-directory org-notes-directory))
          (git-sync)))

      (defun org-notes-save-and-sync ()
        "Save all org buffers and sync gtd repo."
        (interactive)
        (org-save-all-org-buffers)
        (org-notes-sync))
    '';

    usePackage = {
      biblio = {
        enable = true;
        after = [ "org" ];
        config = ''
          (setq biblio-download-directory
                (file-name-as-directory
                 (concat org-notes-references-directory "bibtex-pdfs")))
        '';
      };

      bibtex-completion = {
        enable = true;
        after = [ "org" ];
        config = ''
          (setq bibtex-completion-bibliography
                (concat org-notes-references-directory "master.bib"))
          (setq bibtex-completion-library-path
                (concat org-notes-references-directory "bibtex-pdfs"))
          (setq bibtex-completion-notes-path
                (concat org-notes-references-directory "helm-bibtex-notes"))
        '';
      };

      cdlatex = {
        enable = true;
        command = [ "turn-on-cdlatex" ];
      };

      company-org-roam = {
        enable = true;
        after = [ "company" ];
        config = "(add-to-list 'company-backends 'company-org-roam)";
      };

      deft = {
        enable = true;
        after = [ "org" ];
        config = ''
          (setq deft-auto-save-interval 0
                deft-recursive t
                deft-use-filter-string-for-filename t
                deft-default-extension "org"
                deft-directory org-notes-notes-directory)
        '';
      };

      git-sync = {
        enable = true;
        package = epkgs:
          epkgs.trivialBuild {
            pname = "git-sync";
            version = "2020-11-22";
            src = pkgs.writeText "git-sync.el" ''
              ;;; Package --- Summary
              ;;; Commentary:
              ;;; Code:

              (defvar git-sync-command "git-annex add . && git-annex sync")
              (defvar git-sync-buffer-name (concat "*async " git-sync-command "*"))

              (defun git-sync-sentinel (process event)
                "Watches the git-sync PROCESS for an EVENT indicating a successful sync and closes the window."
                (message event)
                (cond ((string-match-p "finished" event)
                       (message (concat git-sync-command " successful"))
                       (kill-buffer git-sync-buffer-name))
                      ((string-match-p "\\(exited\\|dumped\\)" event)
                       (message (concat git-sync-command " failed"))
                       (when
                           (yes-or-no-p
                            (concat "Error running '" git-sync-command "'. Switch to output?"))
                         (switch-to-buffer git-sync-buffer-name)))))

              (defun git-sync ()
                "Run git-sync as an async process."
                (interactive)
                (if (get-buffer git-sync-buffer-name)
                    (message "git sync already in progress (kill the `%s' buffer to reset)" git-sync-buffer-name)
                  (let* ((process (start-process-shell-command
                                   git-sync-command
                                   git-sync-buffer-name
                                   git-sync-command)))
                    (set-process-sentinel process 'git-sync-sentinel))))

              (provide 'git-sync)
              ;;; git-sync.el ends here
            '';
          };
      };

      ob-restclient = {
        enable = true;
        after = [ "org-babel" "restclient" ];
      };

      org = {
        enable = true;
        package = epkgs: epkgs.org-plus-contrib;
        bind = {
          "C-c o a" = "org-agenda";
          "C-c o c" = "org-capture";
          "C-c o b" = "org-notes-display-bookmarks-in-side-window";
          "C-c o j" = "org-notes-open-journal";
          "C-c o l" = "org-store-link";
          "C-c o o" = "org-notes-gtd-open-projects";
          "C-c o s" = "org-notes-save-and-sync";
          "C-c C-x l" = "org-toggle-link-display";
        };
        hook = [
          "(org-mode . turn-on-visual-line-mode)"
          "(org-mode . turn-on-flyspell)"
          "(after-save . org-notes-maybe-sync)"
          "(org-babel-after-execute . org-redisplay-inline-images)"
        ];
        config = ''
          (require 'git-sync)

          (setq org-hide-emphasis-markers t)
          (setq org-startup-indented t)
          (setq org-tags-column 0) ; don't try to align tags
          (setq org-todo-keywords '((sequence "TODO" "NEXT" "BLOCKED" "REVIEW" "|" "DONE")))
          (setq org-tag-persistent-alist '(("PROJECT" . ?P) (:startgroup) ("@home" . ?h) ("@work" . ?w)))
          (setq org-tags-sort-function #'string<)
          (setq org-confirm-babel-evaluate nil)
          (setq org-log-into-drawer t)

          (add-to-list 'org-file-apps '("\\.pdf\\'" . emacs))
          (add-to-list 'org-file-apps-gnu '(t . "xdg-open %s")) ; use xdg-open as default (replaces mailcap)
          (add-to-list 'org-modules 'org-habit)

          ;; Display centered dots for list bullets
          (font-lock-add-keywords 'org-mode
                                  '(("^ *\\([-]\\) "
                                     (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

          (setq org-format-latex-options (plist-put org-format-latex-options :scale 1.2))

          (org-babel-do-load-languages
           'org-babel-load-languages
           '((R          . t)
             (calc       . t)
             (dot        . t)
             (emacs-lisp . t)
             (haskell    . t)
             (jupyter    . t)
             (latex      . t)
             (restclient . t)
             (shell      . t)))

          ;; Export settings
          (with-eval-after-load 'ox-latex
            (setq org-latex-listings 'minted)
            (setq org-latex-pdf-process '("latexmk -shell-escape -bibtex -f -pdf -output-directory=%o %f"))
            (add-to-list 'org-latex-packages-alist '("newfloat" "minted")))
        '';
      };

      org-agenda = {
        enable = true;
        after = [ "org" ];
        config = ''
          (setq org-agenda-files
                (list org-notes-gtd-inbox-file
                      org-notes-gtd-projects-file
                      org-notes-gtd-habits-file))
          (setq org-agenda-custom-commands
                '(("i" "Inbox" alltodo "" ((org-agenda-files (list org-notes-gtd-inbox-file))))
                  ("p" "Projects" tags "LEVEL=2+PROJECT" ((org-agenda-files (list org-notes-gtd-projects-file))))
                  ("n" "Next tasks"  tags-todo "TODO=\"NEXT\"")))
          (setq org-refile-targets
                (let '(targets (append (list org-notes-gtd-someday-file) org-agenda-files))
                  `((,targets :maxlevel . 2))))
          (setq org-stuck-projects
                '("LEVEL=2+PROJECT-TODO=DONE"
                  ("NEXT")
                  nil
                  ""))
          (setq org-enforce-todo-dependencies t)
        '';
      };

      org-capture = {
        enable = true;
        after = [ "org" ];
        config = ''
          (setq org-capture-templates
                '(("t" "Todo" entry
                   (file org-notes-gtd-inbox-file)
                   "* TODO %?\n%U\n")
                  ("b" "Bookmark" entry
                   (file+headline org-notes-bookmarks-file "Bookmarks")
                   "* [[%^{url}][%?]]\n%U\n")
                  ("j" "Journal" entry
                   (file+olp+datetree org-notes-journal-file)
                   "* %?\nEntered on %U\n  %i\n  %a")
                  ("f" "Flash card" entry
                   (file+headline org-notes-flashcards-file "Flash cards")
                   "* %?\n:PROPERTIES:\n:ANKI_NOTE_TYPE: %^{Note type|Basic}\n:ANKI_DECK: %^{Deck|Misc}\n:END:\n** Front\n** Back")))
        '';
      };

      org-download = {
        enable = true;
        after = [ "org" ];
        bindLocal.org-mode-map = {
          s-Y = "org-download-screenshot";
          s-y = "org-download-yank";
        };
      };

      org-pomodoro = {
        enable = true;
        after = [ "org-agenda" ];
        bindLocal.org-agenda-mode-map.p = "org-pomodoro";
      };

      org-ref = {
        enable = true;
        after = [ "org" ];
        config = ''
          (setq reftex-default-bibliography
                (list (concat org-notes-references-directory "master.bib")))
          (setq org-ref-bibliography-notes
                (concat org-notes-references-directory "notes.org"))
          (setq org-ref-default-bibliography
                (list (concat org-notes-references-directory "master.bib")))
          (setq org-ref-pdf-directory
                (concat org-notes-references-directory
                        (file-name-as-directory "bibtex-pdfs")))
        '';
      };

      org-roam = {
        enable = true;
        after = [ "org" ];
        hook = [ "(after-init . org-roam-mode)" ];
        bindLocal = {
          org-roam-mode-map = {
            "C-c n l" = "org-roam";
            "C-c n f" = "org-roam-find-file";
            "C-c n g" = "org-roam-graph";
          };
          org-mode-map = {
            "C-c n i" = "org-roam-insert";
            "C-c n I" = "org-roam-insert-immediate";
          };
        };
        config = ''
          (setq org-roam-directory org-notes-notes-directory)
          (require 'org-roam-protocol)
        '';
      };

      org-roam-bibtex = {
        enable = true;
        hook = [ "(org-roam-mode . org-roam-bibtex-mode)" ];
        bindLocal.org-mode-map."C-c n a" = "org-note-actions";
      };

      org-superstar = {
        enable = true;
        hook = [ "(org-mode . org-superstar-mode)" ];
      };

      org-variable-pitch = {
        enable = true;
        config = "(setq org-variable-pitch-fixed-faces nil)";
        hook = [ "(org-mode . org-variable-pitch-minor-mode)" ];
      };

      ox-gfm.enable = true;

      ox-pandoc.enable = true;
    };
  };
}