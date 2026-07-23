;;; init.el --- Emacs 30 configuration -*- lexical-binding: t; -*-

;;;; State

(defconst my-state-directory
  (expand-file-name "var/" user-emacs-directory))

(defconst my-frame-geometry-file
  (expand-file-name "frame-geometry.el" my-state-directory))

(dolist (directory '("backups/" "auto-save/"))
  (make-directory (expand-file-name directory my-state-directory) t))

(setq custom-file (expand-file-name "custom.el" my-state-directory)
      backup-directory-alist
      `(("." . ,(expand-file-name "backups/" my-state-directory)))
      auto-save-file-name-transforms
      `((".*" ,(expand-file-name "auto-save/" my-state-directory) t))
      savehist-file (expand-file-name "history" my-state-directory)
      save-place-file (expand-file-name "places" my-state-directory)
      recentf-save-file (expand-file-name "recentf" my-state-directory)
      project-list-file (expand-file-name "projects" my-state-directory)
      frame-resize-pixelwise t
      backup-by-copying t
      version-control t
      delete-old-versions t
      kept-new-versions 5
      kept-old-versions 2)

(load custom-file 'noerror 'nomessage)

(defvar my-frame-geometry-restored nil)

(defun my-save-frame-geometry ()
  "Save the selected graphical frame's size and position."
  (when-let* ((frame (if (display-graphic-p)
                         (selected-frame)
                       (seq-find #'display-graphic-p (frame-list))))
              (position (alist-get 'outer-position (frame-geometry frame))))
    (with-temp-file my-frame-geometry-file
      (prin1 (list :left (car position)
                   :top (cdr position)
                   :width (frame-text-width frame)
                   :height (frame-text-height frame)
                   :fullscreen (frame-parameter frame 'fullscreen))
             (current-buffer)))))

(defun my-restore-frame-geometry (&optional frame)
  "Restore saved size and position to the first graphical FRAME."
  (let ((frame (or frame (selected-frame))))
    (when (and (not my-frame-geometry-restored)
               (display-graphic-p frame))
      (setq my-frame-geometry-restored t)
      (when (file-readable-p my-frame-geometry-file)
        (condition-case nil
            (let ((geometry
                   (with-temp-buffer
                     (insert-file-contents my-frame-geometry-file)
                     (read (current-buffer)))))
              (when (and (natnump (plist-get geometry :width))
                         (natnump (plist-get geometry :height)))
                (set-frame-size frame
                                (plist-get geometry :width)
                                (plist-get geometry :height)
                                t))
              (when (and (integerp (plist-get geometry :left))
                         (integerp (plist-get geometry :top)))
                (set-frame-position frame
                                    (plist-get geometry :left)
                                    (plist-get geometry :top)))
              (set-frame-parameter frame 'fullscreen
                                   (plist-get geometry :fullscreen)))
          (error nil))))))

(add-hook 'window-setup-hook #'my-restore-frame-geometry)
(add-hook 'after-make-frame-functions #'my-restore-frame-geometry)
(add-hook 'kill-emacs-hook #'my-save-frame-geometry)

;;;; Packages

(require 'package)
(require 'seq)
(require 'treesit)

(declare-function dired-hide-details-mode "dired")
(declare-function eglot-code-action-organize-imports "eglot")
(declare-function eglot-format-buffer "eglot")
(declare-function eglot-managed-p "eglot")
(declare-function eglot-server-capable "eglot")
(declare-function flymake-diagnostic-oneliner "flymake")
(declare-function flymake-diagnostics "flymake")
(declare-function flymake-goto-next-error "flymake")
(declare-function flymake-goto-prev-error "flymake")

(defvar flymake-mode-map)

(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/"))
      package-archive-priorities
      '(("gnu" . 30) ("nongnu" . 20) ("melpa" . 10))
      package-install-upgrade-built-in nil)

(package-initialize)
(require 'use-package)

;;;; macOS

(when (eq system-type 'darwin)
  (setq ns-function-modifier 'hyper
        dired-listing-switches "-alh --group-directories-first")

  (defun my-macos-focus-frame (&optional frame)
    "Activate Emacs and focus graphical FRAME on macOS."
    (let ((frame (or frame (selected-frame))))
      (when (display-graphic-p frame)
        (with-selected-frame frame
          (ns-do-applescript
           "tell application id \"org.gnu.Emacs\" to activate")
          (raise-frame frame)
          (select-frame-set-input-focus frame)))))

  (add-hook 'window-setup-hook #'my-macos-focus-frame)
  (add-hook 'after-make-frame-functions #'my-macos-focus-frame)

  (dolist (directory '("/opt/homebrew/bin"
                       "~/.local/bin"
                       "~/.local/share/nvim/mason/bin"
                       "~/.local/share/mise/shims"
                       "~/go/bin"
                       "~/.ghcup/bin"))
    (when (file-directory-p directory)
      (add-to-list 'exec-path (expand-file-name directory))))

  (setenv "PATH" (mapconcat #'identity exec-path path-separator)))

(setq shell-file-name "/bin/zsh"
      explicit-shell-file-name "/bin/zsh")

;;;; Editing

(setq-default indent-tabs-mode nil
              tab-width 4
              truncate-lines t)

(setq completion-ignore-case t
      read-buffer-completion-ignore-case t
      read-file-name-completion-ignore-case t
      completion-cycle-threshold 3
      read-extended-command-predicate
      #'command-completion-default-include-p
      text-mode-ispell-word-completion nil
      enable-recursive-minibuffers t
      minibuffer-prompt-properties
      '(read-only t cursor-intangible t face minibuffer-prompt)
      global-auto-revert-non-file-buffers t
      scroll-conservatively 101
      scroll-preserve-screen-position t
      large-file-warning-threshold 100000000)

(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'dired-mode-hook #'dired-hide-details-mode)
(add-hook 'before-save-hook #'delete-trailing-whitespace)

(defvar my-focus-out-save-timer nil)

(defun my-save-buffers-if-unfocused ()
  "Save modified buffers when every Emacs frame is unfocused."
  (setq my-focus-out-save-timer nil)
  (when (seq-every-p (lambda (frame)
                       (null (frame-focus-state frame)))
                     (frame-list))
    (save-some-buffers t)))

(defun my-save-buffers-on-focus-change ()
  "Debounce saving until asynchronous focus events have settled."
  (when (timerp my-focus-out-save-timer)
    (cancel-timer my-focus-out-save-timer))
  (setq my-focus-out-save-timer
        (run-with-idle-timer 0 nil #'my-save-buffers-if-unfocused)))

(add-function :after after-focus-change-function
              #'my-save-buffers-on-focus-change)

(delete-selection-mode 1)
(editorconfig-mode 1)
(file-name-shadow-mode 1)
(global-auto-revert-mode 1)
(global-completion-preview-mode 1)
(global-hl-line-mode 1)
(global-so-long-mode 1)
(pixel-scroll-precision-mode 1)
(recentf-mode 1)
(repeat-mode 1)
(savehist-mode 1)
(save-place-mode 1)
(show-paren-mode 1)
(tab-bar-mode 1)
(which-key-mode 1)
(fido-vertical-mode 1)
(display-battery-mode 1)

(unless (package-installed-p 'rose-pine-emacs)
  (require 'package-vc)
  (package-vc-install
   "https://github.com/thongpv87/rose-pine-emacs"
   "adcf6f8fe719884f7e32acb9130bdbcaccd6c4c9"
   nil
   'rose-pine-emacs))

(load-theme 'rose-pine-moon t)

;;;; Keys

(keymap-global-set "<escape>" #'keyboard-escape-quit)
(keymap-global-set "s-b" #'ibuffer)
(keymap-global-set "s-k" #'kill-current-buffer)
(keymap-global-set "s-K" #'delete-window)
(keymap-global-set "s-<left>" #'previous-buffer)
(keymap-global-set "s-<right>" #'next-buffer)
(keymap-global-set "s-W" #'delete-frame)
(keymap-global-set "s-{" #'tab-bar-switch-to-prev-tab)
(keymap-global-set "s-}" #'tab-bar-switch-to-next-tab)
(keymap-global-set "s-t" #'tab-bar-new-tab)
(keymap-global-set "s-w" #'tab-bar-close-tab)

;;;; Projects

(require 'project)

(dolist (marker '("bb.edn" "build.boot" "deps.edn" "project.clj"))
  (add-to-list 'project-vc-extra-root-markers marker))

(setq project-mode-line t
      project-file-history-behavior 'relativize)

(keymap-global-set "s-p" project-prefix-map)
(keymap-global-set "C-c p" project-prefix-map)

;;;; Evil

(use-package evil
  :ensure t
  :init
  (setq evil-undo-system 'undo-redo
        evil-split-window-below t
        evil-vsplit-window-right t
        evil-cross-lines t)
  :config
  (evil-mode 1)

  (defvar-keymap my-leader-map
    "RET" #'evil-ex-nohighlight
    "\\" #'switch-to-buffer
    "e b" #'cider-load-buffer
    "e e" #'cider-eval-defun-at-point
    "e j" #'cider-jack-in-clj
    "e l" #'cider-eval-last-sexp
    "f f" #'my-format-buffer
    "p" project-prefix-map
    "g" #'magit-status
    "t" #'vterm)

  (evil-global-set-key 'normal (kbd "\\") my-leader-map)
  (evil-global-set-key 'normal (kbd "SPC") #'evil-forward-char)
  (evil-global-set-key 'normal (kbd "-") #'dired-jump)
  (evil-global-set-key 'normal (kbd "gcc") #'comment-line)
  (evil-global-set-key 'visual (kbd "gc") #'comment-dwim))

(use-package evil-collection
  :ensure t
  :after evil
  :config
  (evil-collection-init))

(use-package evil-surround
  :ensure t
  :after evil
  :config
  (global-evil-surround-mode 1))

;;;; Tree-sitter

(setq treesit-language-source-alist
      '((c-sharp "https://github.com/tree-sitter/tree-sitter-c-sharp")
        (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")
        (elixir "https://github.com/elixir-lang/tree-sitter-elixir")
        (elisp "https://github.com/Wilfred/tree-sitter-elisp")
        (go "https://github.com/tree-sitter/tree-sitter-go")
        (heex "https://github.com/phoenixframework/tree-sitter-heex")
        (python "https://github.com/tree-sitter/tree-sitter-python")))

(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode 1))

(defun my-emacs-lisp-fontify-setq-variable
    (node override start end &rest _)
  "Fontify NODE when it is a variable position in a setq form."
  (let ((position
         (seq-position
          (seq-remove
           (lambda (child)
             (equal (treesit-node-type child) "comment"))
           (treesit-node-children (treesit-node-parent node) t))
          node
          #'treesit-node-eq)))
    (when (and position (zerop (% position 2)))
      (treesit-fontify-with-override
       (treesit-node-start node) (treesit-node-end node)
       'font-lock-variable-name-face override start end))))

(defun my-emacs-lisp-treesit-setup ()
  "Enable tree-sitter parsing and font locking for Emacs Lisp."
  (unless (treesit-ready-p 'elisp t)
    (when (or (eq treesit-auto-install t)
              (and (eq treesit-auto-install 'prompt)
                   (y-or-n-p
                    "Tree-sitter grammar for elisp is missing.  Install it? ")))
      (treesit-install-language-grammar 'elisp)))
  (when (treesit-ready-p 'elisp t)
    (treesit-parser-create 'elisp)
    (setq-local treesit-font-lock-level 4
                treesit-font-lock-feature-list
                '((comment string)
                  (keyword definition)
                  (constant variable)
                  (bracket operator))
                treesit-font-lock-settings
                (treesit-font-lock-rules
                 :language 'elisp
                 :override t
                 :feature 'comment
                 '((comment) @font-lock-comment-face)

                 :language 'elisp
                 :override t
                 :feature 'string
                 '((string) @font-lock-string-face)

                 :language 'elisp
                 :override t
                 :feature 'keyword
                 '(["and" "catch" "cond" "condition-case"
                    "defconst" "defmacro" "defsubst" "defun" "defvar"
                    "function" "if" "interactive" "lambda" "let" "let*"
                    "or" "prog1" "prog2" "progn" "quote"
                    "save-current-buffer" "save-excursion" "save-restriction"
                    "setq" "setq-default" "unwind-protect" "while"]
                   @font-lock-keyword-face)

                 :language 'elisp
                 :override t
                 :feature 'definition
                 "(function_definition
                    name: (symbol) @font-lock-function-name-face
                    parameters: (list (symbol) @font-lock-variable-name-face)
                    docstring: (string)? @font-lock-doc-face)
                  (macro_definition
                    name: (symbol) @font-lock-function-name-face
                    parameters: (list (symbol) @font-lock-variable-name-face)
                    docstring: (string)? @font-lock-doc-face)"

                 :language 'elisp
                 :override t
                 :feature 'constant
                 '((integer) @font-lock-number-face
                   (float) @font-lock-number-face
                   (char) @font-lock-number-face
                   ["nil" "t"] @font-lock-constant-face)

                 :language 'elisp
                 :override t
                 :feature 'variable
                 "(special_form
                    [\"defconst\" \"defvar\"]
                    . (symbol) @font-lock-variable-name-face)
                  (special_form
                    [\"setq\" \"setq-default\"]
                    (symbol) @my-emacs-lisp-fontify-setq-variable)
                  (special_form
                    [\"let\" \"let*\"]
                    (list (list . (symbol) @font-lock-variable-name-face)))"

                 :language 'elisp
                 :override t
                 :feature 'bracket
                 '(["(" ")" "#[" "[" "]"] @font-lock-bracket-face)

                 :language 'elisp
                 :override t
                 :feature 'operator
                 '(["`" "#'" "'" "," ",@"] @font-lock-operator-face)))
    (setq-local font-lock-defaults nil)
    (treesit-major-mode-setup)))

(add-hook 'emacs-lisp-mode-hook #'my-emacs-lisp-treesit-setup)

(use-package clojure-ts-mode
  :ensure t
  :mode (("\\.clj\\'" . clojure-ts-mode)
         ("\\.cljs\\'" . clojure-ts-clojurescript-mode)
         ("\\.cljc\\'" . clojure-ts-clojurec-mode)
         ("\\.edn\\'" . clojure-ts-mode)))

(use-package markdown-mode
  :ensure t
  :commands gfm-view-mode)

;;;; Eglot

(setq eglot-autoshutdown t)

(defconst my-eglot-server-executables
  '((clojure-ts-mode "clojure-lsp")
    (clojure-ts-clojurescript-mode "clojure-lsp")
    (clojure-ts-clojurec-mode "clojure-lsp")
    (csharp-ts-mode "omnisharp" "OmniSharp" "csharp-ls")
    (dockerfile-ts-mode "docker-langserver")
    (elixir-ts-mode "language_server.sh" "start_lexical.sh")
    (heex-ts-mode "language_server.sh" "start_lexical.sh")
    (elm-mode "elm-language-server")
    (go-ts-mode "gopls")
    (haskell-mode "haskell-language-server-wrapper")
    (python-ts-mode "pylsp" "basedpyright-langserver"
                    "pyright-langserver" "pyrefly"
                    "jedi-language-server" "ruff")
    (zig-mode "zls")))

(defun my-clojure-lsp-initialization-options (_server)
  "Return clojure-lsp options suited to the available build tools."
  (append
   '(:cljfmt (:remove-multiple-non-indenting-spaces? t))
   (unless (executable-find "clojure")
     (list
      :project-specs
      (vconcat
       (delq nil
             (list
              (when (executable-find "lein")
                '(:project-path "project.clj"
                                :classpath-cmd ["lein" "classpath"]))
              (when (executable-find "bb")
                '(:project-path "bb.edn"
                                :classpath-cmd ["bb" "print-deps" "--format"
                                                "classpath"])))))))))

(defun my-eglot-ensure ()
  "Start Eglot when a server for the current mode is available."
  (when (seq-some #'executable-find
                  (alist-get major-mode my-eglot-server-executables))
    (eglot-ensure)))

(defun my-format-buffer ()
  "Format the current buffer with Eglot or its indentation rules."
  (interactive)
  (if (and (fboundp 'eglot-managed-p)
           (eglot-managed-p)
           (eglot-server-capable :documentFormattingProvider))
      (eglot-format-buffer)
    (save-restriction
      (widen)
      (indent-region (point-min) (point-max)))))

(defun my-eglot-format-on-save ()
  "Format on save when the current Eglot server supports it."
  (if (and (eglot-managed-p)
           (eglot-server-capable :documentFormattingProvider))
      (add-hook 'before-save-hook #'eglot-format-buffer t t)
    (remove-hook 'before-save-hook #'eglot-format-buffer t)))

(add-hook 'eglot-managed-mode-hook #'my-eglot-format-on-save)

(dolist (hook '(csharp-ts-mode-hook
                clojure-ts-mode-hook
                dockerfile-ts-mode-hook
                elixir-ts-mode-hook
                heex-ts-mode-hook
                elm-mode-hook
                haskell-mode-hook
                zig-mode-hook))
  (add-hook hook #'my-eglot-ensure))

(defun my-flymake-show-line-diagnostics ()
  "Display Flymake diagnostics for the current line."
  (interactive)
  (if-let ((diagnostics
            (flymake-diagnostics (line-beginning-position)
                                 (line-end-position))))
      (message "%s"
               (mapconcat #'flymake-diagnostic-oneliner diagnostics "\n"))
    (message "No diagnostics on this line")))

(with-eval-after-load 'flymake
  (keymap-set flymake-mode-map "M-n" #'flymake-goto-next-error)
  (keymap-set flymake-mode-map "M-p" #'flymake-goto-prev-error)

  (with-eval-after-load 'evil
    (evil-define-key 'normal flymake-mode-map
      (kbd "C-w d") #'my-flymake-show-line-diagnostics)))

(with-eval-after-load 'eglot
  (add-to-list
   'eglot-server-programs
   '((clojure-ts-mode
      clojure-ts-clojurescript-mode
      clojure-ts-clojurec-mode)
     . ("clojure-lsp"
        :initializationOptions my-clojure-lsp-initialization-options)))

  (with-eval-after-load 'evil
    (evil-define-key 'normal eglot-mode-map
      (kbd "K") #'eldoc
      (kbd "gr") #'xref-find-references)))

;;;; Clojure

(use-package cider
  :ensure t
  :commands (cider-connect-clj cider-jack-in-clj)
  :hook (clojure-ts-mode . cider-mode)
  :init
  (setq cider-use-xref nil)
  :config
  (with-eval-after-load 'evil
    (evil-define-key 'visual cider-mode-map
      (kbd "\\ e r") #'cider-eval-region)))

;;;; Go

(defun my-go-before-save ()
  "Organize imports in a Go buffer managed by Eglot."
  (when (and (fboundp 'eglot-managed-p)
             (eglot-managed-p))
    (eglot-code-action-organize-imports (point-min) (point-max))))

(defun my-go-setup ()
  "Start Eglot and configure save actions for Go."
  (my-eglot-ensure)
  (add-hook 'before-save-hook #'my-go-before-save nil t))

(add-hook 'go-ts-mode-hook #'my-go-setup)

;;;; Python

(defvar-local my-python-base-exec-path nil)
(defvar-local my-python-base-process-environment nil)
(defvar-local my-python-base-virtualenv-root nil)
(defvar-local my-python-base-virtualenv-root-local-p nil)

(defun my-python-configure ()
  "Use a project-local Python environment and start Eglot."
  (unless (local-variable-p 'my-python-base-exec-path)
    (setq-local my-python-base-exec-path exec-path
                my-python-base-process-environment process-environment
                my-python-base-virtualenv-root-local-p
                (local-variable-p 'python-shell-virtualenv-root)
                my-python-base-virtualenv-root
                (and (boundp 'python-shell-virtualenv-root)
                     python-shell-virtualenv-root)))
  (setq-local exec-path (copy-sequence my-python-base-exec-path)
              process-environment
              (copy-sequence my-python-base-process-environment))
  (if my-python-base-virtualenv-root-local-p
      (setq-local python-shell-virtualenv-root
                  my-python-base-virtualenv-root)
    (kill-local-variable 'python-shell-virtualenv-root))
  (when-let* ((project (project-current nil))
              (root (project-root project))
              (virtualenv
               (seq-find
                (lambda (directory)
                  (let ((bin (expand-file-name "bin/" directory)))
                    (seq-some
                     #'file-executable-p
                     (list (expand-file-name "python" bin)
                           (expand-file-name "python3" bin)))))
                (list (expand-file-name ".venv/" root)
                      (expand-file-name "venv/" root)))))
    (let ((bin (expand-file-name "bin/" virtualenv))
          (path (getenv "PATH")))
      (setq-local python-shell-virtualenv-root virtualenv
                  exec-path (cons bin exec-path)
                  process-environment (copy-sequence process-environment))
      (setenv "VIRTUAL_ENV" virtualenv)
      (setenv "PATH" (if (and path (> (length path) 0))
                         (concat bin path-separator path)
                       bin))))
  (my-eglot-ensure))

(defun my-python-setup ()
  "Configure Python after file and directory-local variables are applied."
  (if buffer-file-name
      (add-hook 'hack-local-variables-hook #'my-python-configure nil t)
    (my-python-configure)))

(add-hook 'python-ts-mode-hook #'my-python-setup)

;;;; External language modes

(use-package elm-mode
  :ensure t
  :mode "\\.elm\\'"
  :hook (elm-mode . elm-format-on-save-mode))

(use-package haskell-mode
  :ensure t
  :mode "\\.hs\\'")

(use-package zig-mode
  :ensure t
  :mode "\\.zig\\'")

;;;; Git and terminal

(use-package magit
  :ensure t
  :commands magit-status
  :bind ("C-x g" . magit-status))

(use-package diff-hl
  :ensure t
  :custom-face
  (diff-hl-insert ((t (:foreground "#9ccfd8"))))
  (diff-hl-change ((t (:foreground "#f6c177"))))
  (diff-hl-delete ((t (:foreground "#eb6f92"))))
  :config
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1)
  (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh))

(use-package vterm
  :ensure t
  :commands vterm
  :custom
  (vterm-kill-buffer-on-exit t))

;;;; Org

(use-package org
  :ensure nil
  :custom
  (org-startup-folded t)
  (org-startup-indented t)
  (org-startup-with-inline-images t)
  (org-confirm-babel-evaluate t)
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((awk . t)
     (emacs-lisp . t)
     (haskell . t)
     (python . t)
     (ruby . t)
     (sed . t)
     (shell . t))))

;;;; Twitch IRC

(use-package rcirc
  :ensure nil
  :custom
  (rcirc-default-nick "moniquelive")
  (rcirc-default-user-name "moniquelive")
  (rcirc-default-full-name "MoniqueLive")
  (rcirc-auto-authenticate-flag t)
  (rcirc-reconnect-delay 5)
  (rcirc-server-alist
   '(("irc.chat.twitch.tv"
      :port 6697
      :encryption tls
      :channels ("#moniquelive" "#theprimeagen"))))
  :hook
  (rcirc-mode . rcirc-track-minor-mode))

(unless noninteractive
  (server-mode 1))

;;; init.el ends here
