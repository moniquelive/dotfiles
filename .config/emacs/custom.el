(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("4825b816a58680d1da5665f8776234d4aefce7908594bea75ec9d7e3dc429753" default))
 '(org-preview-latex-default-process 'dvisvgm nil nil "Customized with use-package org")
 '(package-selected-packages
   '(corfu vertico-posframe catppuccin-theme spacious-padding company-posframe pdf-tools evil-org org-superstar company-box company auto-package-update auto-virtualenv consult csharp-mode dashboard dockerfile-mode doom-modeline elisp-autofmt elixir-mode elm-mode embark embark-consult evil evil-collection evil-leader evil-nerd-commenter evil-search-highlight-persist evil-surround go-mode helpful lsp-docker lsp-haskell lsp-mode lsp-pyright lsp-ui magit marginalia nerd-icons orderless projectile projectile-ripgrep pyvenv undo-tree vertico which-key)))

(defvar var-font-name
  (cond ((find-font (font-spec :name "Helvetica")) "Helvetica 14")
        ((find-font (font-spec :name "Arial")) "Arial 14")
        (t nil)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:font "Monolisa 15"))))
 '(fixed-pitch ((t (:inherit (default)))))
 '(fixed-pitch-serif ((t (:inherit (default)))))
 '(fringe ((t :background "#222134")))
 '(header-line ((t :box (:line-width 4 :color "grey20" :style nil))))
 '(header-line-highlight ((t :box (:color "#f0f0f0"))))
 '(keycast-key ((t)))
 '(line-number ((t :background "#222134")))
 '(mode-line ((t :background "#222134" :overline "black" :box (:line-width 6 :color "#222134" :style nil))))
 '(mode-line-active ((t :background "#222134" :overline "black" :box (:line-width 6 :color "#222134" :style nil))))
 '(mode-line-highlight ((t :box (:color "#f0f0f0"))))
 '(mode-line-inactive ((t :background "#222134" :overline "grey80" :box (:line-width 6 :color "#222134" :style nil))))
 '(tab-bar-tab ((t :box (:line-width 4 :color "grey85" :style nil))))
 '(tab-bar-tab-inactive ((t :box (:line-width 4 :color "grey75" :style nil))))
 '(tab-line-tab ((t)))
 '(tab-line-tab-active ((t)))
 '(tab-line-tab-inactive ((t)))
 '(variable-pitch ((t `(:font ,var-font-name))))
 '(vertical-border ((t :background "#222134" :foreground "#222134")))
 '(window-divider ((t (:background "#222134" :foreground "#222134"))))
 '(window-divider-first-pixel ((t (:background "#222134" :foreground "#222134"))))
 '(window-divider-last-pixel ((t (:background "#222134" :foreground "#222134")))))
