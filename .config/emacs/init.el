(toggle-debug-on-error)
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

(when (eq system-type 'darwin)
  (set-face-attribute 'default nil
		      :family "JetBrains Mono"
		      :weight 'light
		      :height 150) ;; default font size (point * 10)
  (defconst jetbrains-ligature-mode--ligatures
    '("-->" "//" "/**" "/*" "*/" "<!--" ":=" "->>" "<<-" "->" "<-"
      "<=>" "==" "!=" "<=" ">=" "=:=" "!==" "&&" "||" "..." ".."
      "|||" "///" "&&&" "===" "++" "--" "=>" "|>" "<|" "||>" "<||"
      "|||>" "<|||" ">>" "<<" "::=" "|]" "[|" "{|" "|}"
      "[<" ">]" ":?>" ":?" "/=" "[||]" "!!" "?:" "?." "::"
      "+++" "??" "###" "##" ":::" "####" ".?" "?=" "=!=" "<|>"
      "<:" ":<" ":>" ">:" "<>" "***" ";;" "/==" ".=" ".-" "__"
      "=/=" "<-<" "<<<" ">>>" "<=<" "<<=" "<==" "<==>" "==>" "=>>"
      ">=>" ">>=" ">>-" ">-" "<~>" "-<" "-<<" "=<<" "---" "<-|"
      "<=|" "/\\" "\\/" "|=>" "|~>" "<~~" "<~" "~~" "~~>" "~>"
      "<$>" "<$" "$>" "<+>" "<+" "+>" "<*>" "<*" "*>" "</>" "</" "/>"
      "<->" "..<" "~=" "~-" "-~" "~@" "^=" "-|" "_|_" "|-" "||-"
      "|=" "||=" "#{" "#[" "]#" "#(" "#?" "#_" "#_(" "#:" "#!" "#="
      "&="))

  (sort jetbrains-ligature-mode--ligatures (lambda (x y) (> (length x) (length y))))

  (dolist (pat jetbrains-ligature-mode--ligatures)
    (set-char-table-range composition-function-table
			  (aref pat 0)
			  (nconc (char-table-range composition-function-table (aref pat 0))
				 (list (vector (regexp-quote pat)
                                               0
					       'compose-gstring-for-graphic)))))
  (setq dired-use-ls-dired t
        insert-directory-program "/opt/homebrew/bin/gls"
        dired-listing-switches "-aBhl --group-directories-first"))

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
(use-package no-littering
  :config (push (expand-file-name "tree-sitter/" no-littering-var-directory) treesit-extra-load-path))

;; A few more useful configurations...
(use-package emacs
  :delight
  (auto-fill-function " AF")
  :custom
  (make-backup-files nil)
  (mouse-wheel-tilt-scroll t)
  (truncate-lines t)
  (save-place-mode t)
  (ns-function-modifier 'hyper)
  (explicit-shell-file-name "/bin/zsh")
  :hook
  (prog-mode . display-line-numbers-mode)
  (dired-mode . dired-hide-details-mode)
  (minibuffer-setup . cursor-intangible-mode)
  (focus-out . (lambda () (save-some-buffers t))) ;; autosave on buffer focus lost
  (ibuffer . (lambda ()
	       (ibuffer-vc-set-filter-groups-by-vc-root)
	       (unless (eq ibuffer-sorting-mode 'alphabetic)
		 (ibuffer-do-sort-by-alphabetic))))
  :bind
  (("<escape>" . keyboard-escape-quit) ;; Make ESC quit prompts
   ("s-b" . ibuffer)
   ("s-k" . kill-this-buffer)
   ("s-n" . next-buffer))
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

  ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
  ;; Vertico commands are hidden in normal buffers.
  (setq read-extended-command-predicate #'command-completion-default-include-p
	;; Do not allow the cursor in the minibuffer prompt
	minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt)
	enable-recursive-minibuffers t
	image-types (cons 'svg image-types)
	custom-file "~/.config/emacs/custom.el")
  :config
  (set-language-environment "UTF-8")
  (load custom-file)
  (file-name-shadow-mode 1)
  (mouse-wheel-mode 1)
  (global-auto-revert-mode 1)
  (global-hl-line-mode 1)
  (global-visual-line-mode -1)
  (tool-bar-mode -1)
  (server-mode 1))

(use-package tree-sitter
  :delight
  :hook
  ((bash-mode 
    c-sharp-mode 
    c-mode 
    cmake-mode 
    cpp-mode 
    css-mode 
    dockerfile-mode 
    elisp-mode 
    elixir-mode 
    elm-mode 
    go-mod-mode 
    go-mode 
    heex-mode 
    html-mode 
    js-mode
    js2-mode 
    json-mode
    lua-mode
    make-mode
    markdown-mode
    org-mode
    perl-mode
    python-mode 
    ruby-mode
    rust-mode 
    sh-mode
    sql-mode
    terraform-mode
    toml-mode 
    typescript-mode 
    yaml-mode) . siren-tree-sitter-mode-enable)
  :preface (defun siren-tree-sitter-mode-enable () (tree-sitter-mode t))
  :defer t)

(use-package tree-sitter-langs
  ;; https://github.com/casouri/tree-sitter-module
  :hook (tree-sitter-after-on . tree-sitter-hl-mode))

(use-package auto-package-update
  :custom (auto-package-update-delete-old-versions t)
  :config (auto-package-update-maybe))

(use-package delight
  :config
  (delight '((eldoc-mode nil "eldoc")
	     (flymake-mode nil "Flymake"))))
(use-package rainbow-delimiters :hook (prog-mode . rainbow-delimiters-mode))
(use-package nerd-icons)
(use-package nerd-icons-completion
  :after (nerd-icons marginalia)
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup)
  :config (nerd-icons-completion-mode))

(use-package vterm
  :custom
  (vterm-kill-buffer-on-exit t))

(use-package ibuffer-vc
  :config (ibuffer-vc-set-filter-groups-by-vc-root))

(use-package keycast
  :config
  (define-minor-mode keycast-mode
    "Show current command and its key binding in the mode line."
    :global t
    (if keycast-mode
        (add-hook 'pre-command-hook 'keycast--update t)
      (remove-hook 'pre-command-hook 'keycast--update)))

  (add-to-list 'global-mode-string '("" keycast-mode-line))
  (keycast-mode 1))

(use-package base16-theme
  :custom
  (base16-theme-highlight-mode-line 'box)
  (base16-theme-256-color-source 'colors)
  :config
  (load-theme 'base16-rose-pine-moon t)
  ;; Set the cursor color based on the evil state
  (defvar my/base16-colors base16-rose-pine-moon-theme-colors)
  (setq evil-emacs-state-cursor   `(,(plist-get my/base16-colors :base0D) box)
	evil-insert-state-cursor  `(,(plist-get my/base16-colors :base0D) bar)
	evil-motion-state-cursor  `(,(plist-get my/base16-colors :base0E) box)
	evil-normal-state-cursor  `(,(plist-get my/base16-colors :base0B) box)
	evil-replace-state-cursor `(,(plist-get my/base16-colors :base08) bar)
	evil-visual-state-cursor  `(,(plist-get my/base16-colors :base09) box)))

(use-package doom-modeline
  :custom
  (doom-modeline-height 25)
  (doom-modeline-minor-modes t)
  :config (doom-modeline-mode 1))

(use-package which-key
  :delight
  :defer 0
  :custom
  ((which-key-use-C-h-commands nil)
   (which-key-popup-type 'side-window)
   (which-key-side-window-location 'bottom)
   (which-key-side-window-max-width 0.5)
   (which-key-side-window-max-height 0.5))
  :config (which-key-mode))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind (("C-h f" . helpful-callable)
	 ("C-h v" . helpful-variable)
	 ("C-h k" . helpful-key)
	 ("C-h x" . helpful-command)))

(use-package consult
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command) ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer) ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame) ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)	;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer) ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store) ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop) ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake) ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)	 ;; orig. goto-line
         ("M-g M-g" . consult-goto-line) ;; orig. goto-line
         ("M-g o" . consult-outline) ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-fd)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history) ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history) ;; orig. isearch-edit-string
         ;; ("M-s l" . consult-line) ;; needed by consult-line to detect isearch
         ;; ("M-s L" . consult-line-multi)	;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history) ;; orig. next-matching-history-element
         ("M-r" . consult-history)) ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  :config

  (defun consult--fd-builder (input)
    (let ((fd-command
           (if (eq 0 (process-file-shell-command "fdfind")) "fdfind" "fd")))
      (pcase-let* ((`(,arg . ,opts) (consult--command-split input))
                   (`(,re . ,hl) (funcall consult--regexp-compiler
                                          arg 'extended t)))
	(when re
          (cons (append (list fd-command "--color=never" "--full-path" (consult--join-regexps re 'extended)) opts)
		hl)))))

  (defun consult-fd (&optional dir initial)
    (interactive "P")
    (pcase-let* ((`(,prompt ,paths ,dir) (consult--directory-prompt "Fd" dir))
		 (default-directory dir))
      (find-file (consult--find prompt #'consult--fd-builder initial))))

  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"
  (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'embark-prefix-help-command)

  (autoload 'projectile-project-root "projectile")
  (setq consult-project-function (lambda (_) (projectile-project-root))))

(use-package undo-tree
  :delight
  :custom
  (undo-tree-auto-save-history t)
  :config (global-undo-tree-mode 1))
(use-package evil
  :delight
  :custom
  (evil-want-keybinding nil)
  (evil-want-integration t)
  (evil-undo-system 'undo-tree)
  (evil-split-window-below t)
  (evil-vsplit-window-right t)
  (evil-cross-lines t)
  (evil-start-of-line t)
  :config
  (evil-mode 1)
  (evil-global-set-key 'normal "-" 'dired-jump)
  (evil-global-set-key 'normal (kbd "C-.") nil)
  (evil-global-set-key 'normal (kbd "C-6") nil)

  (setq
   original-background (face-attribute 'mode-line :background)
   emacs-state-background "#31748f")
  (add-hook 'evil-emacs-state-entry-hook
	    (lambda () (set-face-attribute 'mode-line nil :background emacs-state-background)))
  (add-hook 'evil-emacs-state-exit-hook
	    (lambda () (set-face-attribute 'mode-line nil :background original-background))))
(use-package evil-leader
  :after (evil evil-search-highlight-persist)
  :config
  (global-evil-leader-mode)
  (evil-leader/set-key
    (kbd "RET") 'evil-search-highlight-persist-remove-all
    "\\" 'evil-buffer))
(use-package evil-search-highlight-persist
  :after evil
  :config (global-evil-search-highlight-persist t))
(use-package evil-surround
  :after evil
  :config (global-evil-surround-mode 1))
(use-package evil-collection
  :delight evil-collection-unimpaired-mode
  :after evil
  :config (evil-collection-init))
(use-package evil-nerd-commenter
  :after evil
  :config
  (evil-define-key 'normal 'prog-mode-map "gcc" 'evilnc-comment-or-uncomment-lines)
  (evil-define-key 'visual 'prog-mode-map "gc" 'evilnc-comment-or-uncomment-lines))

(use-package vertico
  :custom
  (vertico-scroll-margin 0)
  (vertico-count 15)
  (vertico-resize nil)
  (vertico-cycle t)
  :init (vertico-mode 1)
  :config (vertico-mouse-mode 1)
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist :init (savehist-mode))

(use-package orderless
  :config
  (setq completion-styles '(orderless basic)
	orderless-matching-styles '(orderless-literal orderless-initialism orderless-regexp)
	orderless-component-separator #'orderless-escapable-split-on-space
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia :init (marginalia-mode))

(use-package embark
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :hook
  (eldoc-documentation-functions . embark-eldoc-first-target)
  :init
  (setq prefix-help-command #'embark-prefix-help-command
	eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)
  :config
  (defun embark-which-key-indicator ()
    "An embark indicator that displays keymaps using which-key.
    The which-key help message will show the type and value of the
    current target followed by an ellipsis if there are further
    targets."
    (lambda (&optional keymap targets prefix)
      (if (null keymap)
          (which-key--hide-popup-ignore-command)
	(which-key--show-keymap
	 (if (eq (plist-get (car targets) :type) 'embark-become)
             "Become"
           (format "Act on %s '%s'%s"
                   (plist-get (car targets) :type)
                   (embark--truncate-target (plist-get (car targets) :target))
                   (if (cdr targets) "…" "")))
	 (if prefix
             (pcase (lookup-key keymap prefix 'accept-default)
               ((and (pred keymapp) km) km)
               (_ (key-binding prefix 'accept-default)))
           keymap)
	 nil nil t (lambda (binding)
                     (not (string-suffix-p "-argument" (cdr binding))))))))

  (setq embark-indicators
	'(embark-which-key-indicator
	  embark-highlight-indicator
	  embark-isearch-highlight-indicator))

  (defun embark-hide-which-key-indicator (fn &rest args)
    "Hide the which-key indicator immediately when using the completing-read prompter."
    (which-key--hide-popup-ignore-command)
    (let ((embark-indicators
           (remq #'embark-which-key-indicator embark-indicators)))
      (apply fn args)))

  (advice-add #'embark-completing-read-prompter
              :around #'embark-hide-which-key-indicator))
(use-package embark-consult
  :after (embark consult)
  :demand t
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package elisp-autofmt
  :commands (elisp-autofmt-mode elisp-autofmt-buffer)
  :hook (emacs-lisp-mode . elisp-autofmt-mode))

(use-package lsp-mode
  :delight lsp-mode
  :delight lsp-lens-mode nil lsp-lens
  :commands (lsp lsp-deferred)
  :custom (lsp-keymap-prefix "C-c l")
  :hook (lsp-mode . lsp-enable-which-key-integration)
  :config (lsp-enable-which-key-integration t)
  (evil-define-minor-mode-key 'normal 'lsp-mode "K" 'lsp-ui-doc-glance)
  (evil-define-minor-mode-key 'normal 'lsp-mode "gr" 'lsp-find-references))
(use-package lsp-ui
  :delight
  :custom
    (lsp-ui-doc-position 'at-point)
    (lsp-ui-sideline-enable t)
    (lsp-ui-sideline-show-diagnostics t)
    (lsp-ui-sideline-show-hover nil)
  :hook (lsp-mode . lsp-ui-mode))
(use-package dockerfile-mode
  :delight
  :hook (dockerfile-mode . lsp-deferred))
(use-package csharp-mode
  :delight
  :custom (lsp-csharp-omnisharp-roslyn-binary-path "/Users/cyber/.dotnet/omnisharp/OmniSharp")
  :hook (csharp-mode . lsp-deferred))
(use-package elixir-mode
  :delight
  :mode "\\.heex\\'"
  :custom (lsp-elixir-local-server-command "/opt/homebrew/bin/elixir-ls")
  :hook (elixir-mode . lsp-deferred))
(use-package go-mode
  :delight
  :mode ("\\.go\\'" . go-mode)
  :hook (go-mode . lsp-deferred)
	(before-save . lsp-format-buffer)
	(before-save . lsp-organize-imports))
(use-package lsp-haskell
  :delight
  :custom
  (lsp-haskell-server-path "~/.ghcup/bin/haskell-language-server-wrapper")
  :hook (haskell-mode . lsp-deferred))
(use-package elm-mode
  :delight elm-format-on-save-mode
  :delight elm-indent-mode
  :mode ("\\.elm\\'" . elm-mode)
  :hook (elm-mode . lsp-deferred)
  (elm-mode . elm-format-on-save-mode))
(use-package python
  :delight
  :mode ("\\.py\\'" . python-mode)
  :interpreter ("python" . python-mode))
(use-package lsp-pyright
  :delight
  :custom
  (lsp-pyright-disable-language-service nil)
  (lsp-pyright-disable-organize-imports nil)
  (lsp-pyright-auto-import-completions t)
  (lsp-pyright-use-library-code-for-types t)
  :hook (python-mode . (lambda ()
			 (require 'lsp-pyright) (lsp-deferred))))
(use-package pyvenv
  :delight
  :custom
  (pyvenv-activate "./venv")
  (pyvenv-menu t)
  :config (pyvenv-mode 1)
  (add-hook 'pyvenv-post-activate-hooks 'pyvenv-restart-python)
  :hook (python-mode . pyvenv-mode))
(use-package auto-virtualenv
  :after (pyvenv projectile)
  :hook
  ((python-mode . auto-virtualenv-set-virtualenv)
   (projectile-after-switch-project . auto-virtualenv-set-virtualenv)))

(use-package company
  :delight
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
	      ("C-n" . company-select-next)
	      ("C-p" . company-select-previous)
	      ("<tab>" . company-complete-selection)
	      :map lsp-mode-map
	      ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-idle-delay 0.3)
  (company-minimum-prefix-length 3))
(use-package company-box :delight :hook (company-mode . company-box-mode))

(use-package projectile
  :delight
  :delight '(:eval (concat " " (projectile-project-name)))
  :init
  (when (file-directory-p "~/prj")
    (setq projectile-project-search-path '("~/prj")))
  (setq projectile-switch-project-action #'projectile-dired)
  :bind-keymap
  (("s-p" . projectile-command-map)
   ("C-c p" . projectile-command-map))
  :config (projectile-mode))
(use-package projectile-ripgrep :after projectile)

(use-package dashboard
  :init (setq dashboard-projects-backend 'projectile
	      dashboard-items '((recents . 10)
				(bookmarks . 5)
				(projects . 5)
				(registers . 5))
	      initial-buffer-choice (lambda () (get-buffer-create "*dashboard*"))
	      dashboard-startup-banner 'logo
	      dashboard-set-navigator t
	      dashboard-center-content t
	      dashboard-display-icons-p t
	      dashboard-set-heading-icons t
	      dashboard-icon-type 'nerd-icons)
  :config (dashboard-setup-startup-hook))

;; Magit
(use-package magit
  :commands magit-status
  :bind (("C-x g" . magit-status)))

(advice-remove 'message #'my-message-with-timestamp)
(toggle-debug-on-error)
