(when (< emacs-major-version 24)
  (error "%s" "This .emacs file requires Emacs 24"))

(require 'package)

(setq package-archives '(("elpa" . "http://tromey.com/elpa/")
                         ("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("org" . "http://orgmode.org/elpa/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")
                         ("melpa-stable" . "http://stable.melpa.org/packages/")))

;; Activate the installed packages
(package-initialize)

(defun ensure-package-installed (&rest packages)
  "Assure every package is installed, ask for installation if it’s not.
  Return a list of installed packages or nil for every skipped package."
  (mapcar
    (lambda (package)
      (if (package-installed-p package)
        nil
        (if (y-or-n-p (format "Package %s is missing. Install it? " package))
          (package-install package)
          package)))
    packages))

;; Make sure to have downloaded archive description.
(when (not package-archive-contents)
   (package-refresh-contents))
(or (file-exists-p package-user-dir)
    (package-refresh-contents))

;; --> (nil nil ...) if the packages are already installed
(ensure-package-installed 'evil
                          'evil-leader
                          'evil-numbers
                          'auto-complete
                          'ido-vertical-mode
                          'smex
                          'go-mode
                          'python-mode
                          'js2-mode
                          'ac-js2
                          'json-mode
                          'yaml-mode
                          'monky
                          'markdown-mode
                          ; Visual mode for C-x o
                          'switch-window
                          ; To navigate through notes
                          'deft
                          ; Pandoc export for org-mode
                          'ox-pandoc
                          'org-pomodoro
                          'org-journal
                          ; IRC client
                          'erc
                          ; RSS client
                          'elfeed
                          ; Play media files
                          'bongo)

(unless (version< emacs-version "24.4")
  ; ido-completing-read+ requires Emacs version 24.4 or later
  (ensure-package-installed 'ido-completing-read+)
  (ensure-package-installed 'magit))

(when (>= emacs-major-version 25)
  ; Fill-column-indicator requires Emacs version 25 or later
  (ensure-package-installed 'fill-column-indicator))

;; Don't display the startup screen when starting Emacs
(setq inhibit-startup-screen t)

;; Start the emacs server
(require 'server)
(unless (server-running-p) (server-start))


;; evil-mode settings
;; Use C-U to scroll up instead of universal-argument
; (setq evil-want-C-u-scroll t)
;; Enable evil-mode
; (evil-mode 1)
;; Disable in calendar-mode
; (evil-set-initial-state 'calendar-mode 'emacs)

;; Theme
(load-theme 'wombat)

;; switch-window
(require 'switch-window)
(global-set-key (kbd "C-x o") 'switch-window)
(global-set-key (kbd "C-x 1") 'switch-window-then-maximize)
(global-set-key (kbd "C-x 2") 'switch-window-then-split-below)
(global-set-key (kbd "C-x 3") 'switch-window-then-split-right)
(global-set-key (kbd "C-x 0") 'switch-window-then-delete)

;; Elfeed
(global-set-key (kbd "C-x w") 'elfeed)


;; Show whitespace and trailing characters
(require 'whitespace)

(setq whitespace-line-column 80)
(setq whitespace-style '(spaces tabs newline space-mark tab-mark newline-mark))
; (add-hook 'prog-mode-hook 'whitespace-mode)

(defun tf-toggle-show-trailing-whitespace ()
  "Toggle show-trailing-whitespace between t and nil"
  (interactive)
  (setq show-trailing-whitespace (not show-trailing-whitespace)))

;; delete trailing whitespace on save
; (add-hook 'before-save-hook 'delete-trailing-whitespace)

;; ability to revert split pane config. Call winner-undo 【Ctrl+c ←】 and
;; winner-redo 【Ctrl+c →】
(winner-mode 1) ; in GNU emacs 23.2

;; Automatically reload and externally modified file
(global-auto-revert-mode t)

;; Coding system.
(setq locale-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; Show line numbers
(require 'linum)
(global-linum-mode t)
(setq linum-format "%4d")
; Show the current line and column numbers in the stats bar as well
(line-number-mode t)
(column-number-mode t)


;; JavaScript
(add-hook 'js-mode-hook
          (lambda ()
            (unless (derived-mode-p 'json-mode)
              'js2-minor-mode)))
(add-hook 'js2-mode-hook 'ac-js2-mode)

(setq js2-highlight-level 3)

;; Allow <C-x><C-l> to downcase a region of text
(put 'downcase-region 'disabled nil)
;; Allow <C-x><C-u> to upcase a region of text
(put 'upcase-region 'disabled nil)

;; Improve mouse wheel scrolling
(setq mouse-wheel-follow-mouse 't)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))

; Don't show the start-up screen
; (setq inhibit-startup-screen +1)
; Don't show the menu bar
; (menu-bar-mode nil)
; Don't show the tool bar
; (require 'tool-bar)
; (tool-bar-mode nil)
; Don't show the scroll bar
; (scroll-bar-mode nil)

;; Formatting and whitespace
; Always use spaces instead of tabs
(setq indent-tabs-mode nil)

; Show the trailing whitespace
(setq show-trailing-whitespace 't)

; Ignore case when searching
(setq case-fold-search t)

; Require final newlines in files when they are saved
(setq require-final-newline t)

; Make the cursor as wide as the character it is over
(setq x-strech-cursor 't)

; Highlight matching parentheses
(setq show-paren-mode t)

; Number of characters until the fill column
(setq fill-column 80)

;; Magit
(unless (version< emacs-version "24.4")
  (global-set-key (kbd "C-x g") 'magit-status)
  ;; Disable VC for Git
  (setq vc-handled-backends (delq 'Git vc-handled-backends)))

;; Monkey
;; By default monky spawns a seperate hg process for every command.
;; This will be slow if the repo contains lot of changes.
;; if `monky-process-type' is set to cmdserver then monky will spawn a single
;; cmdserver and communicate over pipe.
;; Available only on mercurial versions 1.9 or higher
(setq monkey-process-type 'cmdserver)
;; Disable VC for Mercurial
(setq vc-handled-backends (delq 'Mercurial vc-handled-backends))

;; Backup files
(defconst backup-dir (concat user-emacs-directory "backup"))

(unless (file-exists-p backup-dir) (make-directory backup-dir))
(setq backup-directory-alist `(("." . ,backup-dir)))

(setq version-control t      ;; Use version numbers for backups.
      kept-new-versions 5    ;; Number of newest versions to keep (default: 2).
      kept-old-versions 2    ;; Number of oldest versions to keep (default: 2).
      backup-by-copying t    ;; Don't ask to delete excess backup versions.
      delete-old-versions t) ;; Copy all files, don't rename them.


(defun my/clean-buffer-formatting ()
    "Indent and clean up the buffer"
    (interactive)
    (indent-region (point-min) (point-max))
    (whitespace-cleanup))

(global-set-key "\C-cn" 'my/clean-buffer-formatting)

(defun my/load-if-exists (file)
  "`load' a file only if it exists on the system."
  (if (file-exists-p file) (load file)))

; Load every Elisp file in ~/.emacs.d/elisp
(defun my/load-all-in-directory (dir)
  "`load' all elisp libraries in directory DIR which are not already loaded."
  (interactive "D")
  (let ((libraries-loaded (mapcar #'file-name-sans-extension
                                  (delq nil (mapcar #'car load-history)))))
    (dolist (file (directory-files dir t ".+\\.elc?$"))
      (let ((library (file-name-sans-extension file)))
        (unless (member library libraries-loaded)
          (load library nil t)
          (push library libraries-loaded))))))

(add-to-list 'load-path (concat user-emacs-directory "elisp"))
(my/load-all-in-directory (concat user-emacs-directory "elisp"))
; (my/load-if-exists "~/.emacs.d/digraphs.el")

;; Load private data, if it exists
(setq private-config (concat user-emacs-directory "init-local")
      system-config (concat user-emacs-directory "init-" system-name))
(my/load-if-exists private-config)
(my/load-if-exists system-config)

;; IDO
(require 'ido)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(setq ido-case-fold t)
(ido-mode 1)

(require 'ido-vertical-mode)
(ido-vertical-mode 1)
(setq ido-vertical-define-keys 'C-n-and-C-p-only)

(unless (version< emacs-version "24.4")
  (require 'ido-completing-read+)
  (ido-ubiquitous-mode 1))

(require 'smex) ; Not needed if you use package.el
(smex-initialize) ; Can be omitted. This might cause a (minimal) delay
                  ; when Smex is auto-initialized on its first run.
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)


;; auto-complete
(require 'auto-complete)
(require 'auto-complete-config)
(ac-config-default)
(global-auto-complete-mode t)

;; fill-column indicator
(when (>= emacs-major-version 25)
  (require 'fill-column-indicator)
  (define-globalized-minor-mode
    global-fci-mode fci-mode (lambda () (fci-mode 1)))
  (global-fci-mode t))

;; Python-mode
(require 'python-mode)

; use IPython
(setq-default py-shell-name "ipython")
(setq-default py-which-bufname "IPython")
; use the wx backend, for both mayavi and matplotlib
(setq py-python-command-args
  '("--gui=wx" "--pylab=wx" "-colors" "Linux"))
(setq py-force-py-shell-name-p t)

; switch to the interpreter after executing code
(setq py-shell-switch-buffers-on-execute-p t)
(setq py-switch-buffers-on-execute-p t)
; don't split windows
(setq py-split-windows-on-execute-p nil)
; try to automagically figure out indentation
(setq py-smart-indentation t)


;; Org-mode
(require 'org)
;; enable the org-indent-mode minor mode by default
;; see http://orgmode.org/manual/Clean-view.html
(setq org-startup-indented t)
(setq org-startup-with-inline-images t)
(setq org-pretty-entities t)
(setq org-completion-use-ido t)
;; hide the emphasis characters by default
(setq org-hide-emphasis-markers t)
;; show all entries unfolded by default
(setq org-startup-folded nil)
(global-set-key (kbd "C-c c") 'org-capture)
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)
; (eval-after-load "org"
;   '(require 'ox-md nil t)) ; Load the Markdown exporter
(eval-after-load "org"
  '(require 'ox-pandoc nil t)) ; Load the Pandoc exporter (org-pandoc)
(eval-after-load "org"
  '(require 'ox-odt nil t)) ; Load the ODT exporter
(eval-after-load "org"
  '(require 'ox-beamer nil t)) ; Load the Beamer exporter
;; Display org-mode agenda on startup
;(add-hook 'after-init-hook '(lambda() (org-agenda-list) (delete-other-windows)))
(setq org-journal-dir "~/Dropbox/Notes/Journal")
(setq org-journal-file-format "%Y-%m-%d.org")

;; Markdown
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;; LilyPond
(autoload 'LilyPond-mode "lilypond-mode")
(setq auto-mode-alist
  (cons '("\\.ly$" . LilyPond-mode) auto-mode-alist))

;; Various commands
(defun my/insert-file-name (filename &optional args)
  "Insert name of file FILENAME into buffer after point.

Prefixed with \\[universal-argument], expand the file name to
its fully canocalized path.  See `expand-file-name'.

Prefixed with \\[negative-argument], use relative path to file
name from current directory, `default-directory'.  See
`file-relative-name'.

The default with no prefix is to insert the file name exactly as
it appears in the minibuffer prompt."
  ;; Based on insert-file in Emacs -- ashawley 20080926
  (interactive "*fInsert file name: \nP")
  (cond ((eq '- args)
         (insert (file-relative-name filename)))
        ((not (null args))
         (insert (expand-file-name filename)))
        (t
          (insert filename))))

(global-set-key "\C-c\C-i" 'my/insert-file-name)

(defun my/update-org-src-locs ()
  "In a list, add an empty line after #+END_SRC if there is none."
  (when (string= major-mode "org-mode")
    (save-excursion
      (org-element-map (org-element-parse-buffer) 'headline
                       (lambda (hl)
                         (goto-char (org-element-property :begin hl))
                         (forward-line -1)
                         (when (string= (buffer-substring-no-properties (point) (line-end-position))
                                        "#+END_SRC")
                           (forward-line)
                           (insert "\n")))))))

(add-hook 'after-save-hook 'my/update-org-src-locs)

(defun my/global-disable-mode (mode-fn)
  "Disable `MODE-FN' in ALL buffers."
  (interactive "a")
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
                         (funcall mode-fn -1))))

(defun my/smart-open-line ()
  "Insert an empty line after the current line.
Position the cursor at its beginning, according to the current mode."
  (interactive)
  (move-end-of-line nil)
  (newline-and-indent))

(defun my/smart-open-line-above ()
  "Insert an empty line above the current line.
Position the cursor at it's beginning, according to the current mode."
  (interactive)
  (move-beginning-of-line nil)
  (newline-and-indent)
  (forward-line -1)
  (indent-according-to-mode))

(global-set-key (kbd "M-o") 'my/smart-open-line)
(global-set-key (kbd "M-O") 'my/smart-open-line-above)
