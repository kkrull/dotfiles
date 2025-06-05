;; (server-start) ;;Load multiple files into one emacs window
(add-to-list 'load-path "~/.emacs.d/lib")
(add-to-list 'load-path "~/.emacs.d/lib/org-7.9.3e/lisp")
(add-to-list 'load-path "~/.emacs.d/lib/org-7.9.3e/contrib/lisp")
(add-to-list 'load-path "~/.emacs.d/lib/tabbar")


;;;; Major modes

;;C / C++
(defvar c-basic-offset 2)
(setq c-indent-level 4)
(setq c-argdecl-indent 0)
(setq c-continued-statement-offset 3)
(setq c-brace-offset -3)
(setq c-label-offset -2)


;;comint (shell)
;; (autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
;; (add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
;; (setq ansi-color-names-vector
;;   ["black" "tomato" "LimeGreen" "gold1" "Blue" "MediumOrchid1" "cyan" "white"])
;; (add-hook 'comint-mode-hook
;;   (function
;;    (lambda ()
;;      (setq comint-scroll-show-maximum-output nil)
;;      (add-hook 'comint-output-filter-functions 'comint-strip-ctrl-m)
;;      (local-set-key "p" 'comint-previous-matching-input-from-input)
;;      (local-set-key "n" 'comint-next-matching-input-from-input))))

;; (setq exec-path (cons "c:/cygwin/bin" exec-path))
;; (setenv "PATH" (concat "c:\\cygwin\\bin;" (getenv "PATH")))
;; (setq process-coding-system-alist '(("bash" . undecided-unix)))
;; (setq shell-file-name "bash")
;; (setq explicit-shell-file-name "bash")
;; (setq w32-quote-process-args ?\")


;;Emacs Lisp
(add-to-list 'auto-mode-alist '("\\.el\\'" . emacs-lisp-mode))


;;Grep
(require 'grep)
(setq grep-command "git grep -nH ''")
(setq grep-use-null-device nil)


;;HTML
(add-to-list 'auto-mode-alist '("\\.htm\\'" . html-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . html-mode))


;;LaTeX
(add-to-list 'auto-mode-alist '("\\.tex\\'" . latex-mode))


;;Markdown
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))


;;Scheme
(autoload 'scheme-mode "kdkscheme" "Run a scheme process." t)
(add-to-list 'auto-mode-alist '("\\.ss\\'" . scheme-mode))
(add-to-list 'auto-mode-alist '("\\.ms\\'" . scheme-mode))
(font-lock-add-keywords 'scheme-mode
  '(
    ("\\<[$!%&*-:[:alpha:][:digit:]]+!" . font-lock-warning-face)
    ("\\<[$!%&*-:[:alpha:][:digit:]]*mat\\>" . font-lock-keyword-face)
    ("\\<trace-[$!%&*-:[:alpha:][:digit:]]+\\>" . font-lock-warning-face)

    ("\\<catch\\>" . font-lock-warning-face)
    ("\\<cond\\>" . font-lock-keyword-face)
    ("\\<cons\\>" . font-lock-keyword-face)
    ("\\<define-record\\>" . font-lock-keyword-face)
    ("\\<define-state-record\\>" . font-lock-keyword-face)
    ("\\<dynamic-wind\\>" . font-lock-warning-face)
    ("\\<else\\>" . font-lock-keyword-face)
    ("\\<exit\\>" . font-lock-warning-face)
    ("\\<library\\>" . font-lock-keyword-face)
    ("\\<match-let[*]\\>" . font-lock-keyword-face)
    ("\\<match\\>" . font-lock-keyword-face)
    ("\\<on-exit\\>" . font-lock-warning-face)
    ("\\<receive\\>" . font-lock-keyword-face)
    ("\\<syntax-case\\>" . font-lock-keyword-face)
    ("\\<syntax-rules\\>" . font-lock-keyword-face)
    ("\\<values\\>" . font-lock-keyword-face)
    ))

;;sh (Shell script editing)
(setq sh-basic-offset 2)
(setq sh-indentation 2)
(add-to-list 'auto-mode-alist '("\\.bats\\'" . sh-mode))


;;Tabbed frames
(require 'tabbar)
(global-set-key (kbd "<C-prior>") 'tabbar-backward)
(global-set-key (kbd "<C-next>") 'tabbar-forward)
(defun tabbar-buffer-groups ()
  "Returns the name of the tab group names the current buffer belongs to.
 There is one group for Emacs buffers (those whose name starts with “*”, plus
 dired buffers), and one for each major mode in use."
  (list (cond
	 ((string-equal "*" (substring (buffer-name) 0 1)) "emacs")
	 ((eq major-mode 'dired-mode) "emacs")
	 (t (symbol-name major-mode)))))

(tabbar-mode)


;;Text
(add-hook 'text-mode-hook
  (function
   (lambda ()
     (auto-fill-mode 1))))


;;XML
(add-to-list 'auto-mode-alist '("\\.xml\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.xsd\\'" . nxml-mode))


;;;; Minor modes

(define-minor-mode sticky-buffer-mode
  "Make the current window always display this buffer."
  nil " sticky" nil
  (set-window-dedicated-p (selected-window) sticky-buffer-mode))


;;;; Backups

(require 'backup-dir)

;;localize it for safety
(make-variable-buffer-local 'backup-inhibited)
(setq bkup-backup-directory-info
  '((t "~/.emacs.d/backup" ok-create full-path prepend-name)))
(setq
 delete-old-versions t
 kept-old-versions 1
 kept-new-versions 3
 version-control t)

(defun make-backup-file-name (FILE)
  (let ((dirname (concat "~/.emacs.d/backups/"
                   (format-time-string "%y-%m-%d/"))))
    (if (not (file-exists-p dirname))
        (make-directory dirname t))
    (concat dirname (file-name-nondirectory FILE))))


;;;; Editing

(prefer-coding-system 'utf-8-unix)
(put 'downcase-region 'disabled nil)
(put 'erase-buffer 'disabled nil)
(put 'eval-expression 'disabled nil)
(put 'upcase-region 'disabled nil)
(setq column-number-mode t)
(setq-default tab-width 2)

(global-set-key "" 'newline-and-indent)
(global-set-key "\C-p" 'ps-print-buffer-with-faces)
(global-set-key "\C-xe" 'erase-buffer)
(global-set-key (kbd "<C-f4>") 'kill-this-buffer)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)
(global-unset-key [mouse-2]) ;;Disable mouse-2 binding for mouse wheel button
(pc-bindings-mode) ;;home/end work like on a PC
(global-linum-mode t) ;;show line numbers

(show-paren-mode 1)
(setq blink-matching-paren-distance nil)
(pc-selection-mode) ;;use shift-cursor to select text, typing will replace selected region
(transient-mark-mode t) ;;Highlight mark (selection)

(defvar standard-indent 2) ; for most things
(setq-default indent-tabs-mode nil)


;;;; Fonts

(require 'font-lock)
;;(set-default-font "-*-Lucida Console-normal-r-*-*-12-90-96-96-c-*-iso8859-1")

;;Font lock: Symbol-for-Face Foreground Background Bold Italic Underline
;; (setq font-lock-face-attributes
;;   '((font-lock-comment-face       "darkgreen")
;;     (font-lock-string-face        "firebrick")
;;     (font-lock-keyword-face       "MediumBlue")
;;     (font-lock-type-face          "olivedrab")
;;     (font-lock-function-name-face "darkmagenta")
;;     (font-lock-variable-name-face "maroon4")))

;;Enable syntax highlighting
(setq font-lock-use-colors t)
(setq font-lock-maximum-decoration t)
(setq font-lock-use-default-maximum-decoration t)
(global-font-lock-mode t)
(setq font-lock-global-modes '(not shell-modes))
