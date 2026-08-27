;;; init-test.el --- Tests for init.el -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)

(defconst my-test-config-directory
  (file-name-directory
   (directory-file-name
    (file-name-directory (or load-file-name buffer-file-name)))))

(defconst my-test-user-emacs-directory
  (file-name-as-directory (make-temp-file "emacs-init-test-" t)))

(defconst my-test-installed-package-directory
  (expand-file-name "emacs/elpa/"
                    (or (getenv "XDG_DATA_HOME") "~/.local/share/")))

(defconst my-test-installed-tree-sitter-directory
  (expand-file-name "emacs/tree-sitter/"
                    (or (getenv "XDG_DATA_HOME") "~/.local/share/")))

(setenv "XDG_CACHE_HOME"
        (expand-file-name "cache/" my-test-user-emacs-directory))
(setenv "XDG_DATA_HOME"
        (expand-file-name "data/" my-test-user-emacs-directory))
(setenv "XDG_STATE_HOME"
        (expand-file-name "state/" my-test-user-emacs-directory))

(setq package-directory-list (list my-test-installed-package-directory)
      user-emacs-directory my-test-user-emacs-directory)

(load (expand-file-name "early-init.el" my-test-config-directory) nil t)
(load (expand-file-name "init.el" my-test-config-directory) nil t)

(add-hook 'kill-emacs-hook
          (lambda ()
            (delete-directory my-test-user-emacs-directory t))
          t)

