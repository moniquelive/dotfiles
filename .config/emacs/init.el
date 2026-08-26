;;; init.el --- Emacs 31 configuration -*- lexical-binding: t; -*-

;;; Commentary:

;; Personal Emacs configuration.

;;; Code:

(require 'seq)

(defvar project-list-file)
(defvar abbrev-file-name)
(defvar bookmark-default-file)
(defvar ibuffer-human-readable-size)
(defvar icomplete-vertical-render-prefix-indicator)
(defvar ielm-history-file-name)
(defvar org-persist-directory)
(defvar recentf-save-file)
(defvar savehist-file)
(defvar save-place-file)
(defvar tramp-persistency-file-name)
(defvar transient-history-file)
(defvar transient-levels-file)
(defvar transient-values-file)
(defvar server-auth-dir)
(defvar url-configuration-directory)
(defvar my-cache-directory)
(defvar my-data-directory)
(defvar my-state-directory)

;;;; State

(defconst my-frame-geometry-file
  (expand-file-name "frame-geometry.el" my-state-directory)
  "File used to persist graphical frame geometry.")

(dolist (directory '("backups/" "auto-save/" "server/" "transient/"
                     "url/"))
  (make-directory (expand-file-name directory my-state-directory) t))

(make-directory (expand-file-name "org-persist/" my-cache-directory) t)

(setq custom-file (expand-file-name "custom.el" my-state-directory)
      abbrev-file-name (expand-file-name "abbrev_defs" my-state-directory)
      bookmark-default-file (expand-file-name "bookmarks" my-state-directory)
      ielm-history-file-name
      (expand-file-name "ielm-history.eld" my-state-directory)
      backup-directory-alist
      `(("." . ,(expand-file-name "backups/" my-state-directory)))
      auto-save-file-name-transforms
      `((".*" ,(expand-file-name "auto-save/" my-state-directory) t))
      savehist-file (expand-file-name "history" my-state-directory)
      save-place-file (expand-file-name "places" my-state-directory)
      recentf-save-file (expand-file-name "recentf" my-state-directory)
      project-list-file (expand-file-name "projects" my-state-directory)
      org-persist-directory (expand-file-name "org-persist/" my-cache-directory)
      server-auth-dir (expand-file-name "server/" my-state-directory)
      tramp-persistency-file-name (expand-file-name "tramp" my-state-directory)
      transient-history-file
      (expand-file-name "transient/history.el" my-state-directory)
      transient-levels-file
      (expand-file-name "transient/levels.el" my-state-directory)
      transient-values-file
      (expand-file-name "transient/values.el" my-state-directory)
      url-configuration-directory (expand-file-name "url/" my-state-directory)
      frame-resize-pixelwise t
      backup-by-copying t
      version-control t
      delete-old-versions t
      kept-new-versions 5
      kept-old-versions 2)

(load custom-file 'noerror 'nomessage)

(with-eval-after-load 'recentf
  (setopt recentf-autosave-interval 300))

(with-eval-after-load 'saveplace
  (setopt save-place-autosave-interval 300))

(defvar my-frame-geometry-restored nil
  "Whether frame geometry has been restored during this session.")

