(push '(background-color . "#19202f") default-frame-alist)
(push '(foreground-color . "#f0f0f0") default-frame-alist)

(when (fboundp 'startup-redirect-eln-cache)
  (progn
    (setq native-comp-eln-load-path '())
    (startup-redirect-eln-cache "var/eln-cache/")))