(defun my-test-make-virtualenv (directory)
  "Create a minimal executable Python environment in DIRECTORY."
  (let ((python (expand-file-name "bin/python" directory)))
    (make-directory (file-name-directory python) t)
    (write-region "" nil python nil 'silent)
    (set-file-modes python #o755)))

(ert-deftest my-test-startup-keeps-state-out-of-the-config-root ()
  (require 'ielm)
  (let ((state-directory
         (expand-file-name "state/emacs/" my-test-user-emacs-directory)))
    (should (equal my-state-directory state-directory))
    (should (equal my-cache-directory
                   (expand-file-name "cache/emacs/"
                                     my-test-user-emacs-directory)))
    (should (equal my-data-directory
                   (expand-file-name "data/emacs/"
                                     my-test-user-emacs-directory)))
    (should (file-in-directory-p package-user-dir my-data-directory))
    (should (file-in-directory-p tramp-persistency-file-name
                                 my-state-directory))
    (dolist (file (list abbrev-file-name bookmark-default-file
                        ielm-history-file-name
                        server-auth-dir transient-history-file
                        transient-levels-file transient-values-file
                        url-configuration-directory))
      (should (file-in-directory-p file my-state-directory)))
    (should (file-in-directory-p org-persist-directory my-cache-directory))
    (should (file-directory-p (expand-file-name "backups/" state-directory)))
    (should (file-directory-p (expand-file-name "auto-save/" state-directory)))
    (dolist (file (list custom-file my-frame-geometry-file savehist-file
                        save-place-file recentf-save-file project-list-file))
      (should (file-in-directory-p file state-directory)))
    (should-not (bound-and-true-p server-mode))))

(ert-deftest my-test-config-byte-compiles-without-warnings ()
  (require 'bytecomp)
  (let ((directory (make-temp-file "emacs-config-compile-" t))
        (byte-compile-error-on-warn t))
    (unwind-protect
        (dolist (name '("early-init.el" "init.el"))
          (let ((target (expand-file-name name directory)))
            (copy-file (expand-file-name name my-test-config-directory) target)
            (should (byte-compile-file target))))
      (delete-directory directory t))))

(ert-deftest my-test-emacs-31-state-and-ui-options-are-enabled ()
  (require 'ibuffer)
  (should (= recentf-autosave-interval 300))
  (should (= save-place-autosave-interval 300))
  (should ibuffer-human-readable-size)
  (should icomplete-vertical-render-prefix-indicator)
  (should (eq mode-line-collapse-minor-modes t))
  (should-not native-comp-async-on-battery-power)
  (should (eq tab-bar-truncate t))
  (should (eq project-mode-line 'non-remote)))

(ert-deftest my-test-macos-tools-are-portable-and-ordered ()
  (skip-unless (eq system-type 'darwin))
  (should delete-by-moving-to-trash)
  (if (executable-find "gls")
      (progn
        (should (string-suffix-p "/gls" insert-directory-program))
        (should (string-match-p "group-directories-first"
                                dired-listing-switches)))
    (should (equal insert-directory-program "ls"))
    (should-not (string-match-p "group-directories-first"
                                dired-listing-switches)))
  (let ((configured
         (seq-filter
          #'file-directory-p
          (mapcar #'expand-file-name
                  '("/opt/homebrew/bin"
                    "~/.local/bin"
                    "~/.local/share/nvim/mason/bin"
                    "~/.local/share/mise/shims"
                    "~/go/bin"
                    "~/.ghcup/bin")))))
    (should (equal (seq-take exec-path (length configured)) configured))))

(ert-deftest my-test-packages-have-an-explicit-manifest ()
  (dolist (package '(browse-at-remote cider evil-surround reformatter
                     fish-mode powershell svelte-mode swift-mode
                     treesit-fold vue-mode))
    (should (memq package package-selected-packages)))
  (should-not use-package-always-ensure))

(ert-deftest my-test-missing-packages-are-synchronized-automatically ()
  (let ((sync-calls 0))
    (cl-letf (((symbol-function 'package-installed-p)
               (lambda (package) (not (eq package 'evil))))
              ((symbol-function 'my-package-sync)
               (lambda () (incf sync-calls))))
      (my-package-sync-if-needed))
    (should (= sync-calls 1))
    (cl-letf (((symbol-function 'package-installed-p) (lambda (_) t))
              ((symbol-function 'my-package-sync)
               (lambda () (incf sync-calls))))
      (my-package-sync-if-needed))
    (should (= sync-calls 1))))

(ert-deftest my-test-evil-normal-post-command-supports-emacs-31 ()
  (should evil-mode)
  (let ((this-command #'ignore))
    (evil-normal-post-command)))

(ert-deftest my-test-org-98-startup-options-are-current ()
  (require 'org)
  (should (eq org-startup-folded 'fold))
  (should org-startup-with-link-previews))

(ert-deftest my-test-frame-geometry-round-trips ()
  (let ((my-frame-geometry-file (make-temp-file "emacs-frame-geometry-"))
        (my-frame-geometry-restored nil)
        (frame 'graphical-frame)
        (calls nil))
    (unwind-protect
        (progn
          (cl-letf (((symbol-function 'display-graphic-p) (lambda (&optional _) t))
                    ((symbol-function 'selected-frame) (lambda () frame))
                    ((symbol-function 'frame-geometry)
                     (lambda (_) '((outer-position . (120 . 80)))))
                    ((symbol-function 'frame-text-width) (lambda (_) 1200))
                    ((symbol-function 'frame-text-height) (lambda (_) 800))
                    ((symbol-function 'frame-parameter)
                     (lambda (_ parameter)
                       (and (eq parameter 'fullscreen) 'maximized))))
            (my-save-frame-geometry))
          (with-temp-buffer
            (insert-file-contents my-frame-geometry-file)
            (should
             (equal (read (current-buffer))
                    '(:left 120 :top 80 :width 1200 :height 800
                      :fullscreen maximized))))
          (cl-letf (((symbol-function 'display-graphic-p) (lambda (_) t))
                    ((symbol-function 'set-frame-size-and-position-pixelwise)
                     (lambda (&rest arguments)
                       (should (eq alter-fullscreen-frames t))
                       (push (cons 'geometry arguments) calls)))
                    ((symbol-function 'set-frame-parameter)
                     (lambda (&rest arguments)
                       (push (cons 'parameter arguments) calls))))
            (let ((alter-fullscreen-frames 'inhibit))
              (my-restore-frame-geometry frame)
              (my-restore-frame-geometry frame)))
          (should
           (equal (nreverse calls)
                  `((geometry ,frame 1200 800 120 80)
                    (parameter ,frame fullscreen maximized)))))
      (delete-file my-frame-geometry-file))))

(ert-deftest my-test-frame-geometry-failure-remains-retryable ()
  (let ((my-frame-geometry-file (make-temp-file "emacs-frame-geometry-"))
        (my-frame-geometry-restored nil)
        (frame 'graphical-frame)
        (geometry-calls 0)
        (warning nil))
    (unwind-protect
        (cl-letf (((symbol-function 'display-graphic-p) (lambda (_) t))
                  ((symbol-function 'set-frame-size-and-position-pixelwise)
                   (lambda (&rest _) (incf geometry-calls)))
                  ((symbol-function 'set-frame-parameter) #'ignore)
                  ((symbol-function 'display-warning)
                   (lambda (_type message &rest _) (setq warning message))))
          (with-temp-file my-frame-geometry-file
            (prin1 '(:left 120 :top 80 :width 0 :height 800) (current-buffer)))
          (my-restore-frame-geometry frame)
          (should-not my-frame-geometry-restored)
          (should (string-match-p "Invalid saved frame geometry" warning))
          (should (zerop geometry-calls))
          (with-temp-file my-frame-geometry-file
            (prin1 '(:left 120 :top 80 :width 1200 :height 800) (current-buffer)))
          (my-restore-frame-geometry frame)
          (should my-frame-geometry-restored)
          (should (= geometry-calls 1)))
      (delete-file my-frame-geometry-file))))

(ert-deftest my-test-focus-change-debounces-save-checks ()
  (let ((my-focus-out-save-timer 'old-timer)
        (cancelled nil))
    (cl-letf (((symbol-function 'timerp)
               (lambda (timer) (eq timer 'old-timer)))
              ((symbol-function 'cancel-timer)
               (lambda (timer) (setq cancelled timer)))
              ((symbol-function 'run-with-idle-timer)
               (lambda (seconds repeat function &rest arguments)
                 (should (zerop seconds))
                 (should-not repeat)
                 (should (eq function #'my-save-buffers-if-unfocused))
                 (should (null arguments))
                 'new-timer)))
      (my-save-buffers-on-focus-change)
      (should (eq cancelled 'old-timer))
      (should (eq my-focus-out-save-timer 'new-timer)))))

(ert-deftest my-test-macos-focus-frame-activates-graphical-emacs ()
  (skip-unless (eq system-type 'darwin))
  (let ((frame (selected-frame))
        (calls nil))
    (cl-letf (((symbol-function 'display-graphic-p)
               (lambda (candidate)
                 (should (eq candidate frame))
                 t))
              ((symbol-function 'ns-do-applescript)
               (lambda (script) (push (list 'activate script) calls)))
              ((symbol-function 'raise-frame)
               (lambda (candidate) (push (list 'raise candidate) calls)))
              ((symbol-function 'select-frame-set-input-focus)
               (lambda (candidate) (push (list 'focus candidate) calls))))
      (my-macos-focus-frame frame)
      (should
       (equal
        (nreverse calls)
        `((activate "tell application id \"org.gnu.Emacs\" to activate")
          (raise ,frame)
          (focus ,frame)))))))

(ert-deftest my-test-focus-check-saves-only-when-every-frame-is-unfocused ()
  (let ((states '((first . t) (second)))
        (save-calls 0)
        (my-focus-out-save-timer 'timer))
    (cl-letf (((symbol-function 'frame-list) (lambda () '(first second)))
              ((symbol-function 'frame-focus-state)
               (lambda (frame) (alist-get frame states)))
              ((symbol-function 'save-some-buffers)
               (lambda (&rest _) (incf save-calls))))
      (my-save-buffers-if-unfocused)
      (should (zerop save-calls))
      (setf (alist-get 'first states) nil
            (alist-get 'second states) 'unknown)
      (my-save-buffers-if-unfocused)
      (should (zerop save-calls))
      (setf (alist-get 'second states) nil)
      (my-save-buffers-if-unfocused)
      (should (= save-calls 1))
      (should-not my-focus-out-save-timer))))

(ert-deftest my-test-whitespace-trimming-respects-editorconfig ()
  (require 'editorconfig)
  (with-temp-buffer
    (text-mode)
    (should delete-trailing-whitespace-mode)
    (insert "Markdown hard break  \n")
    (let ((properties (make-hash-table)))
      (puthash 'trim_trailing_whitespace "false" properties)
      (editorconfig-set-local-variables properties))
    (should-not delete-trailing-whitespace-mode)
    (run-hooks 'before-save-hook)
    (should (equal (buffer-string) "Markdown hard break  \n"))
    (let ((properties (make-hash-table)))
      (puthash 'trim_trailing_whitespace "true" properties)
      (editorconfig-set-local-variables properties))
    (should delete-trailing-whitespace-mode)
    (run-hooks 'before-save-hook)
    (should (equal (buffer-string) "Markdown hard break\n"))))

(ert-deftest my-test-programming-buffers-trim-whitespace-by-default ()
  (with-temp-buffer
    (prog-mode)
    (should delete-trailing-whitespace-mode)
    (should (memq #'delete-trailing-whitespace-if-possible
                  before-save-hook))))

(ert-deftest my-test-emacs-lisp-treesit-setup-does-nothing-when-unavailable ()
  (let ((parser-calls 0)
        (ready-arguments nil)
        (setup-calls 0))
    (cl-letf (((symbol-function 'treesit-ready-p)
               (lambda (&rest arguments)
                 (setq ready-arguments arguments)
                 nil))
              ((symbol-function 'treesit-ensure-installed) #'ignore)
              ((symbol-function 'treesit-parser-create)
               (lambda (_) (incf parser-calls)))
              ((symbol-function 'treesit-major-mode-setup)
               (lambda () (incf setup-calls))))
      (with-temp-buffer
        (setq-local treesit-font-lock-level 'unchanged)
        (my-emacs-lisp-treesit-setup)
        (should (equal ready-arguments '(elisp t)))
        (should (eq treesit-font-lock-level 'unchanged))
        (should (zerop parser-calls))
        (should (zerop setup-calls))))))

(ert-deftest my-test-emacs-lisp-treesit-setup-ensures-missing-grammar ()
  (let ((install-language nil)
        (noninteractive nil))
    (cl-letf (((symbol-function 'treesit-ready-p) (lambda (&rest _) nil))
              ((symbol-function 'treesit-ensure-installed)
               (lambda (language) (setq install-language language))))
      (with-temp-buffer
        (my-emacs-lisp-treesit-setup)
        (should (eq install-language 'elisp))))))

(ert-deftest my-test-emacs-31-tree-sitter-automation-is-enabled ()
  (should (eq treesit-enabled-modes t))
  (should (eq treesit-auto-install-grammar 'never))
  (should-not (featurep 'treesit-auto))
  (dolist (remap '((python-mode . python-ts-mode)
                   (go-mode . go-ts-mode)
                   (elixir-mode . elixir-ts-mode)))
    (should (member remap major-mode-remap-alist))))

(ert-deftest my-test-emacs-lisp-treesit-setup-configures-an-available-parser ()
  (let ((parser-calls 0)
        (rules-arguments nil)
        (setup-calls 0))
    (cl-letf (((symbol-function 'treesit-ready-p)
               (lambda (language quiet)
                 (should (eq language 'elisp))
                 (should quiet)
                 t))
              ((symbol-function 'treesit-parser-create)
               (lambda (language)
                 (should (eq language 'elisp))
                 (incf parser-calls)))
              ((symbol-function 'treesit-font-lock-rules)
               (lambda (&rest arguments)
                 (setq rules-arguments arguments)
                 'settings))
              ((symbol-function 'treesit-major-mode-setup)
               (lambda () (incf setup-calls))))
      (with-temp-buffer
        (my-emacs-lisp-treesit-setup)
        (should (= treesit-font-lock-level 4))
        (should (equal treesit-font-lock-settings 'settings))
        (should (null font-lock-defaults))
        (should (memq :feature rules-arguments))
        (should (= parser-calls 1))
        (should (= setup-calls 1))))))

(ert-deftest my-test-emacs-lisp-treesit-queries-compile ()
  (let ((treesit-extra-load-path
         (cons my-test-installed-tree-sitter-directory
               treesit-extra-load-path)))
    (should (treesit-ready-p 'elisp t))
    (with-temp-buffer
      (insert "(defun foo (bar) bar)\n"
              "(setq first 1 second 2)\n"
              "(setq alpha beta gamma delta)\n"
              "(setq commented 1 ; note\n after-comment symbol-value)\n"
              "(let ((local 1)) local)\n"
              "(lambda (argument) argument)\n"
              "'(quoted data)\n")
      (emacs-lisp-mode)
      (font-lock-ensure)
      (should (= treesit-font-lock-level 4))
      (should (memq 'elisp
                    (mapcar #'treesit-parser-language
                            (treesit-parser-list))))
      (goto-char (point-min))
      (dolist (expected '(("foo" . font-lock-function-name-face)
                          ("bar" . font-lock-variable-name-face)
                          ("first" . font-lock-variable-name-face)
                          ("second" . font-lock-variable-name-face)
                          ("alpha" . font-lock-variable-name-face)
                          ("beta")
                          ("gamma" . font-lock-variable-name-face)
                          ("delta")
                          ("commented" . font-lock-variable-name-face)
                          ("after-comment" . font-lock-variable-name-face)
                          ("symbol-value")
                          ("local" . font-lock-variable-name-face)
                          ("argument")
                          ("quoted")))
        (search-forward (car expected))
        (should (eq (get-text-property (match-beginning 0) 'face)
                    (cdr expected)))))))

(ert-deftest my-test-eglot-ensure-ignores-unsupported-modes ()
  (require 'eglot)
  (let ((guess-calls 0)
        (eglot-calls 0))
    (cl-letf (((symbol-function 'eglot--guess-contact)
               (lambda (&optional _)
                 (incf guess-calls)
                 (user-error "No server")))
              ((symbol-function 'eglot-ensure)
               (lambda () (incf eglot-calls))))
      (my-eglot-ensure)
      (should (= guess-calls 1))
      (should (zerop eglot-calls)))))

(ert-deftest my-test-eglot-ensure-uses-eglots-resolved-contact ()
  (let ((guess-calls 0)
        (eglot-calls 0))
    (cl-letf (((symbol-function 'eglot--guess-contact)
               (lambda (&optional _)
                 (incf guess-calls)
                 '(python-ts-mode project class ("pylsp") nil)))
              ((symbol-function 'eglot-ensure)
               (lambda () (incf eglot-calls))))
      (my-eglot-ensure)
      (should (= guess-calls 1))
      (should (= eglot-calls 1)))))

(ert-deftest my-test-format-on-save-has-one-owner ()
  (with-temp-buffer
    (prog-mode)
    (my-enable-format-on-save)
    (should (local-variable-p 'before-save-hook))
    (should (= (cl-count #'my-format-buffer before-save-hook) 1))
    (should-not (memq #'eglot-format-buffer before-save-hook))))

(ert-deftest my-test-external-formatter-precedes-eglot ()
  (let ((external-calls 0)
        (eglot-calls 0))
    (cl-letf (((symbol-function 'executable-find)
               (lambda (program) (and (equal program "shfmt") program)))
              ((symbol-function 'my-shfmt-buffer)
               (lambda (&optional _) (incf external-calls)))
              ((symbol-function 'my-eglot-can-format-p) (lambda () t))
              ((symbol-function 'eglot-format-buffer)
               (lambda () (incf eglot-calls))))
      (with-temp-buffer
        (setq major-mode 'sh-mode)
        (my-format-buffer))
      (should (= external-calls 1))
      (should (zerop eglot-calls)))))

(ert-deftest my-test-formatting-falls-back-to-eglot ()
  (let ((eglot-calls 0))
    (cl-letf (((symbol-function 'executable-find) (lambda (_) nil))
              ((symbol-function 'my-eglot-can-format-p) (lambda () t))
              ((symbol-function 'eglot-format-buffer)
               (lambda () (incf eglot-calls))))
      (with-temp-buffer
        (setq major-mode 'fundamental-mode)
        (my-format-buffer))
      (should (= eglot-calls 1)))))

(ert-deftest my-test-language-formatters-do-not-compete ()
  (require 'elm-mode)
  (require 'zig-mode)
  (should-not (memq #'elm-format-on-save-mode elm-mode-hook))
  (should-not zig-format-on-save)
  (should-not (memq #'eglot-format-buffer eglot-managed-mode-hook)))

(ert-deftest my-test-conventional-modes-retain-language-setup ()
  (should (memq #'my-python-setup python-mode-hook))
  (should (memq #'my-go-setup go-mode-hook))
  (dolist (hook (list c-mode-hook sh-mode-hook ruby-mode-hook))
    (should (memq #'my-eglot-ensure hook)))
  (should (eq (assoc-default "/tmp/go.mod" auto-mode-alist #'string-match)
              'go-dot-mod-mode))
  (should (eq (assoc-default "/tmp/go.work" auto-mode-alist #'string-match)
              'go-dot-work-mode))
  (should (memq #'my-enable-format-on-save html-mode-hook))
  (should (memq #'my-enable-format-on-save html-ts-mode-hook)))

(ert-deftest my-test-flymake-uses-emacs-31-diagnostic-display ()
  (require 'flymake)
  (should (eq flymake-show-diagnostics-at-end-of-line 'fancy))
  (let ((formatted nil)
        (shown nil))
    (cl-letf (((symbol-function 'flymake-diagnostics)
               (lambda (&rest _) '(first second)))
              ((symbol-function 'flymake-diagnostic-text)
               (lambda (diagnostic parts)
                 (push (list diagnostic parts) formatted)
                 (symbol-name diagnostic)))
              ((symbol-function 'message)
               (lambda (format-string &rest arguments)
                 (setq shown (apply #'format format-string arguments)))))
      (with-temp-buffer
        (my-flymake-show-line-diagnostics)))
    (should (equal shown "first\nsecond"))
    (should
     (equal (nreverse formatted)
            '((first (origin code oneliner))
              (second (origin code oneliner)))))))

(ert-deftest my-test-clojure-modes-use-clojure-lsp ()
  (require 'eglot)
  (should
   (equal
    (cdr
     (seq-find
      (lambda (entry)
        (equal (car entry)
               '(clojure-ts-mode clojure-ts-clojurescript-mode
                 clojure-ts-clojurec-mode)))
      eglot-server-programs))
    '("clojure-lsp"
      :initializationOptions my-clojure-lsp-initialization-options)))
  (should (memq #'my-eglot-ensure clojure-ts-mode-hook))
  (should (memq #'my-eglot-ensure clojure-mode-hook))
  (should (memq #'cider-mode clojure-ts-mode-hook)))

(ert-deftest my-test-clojure-build-files-mark-project-roots ()
  (let* ((root (make-temp-file "clojure-project-" t))
         (source-directory (expand-file-name "src/example/" root)))
    (unwind-protect
        (progn
          (make-directory source-directory t)
          (write-region "" nil (expand-file-name "project.clj" root))
          (should
           (equal (project-root (project-current nil source-directory))
                  (file-name-as-directory root))))
      (delete-directory root t))))

(ert-deftest my-test-eglot-has-a-markdown-hover-renderer ()
  (require 'eglot)
  (should (fboundp 'gfm-view-mode)))

(ert-deftest my-test-clojure-lsp-options-use-available-fallbacks ()
  (cl-letf (((symbol-function 'executable-find)
             (lambda (executable)
               (member executable '("lein" "bb")))))
    (should
     (equal
      (my-clojure-lsp-initialization-options nil)
      '(:cljfmt (:remove-multiple-non-indenting-spaces? t)
        :project-specs
        [(:project-path "project.clj"
          :classpath-cmd ["lein" "classpath"])
         (:project-path "bb.edn"
          :classpath-cmd ["bb" "print-deps" "--format" "classpath"])])))))

(ert-deftest my-test-clojure-lsp-options-prefer-clojure-cli ()
  (let ((checked nil))
    (cl-letf (((symbol-function 'executable-find)
               (lambda (executable)
                 (push executable checked)
                 (equal executable "clojure"))))
      (should
       (equal
        (my-clojure-lsp-initialization-options nil)
        '(:cljfmt (:remove-multiple-non-indenting-spaces? t))))
      (should (equal checked '("clojure"))))))

(ert-deftest my-test-go-before-save-runs-actions-only-when-managed ()
  (let ((managed nil)
        (calls nil))
    (cl-letf (((symbol-function 'eglot-managed-p) (lambda () managed))
              ((symbol-function 'eglot-code-action-organize-imports)
               (lambda (start end)
                 (push (list 'organize start end) calls)))
              ((symbol-function 'eglot-format-buffer)
               (lambda () (push 'format calls))))
      (with-temp-buffer
        (my-go-before-save)
        (should (null calls))
        (setq managed t)
        (my-go-before-save)
        (should (equal calls '((organize 1 1))))))))

(ert-deftest my-test-go-before-save-ignores-unloaded-eglot ()
  (let ((calls 0))
    (cl-letf (((symbol-function 'eglot-managed-p) nil)
              ((symbol-function 'eglot-code-action-organize-imports)
               (lambda (&rest _) (incf calls)))
              ((symbol-function 'eglot-format-buffer)
               (lambda () (incf calls))))
      (my-go-before-save)
      (should (zerop calls)))))

(ert-deftest my-test-go-setup-keeps-one-buffer-local-save-hook ()
  (let ((eglot-calls 0))
    (cl-letf (((symbol-function 'my-eglot-ensure)
               (lambda () (incf eglot-calls))))
      (with-temp-buffer
        (my-go-setup)
        (my-go-setup)
        (should (local-variable-p 'before-save-hook))
        (should (= (cl-count #'my-go-before-save before-save-hook) 1))
        (should (= eglot-calls 2))))))

(ert-deftest my-test-compile-commands-follow-language-and-project ()
  (let ((root (make-temp-file "emacs-compile-command-" t)))
    (unwind-protect
        (progn
          (with-temp-buffer
            (setq buffer-file-name
                  (expand-file-name "Exercism/go/two-fer/two_fer.go" root)
                  default-directory (file-name-directory buffer-file-name)
                  major-mode 'go-mode)
            (make-directory default-directory t)
            (my-configure-compile-command)
            (should (equal compile-command "go test -v .")))
          (write-region "" nil (expand-file-name "build.zig" root))
          (with-temp-buffer
            (setq buffer-file-name (expand-file-name "src/main.zig" root)
                  default-directory (file-name-directory buffer-file-name)
                  major-mode 'zig-mode)
            (make-directory default-directory t)
            (my-configure-compile-command)
            (should
             (equal compile-command
                    (my-command-in-directory root "zig build run")))))
      (delete-directory root t))))

(ert-deftest my-test-auto-insert-provides-neovim-file-templates ()
  (dolist (spec '(("example.c" . "/*usr/bin/env gcc")
                  ("main.go" . "package main")
                  ("example.rb" . "#! /usr/bin/env ruby")))
    (with-temp-buffer
      (setq buffer-file-name (expand-file-name (car spec) temporary-file-directory))
      (auto-insert)
      (goto-char (point-min))
      (should (looking-at-p (regexp-quote (cdr spec)))))))

(ert-deftest my-test-navigation-and-structural-keys-are-configured ()
  (should (eq (key-binding (kbd "M-g d")) #'consult-flymake))
  (should (eq (key-binding (kbd "M-s m")) #'consult-man))
  (should (eq (key-binding (kbd "C-c g b")) #'browse-at-remote))
  (should (eq (key-binding (kbd "<f5>")) #'my-compile))
  (should (eq (lookup-key evil-normal-state-map (kbd "ghx"))
              #'browse-at-remote))
  (should (eq (lookup-key evil-normal-state-map (kbd "TAB"))
              #'evil-toggle-fold))
  (should (eq (lookup-key evil-normal-state-map (kbd "<tab>"))
              #'evil-toggle-fold))
  (dolist (level (number-sequence 0 5))
    (should (eq (lookup-key evil-normal-state-map
                            (kbd (format "z%d" level)))
                #'my-treesit-fold-level)))
  (should global-treesit-fold-mode)
  (with-temp-buffer
    (insert "(alpha beta)")
    (goto-char (point-min))
    (my-treesit-expand-selection)
    (should mark-active)
    (should (equal (buffer-substring (region-beginning) (region-end))
                   "(alpha beta)"))))

(ert-deftest my-test-treesit-selection-uses-syntax-node-ranges ()
  (with-temp-buffer
    (insert "abcdef")
    (goto-char 3)
    (cl-letf (((symbol-function 'treesit-node-at) (lambda (&rest _) 'node))
              ((symbol-function 'treesit-node-start) (lambda (_) 2))
              ((symbol-function 'treesit-node-end) (lambda (_) 5)))
      (my-treesit-expand-selection))
    (should (= (point) 2))
    (should (= (mark) 5))))

(ert-deftest my-test-treesit-fold-level-closes-only-deeper-folds ()
  (let ((major-mode 'my-test-mode)
        (treesit-fold-range-alist
         '((my-test-mode . ((fold . ignore)))))
        (parents '((outer . root) (inner . outer) (deep . inner)))
        closed
        (opened 0))
    (cl-letf (((symbol-function 'treesit-fold-open-all)
               (lambda () (incf opened)))
              ((symbol-function 'treesit-buffer-root-node)
               (lambda () 'root))
              ((symbol-function 'treesit-node-language)
               (lambda (_) 'test))
              ((symbol-function 'treesit-query-compile)
               (lambda (&rest _) 'query))
              ((symbol-function 'treesit-query-capture)
               (lambda (&rest _)
                 '((name . outer) (name . inner) (name . deep))))
              ((symbol-function 'treesit-node-type)
               (lambda (node) (if (eq node 'root) "root" "fold")))
              ((symbol-function 'treesit-node-parent)
               (lambda (node) (alist-get node parents)))
              ((symbol-function 'treesit-fold--node-range-on-same-line)
               (lambda (_) nil))
              ((symbol-function 'treesit-fold-close)
               (lambda (node) (push node closed))))
      (my-treesit-fold-level 1))
    (should (= opened 1))
    (should (equal (nreverse closed) '(inner deep)))))

(ert-deftest my-test-python-setup-prefers-dot-venv ()
  (let ((root (make-temp-file "emacs-python-project-" t))
        (eglot-calls 0))
    (unwind-protect
        (progn
          (my-test-make-virtualenv (expand-file-name ".venv/" root))
          (my-test-make-virtualenv (expand-file-name "venv/" root))
          (cl-letf (((symbol-function 'project-current) (lambda (&optional _) t))
                    ((symbol-function 'project-root) (lambda (_) root))
                    ((symbol-function 'my-eglot-ensure)
                     (lambda () (incf eglot-calls))))
            (with-temp-buffer
              (setq-local exec-path '("/base/bin")
                          process-environment '("PATH=/base/bin" "KEEP=yes"))
              (my-python-setup)
              (let ((virtualenv (expand-file-name ".venv/" root))
                    (bin (expand-file-name ".venv/bin/" root)))
                (should (equal python-shell-virtualenv-root virtualenv))
                (should (equal exec-path (list bin "/base/bin")))
                (should (equal (getenv "PATH")
                               (concat bin path-separator "/base/bin")))
                (should (equal (getenv "VIRTUAL_ENV") virtualenv))
                (should (equal (getenv "KEEP") "yes"))
                (should (= eglot-calls 1))))))
      (delete-directory root t))))

(ert-deftest my-test-python-setup-handles-a-missing-path ()
  (let ((root (make-temp-file "emacs-python-project-" t)))
    (unwind-protect
        (progn
          (make-directory (expand-file-name ".venv/bin/" root) t)
          (my-test-make-virtualenv (expand-file-name "venv/" root))
          (cl-letf (((symbol-function 'project-current) (lambda (&optional _) t))
                    ((symbol-function 'project-root) (lambda (_) root))
                    ((symbol-function 'my-eglot-ensure) #'ignore))
            (with-temp-buffer
              (setq-local exec-path nil
                          process-environment '("KEEP=yes"))
              (my-python-setup)
              (let ((virtualenv (expand-file-name "venv/" root))
                    (bin (expand-file-name "venv/bin/" root)))
                (should (equal python-shell-virtualenv-root virtualenv))
                (should (equal exec-path (list bin)))
                (should (equal (getenv "PATH") bin))
                (should (equal (getenv "VIRTUAL_ENV") virtualenv))))))
      (delete-directory root t))))

(ert-deftest my-test-python-setup-is-idempotent-and-clears-stale-state ()
  (let ((root (make-temp-file "emacs-python-project-" t))
        (project-present t)
        (eglot-calls 0))
    (unwind-protect
        (progn
          (my-test-make-virtualenv (expand-file-name ".venv/" root))
          (cl-letf (((symbol-function 'project-current)
                     (lambda (&optional _) (and project-present t)))
                    ((symbol-function 'project-root) (lambda (_) root))
                    ((symbol-function 'my-eglot-ensure)
                     (lambda () (incf eglot-calls))))
            (with-temp-buffer
              (setq-local exec-path '("/base/bin")
                          process-environment '("PATH=/base/bin" "KEEP=yes")
                          python-shell-virtualenv-root "/existing/venv/")
              (my-python-setup)
              (my-python-setup)
              (let ((bin (expand-file-name ".venv/bin/" root)))
                (should (equal exec-path (list bin "/base/bin")))
                (should (equal (getenv "PATH")
                               (concat bin path-separator "/base/bin"))))
              (setq project-present nil)
              (my-python-setup)
              (should (equal exec-path '("/base/bin")))
              (should (equal process-environment
                             '("PATH=/base/bin" "KEEP=yes")))
              (should (local-variable-p 'python-shell-virtualenv-root))
              (should (equal python-shell-virtualenv-root
                             "/existing/venv/"))
              (should (= eglot-calls 3)))))
      (delete-directory root t))))

(ert-deftest my-test-python-file-setup-waits-for-local-variables ()
  (let ((configure-calls 0))
    (cl-letf (((symbol-function 'my-python-configure)
               (lambda () (incf configure-calls))))
      (with-temp-buffer
        (setq buffer-file-name "/tmp/example.py")
        (my-python-setup)
        (should (zerop configure-calls))
        (should (memq #'my-python-configure hack-local-variables-hook))
        (run-hooks 'hack-local-variables-hook)
        (should (= configure-calls 1))))))

;;; init-test.el ends here
