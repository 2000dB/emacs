;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GENERAL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq inhibit-splash-screen t) ;; no splashscreen
(tool-bar-mode -1)             ;; turn off toolbar
(scroll-bar-mode -1)           ;; turn off scrollbar
(menu-bar-mode -1)             ;; turn off menubar
(fset 'yes-or-no-p 'y-or-n-p)  ;; yes/no - y/n
(setq confirm-nonexistent-file-or-buffer nil) ;; don't prompt to create new file
(setq kill-buffer-query-functions ;; kill buffer without prompting if there's a running process
      (remq 'process-kill-buffer-query-function
	    kill-buffer-query-functions))
(setq initial-scratch-message  ;; scratch message
      ";; scratch buffer \n")

(server-start) ;; start emacs server

;; Load PATH
(let* ((my-lisp-dir "~/.emacs.d/")
       (default-directory my-lisp-dir))
  (setq load-path (cons my-lisp-dir load-path))
  (normal-top-level-add-subdirs-to-load-path))

;; FACE
(set-face-foreground 'region "#ffffff")
;; (set-face-background 'region "#ff0000")
(set-face-attribute 'region nil :background "red") ;; weird 24.x bug

;; GLOBAL BINDINGS
(dolist (command '(yank yank-pop)) ;; yank and indent
  (eval `(defadvice ,command (after indent-region activate)
	   (indent-region (region-beginning) (region-end) nil))))
(global-set-key (kbd "RET") 'newline-and-indent) ;; maintain indention level on new line

;; SCROLLING
(setq 
  scroll-margin 0
  scroll-conservatively 100000
  scroll-up-aggressively 0
  scroll-down-aggressively 0
  scroll-preserve-screen-position t)

;; LINUM
(setq linum-format "%4d ")
(global-linum-mode 1)
(setq linum-disabled-modes-list '(eshell-mode  compilation-mode))
(defun linum-on ()
  (unless (or (minibufferp) (member major-mode linum-disabled-modes-list))
    (linum-mode 1)))

;; MODELINE
(line-number-mode t)     ;; show line numbers
(column-number-mode t)   ;; colum numbrs
(size-indication-mode t) ;; file size

;; MINIBUFFER
(setq
  enable-recursive-minibuffers nil
  max-mini-window-height .25      
  minibuffer-scroll-window nil
  resize-mini-windows nil)

(require 'icomplete+)
(setq 
  icomplete-prospects-height 1
  icomplete-compute-delay 0)
(icomplete-mode t)

;; CACHE
;; backups - broken
(setq make-backup-files t ;; make backups
  backup-by-copying t     ;; set directory
  backup-directory-alist '(("." . "~/.emacs.d/backups")) 
  version-control t
  kept-new-versions 2
  kept-old-versions 5
  delete-old-versions t)


;; autosave
(setq auto-save-list-file-prefix
  "~/.emacs.d/cache/auto-save-list/.saves-")

;; recent files
(require 'recentf)    ;; save recently used files
(setq
  recentf-save-file "~/.emacs.d/cache/recentfiles"
  recentf-max-saved-items 100     ;; max save 100
  recentf-max-menu-items 15)      ;; max 15 in menu
(recentf-mode t)                  ;; turn it on

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PACKAGES 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; lookup
(autoload 'lookup-google "lookup-word-on-internet" "Lookup in browser" t)
(autoload 'lookup-wikipedia "lookup-word-on-internet" "Lookup in browser" t)
(autoload 'lookup-word-definition "lookup-word-on-internet" "Lookup in browser" t)

;; autocomplete
(add-to-list 'load-path "~/.emacs.d/packages/autocomplete")    ; This may not be appeared if you have already added.
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/packages/autocomplete")
(ac-config-default)
(set-face-background 'ac-candidate-face "#ffffff")
(set-face-foreground 'ac-candidate-face "#666666")
(set-face-background 'ac-selection-face "#666666")
(set-face-foreground 'ac-selection-face "#00ffff")

;; ido
;; XXX : suppress new buffer when too many completions
(require 'ido)
(ido-mode 'both) ;; buffers and files
(setq
 ido-save-directory-list-file "~/.emacs.d/cache/ido.last"
 ido-ignore-buffers ;; ignore the following buffer names in C-x b
 '("\\` " "^\*Mess" "\*scra" "^\*Back" ".*Completion" "^\*Ido" "^\*trace"
   "^\*compilation" "^\*GTAGS" "^session\.*" "^\*")
 ido-work-directory-list '("~/" "~/Desktop" "~/Documents" "~src")
 ido-case-fold  t                    ; be case-insensitive
 ido-enable-last-directory-history t ; remember last used dirs
 ido-max-work-directory-list 30      ; should be enough
 ido-max-work-file-list      50      ; remember many
 ido-use-filename-at-point nil       ; don't use filename at point (annoying)
 ido-enable-flex-matching nil        ; don't try to be too smart
 ido-max-prospects 8                 ; don't spam my minibuffer
 ido-create-new-buffer 'always       ; 
 ido-confirm-unique-completion nil)  ; wait for RET, even with unique completion

;; uniquify
(require 'uniquify) ;; makes buffer names unique without <2> type stuff
(setq
 uniquify-buffer-name-style 'post-forward
 uniquify-separator ":"
 uniquify-after-kill-buffer-p t
 uniquify-ignore-buffers-re "^\\*")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SPELLING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; aspell
(setq ispell-program-name "aspell"
  ispell-extra-args '("--sug-mode=ultra"))

;; set dictionaries and run flyspell on buffer
(global-set-key (kbd "C-c F")
(lambda()(interactive)
  (ispell-change-dictionary "francais")
  (flyspell-buffer)))
(global-set-key (kbd "C-c E")
(lambda()(interactive)
  (ispell-change-dictionary "american")
  (flyspell-buffer)))

;; yassnippet
(require 'yasnippet)
(yas/load-directory "~/.emacs.d/packages/yasnippet-0.6.1c/snippets")
(yas/global-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; KEY BINDINGS/vdb-global
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Word Counter
(defun vdb-count-words (&optional begin end)
  "count words in the selected region if available, otherwise in whole buffer"
  (interactive "r")
  (let ((b (if mark-active begin (point-min)))
	(e (if mark-active end (point-max))))
    (message "word count: %s" (how-many "\\w+" b e))))

;; Remove 
(defun vdb-remove-m ()
  (interactive)
  (save-match-data
    (save-excursion
      (let ((remove-count 0))
	(goto-char (point-min))
	(while (re-search-forward (concat (char-to-string 13) "$") (point-max) t)
	  (setq remove-count (+ remove-count 1))
	  (replace-match "" nil nil))
	(message (format "%d  removed from buffer." remove-count))))))

(require 'rect-mark) ;; rectangle selection highlight

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; KEYMAP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar vdb-keys-minor-mode-map (make-keymap) "vdb-keys-minor-mode.")
(define-key vdb-keys-minor-mode-map (kbd "C-c C-c") 'vdb-compile)
(define-key vdb-keys-minor-mode-map (kbd "C-c C-k") 'kill-compilation)
(define-key vdb-keys-minor-mode-map (kbd "C-c C-r") 'replace-string)
(define-key vdb-keys-minor-mode-map (kbd "C-c r C-SPC") 'rm-set-mark)
(define-key vdb-keys-minor-mode-map (kbd "C-c r C-r") 'replace-rectangle)
(define-key vdb-keys-minor-mode-map (kbd "C-c r C-i") 'string-insert-rectangle)
(define-key vdb-keys-minor-mode-map (kbd "C-c r C-r") 'string-rectangle)
(define-key vdb-keys-minor-mode-map (kbd "C-c r C-w") 'rm-kill-region)
(define-key vdb-keys-minor-mode-map (kbd "C-c r M-w") 'rm-kill-ring-save)
(define-key vdb-keys-minor-mode-map (kbd "M-1") 'delete-other-windows)
(define-key vdb-keys-minor-mode-map (kbd "M-2") 'split-window-horizontally)
(define-key vdb-keys-minor-mode-map (kbd "M-3") 'split-window-vertically)
(define-key vdb-keys-minor-mode-map (kbd "C-c c") 'comment-region)
(define-key vdb-keys-minor-mode-map (kbd "C-c u") 'uncomment-region)
(define-key vdb-keys-minor-mode-map (kbd "C-c w") 'vdb-count-words)
(define-key vdb-keys-minor-mode-map (kbd "C-c m") 'vdb-remove-m)
(define-key vdb-keys-minor-mode-map (kbd "C-h C-g") 'lookup-google)
(define-key vdb-keys-minor-mode-map (kbd "C-h C-d") 'lookup-word-definition)
(define-key vdb-keys-minor-mode-map (kbd "C-h C-w") 'lookup-wikipedia)

;; create the minor mode
(define-minor-mode vdb-keys-minor-mode
  "clean way of mapping my bidings with major modes"
  t " vdb-keys" 'vdb-keys-minor-mode-map)
(vdb-keys-minor-mode t) ;; make it global

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; COMPILATION 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'compile)
(setq compilation-scroll-output t)

;; ;; lets make the compile behave how we want: small horizontal buffer
(defun vdb-compile ()
  (interactive)
  (progn
    (call-interactively 'compile)
    ;; XXX : for some reason the resizing fucks up when used with the vdb-keys-minor-mode
    (setq cur (selected-window))
    (setq w (get-buffer-window "*compilation*"))
    (select-window w)
    (setq h (window-height w))
    (shrink-window (- h 10))
    (select-window cur)
    )
  )

;; make the compile window split vertically
(defadvice compile (around split-vertically activate)
  (let ((split-width-threshold nil)
	(split-height-threshold 0))
    ad-do-it))

;; python
(add-hook 'python-mode-hook
	  (lambda ()
	    (set (make-local-variable 'compile-command)
		 (let ((file (file-name-nondirectory buffer-file-name)))
		   (format "%s %s"
			   (or "python")
			   file)))))



;; processing/.pde files
(add-to-list 'auto-mode-alist '("\\.pde\\'" . java-mode))

;; java/processing via ant
(add-hook 'java-mode-hook
	  (lambda ()
	    (if (string-match "\\.pde\\'" buffer-file-name)
		(set (make-local-variable 'compile-command)
		     (let ((file (file-name-directory buffer-file-name)))
		     (format "%s%s %s%s%s"
			     (or "processing-java --force --run --sketch=")
			     file
			     (or "--output=")
			     file
			     (or "tmp"))))
	      (set (make-local-variable 'compile-command)
		   (format "%s -find" ;; for now just look for the build file in the tree
			   (or "ant"))))))



;; arduino .ino files
(add-to-list 'auto-mode-alist '("\\.ino\\'" . c-mode))
;; (setq tab-width 2) ; or any other preferred value
;; (defvaralias 'c-basic-offset 'tab-width)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ORG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq load-path (cons "~/.emacs.d/packages/org-jambu/lisp" load-path))
(setq load-path (cons "~/.emacs.d/packages/org-jambu/contrib/lisp" load-path))


(require 'org-install)
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

;; automatically load spell check in org mode
(add-hook 'org-mode-hook
	  (lambda ()
	    (flyspell-mode)))


;; not optimal
(require 'org-latex)
(unless (boundp 'org-export-latex-classes)
  (setq org-export-latex-classes nil))
(add-to-list 'org-export-latex-classes
	     '("letter"
	       "\\documentclass[11pt]{letter}"
	       ("\\section{%s}" . "\\section*{%s}")
	       ("\\subsection{%s}" . "\\subsection*{%s}")
	       ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
	       ("\\paragraph{%s}" . "\\paragraph*{%s}")
	       ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))


;; ack (full-ack)

(autoload 'ack-same "full-ack" nil t)
(autoload 'ack "full-ack" nil t)
(autoload 'ack-find-same-file "full-ack" nil t)
(autoload 'ack-find-file "full-ack" nil t)

;; yaml
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode))
(add-hook 'yaml-mode-hook
	  '(lambda ()
	     (define-key yaml-mode-map "\C-m" 'newline-and-indent)))

;; jinja2
(require 'jinja2-mode)
(add-to-list 'auto-mode-alist '("\\.j2$" . jinja2-mode))

;; web-multi-mode
(add-to-list 'load-path "~/.emacs.d/packages/multi-web-mode")
(require 'multi-web-mode)
(setq mweb-default-major-mode 'html-mode)
(setq mweb-tags '(;; (php-mode "<\\?php\\|<\\? \\|<\\?=" "\\?>")
		  (js-mode "<script +\\(type=\"text/javascript\"\\|language=\"javascript\"\\)[^>]*>" "</script>")
		  (css-mode "<style +type=\"text/css\"[^>]*>" "</style>")))
(setq mweb-filename-extensions '("php" "htm" "html" "ctp" "phtml" "php4" "php5"))
(multi-web-global-mode 1)
