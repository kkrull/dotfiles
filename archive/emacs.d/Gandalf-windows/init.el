(server-start) ;;Load multiple files into one emacs window
(add-to-list 'load-path "~/.emacs.d/lib")
(add-to-list 'load-path "~/.emacs.d/lib/")
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
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(setq ansi-color-names-vector
  ["black" "tomato" "LimeGreen" "gold1" "Blue" "MediumOrchid1" "cyan" "white"])
(add-hook 'comint-mode-hook
  (function
   (lambda ()
     (setq comint-scroll-show-maximum-output nil)
     (add-hook 'comint-output-filter-functions 'comint-strip-ctrl-m)
     (local-set-key "p" 'comint-previous-matching-input-from-input)
     (local-set-key "n" 'comint-next-matching-input-from-input))))

(setq exec-path (cons "c:/cygwin/bin" exec-path))
(setenv "PATH" (concat "c:\\cygwin\\bin;" (getenv "PATH")))
(setq process-coding-system-alist '(("bash" . undecided-unix)))
(setq shell-file-name "bash")
(setq explicit-shell-file-name "bash")
(setq w32-quote-process-args ?\")


;;Emacs Lisp
(add-to-list 'auto-mode-alist '("\\.el\\'" . emacs-lisp-mode))


;;Grep
(require 'grep)
(setq grep-command "git grep -nH ''")
(setq grep-use-null-device nil)


;;HTML
(add-to-list 'auto-mode-alist '("\\.htm\\'" . html-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . html-mode))


;;Javascript
(autoload 'js2-mode "js2"
  "Major mode for editing Javascript files" t)
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.json\\'" . js2-mode))
(setq js2-auto-indent-p t)
(setq js2-bounce-indent-p t)
(setq js2-enter-indents-newline nil)
(setq js2-indent-on-enter-key nil)
(setq max-specpdl-size 10000)


;;LaTeX
(add-to-list 'auto-mode-alist '("\\.tex\\'" . latex-mode))


;;Markdown
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
;; (add-hook 'after-save-hook
;;   (lambda ()
;;     (let* ((perl "/bin/perl")
;; 	   (markdown "~/.emacs.d/lib/markdown/Markdown.pl --html4tags")
;;            (in-path (buffer-file-name))
;;            (out-path (concat in-path ".html"))
;;            (cmd (format "%s %s \"%s\" > \"%s\""
;;                   perl markdown in-path out-path)))
;;       (if (not (or (equal 'markdown-mode major-mode)
;;                    (equal 'gfm-mode major-mode)))
;;           'ok
;; 	  (let ()
;; 	    (when (file-exists-p out-path)
;; 	      (delete-file out-path))
;; 	    (if (and (= 0 (shell-command cmd))
;; 		     (file-exists-p out-path))
;; 		(message (format "Rendered Markdown: %s" out-path))
;; 		(message (format "Failed to render Markdown: %s" cmd))))))))


;;Org-mode
(require 'org)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cl" 'org-store-link)
(setq org-log-done t)

(require 'org-agenda)
(setq org-agenda-clockreport-parameter-plist
  '(:link t :maxlevel 5 :compact t :narrow 80))
(defun org-find-dangling-clock ()
  "Find a dangling clock entry in an org-mode buffer"
  (interactive)
  (re-search-forward "CLOCK: \\[[^]]*\\] *$"))

(setq inbox-file (concat (getenv "DROPBOX_HOME") "/org/inbox.org"))
(setq org-agenda-files
  (list
   (concat (getenv "DROPBOX_HOME") "/org/projects.org")))

(setq org-default-notes-file inbox-file)
(setq org-capture-templates
  '(("p" "[p]ersonal" entry (file+headline inbox-file "Personal")
     "* %?\n%i\n\n\n")
    ("w" "[w]ork" entry (file+headline inbox-file "Work")
     "* %?\n%i\n\n\n")))

(require 'org-latex)
(unless (boundp 'org-export-latex-classes)
  (setq org-export-latex-classes nil))
(setq org-latex-to-pdf-process '("texi2dvi --pdf --build=local --verbose --batch `cygpath %f`"))
(setq org-export-html-validation-link nil)
(add-to-list 'org-export-latex-classes
  '("koma-article" "\\documentclass{scrartcl}"
    ("\\section{%s}" . "\\section*{%s}")
    ("\\subsection{%s}" . "\\subsection*{%s}")
    ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
    ("\\paragraph{%s}" . "\\paragraph*{%s}")
    ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))


;;org-mode source code syntax highlighting (export to HTML)
(require 'htmlize)
(setq org-src-fontify-natively t)


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

(global-set-key "
" 'newline-and-indent)
(global-set-key "\C-p" 'ps-print-buffer-with-faces)
(global-set-key "\C-xe" 'erase-buffer)
(global-set-key (kbd "<C-f4>") 'kill-this-buffer)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)
(global-unset-key [mouse-2]) ;;Disable mouse-2 binding for mouse wheel button
(pc-bindings-mode) ;;home/end work like on a PC

(show-paren-mode 1)
(setq blink-matching-paren-distance nil)
(pc-selection-mode) ;;use shift-cursor to select text, typing will replace selected region
(transient-mark-mode t) ;;Highlight mark (selection)

(defvar standard-indent 2) ; for most things
(setq indent-tabs-mode nil)


;;;; Fonts

(require 'font-lock)
(set-default-font "-*-Lucida Console-normal-r-*-*-12-90-96-96-c-*-iso8859-1")

;;Font lock: Symbol-for-Face Foreground Background Bold Italic Underline
(setq font-lock-face-attributes
  '((font-lock-comment-face       "darkgreen")
    (font-lock-string-face        "firebrick")
    (font-lock-keyword-face       "MediumBlue")
    (font-lock-type-face          "olivedrab")
    (font-lock-function-name-face "darkmagenta")
    (font-lock-variable-name-face "maroon4")))

;;Enable syntax highlighting
(setq font-lock-use-colors t)
(setq font-lock-maximum-decoration t)
(setq font-lock-use-default-maximum-decoration t)
(global-font-lock-mode t)
(setq font-lock-global-modes '(not shell-modes))


;;;; Printing

(setenv "PRINTER" "PDFCreator")
(setq ps-printer-name "PDFCreator")
(setq ps-printer-name-option "-d")
(setq ps-lpr-command "C:\\cygwin\\bin\\lpr.exe")
(setq ps-font-size 12)

(setq ps-left-margin (* 72 0.25))
(setq ps-right-margin (* 72 0))
(setq ps-top-margin (* 72 1))
(setq ps-bottom-margin (* 72 0.25))


;;;; UI

(setq explicit-cmdproxy.exe-args '("-- /q"))
(setq inhibit-startup-message t)

(require 'maxframe)
(let ((rows (- (mf-max-rows (mf-max-display-pixel-height)) 1))
      (columns (min 120 (mf-max-columns (/ (mf-max-display-pixel-width) 2))))
      (offset-columns 12))
  (setq initial-frame-alist
    `((top . 0)
      (left . ,(- (+ columns (* (frame-char-width) offset-columns))))
      (width . ,columns)
      (height . ,rows)
      (tool-bar-lines . 0)
      (font . "-*-Lucida Console-normal-r-*-*-12-90-96-96-c-*-iso8859-1")))
  (setq default-frame-alist
    `((top . 0)
      (left . ,(* (frame-char-width) 9))
      (width . ,(- columns 0))
      (height . ,(- rows 0))
      (tool-bar-lines . 0)
      (font . "-*-Lucida Console-normal-r-*-*-12-90-96-96-c-*-iso8859-1"))))

;; Open files

(find-file (concat (getenv "DROPBOX_HOME") "/org/index.org"))
(find-file (concat (getenv "DROPBOX_HOME") "/org/projects.org"))
