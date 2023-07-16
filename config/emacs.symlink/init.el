(require 'package)
(add-to-list 'package-archives '("gnu-devel" . "https://elpa.gnu.org/devel/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/"))
(package-initialize)

(setq image-types (cons 'svg image-types))
(setq custom-file "~/.config/emacs/custom.el")
(load custom-file)

(global-hl-line-mode t)
(tool-bar-mode -1)
(when (eq system-type 'darwin)
  (set-face-attribute 'default nil
		      :family "JetBrains Mono"
		      :height 150) ;; default font size (point * 10)
  )

(setq use-package-always-ensure t)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package)) ;; This is only needed once, near the top of the file

;;;; Mouse scrolling in terminal emacs
(unless (display-graphic-p)
  ;; activate mouse-based scrolling
  (xterm-mouse-mode 1)
  (global-set-key (kbd "<mouse-4>") 'scroll-down-line)
  (global-set-key (kbd "<mouse-5>") 'scroll-up-line)
  )

(use-package auto-package-update
  :config
  (setq auto-package-update-delete-old-versions t
	auto-package-update-hide-results t)
  (auto-package-update-maybe))

(use-package nerd-icons)
(use-package modus-themes
  :config
  (setq modus-themes-italic-constructs t
	modus-themes-bold-constructs t
	modus-themes-mixed-fonts t
	modus-themes-prompts '(italic bold)
	)
  (load-theme 'modus-vivendi-tinted :no-confirm)
  (define-key global-map (kbd "<f5>") #'modus-themes-toggle))

(use-package doom-modeline
  :init (setq doom-modeline-icon t)
  :config (doom-modeline-mode 1))

(use-package which-key
  :config
  (which-key-setup-side-window-right-bottom)
  (which-key-mode))

(use-package evil
  :after lsp-mode
  :init
  (setq evil-want-keybinding nil)
  :custom
  (evil-split-window-below t)
  (evil-undo-system 'undo-redo)
  (evil-vsplit-window-right t)
  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-redo)
  (evil-define-key 'normal 'lsp-mode-map "K" 'lsp-ui-doc-glance)
  (evil-define-key 'normal 'lsp-mode-map "gr" 'lsp-find-references))
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
  :config
  (evil-collection-init)
  (evil-collection-unimpaired-mode))

(use-package helm
  :init
  (global-set-key (kbd "M-x") #'helm-M-x)
  (global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
  (global-set-key (kbd "C-x C-f") #'helm-find-files)
  :custom
  (helm-minibuffer-history-key "M-p")
  :config
  (setq completion-styles '(flex))
  (helm-mode 1))

(use-package elisp-autofmt
  :commands (elisp-autofmt-mode elisp-autofmt-buffer)
  :hook (emacs-lisp-mode . elisp-autofmt-mode))

(use-package company
  :after lsp-mode
  :hook (prog-mode . company-mode)
  :bind (:map company-active-map
	      ("C-n" . company-select-next)
	      ("C-p" . company-select-previous)
	      ("<tab>" . company-complete-selection))
	(:map lsp-mode-map
		("<tab>" . company-indent-or-complete-common))
  :config
  (setq company-idle-delay 0.3
	company-minimum-prefix-length 3)
  (global-company-mode t))
(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package lsp-mode
  :init (setq lsp-keymap-prefix "C-c l") ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  :custom (lsp-elixir-local-server-command "/opt/homebrew/bin/elixir-ls")
  :hook ((haskell-mode . lsp-deferred)
	 (go-mode . lsp-deferred)
	 (elixir-mode . lsp-deferred))
         ;; if you want which-key integration
         ;;(lsp-mode . lsp-enable-which-key-integration))
  :commands (lsp lsp-deferred))
(use-package lsp-ui
  :custom (lsp-ui-doc-position 'at-point)
  :hook (lsp-mode . lsp-ui-mode))
(use-package helm-lsp
  :after lsp-mode
  :init
  (define-key lsp-mode-map [remap xref-find-apropos] #'helm-lsp-workspace-symbol))
(use-package lsp-haskell)
(use-package go-mode)
(use-package elixir-mode)
(use-package lsp-pyright
  :hook (python-mode . (lambda ()
			 (require 'lsp-pyright)
			 (lsp-deferred))))

(use-package projectile
  :init (projectile-mode +1)
  :custom
  (projectile-project-search-path '(("~/prj" . 3)))
  :bind (:map projectile-mode-map
	      ("s-p" . projectile-command-map)
	      ("C-c p" . projectile-command-map)))
