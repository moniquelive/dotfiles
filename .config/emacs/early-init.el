;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-

(defvar evil-want-integration)
(defvar evil-want-keybinding)

(setq package-enable-at-startup nil
      inhibit-startup-screen t
      frame-inhibit-implied-resize t
      load-prefer-newer t
      evil-want-integration t
      evil-want-keybinding nil)

(setq default-frame-alist
      (append '((tool-bar-lines . 0)
                (menu-bar-lines . 0)
                (vertical-scroll-bars . nil)
                (internal-border-width . 12)
                (background-color . "#190a0f")
                (foreground-color . "#d3cfcf")
                (font . "MonoLisaCode 15"))
              default-frame-alist))

;;; early-init.el ends here