(defun my-save-frame-geometry ()
  "Save the selected graphical frame's size and position."
  (when-let* ((frame (if (display-graphic-p)
                         (selected-frame)
                       (seq-find #'display-graphic-p
                                 (get-mru-frames t t))))
              (position (alist-get 'outer-position (frame-geometry frame))))
    (with-temp-file my-frame-geometry-file
      (prin1 (list :left (car position)
                   :top (cdr position)
                   :width (frame-text-width frame)
                   :height (frame-text-height frame)
                   :fullscreen (frame-parameter frame 'fullscreen))
             (current-buffer)))))

(defun my-restore-frame-geometry (&optional frame)
  "Restore saved size and position to graphical FRAME."
  (let ((frame (or frame (selected-frame))))
    (when (and (not my-frame-geometry-restored)
               (display-graphic-p frame)
               (file-readable-p my-frame-geometry-file))
      (condition-case error-data
          (let* ((geometry
                  (with-temp-buffer
                    (insert-file-contents my-frame-geometry-file)
                    (read (current-buffer))))
                 (left (plist-get geometry :left))
                 (top (plist-get geometry :top))
                 (width (plist-get geometry :width))
                 (height (plist-get geometry :height))
                 (fullscreen (plist-get geometry :fullscreen)))
            (unless (and (integerp width)
                         (> width 0)
                         (integerp height)
                         (> height 0)
                         (integerp left)
                         (integerp top))
              (error "Invalid saved frame geometry"))
            (let ((alter-fullscreen-frames t))
              (set-frame-size-and-position-pixelwise
               frame width height left top))
            (set-frame-parameter frame 'fullscreen fullscreen)
            (setq my-frame-geometry-restored t))
        (error
         (display-warning
          'my-frame-geometry
          (format "Could not restore frame geometry: %s"
                  (error-message-string error-data))
          :warning))))))

(add-hook 'window-setup-hook #'my-restore-frame-geometry)
(add-hook 'after-make-frame-functions #'my-restore-frame-geometry)
(add-hook 'kill-emacs-hook #'my-save-frame-geometry)

;;;; Packages

(require 'package)
(require 'treesit)

(declare-function cider-eval-defun-at-point "cider-eval")
(declare-function cider-eval-last-sexp "cider-eval")
(declare-function cider-eval-region "cider-eval")
(declare-function cider-load-buffer "cider-eval")
(declare-function consult-find "consult")
(declare-function diff-hl-magit-post-refresh "diff-hl")
(declare-function dired-hide-details-mode "dired")
(declare-function eglot-code-action-organize-imports "eglot")
(declare-function eglot-format-buffer "eglot")
(declare-function eglot-inlay-hints-mode "eglot")
(declare-function eglot-managed-p "eglot")
(declare-function eglot-server-capable "eglot")
(declare-function eglot--guess-contact "eglot")
(declare-function evil-delay "evil-core")
(declare-function evil-ex-nohighlight "evil-commands")
(declare-function evil-forward-char "evil-commands")
(declare-function evil-global-set-key "evil-core")
(declare-function flymake-diagnostic-text "flymake")
(declare-function flymake-diagnostics "flymake")
(declare-function flymake-goto-next-error "flymake")
(declare-function flymake-goto-prev-error "flymake")
(declare-function my-black-buffer "init")
(declare-function my-elm-format-buffer "init")
(declare-function my-isort-buffer "init")
(declare-function my-macos-focus-frame "init")
(declare-function my-prettier-buffer "init")
(declare-function my-rubyfmt-buffer "init")
(declare-function my-rustfmt-buffer "init")
(declare-function my-shfmt-buffer "init")
(declare-function my-stylua-buffer "init")
(declare-function my-zig-format-buffer "init")

(defvar eglot-autoshutdown)
(defvar eglot-server-programs)
(defvar explicit-shell-file-name)
(defvar flymake-mode-map)
(defvar flymake-mode)
(defvar global-auto-revert-non-file-buffers)

(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/"))
      package-archive-priorities
      '(("gnu" . 30) ("nongnu" . 20) ("melpa" . 10))
      package-pinned-packages
      '((browse-at-remote . "melpa")
        (evil . "melpa"))
      package-install-upgrade-built-in nil)

(package-initialize)
(require 'use-package)

(defconst my-packages
  '(browse-at-remote cider clojure-ts-mode consult diff-hl ef-themes
    elm-mode evil evil-collection evil-surround fish-mode haskell-mode
    magit marginalia markdown-mode powershell reformatter svelte-mode
    swift-mode treesit-fold vterm vue-mode zig-mode)
  "Packages provisioned by this configuration.")

(setq package-selected-packages my-packages)

(defun my-package-sync ()
  "Install packages declared by this configuration."
  (interactive)
  (setq package-selected-packages my-packages)
  (unless package-archive-contents
    (package-refresh-contents))
  (package-install-selected-packages t))

(defun my-package-sync-if-needed ()
  "Install any missing packages declared by this configuration."
  (when (seq-some (lambda (package) (not (package-installed-p package)))
                  my-packages)
    (my-package-sync)))

(my-package-sync-if-needed)

;;;; macOS

(when (eq system-type 'darwin)
  (setq ns-function-modifier 'hyper)

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

  (let ((directories
         (seq-filter
          #'file-directory-p
          (mapcar #'expand-file-name
                  '("/opt/homebrew/bin"
                    "~/.local/bin"
                    "~/.local/share/nvim/mason/bin"
                    "~/.local/share/mise/shims"
                    "~/go/bin"
                    "~/.ghcup/bin")))))
    (setq exec-path
          (append directories
                  (seq-remove (lambda (directory)
                                (member directory directories))
                              exec-path))))

  (setq insert-directory-program (or (executable-find "gls") "ls")
        dired-listing-switches
        (if (executable-find "gls")
            "-alh --group-directories-first"
          "-alh"))

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
       delete-by-moving-to-trash t
      ibuffer-human-readable-size t
      icomplete-vertical-render-prefix-indicator t
      scroll-conservatively 101
      scroll-preserve-screen-position t
      large-file-warning-threshold 100000000
      mode-line-collapse-minor-modes t
      tab-bar-truncate t)

(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'delete-trailing-whitespace-mode)
(add-hook 'text-mode-hook #'delete-trailing-whitespace-mode)
(add-hook 'dired-mode-hook #'dired-hide-details-mode)

(defvar my-focus-out-save-timer nil
  "Timer used to debounce saves after frame focus changes.")

(defun my-save-buffers-if-unfocused ()
  "Save modified buffers when every Emacs frame is unfocused."
  (setq my-focus-out-save-timer nil)
  (when (seq-every-p (lambda (frame)
                        (not (frame-focus-state frame)))
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
(display-battery-mode 1)
(editorconfig-mode 1)
(fido-vertical-mode 1)
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

(use-package consult
  :bind
  (("C-x b" . consult-buffer)
   ("C-x M-:" . consult-complex-command)
   ("M-#" . consult-register)
   ("M-g d" . consult-flymake)
   ("M-g i" . consult-imenu)
   ("M-g m" . consult-mark)
   ("M-g M" . consult-global-mark)
   ("M-s f" . consult-recent-file)
   ("M-s h" . consult-history)
   ("M-s i" . consult-info)
   ("M-s l" . consult-line)
   ("M-s m" . consult-man)
   ("M-s r" . consult-ripgrep)
   ("M-y" . consult-yank-pop)))

(use-package marginalia
  :config
  (marginalia-mode 1))

(use-package ef-themes
  :config
  (load-theme 'ef-cherie t))

(defun my-find-config-file ()
  "Find a file in `user-emacs-directory' with Consult."
  (interactive)
  (consult-find user-emacs-directory))

(use-package reformatter
  :demand t
  :config
  (reformatter-define my-shfmt
    :program "shfmt"
    :args '("-i" "2")
    :mode nil)

  (reformatter-define my-prettier
    :program (or (executable-find "prettierd") "prettier")
    :args (list "--stdin-filepath" (or buffer-file-name "stdin.js"))
    :mode nil)

  (reformatter-define my-stylua
    :program "stylua"
    :args (list "--stdin-filepath" (or buffer-file-name "stdin.lua") "-")
    :mode nil)

  (reformatter-define my-isort
    :program "isort"
    :args (list "--stdout" "--filename"
                (or buffer-file-name "stdin.py") "-")
    :mode nil)

  (reformatter-define my-black
    :program "black"
    :args (list "--quiet" "--stdin-filename"
                (or buffer-file-name "stdin.py") "-")
    :mode nil)

  (reformatter-define my-rubyfmt
    :program "rubyfmt"
    :mode nil)

  (reformatter-define my-rustfmt
    :program "rustfmt"
    :mode nil)

  (reformatter-define my-elm-format
    :program "elm-format"
    :args '("--stdin")
    :mode nil)

  (reformatter-define my-zig-format
    :program "zig"
    :args '("fmt" "--stdin")
    :mode nil))

(defun my-formatter-pipeline ()
  "Return available external formatters for the current mode."
  (let ((formatters
         (cond
          ((derived-mode-p 'bash-ts-mode 'sh-mode)
           '((("shfmt") my-shfmt-buffer)))
          ((derived-mode-p 'css-mode 'css-ts-mode 'html-mode 'html-ts-mode
                           'js-mode 'js-ts-mode 'js-jsx-mode 'json-mode
                           'json-ts-mode 'svelte-mode 'tsx-ts-mode
                           'typescript-ts-mode 'vue-mode)
           '((("prettierd" "prettier") my-prettier-buffer)))
          ((derived-mode-p 'lua-mode 'lua-ts-mode)
           '((("stylua") my-stylua-buffer)))
          ((derived-mode-p 'python-mode 'python-ts-mode)
           '((("isort") my-isort-buffer)
             (("black") my-black-buffer)))
          ((derived-mode-p 'ruby-mode 'ruby-ts-mode)
           '((("rubyfmt") my-rubyfmt-buffer)))
          ((derived-mode-p 'rust-mode 'rust-ts-mode)
           '((("rustfmt") my-rustfmt-buffer)))
          ((derived-mode-p 'elm-mode)
           '((("elm-format") my-elm-format-buffer)))
          ((derived-mode-p 'zig-mode 'zig-ts-mode)
           '((("zig") my-zig-format-buffer))))))
    (seq-filter
     (lambda (formatter)
       (seq-some #'executable-find (car formatter)))
     formatters)))

(defun my-eglot-can-format-p ()
  "Return non-nil when Eglot can format the current buffer."
  (and (fboundp 'eglot-managed-p)
       (eglot-managed-p)
       (eglot-server-capable :documentFormattingProvider)))

(defun my-format-buffer ()
  "Format the current buffer with one configured formatting owner."
  (interactive)
  (let ((formatters (my-formatter-pipeline)))
    (cond
     ((and (derived-mode-p 'ruby-mode 'ruby-ts-mode)
           (my-eglot-can-format-p))
      (eglot-format-buffer))
     (formatters
      (dolist (formatter formatters)
        (funcall (cadr formatter))))
     ((my-eglot-can-format-p)
      (eglot-format-buffer))
     ((called-interactively-p 'interactive)
      (save-restriction
        (widen)
        (indent-region (point-min) (point-max)))))))

(defun my-enable-format-on-save ()
  "Use the central formatter dispatcher before saving this buffer."
  (add-hook 'before-save-hook #'my-format-buffer nil t))

(add-hook 'prog-mode-hook #'my-enable-format-on-save)
(add-hook 'html-mode-hook #'my-enable-format-on-save)
(add-hook 'html-ts-mode-hook #'my-enable-format-on-save)

(defun my-toggle-flymake ()
  "Toggle Flymake diagnostics in the current buffer."
  (interactive)
  (flymake-mode (if flymake-mode -1 1)))

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
(keymap-global-set "<f5>" #'my-compile)
(keymap-global-set "M-<up>" #'my-treesit-expand-selection)
(keymap-global-set "M-<down>" #'my-treesit-shrink-selection)

;;;; Projects

(require 'project)

(dolist (marker '("bb.edn" "build.boot" "deps.edn" "project.clj"))
  (add-to-list 'project-vc-extra-root-markers marker))

(setq project-mode-line 'non-remote
      project-file-history-behavior 'relativize)

(keymap-global-set "s-p" project-prefix-map)
(keymap-global-set "C-c p" project-prefix-map)

;;;; Evil

(use-package evil
  :pin melpa
  :custom
  (evil-cross-lines t)
  (evil-split-window-below t)
  (evil-undo-system 'undo-redo)
  (evil-vsplit-window-right t)
  :config
  (evil-mode 1)

  (defvar-keymap my-leader-map
    "RET" #'evil-ex-nohighlight
    "\\" #'consult-buffer
    "e b" #'cider-load-buffer
    "e e" #'cider-eval-defun-at-point
    "e j" #'cider-jack-in-clj
    "e l" #'cider-eval-last-sexp
    "f c" #'my-find-config-file
    "f d" #'consult-flymake
    "f f" #'my-format-buffer
    "f h" #'consult-history
    "f k" #'consult-mark
    "f m" #'consult-man
    "f n" #'view-echo-area-messages
    "f r" #'consult-register
    "f t" #'consult-theme
    "g" #'magit-status
    "i d" #'my-toggle-flymake
    "i h" #'eglot-inlay-hints-mode
    "p" project-prefix-map
    "t" #'vterm)

  (evil-global-set-key 'normal (kbd "\\") my-leader-map)
  (evil-global-set-key 'normal (kbd "SPC") #'evil-forward-char)
  (evil-global-set-key 'normal (kbd "-") #'dired-jump)
  (evil-global-set-key 'normal (kbd "TAB") #'evil-toggle-fold)
  (evil-global-set-key 'normal (kbd "<tab>") #'evil-toggle-fold)
  (evil-global-set-key 'normal (kbd "ghx") #'browse-at-remote)
  (evil-global-set-key 'normal (kbd "]m") #'my-next-defun)
  (evil-global-set-key 'normal (kbd "[m") #'my-previous-defun)
  (evil-global-set-key 'normal (kbd "]M") #'my-next-defun-end)
  (evil-global-set-key 'normal (kbd "[M") #'my-previous-defun-end)
  (evil-global-set-key 'normal (kbd "gcc") #'comment-line)
  (evil-global-set-key 'visual (kbd "gc") #'comment-dwim))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

;;;; Tree-sitter

(add-to-list 'treesit-language-source-alist
             '(elisp "https://github.com/Wilfred/tree-sitter-elisp" "1.6.1"))

(setopt treesit-enabled-modes t
        treesit-auto-install-grammar (if noninteractive 'never 'always))

(defvar-local my-treesit-selection-history nil
  "Previous regions recorded while expanding a syntax selection.")

(defun my-treesit-expand-selection ()
  "Expand the active region to the next enclosing syntax node."
  (interactive)
  (if-let* ((node (condition-case nil
                      (treesit-node-at
                       (if (use-region-p) (region-beginning) (point)))
                    (error nil))))
      (let ((beginning (and (use-region-p) (region-beginning)))
            (end (and (use-region-p) (region-end))))
        (when beginning
          (push (cons beginning end) my-treesit-selection-history)
          (while (and node
                      (>= (treesit-node-start node) beginning)
                      (<= (treesit-node-end node) end))
            (setq node (treesit-node-parent node))))
        (when node
          (goto-char (treesit-node-start node))
          (push-mark (treesit-node-end node) t t)))
    (mark-sexp)))

(defun my-treesit-shrink-selection ()
  "Restore the previous syntax selection."
  (interactive)
  (if-let* ((range (pop my-treesit-selection-history)))
      (progn
        (goto-char (car range))
        (push-mark (cdr range) t t))
    (deactivate-mark)))

(defun my-next-defun (&optional count)
  "Move to the next definition, honoring COUNT."
  (interactive "p")
  (beginning-of-defun (- (or count 1))))

(defun my-previous-defun (&optional count)
  "Move to the previous definition, honoring COUNT."
  (interactive "p")
  (beginning-of-defun (or count 1)))

(defun my-next-defun-end (&optional count)
  "Move to the next definition end, honoring COUNT."
  (interactive "p")
  (end-of-defun (or count 1)))

(defun my-previous-defun-end (&optional count)
  "Move to the previous definition end, honoring COUNT."
  (interactive "p")
  (end-of-defun (- (or count 1))))

(let ((native-comp-jit-compilation nil))
  (require 'treesit-fold))

(global-treesit-fold-mode 1)

(defun my-emacs-lisp-fontify-setq-variable
    (node override start end &rest _)
  "Fontify variable NODE between START and END, honoring OVERRIDE."
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
  (unless (or noninteractive (treesit-ready-p 'elisp t))
    (treesit-ensure-installed 'elisp))
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
  :mode (("\\.clj\\'" . clojure-ts-mode)
         ("\\.cljs\\'" . clojure-ts-clojurescript-mode)
         ("\\.cljc\\'" . clojure-ts-clojurec-mode)
         ("\\.edn\\'" . clojure-ts-mode)))

(use-package markdown-mode
  :commands gfm-view-mode)

;;;; Eglot

(setq eglot-autoshutdown t)

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
  "Start Eglot when its own registry can resolve a server contact."
  (require 'eglot)
  (when (condition-case nil
            (progn (eglot--guess-contact) t)
          (error nil))
    (eglot-ensure)))

(dolist (hook '(bash-ts-mode-hook
                 c-mode-hook
                 c-ts-mode-hook
                 c++-mode-hook
                 c++-ts-mode-hook
                 clojure-mode-hook
                 clojure-ts-mode-hook
                 clojure-ts-clojurescript-mode-hook
                 clojure-ts-clojurec-mode-hook
                 csharp-mode-hook
                 csharp-ts-mode-hook
                 css-mode-hook
                 css-ts-mode-hook
                 dockerfile-ts-mode-hook
                 elixir-mode-hook
                 elixir-ts-mode-hook
                 elm-mode-hook
                 fish-mode-hook
                 go-dot-mod-mode-hook
                 go-dot-work-mode-hook
                 go-mod-ts-mode-hook
                 go-work-ts-mode-hook
                 haskell-mode-hook
                 heex-ts-mode-hook
                 html-mode-hook
                 html-ts-mode-hook
                 js-mode-hook
                 js-ts-mode-hook
                 json-mode-hook
                 json-ts-mode-hook
                 lua-mode-hook
                 lua-ts-mode-hook
                 powershell-mode-hook
                 ruby-mode-hook
                 ruby-ts-mode-hook
                 rust-mode-hook
                 rust-ts-mode-hook
                 sh-mode-hook
                 swift-mode-hook
                 swift-ts-mode-hook
                 toml-ts-mode-hook
                 tsx-ts-mode-hook
                 typescript-ts-mode-hook
                 yaml-mode-hook
                 yaml-ts-mode-hook
                 zig-mode-hook))
  (add-hook hook #'my-eglot-ensure))

(defun my-flymake-show-line-diagnostics ()
  "Display Flymake diagnostics for the current line."
  (interactive)
  (if-let* ((diagnostics
             (flymake-diagnostics (line-beginning-position)
                                  (line-end-position))))
      (message "%s"
               (mapconcat
                (lambda (diagnostic)
                  (flymake-diagnostic-text
                   diagnostic '(origin code oneliner)))
                diagnostics "\n"))
    (message "No diagnostics on this line")))

(with-eval-after-load 'flymake
  (setopt flymake-show-diagnostics-at-end-of-line 'fancy)

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

  (add-to-list 'eglot-server-programs
               '((elixir-mode elixir-ts-mode heex-ts-mode) . ("expert")))
  (add-to-list 'eglot-server-programs
               '(fish-mode . ("fish-lsp" "start")))
  (add-to-list 'eglot-server-programs
               '(swift-mode . ("sourcekit-lsp")))

  (let* ((bundle
          (expand-file-name
           "~/.local/share/nvim/mason/packages/powershell-editor-services/"))
         (start-script
          (expand-file-name
           "PowerShellEditorServices/Start-EditorServices.ps1" bundle)))
    (when (file-readable-p start-script)
      (add-to-list
       'eglot-server-programs
       `(powershell-mode
         . ("pwsh" "-NoLogo" "-NoProfile" "-Command"
            ,(format
              (concat "& '%s' -BundledModulesPath '%s' -LogPath '%s' "
                      "-SessionDetailsPath '%s' -FeatureFlags @() "
                      "-AdditionalModules @() -HostName Emacs "
                      "-HostProfileId 0 -HostVersion 31.1 -Stdio "
                      "-LogLevel Normal")
              start-script bundle
              (expand-file-name "powershell-editor-services.log"
                                my-cache-directory)
              (expand-file-name "powershell-editor-services.json"
                                my-cache-directory)))))))

  (with-eval-after-load 'evil
    (evil-define-key 'normal eglot-mode-map
      (kbd "K") #'eldoc
      (kbd "gr") #'xref-find-references)))

;;;; Clojure

(use-package cider
  :commands (cider-connect-clj cider-jack-in-clj)
  :hook ((clojure-mode clojure-ts-mode) . cider-mode)
  :custom
  (cider-use-xref nil)
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
(add-hook 'go-mode-hook #'my-go-setup)

;;;; Python

(defvar-local my-python-base-exec-path nil
  "Original value of variable `exec-path' before virtualenv activation.")

(defvar-local my-python-base-process-environment nil
  "Original environment before activating a project virtual environment.")

(defvar-local my-python-base-virtualenv-root nil
  "Original value of `python-shell-virtualenv-root'.")

(defvar-local my-python-base-virtualenv-root-local-p nil
  "Whether `python-shell-virtualenv-root' originally had a local value.")

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
                  (let ((bin-directory
                         (expand-file-name "bin/" directory)))
                    (seq-some
                     #'file-executable-p
                     (list (expand-file-name "python" bin-directory)
                           (expand-file-name "python3" bin-directory)))))
                (list (expand-file-name ".venv/" root)
                      (expand-file-name "venv/" root)))))
    (let ((bin-directory (expand-file-name "bin/" virtualenv))
          (existing-path (getenv "PATH")))
      (setq-local python-shell-virtualenv-root virtualenv
                  exec-path (cons bin-directory exec-path)
                  process-environment (copy-sequence process-environment))
      (setenv "VIRTUAL_ENV" virtualenv)
      (setenv "PATH" (if (and existing-path
                               (> (length existing-path) 0))
                          (concat bin-directory path-separator existing-path)
                        bin-directory))))
  (my-eglot-ensure))

(defun my-python-setup ()
  "Configure Python after file and directory-local variables are applied."
  (if buffer-file-name
      (add-hook 'hack-local-variables-hook #'my-python-configure nil t)
    (my-python-configure)))

(add-hook 'python-ts-mode-hook #'my-python-setup)
(add-hook 'python-mode-hook #'my-python-setup)

;;;; Compile and templates

(defun my-exercism-file-p ()
  "Return non-nil when the current file belongs to Exercism."
  (and buffer-file-name
       (string-match-p "/exercism/" (downcase buffer-file-name))))

(defun my-project-file-directory (name)
  "Return the nearest parent directory containing NAME."
  (locate-dominating-file default-directory name))

(defun my-command-in-directory (directory command)
  "Return shell COMMAND prefixed to run in DIRECTORY."
  (format "cd %s && %s"
          (shell-quote-argument (directory-file-name directory)) command))

(defun my-configure-compile-command ()
  "Set a useful run or test command for the current buffer."
  (when buffer-file-name
    (let ((file (shell-quote-argument buffer-file-name)))
      (setq-local
       compile-command
       (cond
        ((derived-mode-p 'c-mode 'c-ts-mode)
         (save-excursion
           (goto-char (point-min))
           (if (looking-at-p
                (regexp-quote
                 "/*usr/bin/env gcc \"$0\"; ./a.out; rm a.out; exit 0; */"))
               (format "chmod +x %s && %s" file file)
             (if-let* ((root (my-project-file-directory "Makefile")))
                 (my-command-in-directory root "make")
               "make"))))
        ((derived-mode-p 'clojure-mode 'clojure-ts-mode)
         (if-let* ((root (my-project-file-directory "project.clj")))
             (my-command-in-directory
              root (if (my-exercism-file-p) "lein test" "lein run"))
           (format "bb %s" file)))
        ((derived-mode-p 'elixir-mode 'elixir-ts-mode)
         (if-let* ((root (my-project-file-directory "mix.exs")))
             (my-command-in-directory root "mix test")
           "mix test"))
        ((derived-mode-p 'go-mode 'go-ts-mode)
         (if (my-exercism-file-p)
             "go test -v ."
           (format "go run %s" file)))
        ((derived-mode-p 'haskell-mode 'haskell-ts-mode)
         (let ((command (if (my-exercism-file-p) "cabal test" "cabal run")))
           (if-let* ((root (or (my-project-file-directory "cabal.project")
                               (and-let* ((project (project-current nil)))
                                 (project-root project)))))
               (my-command-in-directory root command)
             command)))
        ((derived-mode-p 'lua-mode 'lua-ts-mode)
         (if (my-exercism-file-p) "busted" (format "lua %s" file)))
        ((derived-mode-p 'python-mode 'python-ts-mode)
         (format "python3 %s" file))
        ((derived-mode-p 'ruby-mode 'ruby-ts-mode)
         (if (my-exercism-file-p)
             "minitest ."
           (format "ruby --zjit %s" file)))
        ((derived-mode-p 'swift-mode 'swift-ts-mode)
         (if (my-exercism-file-p)
             (my-command-in-directory
              (or (my-project-file-directory "Package.swift")
                  (file-name-directory buffer-file-name))
              "RUNALL=true swift test -j 10")
           (format "swift %s" file)))
        ((derived-mode-p 'zig-mode 'zig-ts-mode)
         (cond
          ((my-exercism-file-p)
           (format "cd %s && zig test test_%s"
                   (shell-quote-argument
                    (file-name-directory buffer-file-name))
                   (shell-quote-argument
                    (file-name-nondirectory buffer-file-name))))
          ((my-project-file-directory "build.zig")
           (my-command-in-directory
            (my-project-file-directory "build.zig") "zig build run"))
          (t (format "zig run %s" file))))
        ((derived-mode-p 'forth-mode)
         (format "gforth %s -e bye" file))
        (t compile-command))))))

(defun my-compile ()
  "Run the buffer-local compile or test command."
  (interactive)
  (save-some-buffers t)
  (compile compile-command))

(add-hook 'prog-mode-hook #'my-configure-compile-command)

(require 'autoinsert)

(setq auto-insert-query nil)

(define-auto-insert "\\.c\\'"
  (lambda ()
    (insert "/*usr/bin/env gcc \"$0\"; ./a.out; rm a.out; exit 0; */\n\n\n")
    (my-configure-compile-command)))

(define-auto-insert "/main\\.go\\'"
  (lambda ()
    (insert "package main\n\nimport \"fmt\"\n\n"
            "func main() {\n    fmt.Println(\"Hello, world!\")\n}\n")))

(define-auto-insert "\\.rb\\'"
  (lambda ()
    (insert "#! /usr/bin/env ruby\n# frozen_string_literal: true\n\n")))

(auto-insert-mode 1)

;;;; External language modes

(add-to-list 'auto-mode-alist '("/go\\.mod\\'" . go-dot-mod-mode))
(add-to-list 'auto-mode-alist '("/go\\.work\\'" . go-dot-work-mode))

(use-package fish-mode
  :mode "\\.fish\\'")

(use-package elm-mode
  :mode "\\.elm\\'")

(use-package haskell-mode
  :mode "\\.hs\\'")

(use-package powershell
  :mode (("\\.ps[dm]?1\\'" . powershell-mode)))

(use-package svelte-mode
  :mode "\\.svelte\\'")

(use-package swift-mode
  :mode "\\.swift\\'")

(use-package vue-mode
  :mode "\\.vue\\'"
  :hook (vue-mode . my-enable-format-on-save))

(use-package zig-mode
  :mode "\\.zig\\'"
  :custom
  (zig-format-on-save nil))

;;;; Git and terminal

(use-package browse-at-remote
  :commands browse-at-remote
  :bind ("C-c g b" . browse-at-remote))

(use-package magit
  :commands magit-status
  :bind ("C-x g" . magit-status))

(use-package diff-hl
  :custom-face
  (diff-hl-insert ((t (:foreground "#60b444"))))
  (diff-hl-change ((t (:foreground "#ea9955"))))
  (diff-hl-delete ((t (:foreground "#ff656f"))))
  :config
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1)
  (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh))

(use-package vterm
  :commands vterm
  :custom
  (vterm-kill-buffer-on-exit t))

;;;; Org

(use-package org
  :ensure nil
  :custom
  (org-startup-folded 'fold)
  (org-startup-indented t)
  (org-startup-with-link-previews t)
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

(setq package-selected-packages my-packages)

(unless noninteractive
  (server-mode 1))

;;; init.el ends here
