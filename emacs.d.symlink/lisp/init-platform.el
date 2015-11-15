;;; init-platform --- Platform-specific settings
;;; Commentary:

;;; Code:
(require 'init-fonts)

;; This must run after window setup or it seems to have no effect.
(add-hook 'window-setup-hook
          (lambda ()
            (when (memq window-system '(mac ns))
              (add-to-list 'default-frame-alist '(font . "Ubuntu Mono Regular-18"))
              (set-face-attribute 'default nil :font "Ubuntu Mono Regular-18")
              (sanityinc/set-frame-font-size 18)
              (define-key global-map (kbd "<s-return>") 'toggle-frame-fullscreen))

            (when (memq window-system '(x))
              (add-to-list 'default-frame-alist '(font . "Ubuntu Mono Regular-18"))
              (set-face-attribute 'default nil :font "Ubuntu Mono Regular-18")
              (sanityinc/set-frame-font-size 20))))

(provide 'init-platform)
;;; init-platform.el ends here
