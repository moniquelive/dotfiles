;;; init-test.el --- Tests for init.el -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)

(defconst my-test-config-directory
  (file-name-directory
   (directory-file-name
    (file-name-directory (or load-file-name buffer-file-name)))))

(defconst my-test-user-emacs-directory
  (file-name-as-directory (make-temp-file "emacs-init-test-" t)))

(setq package-user-dir
      (expand-file-name "elpa/" my-test-user-emacs-directory)
      package-directory-list
      (list (expand-file-name "elpa/" my-test-config-directory))
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
  (let ((state-directory
         (expand-file-name "var/" my-test-user-emacs-directory)))
    (should (equal my-state-directory state-directory))
    (should (file-directory-p (expand-file-name "backups/" state-directory)))
    (should (file-directory-p (expand-file-name "auto-save/" state-directory)))
    (dolist (file (list custom-file savehist-file save-place-file
                        recentf-save-file project-list-file))
      (should (file-in-directory-p file state-directory)))
    (should-not (bound-and-true-p server-mode))))

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
               (lambda (&rest _) (cl-incf save-calls))))
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

(ert-deftest my-test-emacs-lisp-treesit-setup-does-nothing-when-unavailable ()
  (let ((parser-calls 0)
        (ready-arguments nil)
        (setup-calls 0)
        (treesit-auto-install nil))
    (cl-letf (((symbol-function 'treesit-ready-p)
               (lambda (&rest arguments)
                 (setq ready-arguments arguments)
                 nil))
              ((symbol-function 'treesit-parser-create)
               (lambda (_) (cl-incf parser-calls)))
              ((symbol-function 'treesit-major-mode-setup)
               (lambda () (cl-incf setup-calls))))
      (with-temp-buffer
        (setq-local treesit-font-lock-level 'unchanged)
        (my-emacs-lisp-treesit-setup)
        (should (equal ready-arguments '(elisp t)))
        (should (eq treesit-font-lock-level 'unchanged))
        (should (zerop parser-calls))
        (should (zerop setup-calls))))))

(ert-deftest my-test-emacs-lisp-treesit-setup-offers-to-install-grammar ()
  (let ((install-language nil)
        (prompt nil)
        (treesit-auto-install 'prompt))
    (cl-letf (((symbol-function 'treesit-ready-p) (lambda (&rest _) nil))
              ((symbol-function 'y-or-n-p)
               (lambda (message)
                 (setq prompt message)
                 t))
              ((symbol-function 'treesit-install-language-grammar)
               (lambda (language) (setq install-language language))))
      (with-temp-buffer
        (my-emacs-lisp-treesit-setup)
        (should (equal prompt
                       "Tree-sitter grammar for elisp is missing.  Install it? "))
        (should (eq install-language 'elisp))))))

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
                 (cl-incf parser-calls)))
              ((symbol-function 'treesit-font-lock-rules)
               (lambda (&rest arguments)
                 (setq rules-arguments arguments)
                 'settings))
              ((symbol-function 'treesit-major-mode-setup)
               (lambda () (cl-incf setup-calls))))
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
         (cons (expand-file-name "tree-sitter/" my-test-config-directory)
               treesit-extra-load-path)))
    (skip-unless (treesit-ready-p 'elisp t))
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
  (let ((major-mode 'unsupported-mode)
        (executable-calls 0)
        (eglot-calls 0))
    (cl-letf (((symbol-function 'executable-find)
               (lambda (_)
                 (cl-incf executable-calls)))
              ((symbol-function 'eglot-ensure)
               (lambda () (cl-incf eglot-calls))))
      (my-eglot-ensure)
      (should (zerop executable-calls))
      (should (zerop eglot-calls)))))

(ert-deftest my-test-eglot-ensure-starts-only-for-an-available-candidate ()
  (let ((major-mode 'python-ts-mode)
        (checked nil)
        (eglot-calls 0))
    (cl-letf (((symbol-function 'executable-find)
               (lambda (executable)
                 (push executable checked)
                 (and (equal executable "pyright-langserver") executable)))
              ((symbol-function 'eglot-ensure)
               (lambda () (cl-incf eglot-calls))))
      (my-eglot-ensure)
      (should (equal (nreverse checked)
                     '("pylsp" "basedpyright-langserver"
                       "pyright-langserver")))
      (should (= eglot-calls 1)))
    (setq checked nil
          eglot-calls 0)
    (cl-letf (((symbol-function 'executable-find)
               (lambda (executable)
                 (push executable checked)
                 nil))
              ((symbol-function 'eglot-ensure)
               (lambda () (cl-incf eglot-calls))))
      (my-eglot-ensure)
      (should (= (length checked) 6))
      (should (zerop eglot-calls)))))

(ert-deftest my-test-eglot-format-on-save-follows-server-capability ()
  (let ((managed nil)
        (formatting nil))
    (cl-letf (((symbol-function 'eglot-managed-p) (lambda () managed))
              ((symbol-function 'eglot-server-capable)
               (lambda (_) formatting)))
      (with-temp-buffer
        (my-eglot-format-on-save)
        (should-not (memq #'eglot-format-buffer before-save-hook))

        (setq managed t)
        (my-eglot-format-on-save)
        (should-not (memq #'eglot-format-buffer before-save-hook))

        (setq formatting t)
        (my-eglot-format-on-save)
        (my-eglot-format-on-save)
        (should (local-variable-p 'before-save-hook))
        (should (= (cl-count #'eglot-format-buffer before-save-hook) 1))

        (setq managed nil)
        (my-eglot-format-on-save)
        (should-not (memq #'eglot-format-buffer before-save-hook))))))

(ert-deftest my-test-clojure-modes-use-clojure-lsp ()
  (dolist (mode '(clojure-ts-mode
                  clojure-ts-clojurescript-mode
                  clojure-ts-clojurec-mode))
    (should (equal (alist-get mode my-eglot-server-executables)
                   '("clojure-lsp"))))
  (should (memq #'my-eglot-ensure clojure-ts-mode-hook))
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
               (lambda (&rest _) (cl-incf calls)))
              ((symbol-function 'eglot-format-buffer)
               (lambda () (cl-incf calls))))
      (my-go-before-save)
      (should (zerop calls)))))

(ert-deftest my-test-go-setup-keeps-one-buffer-local-save-hook ()
  (let ((eglot-calls 0))
    (cl-letf (((symbol-function 'my-eglot-ensure)
               (lambda () (cl-incf eglot-calls))))
      (with-temp-buffer
        (my-go-setup)
        (my-go-setup)
        (should (local-variable-p 'before-save-hook))
        (should (= (cl-count #'my-go-before-save before-save-hook) 1))
        (should (= eglot-calls 2))))))

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
                     (lambda () (cl-incf eglot-calls))))
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
                     (lambda () (cl-incf eglot-calls))))
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
               (lambda () (cl-incf configure-calls))))
      (with-temp-buffer
        (setq buffer-file-name "/tmp/example.py")
        (my-python-setup)
        (should (zerop configure-calls))
        (should (memq #'my-python-configure hack-local-variables-hook))
        (run-hooks 'hack-local-variables-hook)
        (should (= configure-calls 1))))))

;;; init-test.el ends here
