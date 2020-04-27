{ emacs, emacsPackagesGen }:
let emacsWithPackages = (emacsPackagesGen emacs).emacsWithPackages;
in emacsWithPackages (epkgs:
  with epkgs; [
    all-the-icons
    anaconda-mode
    anki-editor
    auctex
    browse-at-remote
    cdlatex
    company
    company-anaconda
    company-lsp
    company-org-roam
    company-restclient
    counsel
    counsel-projectile
    counsel-tramp
    dap-mode
    deft
    delight
    dhall-mode
    direnv
    doom-themes
    erc-hl-nicks
    erc-image
    ess
    esup
    evil
    evil-collection
    evil-escape
    evil-magit
    evil-smartparens
    evil-surround
    exec-path-from-shell
    fira-code-mode
    flycheck
    format-all
    general
    gist
    haskell-mode
    haskell-snippets
    hl-todo
    ivy
    ivy-bibtex
    json-mode
    jupyter
    logview
    lsp-haskell
    lsp-ivy
    lsp-mode
    lsp-treemacs
    lsp-ui
    magit
    markdown-mode
    mixed-pitch
    nix-mode
    nlinum-relative
    ob-restclient
    org-bullets
    org-evil
    org-noter
    org-plus-contrib
    org-pomodoro
    org-ref
    org-roam
    org-roam-bibtex
    ox-gfm
    pdf-tools
    pinentry
    posframe
    projectile
    proof-general
    pyenv-mode
    rainbow-delimiters
    restclient
    ripgrep
    sbt-mode
    scala-mode
    smartparens
    sql-indent
    treemacs
    treemacs-evil
    treemacs-icons-dired
    treemacs-magit
    treemacs-projectile
    use-package
    which-key
    yaml-mode
    yasnippet
    yasnippet-snippets
    zenburn-theme
  ])
