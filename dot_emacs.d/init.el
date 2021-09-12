(when (< emacs-major-version 24)
  (error "%s" "This .emacs file requires Emacs 24"))


;;;; Package initialization

(require 'package)

(setq package-archives '(("elpa" . "http://tromey.com/elpa/")
                         ("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("org" . "http://orgmode.org/elpa/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "http://stable.melpa.org/packages/")))

;; Activate the installed packages
(package-initialize)

;; Install use-package if not present
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))


;;;; Global setup

;; Load Common Lisp
(require 'cl)
(require 'cl-lib)
(require 'cl-extra)

;; Start the emacs server
(require 'server)
(unless (server-running-p) (server-start))

;; Theme
(load-theme 'wombat)

;; Show whitespace and trailing characters
(require 'whitespace)

(setq whitespace-line-column 80)
(setq whitespace-style '(spaces tabs newline space-mark tab-mark newline-mark))
; (add-hook 'prog-mode-hook 'whitespace-mode)

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
; Disable linum in certain modes
(setq linum-disabled-modes-list '(eshell-mode
                                  wl-summary-mode
                                  compilation-mode
                                  dired-mode
                                  doc-view-mode
                                  image-mode
                                  nov-mode))
(defun linum-on ()
  "* When linum is running globally, disable line number in modes defined in `linum-disabled-modes-list'. Also turns off numbering in starred modes like *scratch*."
  (unless (or (minibufferp)
              (member major-mode linum-disabled-modes-list)
              (string-match "*" (buffer-name))
              (> (buffer-size) 3000000)) ; disable linum on buffer greater than 3MB, otherwise it's unbearably slow
    (linum-mode 1)))

; Highlight matching parentheses
(setq show-paren-mode t)
(setq show-paren-delay 0)

;;;; Disabled commands
;; Allow <C-x><C-l> to downcase a region of text
(put 'downcase-region 'disabled nil)
;; Allow <C-x><C-u> to upcase a region of text
(put 'upcase-region 'disabled nil)
;; `erase-buffer' deletes the entire contents of the current buffer
(put 'erase-buffer 'disabled nil)

;; Improve mouse wheel scrolling
(setq mouse-wheel-follow-mouse 't)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))

; Don't show the start-up screen
(setq inhibit-startup-screen t)
; Don't show the menu bar
; (menu-bar-mode -1))
; Don't show the tool bar
(tool-bar-mode -1)

;; Formatting and whitespace
; Always use spaces instead of tabs
(setq indent-tabs-mode nil)
(defun my/infer-indentation-style ()
  ;; if our source file uses tabs, we use tabs, if spaces spaces, and if
  ;; neither, we use the current indent-tabs-mode
  (let ((space-count (how-many "^  " (point-min) (point-max)))
        (tab-count (how-many "^\t" (point-min) (point-max))))
    (if (> space-count tab-count) (setq indent-tabs-mode nil))
    (if (> tab-count space-count) (setq indent-tabs-mode t))))
(add-hook 'prog-mode-hook 'my/infer-indentation-style)

; Show the trailing whitespace
(setq show-trailing-whitespace 't)

; Ignore case when searching
(setq case-fold-search t)

; Require final newlines in files when they are saved
(setq require-final-newline t)

; Make the cursor as wide as the character it is over
(setq x-strech-cursor 't)

; Number of characters until the fill column
(setq fill-column 80)

; Flash the screen instead of producing a sound when an error happens
(setq visible-bell t)

;; Backup files
(defconst backup-dir (concat user-emacs-directory "backup/"))
(defconst auto-save-dir (concat user-emacs-directory "auto-save/"))

(unless (file-exists-p backup-dir)
  (make-directory backup-dir))
(setq backup-directory-alist `(("." . ,backup-dir)))

(unless (file-exists-p auto-save-dir)
  (make-directory auto-save-dir))
(setq auto-save-file-name-transforms `((".*" ,auto-save-dir t)))

(setq make-backup-files t    ; backup of a file the first time it is saved
      backup-by-copying t    ; copy all files, don't rename them (don't clobber symlinks)
      version-control t      ; version numbers for backup files
      delete-old-versions t  ; delete excess backup files silently
      kept-old-versions 6    ; oldest versions to keep when a new numbered backup is made (default: 2)
      kept-new-versions 9    ; newest versions to keep when a new numbered backup is made (default: 2)
      auto-save-default t    ; auto-save every buffer that visits a file
      auto-save-timeout 20   ; number of seconds idle time before auto-save (default: 30)
      auto-save-interval 200 ; number of keystrokes between auto-saves (default: 300)
      )

;; Tell emacs where to read abbrev
(setq abbrev-file-name "~/.emacs.d/abbrev_defs")
(setq save-abbrevs t)
(if (file-exists-p abbrev-file-name) (quietly-read-abbrev-file))

(setq version-control t      ;; Use version numbers for backups.
      kept-new-versions 5    ;; Number of newest versions to keep (default: 2).
      kept-old-versions 2    ;; Number of oldest versions to keep (default: 2).
      backup-by-copying t    ;; Don't ask to delete excess backup versions.
      delete-old-versions t) ;; Copy all files, don't rename them.

;; Change the font size in the current frame using Ctrl + mouse wheel
;; (same as C-x C-+ and C-x C--)
(global-set-key [C-mouse-4] '(lambda () (interactive) (text-scale-increase 1)))
(global-set-key [C-mouse-5] '(lambda () (interactive) (text-scale-decrease 1)))

;; Local configuration file
(let ((local-config (concat user-emacs-directory "init-local.el")))
  (if (file-exists-p local-config) (load local-config)))


;;;; Packages

(use-package diminish
  :ensure t)

(use-package evil
  ;:disabled
  :ensure f
  :init
  ;; Use C-U to scroll up instead of universal-argument
  (setq evil-want-C-u-scroll t)
  :config
  ;; Enable evil-mode
  (evil-mode 1)
  ;; Disable in calendar-mode
  (evil-set-initial-state 'calendar-mode 'emacs)
  (use-package evil-leader
    :ensure t)
  (use-package evil-numbers
    :ensure t)
  (use-package evil-magit
    :if (not (version< emacs-version "24.4"))
    :ensure t)
  (use-package evil-org
    :ensure t))
;; Go
(use-package go-mode
  :ensure t)
;; JSON
(use-package json-mode
  :ensure t)
(use-package yaml-mode
  :ensure t)
;; Haskell
(use-package haskell-mode
  :ensure t)
(use-package scion
  :ensure t)
;; Erlang
(use-package erlang
  :ensure t)
;; Elixir
; Auto-completion
(use-package company
  :ensure t
  :config
  ;; Enable company-mode in all buffers
  (add-hook 'after-init-hook 'global-company-mode))
(use-package elixir-mode
  :ensure t
  :config
  ;; Create a buffer-local hook to run elixir-format on save,
  ;; only when we enable elixir-mode.
  (add-hook 'elixir-mode-hook
            (lambda () (add-hook 'before-save-hook 'elixir-format nil t)))
  ;; Use Projectile to determine if we are in a project
  ;; and then set elixir-format-arguments accordingly
  (add-hook 'elixir-format-hook (lambda ()
                                  (if (projectile-project-p)
                                      (setq elixir-format-arguments
                                            (list "--dot-formatter"
                                                  (concat (locate-dominating-file buffer-file-name ".formatter.exs") ".formatter.exs")))
                                    (setq elixir-format-arguments nil)))))
(use-package alchemist
  :ensure t)

;; Lilypond
(mapc (lambda (dir)
        (when (file-directory-p dir)
          (setq load-path (append (list (expand-file-name dir)) load-path))))
      '("C:\\Program Files (x86)\\LilyPond\\usr\\share\\emacs\\site-lisp"
        "C:\\Program Files\\LilyPond\\usr\\share\\emacs\\site-lisp"
        "/Applications/LilyPond.app/Contents/Resources/share/emacs/site-lisp"
        "/usr/local/lilypond/usr/share/emacs/site-lisp"))
(use-package lilypond-mode
  :mode (("\\.ly\\'"  . LilyPond-mode)
         ("\\.ily\\'" . LilyPond-mode))
  :config
  (cond
    ((executable-find "zathura")
      (setq LilyPond-ps-command "zathura")
      (setq LilyPond-pdf-command "zathura"))
    ((executable-find "evince")
      (setq LilyPond-ps-command "evince")
      (setq LilyPond-pdf-command "evince"))))
;; Minor mode for dealing with pairs
(use-package smartparens
  :ensure t
  :diminish smartparens-mode
  :config
  (require 'smartparens-config)
  (smartparens-global-mode t))
;; To navigate through notes
(use-package deft
  :if (not (version< emacs-version "24.4"))
  :ensure t)

;; Calendar with Japanese holidays
(use-package calendar
  :ensure t
  :config
    (setq calendar-week-start-day 1)
    (setq calendar-day-name-array ["Dimanche" "Lundi" "Mardi" "Mercredi"
                                   "Jeudi" "Vendredi" "Samedi"])
    (setq calendar-month-name-array ["Janvier" "Février" "Mars" "Avril" "Mai"
                                     "Juin" "Juillet" "Août" "Septembre"
                                     "Octobre" "Novembre" "Décembre"])
    (setq number-of-diary-entries 31)
    (add-hook 'calendar-today-visible-hook 'calendar-mark-today)

    ;; Display the week numbers
    (copy-face font-lock-constant-face 'calendar-iso-week-face)
    (set-face-attribute 'calendar-iso-week-face nil
                        :height 1.0 :foreground "salmon")
    (setq calendar-intermonth-text
          '(propertize
            (format "%2d"
                    (car
                     (calendar-iso-from-absolute
                      (calendar-absolute-from-gregorian (list month day year)))))
            'font-lock-face 'calendar-iso-week-face))

    (use-package japanese-era
      :load-path "lisp/")

    (use-package japanese-holidays
      :ensure t
      :config
        (setq calendar-holidays
              (append japanese-holidays
                      holiday-local-holidays
                      holiday-other-holidays))
        (setq mark-holidays-in-calendar t)
        ;; Show Saturday as a holiday
        (setq japanese-holiday-weekend '(0 6))
        ;; Highlight Saturdays in blue
        (setq japanese-holiday-weekend-marker
              '(holiday nil nil nil nil nil japanese-holiday-saturday))
        (add-hook 'calendar-today-visible-hook
          'japanese-holiday-mark-weekend)
        (add-hook 'calendar-today-invisible-hook
          'japanese-holiday-mark-weekend)))
;; Org-mode
;; Install the latest version
(use-package org
  :ensure t
  :bind (("C-c a" . org-agenda)
         ("C-c b" . org-iswitchb)
         ("C-c c" . org-capture)
         ("C-c l" . org-store-link)
         :map org-mode-map
         ("C-c !" . org-time-stamp-inactive))
  :mode ("\\.org$" . org-mode)
  :config
  (require 'org)
  (require 'org-compat)

  ;; enable the org-indent-mode minor mode by default
  ;; see http://orgmode.org/manual/Clean-view.html
  (setq org-startup-indented t)
  (setq org-startup-with-inline-images t)
  (setq org-pretty-entities t)
  ;; hide the emphasis characters by default
  (setq org-hide-emphasis-markers t)
  ;; show all entries unfolded by default
  (setq org-startup-folded nil)
  ;; use inline footnotes by default for easier management
  (setq org-footnote-define-inline t)
  ;; when displaying an inline image, don't use it's actual width
  ;; when set to nil, try to get the width from an #+ATTR.* keyword and fall
  ;; back on the original width if none is found
  (setq org-image-actual-width nil)
  (setq org-log-done t)
  (if (boundp 'my/local-org-agenda-files)
    (setq org-agenda-files (symbol-value 'my/local-org-agenda-files))
    (setq org-agenda-files '("~/Dropbox/Notes")))

  ;; Capture templates for org-template-extension
  (setq org-capture-templates `(
    ("p" "Protocol" entry (file+headline ,(concat org-directory "notes.org") "Inbox")
        "* %^{Title}\nSource: %u, %c\n #+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n\n%?")
    ("L" "Protocol Link" entry (file+headline ,(concat org-directory "notes.org") "Inbox")
        "* %? [[%:link][%:description]] \nCaptured On: %U")))

  ;; Allow the execution of the code blocks in the following languages
  (org-babel-do-load-languages
    'org-babel-load-languages
    '((emacs-lisp . t)
      (org . t)
      (shell . t)
      (plantuml . t)))

  ;; Exporters
  ;; ODT
  (eval-after-load "org"
    '(require 'ox-odt nil t))
  ;; Beamer
  (eval-after-load "org"
    '(require 'ox-beamer nil t))
  ;; Pandoc
  (use-package ox-pandoc
    ;; Don't use ox-pandoc unless Pandoc >= 1.13 is installed
    ;; since it's useless without the Org-mode reader
    :if
      (and (executable-find "pandoc")
           (let ((version (with-temp-buffer
                            (call-process "pandoc" nil t nil "-v")
                            (buffer-string))))
             (when (string-match "^pandoc.*? \\([0-9]+\\)\\.\\([0-9]+\\)" version)
               (let ((major (string-to-number (match-string 1 version)))
                     (minor (string-to-number (match-string 2 version))))
                 (or (< 1 major)
                     (and (= 1 major)
                          (< 12 minor)))))))
    :ensure t
    :config
      (eval-after-load "org"
        ;; Load the exporter
        '(require 'ox-pandoc nil t)))
  ;; Github-flavored Markdown
  (use-package ox-gfm
    :ensure t
    :config
    (eval-after-load "org"
      ;; Load the exporter
      '(require 'ox-gfm nil t)))
  ;; Textile
  (use-package ox-textile
    :ensure t
    :config
    (eval-after-load "org"
      ;; Load the exporter
      '(require 'ox-textile nil t)))
  ;; MediaWiki
  (use-package ox-mediawiki
    :ensure t
    :config
    (eval-after-load "org"
      ;; Load the exporter
      '(require 'ox-mediawiki nil t)))

  ;; Other extensions
  (use-package org-download
    :ensure t)
  (use-package org-pomodoro
    :ensure t)
  (use-package org-journal
    :ensure t
    :init
    (if (boundp 'my/local-org-journal-dir)
      (setq org-journal-dir (symbol-value 'my/local-org-journal-dir))
      (setq org-journal-dir "~/Dropbox/Notes/Journal"))
    (setq org-journal-file-format "%Y-%m-%d.org")
    (setq org-journal-date-format
      (lambda (&optional time)
        "Format the time as %Y-%m-%d with the current weekday in French."
        (let ((weekday (pcase (format-time-string "%u" time)
                         ("1" "lundi")
                         ("2" "mardi")
                         ("3" "mercredi")
                         ("4" "jeudi")
                         ("5" "vendredi")
                         ("6" "samedi")
                         ("7" "dimanche"))))
          (concat
            (format-time-string "#+TITLE: %Y-%m-%d" time)
            " (" weekday ")"))))
    (setq org-journal-time-prefix "* "))

  (use-package org-caldav
    :ensure t
    :init
    ;; Required to use Google's APIs
    (use-package oauth2
      :ensure t)
    :config
    (setq org-caldav-files '())
    (setq plstore-cache-passphrase-for-symmetric-encryption t))

  (use-package bongo
    :ensure t
    :config
    (use-package org-player
      :load-path "lisp/")))


;; Project management.
(use-package projectile
  :ensure t
  :commands (projectile-find-file projectile-switch-project)
  :diminish projectile-mode
  :init
  :config
  (projectile-mode))

;; IDO
(use-package ido
  :ensure t
  :config
  (setq ido-enable-flex-matching t)
  (setq ido-everywhere t)
  (setq ido-case-fold t)
  (ido-mode 1)

  (use-package ido-vertical-mode
    :if (not (version< emacs-version "24.4"))
    :ensure t
    :config
    (ido-vertical-mode 1)
    (setq ido-vertical-define-keys 'C-n-and-C-p-only))

  ;; ido-completing-read+
  (use-package ido-completing-read+
    :if (not (version< emacs-version "24.4"))
    :ensure t
    :config
    (ido-ubiquitous-mode 1))

  (use-package smex
    :ensure t
    :bind (("M-x" . smex)
           ("M-X" . smex-major-mode-commands)
           ;; This is your old M-x.
           ("C-c C-c M-x" . execute-extended-command))
    :config
    ;; Can be omitted. This might cause a (minimal) delay
    ;; when Smex is auto-initialized on its first run.
    (smex-initialize)))

;; Hydra
(use-package hydra
  :ensure t
  :bind (("s-f" . hydra-projectile/body)
         ("C-x t" . hydra-toggle/body)
         ("C-M-o" . hydra-window/body))
  :config
  (hydra-add-font-lock)

  (require 'windmove)

  (defun hydra-move-splitter-left (arg)
    "Move window splitter left."
    (interactive "p")
    (if (let ((windmove-wrap-around))
          (windmove-find-other-window 'right))
        (shrink-window-horizontally arg)
      (enlarge-window-horizontally arg)))

  (defun hydra-move-splitter-right (arg)
    "Move window splitter right."
    (interactive "p")
    (if (let ((windmove-wrap-around))
          (windmove-find-other-window 'right))
        (enlarge-window-horizontally arg)
      (shrink-window-horizontally arg)))

  (defun hydra-move-splitter-up (arg)
    "Move window splitter up."
    (interactive "p")
    (if (let ((windmove-wrap-around))
          (windmove-find-other-window 'up))
        (enlarge-window arg)
      (shrink-window arg)))

  (defun hydra-move-splitter-down (arg)
    "Move window splitter down."
    (interactive "p")
    (if (let ((windmove-wrap-around))
          (windmove-find-other-window 'up))
        (shrink-window arg)
      (enlarge-window arg)))

  (defhydra hydra-toggle (:color teal)
    "
_a_ abbrev-mode:      %`abbrev-mode
_d_ debug-on-error    %`debug-on-error
_f_ auto-fill-mode    %`auto-fill-function
_t_ truncate-lines    %`truncate-lines

"
    ("a" abbrev-mode nil)
    ("d" toggle-debug-on-error nil)
    ("f" auto-fill-mode nil)
    ("t" toggle-truncate-lines nil)
    ("q" nil "cancel"))

  (defhydra hydra-error (global-map "M-g")
    "goto-error"
    ("h" flycheck-list-errors "first")
    ("j" flycheck-next-error "next")
    ("k" flycheck-previous-error "prev")
    ("v" recenter-top-bottom "recenter")
    ("q" nil "quit"))

  (defhydra hydra-org-template (:color blue :hint nil)
    "
_c_enter  _q_uote     _e_macs-lisp    _L_aTeX:
_l_atex   _E_xample   _p_erl          _i_ndex:
_a_scii   _v_erse     _P_erl tangled  _I_NCLUDE:
_s_rc     ^ ^         plant_u_ml      _H_TML:
_h_tml    ^ ^         ^ ^             _A_SCII:
"
    ("s" (hot-expand "<s"))
    ("E" (hot-expand "<e"))
    ("q" (hot-expand "<q"))
    ("v" (hot-expand "<v"))
    ("c" (hot-expand "<c"))
    ("l" (hot-expand "<l"))
    ("h" (hot-expand "<h"))
    ("a" (hot-expand "<a"))
    ("L" (hot-expand "<L"))
    ("i" (hot-expand "<i"))
    ("e" (progn
           (hot-expand "<s")
           (insert "emacs-lisp")
           (forward-line)))
    ("p" (progn
           (hot-expand "<s")
           (insert "perl")
           (forward-line)))
    ("u" (progn
           (hot-expand "<s")
           (insert "plantuml :file CHANGE.png")
           (forward-line)))
    ("P" (progn
           (insert "#+HEADERS: :results output :exports both :shebang \"#!/usr/bin/env perl\"\n")
           (hot-expand "<s")
           (insert "perl")
           (forward-line)))
    ("I" (hot-expand "<I"))
    ("H" (hot-expand "<H"))
    ("A" (hot-expand "<A"))
    ("<" self-insert-command "ins")
    ("o" nil "quit"))

  (defun hot-expand (str)
    "Expand org template."
    (insert str)
    (org-try-structure-completion))

  (eval-after-load "org"
    '(define-key org-mode-map "<"
       (lambda () (interactive)
         (if (looking-back "^")
             (hydra-org-template/body)
           (self-insert-command 1)))))

  (defhydra hydra-projectile (:color blue :columns 4)
    "Projectile"
    ("a" counsel-git-grep "ag")
    ("b" projectile-switch-to-buffer "switch to buffer")
    ("c" projectile-compile-project "compile project")
    ("d" projectile-find-dir "dir")
    ("f" projectile-find-file "file")
    ;; ("ff" projectile-find-file-dwim "file dwim")
    ;; ("fd" projectile-find-file-in-directory "file curr dir")
    ("g" ggtags-update-tags "update gtags")
    ("i" projectile-ibuffer "Ibuffer")
    ("K" projectile-kill-buffers "Kill all buffers")
    ;; ("o" projectile-multi-occur "multi-occur")
    ("p" projectile-switch-project "switch")
    ("r" projectile-run-async-shell-command-in-root "run shell command")
    ("x" projectile-remove-known-project "remove known")
    ("X" projectile-cleanup-known-projects "cleanup non-existing")
    ("z" projectile-cache-current-file "cache current")
    ("q" nil "cancel")))

(use-package rainbow-delimiters
  :ensure t
  :config
  (require 'rainbow-delimiters)
  ; (add-hook 'clojure-mode-hook 'rainbow-delimiters-mode)
  (add-hook 'lisp-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'emacs-lisp-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'clojure-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'racket-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'scheme-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'lilypond-mode-hook #'rainbow-delimiters-mode)
  ;; use stronger colors
  (require 'color)
  (defun rainbow-delimiters-using-stronger-colors ()
    (interactive)
    (cl-loop
      for index from 1 to rainbow-delimiters-max-face-count
      do
      (let ((face (intern (format "rainbow-delimiters-depth-%d-face" index))))
        (cl-callf color-saturate-name (face-foreground face) 40))))
  (add-hook 'emacs-startup-hook #'rainbow-delimiters-using-stronger-colors))

;; Magit
(use-package magit
  :if (not (version< emacs-version "24.4"))
  :ensure t
  :commands magit-status
  :bind (("C-x g" . magit-status))
  :config
  ;; Disable VC for Git
  (setq vc-handled-backends (delq 'Git vc-handled-backends)))

;; Monky
(use-package monky
  :ensure t
  :commands monky-status
  :config
  ;; By default monky spawns a seperate hg process for every command.
  ;; This will be slow if the repo contains lot of changes.
  ;; if `monky-process-type' is set to cmdserver then monky will spawn a single
  ;; cmdserver and communicate over pipe.
  ;; Available only on mercurial versions 1.9 or higher
  (setq monkey-process-type 'cmdserver)
  ;; Disable VC for Mercurial
  (setq vc-handled-backends (delq 'Mercurial vc-handled-backends)))

;; IRC client
(use-package erc
  :ensure t
  :commands erc)

;; Elfeed
;; RSS client
(use-package elfeed
  :disabled
  :ensure t
  :bind (("C-x w" . elfeed)))

(use-package jabber
  :ensure t)

;; switch-window
;; Visual mode for C-x o
(use-package switch-window
  :ensure t
  :bind (("C-x o" . switch-window)
         ("C-x 1" . switch-window-then-maximize)
         ("C-x 2" . switch-window-then-split-below)
         ("C-x 3" . switch-window-then-split-right)
         ("C-x 0" . switch-window-then-delete)))

;; JavaScript
(use-package js2-mode
  :ensure t
  :init
  (setq js2-highlight-level 3)
  :config
  (add-hook 'js-mode-hook
            (lambda ()
              (unless (derived-mode-p 'json-mode)
                'js2-minor-mode)))
  (use-package ac-js2
    :ensure t
    :config
    (add-hook 'js2-mode-hook 'ac-js2-mode)))


;; Markdown
(use-package markdown-mode
  :ensure t
  :mode (("\\.text\\'"  . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)
         ("\\.md\\'" . markdown-mode))
  :init
  (cond
    ((executable-find "pandoc")
      (setq markdown-command "pandoc"))
    ((executable-find "multimarkdown")
      (setq markdown-command "multimarkdown")))
  :config
  (use-package markdown-preview-mode
    :ensure t))

;; PlantUML
(use-package plantuml-mode
  :ensure t
  :mode (("\\.plantuml\\'"  . plantuml-mode)
         ("\\.puml\\'"  . plantuml-mode)
         ("\\.uml\\'"  . plantuml-mode))
  :init
  ;; Set the first JAR file found
  (cl-some (lambda (file)
             (when (file-exists-p file)
               (setq plantuml-jar-path file)))
           `("C:\\bin\\plantuml.jar"
             ,(concat (getenv "HOME") "/lib/java/plantuml.jar")
             "/opt/plantuml/plantuml.jar")))

;; PKGBUILD
(use-package pkgbuild-mode
  :ensure t
  :mode (("/PKGBUILD$" . pkgbuild-mode)))

;; Image+ - Zoom / Dezoom using C-c + / C-c -
(use-package image+
  :ensure t)

;; auto-complete
(use-package auto-complete
  :ensure t
  :diminish auto-complete-mode
  :config
  (ac-config-default)
  (global-auto-complete-mode t))

;; Flycheck
(use-package flycheck
  :ensure t
  :diminish flycheck-mode
  :commands flycheck-mode
  :init
  (add-hook 'after-init-hook #'global-flycheck-mode)
  :config
  (use-package flycheck-plantuml
    :ensure t
    :config
    (flycheck-plantuml-setup)))

;; multiple-cursors
(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<"  . mc/mark-all-like-this)))

;; fill-column indicator
(use-package fill-column-indicator
  :if (>= emacs-major-version 25)
  :ensure t
  :config
  (define-globalized-minor-mode
    global-fci-mode fci-mode (lambda () (fci-mode 1)))
  (global-fci-mode t))

;; TeX
(use-package tex
  :defer t
  :ensure auctex
  :config
  ; (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  ; (setq TeX-save-query nil)
  (setq TeX-PDF-mode t)
  (use-package auctex-latexmk
    :ensure t
    :config
    (auctex-latexmk-setup)
    (setq auctex-latexmk-inherit-TeX-PDF-mode t)))

;; Python
(use-package python-mode
  :ensure t
  :mode ("\\.py\\'" . python-mode)
  :interpreter "python"
  :init
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
  (setq py-smart-indentation t))

;; Ruby
(use-package ruby-mode
  :ensure t
  :mode "\\.rb\\'"
  :interpreter "ruby")

;; Go
(use-package go-mode
  :ensure t
  :mode "\\.go\\'")

;; Language Server Protocol
(use-package lsp-mode
  :commands lsp)

(add-hook 'go-mode-hook #'lsp)

;; optional - provides fancier overlays
(use-package lsp-ui
  :commands lsp-ui-mode)

;; if you use company-mode for completion (otherwise, complete-at-point works out of the box):
(use-package company-lsp
  :commands company-lsp)

;; Epub
(use-package nov
  :if (executable-find "unzip")
  :ensure t
  :mode ("\\.epub\\'" . nov-mode)
  :config
  ;; Setup text justification
  (use-package dash-functional
    :ensure t
    :config
    (use-package justify-kp
      :load-path "lisp/"
      :ensure t
      :config
      (setq nov-text-width most-positive-fixnum)

      (defun my/nov-window-configuration-change-hook ()
        (my/nov-post-html-render-hook)
        (remove-hook 'window-configuration-change-hook
                     'my/nov-window-configuration-change-hook
                     t))

      (defun my/nov-post-html-render-hook ()
        (if (get-buffer-window)
            (let ((max-width (pj-line-width))
                  buffer-read-only)
              (save-excursion
                (goto-char (point-min))
                (while (not (eobp))
                  (when (not (looking-at "^[[:space:]]*$"))
                    (goto-char (line-end-position))
                    (when (> (shr-pixel-column) max-width)
                      (goto-char (line-beginning-position))
                      (pj-justify)))
                  (forward-line 1))))
          (add-hook 'window-configuration-change-hook
                    'my/nov-window-configuration-change-hook
                    nil t)))

      (add-hook 'nov-post-html-render-hook 'my/nov-post-html-render-hook))))

;; pretty-mode + prettify-symbols-mode
;; Equivalent to Vim's conceal feature
;; See [[http://www.modernemacs.com/post/prettify-mode/]]
(when (find-font (font-spec :name "Fira Code"))
  (set-frame-font "Fira Code" nil t))
;; Set the size (10pt)
(set-face-attribute 'default nil :height 100)

(use-package pretty-mode
  :ensure t
  :config
    (use-package pretty-mode-plus :ensure t)
    (global-pretty-mode t)
    (pretty-deactivate-groups
     '(:equality :ordering :ordering-double :ordering-triple :nil
       :punctuation :logic :sets))

    (pretty-activate-groups
     '(:sub-and-superscripts :greek :arithmetic-nary)))

(unless (version< emacs-version "24.4")
  (global-prettify-symbols-mode 1)

  (add-hook
    'python-mode-hook
    (lambda ()
      (mapc (lambda (pair) (push pair prettify-symbols-alist))
            '(;; Syntax
              ("def" .      #x2131)
              ("not" .      #x2757)
              ("in" .       #x2208)
              ("not in" .   #x2209)
              ("return" .   #x27fc)
              ("yield" .    #x27fb)
              ("for" .      #x2200)
              ;; Base Types
              ("int" .      #x2124)
              ("float" .    #x211d)
              ("str" .      #x1d54a)
              ("True" .     #x1d54b)
              ("False" .    #x1d53d)
              ;; Mypy
              ("Dict" .     #x1d507)
              ("List" .     #x2112)
              ("Tuple" .    #x2a02)
              ("Set" .      #x2126)
              ("Iterable" . #x1d50a)
              ("Any" .      #x2754)
              ("Union" .    #x22c3))))))

(use-package vim-digraphs
  :load-path "lisp/")

(use-package decide
  :load-path "lisp/")


;;;; Custom functions
;; Reload the init file
(global-set-key "\C-cs" (lambda () (interactive) (load-file user-init-file)))

(defun my/clean-buffer-formatting ()
    "Indent and clean up the buffer."
    (interactive)
    (indent-region (point-min) (point-max))
    (whitespace-cleanup))

(global-set-key "\C-cn" 'my/clean-buffer-formatting)

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

(defun my/tf-toggle-show-trailing-whitespace ()
  "Toggle show-trailing-whitespace between t and nil."
  (interactive)
  (setq show-trailing-whitespace (not show-trailing-whitespace)))

;; Usage Example:
;;
;; <!--- BEGIN RECEIVE ORGTBL ${1:YOUR_TABLE_NAME} --->
;; <!--- END RECEIVE ORGTBL $1 --->
;;
;; <!---
;; #+ORGTBL: SEND $1 orgtbl-to-gfm
;; | $0 |
;; --->
(defun orgtbl-to-gfm (table params)
  "Convert the Orgtbl mode TABLE to GitHub Flavored Markdown."
  (let* ((alignment (mapconcat (lambda (x) (if x "|--:" "|---"))
                   org-table-last-alignment ""))
     (params2
      (list
       :splice t
       :hline (concat alignment "|")
       :lstart "| " :lend " |" :sep " | ")))
    (orgtbl-to-generic table (org-combine-plists params2 params))))

(defun stag-insert-org-to-md-table (table-name)
  (interactive "*sEnter table name: ")
  (insert "<!---
#+ORGTBL: SEND " table-name " orgtbl-to-gfm

-->
<!--- BEGIN RECEIVE ORGTBL " table-name " -->
<!--- END RECEIVE ORGTBL " table-name " -->")
  (previous-line)
  (previous-line)
  (previous-line))

;; Store entries created by customize in a separate file
(setq custom-file (concat user-emacs-directory "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))
