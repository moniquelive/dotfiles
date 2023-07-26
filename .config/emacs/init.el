(with-eval-after-load "~/.config/emacs/gcmh.el"
  (gcmh-mode 1))

(defun my-message-with-timestamp (old-func fmt-string &rest args)
   "Prepend current timestamp (with microsecond precision) to a message"
   (apply old-func
          (concat (format-time-string "[%F %T.%3N %Z] ")
                   fmt-string)
          args))
(advice-add 'message :around #'my-message-with-timestamp)

(require 'package)
(add-to-list 'package-archives '("gnu-devel" . "https://elpa.gnu.org/devel/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/"))
(package-initialize)

(setq image-types (cons 'svg image-types))
(setq custom-file "~/.config/emacs/custom.el")
(load custom-file)

;; GLOBAL settings
(file-name-shadow-mode 1)
(global-hl-line-mode 1)
(global-auto-revert-mode 1)
(tool-bar-mode -1)
(when (eq system-type 'darwin)
  (set-face-attribute 'default nil
		      :family "JetBrains Mono"
		      :height 150) ;; default font size (point * 10)
  (setq dired-use-ls-dired t
        insert-directory-program "/opt/homebrew/bin/gls"
        dired-listing-switches "-aBhl --group-directories-first"))
(add-hook 'dired-mode-hook 'dired-hide-details-mode)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;;;; Mouse scrolling in terminal emacs
(unless (display-graphic-p)
  ;; activate mouse-based scrolling
  (xterm-mouse-mode 1)
  (global-set-key (kbd "<mouse-4>") 'scroll-down-line)
  (global-set-key (kbd "<mouse-5>") 'scroll-up-line))

;;
;; Packages
;;
(setq use-package-always-ensure t)
;; (setq use-package-verbose t)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package)) ;; This is only needed once, near the top of the file

;; first one please
(use-package no-littering)

(use-package auto-package-update
  :config
  (setq auto-package-update-delete-old-versions t
        auto-package-update-hide-results t)
  (auto-package-update-maybe))

(use-package rainbow-delimiters :hook (prog-mode . rainbow-delimiters-mode))
(use-package nerd-icons)
(use-package modus-themes
  :config
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-mixed-fonts t
        modus-themes-prompts '(italic bold))
  (load-theme 'modus-vivendi-tinted :no-confirm)
  (define-key global-map (kbd "<f5>") #'modus-themes-toggle))

(use-package doom-modeline
  :config (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :custom
    ((which-key-popup-type 'side-window)
     (which-key-side-window-location '(right bottom))
     (which-key-side-window-max-width 0.5))
  :config
    (which-key-mode))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :config
  (global-set-key (kbd "C-h f") #'helpful-callable)
  (global-set-key (kbd "C-h v") #'helpful-variable)
  (global-set-key (kbd "C-h k") #'helpful-key)
  (global-set-key (kbd "C-h x") #'helpful-command))

(use-package evil
  :custom
    (evil-want-keybinding nil)
    (evil-want-integration t)
    (evil-undo-system 'undo-redo)
    (evil-split-window-below t)
    (evil-vsplit-window-right t)
    (evil-cross-lines t)
    (evil-start-of-line t)
  :config
    (evil-mode 1)
    (evil-global-set-key 'normal "-" 'dired-jump)
    (evil-set-undo-system 'undo-redo))
(use-package evil-leader
  :after evil
  :config
    (global-evil-leader-mode)
    (evil-leader/set-key
    (kbd "RET") 'evil-ex-nohighlight
    "\\" 'evil-buffer))
(use-package evil-surround
  :after evil
  :config (global-evil-surround-mode 1))
(use-package evil-collection
  :after evil
  :config (evil-collection-init))

(use-package vertico
  :init
  (vertico-mode 1)
  (setq vertico-scroll-margin 0)
  (setq vertico-count 20)
  (setq vertico-resize nil)
  (setq vertico-cycle t)
  :hook
  (rfn-eshadow-update-overlay . vertico-directory-tidy))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist :init (savehist-mode))

;; A few more useful configurations...
(use-package emacs
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
  ;; Vertico commands are hidden in normal buffers.
  (setq read-extended-command-predicate #'command-completion-default-include-p)
  (setq enable-recursive-minibuffers t))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
	orderless-component-separator #'orderless-escapable-split-on-space
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

(use-package elisp-autofmt
  :commands (elisp-autofmt-mode elisp-autofmt-buffer)
  :hook (emacs-lisp-mode . elisp-autofmt-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init (setq lsp-keymap-prefix "C-c l")
  :hook (
         (go-mode . lsp)
         (haskell-mode . lsp)
         (elixir-mode . lsp)
         (csharp-mode . lsp)
         (python-mode . lsp)
         (lsp-mode . lsp-enable-which-key-integration))
  :config
    (lsp-enable-which-key-integration t)
    (evil-define-key 'normal 'lsp-mode-map "K" 'lsp-ui-doc-glance)
    (evil-define-key 'normal 'lsp-mode-map "gr" 'lsp-find-references))
(use-package lsp-ui
  :custom (lsp-ui-doc-position 'at-point)
  :hook (lsp-mode . lsp-ui-mode))
(use-package csharp-mode
  :custom (lsp-csharp-omnisharp-roslyn-binary-path "/Users/cyber/.dotnet/omnisharp/OmniSharp")
  :hook (csharp-mode . lsp-deferred))
(use-package elixir-mode
  :custom (lsp-elixir-local-server-command "/opt/homebrew/bin/elixir-ls")
  :hook (elixir-mode . lsp-deferred))
(use-package go-mode
  :mode ("\\.go\\'" . go-mode)
  :hook (go-mode . lsp-deferred)
	(before-save . lsp-format-buffer)
	(before-save . lsp-organize-imports))
(use-package lsp-haskell
  :custom
  (lsp-haskell-server-path "~/.ghcup/bin/haskell-language-server-wrapper")
  :hook (haskell-mode . lsp-deferred))
(use-package python
  :mode ("\\.py\\'" . python-mode)
  :interpreter ("python" . python-mode))
(use-package lsp-pyright
  :after python-mode
  :hook (python-mode . (lambda ()
			 (require 'lsp-pyright)
			 (lsp-deferred))))
(use-package pyvenv
  :after python-mode
  :config (pyvenv-mode 1))
(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)
          ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
          ("<tab>" . company-indent-or-complete-common))
  :custom
    (company-idle-delay 0.3)
    (company-minimum-prefix-length 3))
(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package projectile
  :diminish projectile-mode
  :init
    (when (file-directory-p "~/prj")
      (setq projectile-project-search-path '("~/prj")))
    (setq projectile-switch-project-action #'projectile-dired)
  :bind-keymap
    (("s-p" . projectile-command-map)
		 ("C-c p" . projectile-command-map))
  :config (projectile-mode))

(use-package dashboard
  :init (setq dashboard-projects-backend 'projectile
	      dashboard-items '((recents . 10)
                          (bookmarks . 5)
                          (projects . 5)
                          (registers . 5))
	      dashboard-set-navigator t
	      dashboard-center-content t
	      dashboard-display-icons-p t
	      dashboard-set-heading-icons t
	      dashboard-icon-type 'nerd-icons)
  :config (dashboard-setup-startup-hook))

;; Magit
(use-package magit
  :commands magit-status
  :bind (("C-x g" . magit-status)
         ("C-x C-g" . magit-status)))

;; Treemacs
(use-package treemacs
  :commands (treemacs treemacs-select-window)
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
	  treemacs-deferred-git-apply-delay        0.5
	  treemacs-directory-name-transformer      #'identity
	  treemacs-display-in-side-window          t
	  treemacs-eldoc-display                   'simple
	  treemacs-file-event-delay                2000
	  treemacs-file-extension-regex            treemacs-last-period-regex-value
	  treemacs-file-follow-delay               0.2
	  treemacs-file-name-transformer           #'identity
	  treemacs-follow-after-init               t
	  treemacs-expand-after-init               t
	  treemacs-find-workspace-method           'find-for-file-or-pick-first
	  treemacs-git-command-pipe                ""
	  treemacs-goto-tag-strategy               'refetch-index
	  treemacs-header-scroll-indicators        '(nil . "^^^^^^")
	  treemacs-hide-dot-git-directory          t
	  treemacs-indentation                     2
	  treemacs-indentation-string              " "
	  treemacs-is-never-other-window           nil
	  treemacs-max-git-entries                 5000
	  treemacs-missing-project-action          'ask
	  treemacs-move-forward-on-expand          nil
	  treemacs-no-png-images                   nil
	  treemacs-no-delete-other-windows         t
	  treemacs-project-follow-cleanup          nil
	  treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
	  treemacs-position                        'left
	  treemacs-read-string-input               'from-child-frame
	  treemacs-recenter-distance               0.1
	  treemacs-recenter-after-file-follow      nil
	  treemacs-recenter-after-tag-follow       nil
	  treemacs-recenter-after-project-jump     'always
	  treemacs-recenter-after-project-expand   'on-distance
	  treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask" "/venv")
	  treemacs-project-follow-into-home        nil
	  treemacs-show-cursor                     nil
	  treemacs-show-hidden-files               t
	  treemacs-silent-filewatch                nil
	  treemacs-silent-refresh                  nil
	  treemacs-sorting                         'alphabetic-asc
	  treemacs-select-when-already-in-treemacs 'move-back
	  treemacs-space-between-root-nodes        t
	  treemacs-tag-follow-cleanup              t
	  treemacs-tag-follow-delay                1.5
	  treemacs-text-scale                      nil
	  treemacs-user-mode-line-format           nil
	  treemacs-user-header-line-format         nil
	  treemacs-wide-toggle-width               70
	  treemacs-width                           35
	  treemacs-width-increment                 1
	  treemacs-width-is-initially-locked       t
	  treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map treemacs-mode-map
	("<backtab>" . nil))
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("<backtab>" . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil :after (treemacs evil))
(use-package treemacs-projectile :after (treemacs projectile))
(use-package treemacs-icons-dired :hook (dired-mode . treemacs-icons-dired-enable-once))
(use-package treemacs-magit :after (treemacs magit))

(advice-remove 'message #'my-message-with-timestamp)
