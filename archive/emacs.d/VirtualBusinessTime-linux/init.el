;; Startup

(setq inhibit-startup-message t)

(require 'package)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
;(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
(package-initialize)

;; Backup

(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; Colors

(load-theme 'zenburn t)

;; Editing

(global-linum-mode t) ;;show line numbers
(prefer-coding-system 'utf-8-unix)
(put 'downcase-region 'disabled nil)
(put 'erase-buffer 'disabled nil)
(put 'eval-expression 'disabled nil)
(put 'upcase-region 'disabled nil)
(setq blink-matching-paren-distance nil)
(setq column-number-mode t)
(setq-default tab-width 2)
(show-paren-mode 1)
(transient-mark-mode t) ;;Highlight mark (selection)

;; Indentation

(defvar standard-indent 2) ; for most things
(setq-default indent-tabs-mode nil)

;; Keyboard

;(global-set-key "
;" 'newline-and-indent)
(global-set-key "\C-xe" 'erase-buffer)
(global-set-key (kbd "<C-f4>") 'kill-this-buffer)

; Fix home/end
(define-key global-map "\M-[1~" 'beginning-of-line)
(define-key global-map [select] 'end-of-line)

;; Mouse

(global-unset-key [mouse-2]) ;;Disable mouse-2 binding for mouse wheel button
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

;; Racket scheme

(mapc (lambda (name)
        (put name 'scheme-indent-function 1))
      '(test-case test-suite))
(add-hook 'scheme-mode-hook
  (lambda () (local-set-key (kbd "M-SPC") 'mark-sexp)))

;; Shell

(defun run-mongo-on-buffer ()
  "Runs the mongo commands in the current buffer in an inferior mongo shell process."
  (interactive)
  (shell-command-on-region
   (point-min) (point-max)
   "mongo ascent_production_cdc"))
(global-set-key (kbd "C-x C-}") 'run-mongo-on-buffer)

(defun run-mongo-on-region (start end)
  "Runs the mongo commands in the current region in an inferior mongo shell process."
  (interactive "r")
  (shell-command-on-region
   start end
   "mongo ascent_production_cdc"))
(global-set-key (kbd "C-x C-]") 'run-mongo-on-region)

;; Customization

(custom-set-variables
 '(custom-safe-themes (quote ("dd4db38519d2ad7eb9e2f30bc03fba61a7af49a185edfd44e020aa5345e3dca7" default))))

(custom-set-faces)
