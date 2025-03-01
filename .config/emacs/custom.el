(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("4825b816a58680d1da5665f8776234d4aefce7908594bea75ec9d7e3dc429753"
     default))
 '(org-preview-latex-default-process 'dvisvgm nil nil "Customized with use-package org")
 '(package-selected-packages
   '(auto-package-update auto-virtualenv catppuccin-theme company
                         company-box company-posframe consult corfu
                         csharp-mode dashboard dockerfile-mode
                         doom-modeline elisp-autofmt elixir-mode
                         elm-mode embark embark-consult evil
                         evil-collection evil-leader
                         evil-nerd-commenter evil-org
                         evil-search-highlight-persist evil-surround
                         go-mode helpful lsp-docker lsp-haskell
                         lsp-mode lsp-pyright lsp-ui magit marginalia
                         nerd-icons orderless org-superstar pdf-tools
                         projectile projectile-ripgrep pyvenv
                         spacious-padding undo-tree vertico
                         vertico-posframe which-key zig-mode
                         zig-ts-mode)))

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
 '(variable-pitch ((t `(:font ,var-font-name)))))
