;;,-----------------------------------------------------------------------------
;;| custom-file / load-path
;;`-----------------------------------------------------------------------------
(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file)

(add-to-list 'load-path (concat user-emacs-directory "lisp/"))

;;,-----------------------------------------------------------------------------
;;| cask / use-package
;;`-----------------------------------------------------------------------------
(require 'cask)
(cask-initialize)

(eval-when-compile
  (require 'use-package))

;;,-----------------------------------------------------------------------------
;;| editing
;;`-----------------------------------------------------------------------------
(defun indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defun rename-current-buffer-file ()
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file" name)
      (let ((new-name (read-file-name "New name: " filename)))
        (if (get-buffer new-name)
            (error "A buffer named '%s' already exists" new-name)
          (rename-file filename new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil)
          (message "File '%s' successfully renamed to '%s'"
                   name (file-name-nondirectory new-name)))))))

(defun delete-current-buffer-file ()
  (interactive)
  (let ((filename (buffer-file-name))
        (buffer (current-buffer))
        (name (buffer-name)))
    (if (not (and filename (file-exists-p filename)))
        (ido-kill-buffer)
      (when (yes-or-no-p "Are you sure you want to remove this file? ")
        (delete-file filename)
        (kill-buffer buffer)
        (message "File '%s' successfully removed" filename)))))

(delete-selection-mode 1)
(global-subword-mode 1)

(diminish 'auto-fill-function)
(diminish 'subword-mode)

(setq-default fill-column 80
              indent-tabs-mode nil)

(setq mode-require-final-newline 'visit-save
      require-final-newline 'visit-save
      sentence-end-double-space nil
      shift-select-mode nil
      x-select-enable-clipboard t)

(dolist (x '(downcase-region
             erase-buffer
             narrow-to-region
             set-goal-column))
  (put x 'disabled nil))

(defadvice kill-region (before slick-cut activate compile)
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))

(defadvice kill-ring-save (before slick-copy activate compile)
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (message "Copied line")
     (list (line-beginning-position)
           (line-beginning-position 2)))))

(bind-key "C-M-'" #'indent-buffer)
(bind-key "C-M-\"" #'indent-region)
(bind-key "M-'" #'just-one-space)

(bind-key "C-x C-r" #'rename-current-buffer-file)
(bind-key "C-x C-k" #'delete-current-buffer-file)

;;,-----------------------------------------------------------------------------
;;| locale
;;`-----------------------------------------------------------------------------
(setq locale-coding-system 'utf-8)

(set-charset-priority 'unicode)
(set-keyboard-coding-system 'utf-8)
(set-language-environment "UTF-8")
(set-selection-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)

(prefer-coding-system 'utf-8)

;;,-----------------------------------------------------------------------------
;;| misc
;;`-----------------------------------------------------------------------------
(auto-compression-mode 1)

(setq gc-cons-threshold 67108864)

(setenv "PATH" (concat (getenv "PATH") ":/usr/texbin"))

;;,-----------------------------------------------------------------------------
;;| backup / recentf
;;`-----------------------------------------------------------------------------
(setq backup-by-copying t
      backup-directory-alist '(("." . "~/.emacs.d/backups/"))
      delete-by-moving-to-trash t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      user-full-name "Michael Griffiths"
      user-mail-address "mikey@cich.li"
      version-control t)

(use-package recentf
  :config
  (recentf-mode 1)
  (setq recentf-max-saved-items 100
        recentf-save-file "~/.emacs.d/.recentf"))

;;,-----------------------------------------------------------------------------
;;| ui
;;`-----------------------------------------------------------------------------
(defun diminish-major (hook alias)
  (add-hook hook `(lambda () (setq mode-name ,alias))))

(defun hide-trailing-whitespace ()
  (interactive)
  (setq show-trailing-whitespace nil))

(defun show-trailing-whitespace ()
  (interactive)
  (setq show-trailing-whitespace t))

(blink-cursor-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)

(column-number-mode 1)
(fringe-mode '(1 . nil))
(global-font-lock-mode 1)
(line-number-mode 1)
(mac-auto-operator-composition-mode 1)
(winner-mode 1)

(setq-default indicate-empty-lines t
              show-trailing-whitespace t
              truncate-lines t)

(setq echo-keystrokes 0.1
      frame-title-format '(buffer-file-name "%f" ("%b"))
      inhibit-startup-echo-area-message t
      inhibit-startup-screen t
      split-height-threshold nil
      split-width-threshold 160
      x-underline-at-descent-line t)

(set-face-attribute 'default nil :font "Fira Code Retina 10")
(set-frame-font "Fira Code Retina 10" nil t)

(plist-put minibuffer-prompt-properties 'point-entered 'minibuffer-avoid-prompt)

(defadvice kill-buffer (around kill-buffer-around-advice activate)
  (let ((buffer-to-kill (ad-get-arg 0)))
    (if (equal buffer-to-kill "*scratch*")
        (bury-buffer)
      ad-do-it)))

(defalias 'yes-or-no-p 'y-or-n-p)

(bind-key "M-ƒ" #'toggle-frame-fullscreen)
(bind-key "C-o" #'isearch-occur isearch-mode-map)

(use-package autorevert
  :config
  (global-auto-revert-mode 1)
  (diminish 'auto-revert-mode)
  (setq auto-revert-verbose nil
        global-auto-revert-non-file-buffers t))

(use-package solarized
  :config
  (setq solarized-distinct-doc-face t
        solarized-scale-org-headlines nil
        solarized-use-more-italic t
        solarized-use-variable-pitch nil)
  (load-theme 'solarized-dark t))

(make-variable-buffer-local 'transient-mark-mode)
(put 'transient-mark-mode 'permanent-local t)
(setq-default transient-mark-mode t)

;;,-----------------------------------------------------------------------------
;;| packages
;;`-----------------------------------------------------------------------------
(use-package ace-jump-buffer
  :bind
  (("C-c b" . ace-jump-buffer)
   ("C-c B" . ace-jump-buffer-other-window)
   ("C-c C-S-b" . ace-jump-buffer-in-one-window)))

(use-package ace-window
  :config
  (setq aw-scope 'frame)
  (set-face-attribute 'aw-leading-char-face nil :height 3.0)
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  :bind
  (("M-o" . ace-window)))

(use-package avy
  :bind
  (("C-c SPC" . avy-goto-char)
   ("C-c C-SPC" . avy-goto-word-or-subword-1)
   ("C-c g" . avy-goto-line)
   ("C-c M-g" . avy-goto-line)))

(use-package avy-zap
  :bind
  (("M-z" . avy-zap-to-char-dwim)
   ("M-Z" . avy-zap-up-to-char-dwim)))

(use-package back-button
  :defer 1
  :commands
  back-button-mode
  :config
  (back-button-mode 1)
  (diminish 'back-button-mode))

(use-package beacon
  :config
  (beacon-mode 1)
  (diminish 'beacon-mode))

(use-package bind-key)

(use-package browse-kill-ring
  :config
  (browse-kill-ring-default-keybindings)
  :bind
  (("C-c k" . browse-kill-ring)))

(use-package buffer-move
  :bind
  (("C-' f" . buf-move-right)
   ("C-' b" . buf-move-left)
   ("C-' n" . buf-move-down)
   ("C-' p" . buf-move-up)))

(use-package cider
  :defer t
  :config
  (diminish-major 'cider-repl-mode-hook nil)
  (diminish-major 'cider-stacktrace-mode-hook nil)
  (diminish-major 'nrepl-messages-mode-hook nil)

  (setq cider-auto-select-error-buffer t
        cider-macroexpansion-print-metadata t
        cider-mode-line nil
        cider-pprint-fn 'puget
        cider-prompt-for-symbol nil
        cider-repl-history-file (concat user-emacs-directory ".cider-history")
        cider-repl-history-size 1000
        cider-repl-pop-to-buffer-on-connect nil
        cider-repl-use-clojure-font-lock t
        cider-repl-use-pretty-printing t
        cider-repl-wrap-history t
        cider-show-error-buffer 'always
        nrepl-buffer-name-show-port t
        nrepl-log-messages t
        nrepl-message-buffer-max-size 100000000)

  (add-hook 'cider-inspector-mode-hook #'hide-trailing-whitespace)
  (add-hook 'cider-repl-mode-hook #'enable-clj-refactor-mode)
  (add-hook 'cider-repl-mode-hook #'enable-paredit-mode)
  (add-hook 'cider-repl-mode-hook #'hide-trailing-whitespace)

  (bind-key "C-c C-b" #'cider-eval-buffer cider-mode-map)
  (bind-key "{" #'paredit-open-curly cider-repl-mode-map)
  (bind-key "}" #'paredit-close-curly cider-repl-mode-map)

  (dolist (keymap (list cider-mode-map cider-repl-mode-map))
    (bind-key "C-c C-q" #'cider-quit keymap)
    (bind-key "C-c M-q" #'cider-restart keymap)
    (bind-key "C-c C-j" #'cider-create-sibling-cljs-repl keymap)))

(use-package clj-refactor
  :defer t
  :commands
  enable-clj-refactor-mode
  :config
  (setq cljr-eagerly-build-asts-on-startup nil
        cljr-favor-prefix-notation nil
        cljr-magic-requires nil)
  (defun enable-clj-refactor-mode ()
    (interactive)
    (clj-refactor-mode 1)
    (diminish 'clj-refactor-mode)
    (cljr-add-keybindings-with-prefix "C-c r")))

(use-package clojure-mode
  :config
  (diminish-major 'clojure-mode-hook "clj")
  (add-hook 'clojure-mode-hook #'enable-clj-refactor-mode)
  (add-hook 'clojure-mode-hook #'enable-paredit-mode)
  (add-hook 'clojure-mode-hook #'rainbow-delimiters-mode)
  (define-clojure-indent
    (for-all 1)
    (quick-check 1)
    (lazy-loop 1))
  (bind-key "C-c SPC" nil clojure-mode-map))

(use-package comint
  :config
  (ansi-color-for-comint-mode-on)
  (add-hook 'comint-output-filter-functions #'ansi-color-process-output)
  (add-hook 'comint-output-filter-functions #'comint-strip-ctrl-m)
  (defun comint-clear-output (&optional arg)
    (interactive "P")
    (if arg
        (progn
          (goto-char (point-max))
          (forward-line 0)
          (comint-kill-region (point-min) (point))
          (goto-char (point-max)))
      (comint-delete-output)))
  (bind-key "C-c SPC" nil comint-mode-map)
  (bind-key "C-c C-o" #'comint-clear-output comint-mode-map))

(use-package company
  :config
  (global-company-mode 1)
  (diminish 'company-mode)
  (setq company-idle-delay nil
        company-minimum-prefix-length 0
        company-selection-wrap-around t
        company-tooltip-align-annotations t
        company-tooltip-limit 16
        company-require-match nil)
  (bind-key "C-q" #'company-show-doc-buffer company-active-map)
  :bind
  (("C-<tab>" . company-complete)))

(use-package conf-mode
  :config
  (bind-key "C-c SPC" nil conf-mode-map))

(use-package diff-hl
  :config
  (global-diff-hl-mode 1)
  (setq diff-hl-draw-borders nil))

(use-package diff-mode
  :config
  (add-hook 'diff-mode-hook '(lambda ()
                               (setq-local whitespace-style '(face
                                                              indentation
                                                              tabs tab-mark
                                                              spaces space-mark
                                                              newline newline-mark
                                                              space-before-tab space-after-tab))
                               (whitespace-mode 1)
                               (hide-trailing-whitespace)))
  (bind-key "M-o" nil diff-mode-map))

(use-package diminish)

(use-package dired
  :config
  (setq dired-recursive-deletes 'top))

(use-package ediff
  :config
  (setq ediff-diff-options "-w"
        ediff-split-window-function 'split-window-horizontally
        ediff-window-setup-function 'ediff-setup-windows-plain))

(use-package eldoc
  :config
  (diminish 'eldoc-mode)
  (setq eldoc-idle-delay 0))

(use-package elisp-slime-nav
  :config
  (diminish 'elisp-slime-nav-mode))

(use-package epa
  :config
  (setq epa-armor t))

(use-package eshell
  :config
  (setq eshell-directory-name "~/.emacs.d/eshell/"
        eshell-scroll-show-maximum-output nil)
  (defun eshell-clear-output (&optional arg)
    (interactive "P")
    (if arg
        (let ((eshell-buffer-maximum-lines 0))
          (eshell-truncate-buffer))
      (eshell-kill-output)))
  (add-hook 'eshell-mode-hook '(lambda ()
                                 (hide-trailing-whitespace)
                                 (bind-key "C-c SPC" nil eshell-mode-map)
                                 (bind-key "C-c C-o" #'eshell-clear-output eshell-mode-map))))

(use-package electric
  :bind
  (("C-j" . newline-and-indent)
   ("C-m" . electric-indent-just-newline)))

(use-package expand-region
  :bind
  (("C-;" . er/expand-region)))

(use-package fancy-narrow
  :config
  (fancy-narrow-mode 1)
  (diminish 'fancy-narrow-mode))

(use-package flx-ido
  :config
  (flx-ido-mode 1))

(use-package flyspell
  :config
  (diminish 'flyspell-mode))

(use-package grep
  :config
  (add-hook 'grep-mode-hook #'hide-trailing-whitespace))

(use-package guide-key
  :config
  (guide-key-mode 1)
  (diminish 'guide-key-mode)
  (setq guide-key/guide-key-sequence '("C-c" "C-x" "C-z")
        guide-key/idle-delay 0.5
        guide-key/popup-window-position 'bottom
        guide-key/recursive-key-sequence-flag t))

(use-package help-mode
  :config
  (add-hook 'help-mode-hook #'hide-trailing-whitespace))

(use-package help+)

(use-package help-fns+
  :config
  (setq help-cross-reference-manuals nil))

(use-package help-mode+)

(use-package ibuffer
  :config
  (bind-key "M-o" nil ibuffer-mode-map)
  (bind-key "C-M-o" #'ibuffer-visit-buffer-1-window ibuffer-mode-map)
  :bind
  (("C-x C-b" . ibuffer)))

(use-package ido
  :config
  (ido-mode 1)
  (ido-everywhere 1)
  (setq ido-default-buffer-method 'selected-window
        ido-default-file-method 'selected-window
        ido-save-directory-list-file (concat user-emacs-directory ".ido.last")))

(use-package ido-ubiquitous
  :config
  (ido-ubiquitous-mode 1)
  (setq ido-ubiquitous-default-state 'enable-old)
  (push '(disable exact "sql-connect") ido-ubiquitous-command-overrides))

(use-package iflipb
  :config
  (setq iflipb-include-more-buffers t
        iflipb-wrap-around t)
  :bind
  (("M-[" . iflipb-previous-buffer)
   ("M-]" . iflipb-next-buffer)))

(use-package imenu)

(use-package imenu-anywhere
  :bind
  (("C-." . ido-imenu-anywhere)))

(use-package js2-mode
  :mode "\\.js\\'"
  :interpreter "node"
  :config
  (diminish-major 'js2-mode-hook "js"))

(use-package jump-char
  :bind
  (("C-<" . jump-char-backward)
   ("C->" . jump-char-forward)))

(use-package lisp-mode
  :config
  (diminish-major 'emacs-lisp-mode-hook "el")
  (setq initial-major-mode 'emacs-lisp-mode)
  (add-hook 'emacs-lisp-mode-hook #'eldoc-mode)
  (add-hook 'emacs-lisp-mode-hook #'elisp-slime-nav-mode)
  (add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode)
  (add-hook 'emacs-lisp-mode-hook #'rainbow-delimiters-mode))

(use-package magit
  :config
  (magit-auto-revert-mode 1)
  (diminish-major 'magit-mode-hook nil)
  (diminish-major 'magit-popup-mode-hook nil)
  (setq magit-branch-read-upstream-first t
        magit-completing-read-function 'magit-ido-completing-read
        magit-diff-arguments '("-C" "-M" "--no-ext-diff" "--stat")
        magit-display-buffer-function (lambda (buffer)
                                        (if magit-display-buffer-noselect
                                            (magit-display-buffer-traditional buffer)
                                          (progn
                                            (delete-other-windows)
                                            (set-window-dedicated-p nil nil)
                                            (set-window-buffer nil buffer)
                                            (get-buffer-window buffer))))
        magit-fetch-arguments '("--prune")
        magit-log-arguments '("--color" "--decorate" "--graph" "-n256" "--show-signature")
        magit-merge-arguments '("--no-ff")
        magit-tag-arguments '("--annotate" "--sign"))
  (add-hook 'magit-popup-mode-hook #'hide-trailing-whitespace)
  (magit-add-section-hook 'magit-status-sections-hook #'magit-insert-recent-commits nil t)
  (magit-define-popup-switch 'magit-log-popup ?f
    "Follow only the first parent commit of merge commits"
    "--first-parent")
  :bind
  (("C-x m" . magit-status)
   ("C-x l" . magit-log-popup)))

(use-package markdown-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.md\\'" . gfm-mode)))

(use-package org
  :defer t
  :config
  (setq org-enforce-todo-dependencies t
        org-src-fontify-natively t
        org-startup-indented nil))

(use-package ox-reveal
  :defer t)

(use-package page-break-lines
  :config
  (global-page-break-lines-mode 1)
  (diminish 'page-break-lines-mode))

(use-package pallet
  :config
  (pallet-mode 1))

(use-package paredit
  :config
  (diminish 'paredit-mode))

(use-package paren
  :config
  (show-paren-mode 1))

(use-package paradox
  :defer t
  :config
  (setq paradox-github-token t)
  (add-hook 'paradox-menu-mode-hook #'hide-trailing-whitespace))

(use-package popwin
  :config
  (add-hook 'popwin:after-popup-hook #'hide-trailing-whitespace))

(use-package smart-mode-line
  :config
  (sml/setup))

(use-package projectile
  :config
  (projectile-global-mode 1)
  (diminish 'projectile-mode)
  (setq projectile-cache-file (concat user-emacs-directory "projectile/cache")
        projectile-known-projects-file (concat user-emacs-directory "projectile/bookmarks.eld")
        projectile-use-git-grep t))

(use-package rainbow-delimiters)

(use-package re-builder
  :config
  (setq reb-re-syntax 'string))

(use-package rebox
  :config
  (setq rebox-min-fill-column 80)
  :bind
  (("C-M-;" . rebox-dwim)
   ("C-M-:" . rebox-cycle)))

(use-package rotate
  :bind
  (("C-' l" . rotate-layout)
   ("C-' w" . rotate-window)
   ("C-' C-l" . rotate-layout)
   ("C-' C-w" . rotate-window)))

(use-package server
  :config
  (server-start))

(use-package smartrep
  :config
  (setq smartrep-mode-line-string-activated "[SMARTREP]"))

(use-package smex
  :config
  (setq smex-save-file (concat user-emacs-directory ".smex-items"))
  :bind
  (("M-x" . smex)
   ("C-c M-x" . smex-major-mode-commands)
   ("C-c C-c M-x" . execute-extended-command)))

(use-package smooth-scrolling)

(use-package sql
  :config
  (setq sql-connection-alist '(("social-dev"
                                (sql-product 'postgres)
                                (sql-server "localhost")
                                (sql-port 5432)
                                (sql-database "social")
                                (sql-user "social"))

                               ("social-beta1"
                                (sql-product 'postgres)
                                (sql-server "localhost")
                                (sql-port 5437)
                                (sql-database "social")
                                (sql-user "social"))

                               ("social-beta2"
                                (sql-product 'postgres)
                                (sql-server "localhost")
                                (sql-port 5438)
                                (sql-database "social")
                                (sql-user "social"))

                               ("social-qa"
                                (sql-product 'postgres)
                                (sql-server "localhost")
                                (sql-port 5434)
                                (sql-database "social")
                                (sql-user "social"))
                               ("social-v1"
                                (sql-product 'postgres)
                                (sql-server "localhost")
                                (sql-port 5436)
                                (sql-database "social")
                                (sql-user "social")))
        sql-product 'postgres)
  (add-hook 'sql-interactive-mode-hook #'hide-trailing-whitespace))

(use-package undo-tree
  :config
  (global-undo-tree-mode 1)
  (diminish 'undo-tree-mode)
  (diminish-major 'undo-tree-visualizer-mode-hook nil)
  (add-hook 'undo-tree-visualizer-mode-hook #'hide-trailing-whitespace))

(use-package uniquify
  :config
  (setq uniquify-buffer-name-style 'forward))

(use-package volatile-highlights
  :config
  (volatile-highlights-mode 1)
  (diminish 'volatile-highlights-mode)
  (set-face-inverse-video 'vhl/default-face t))

(use-package webjump
  :config
  (setq webjump-sites '(("Google" .
                         [simple-query "google.com" "google.com/search?q=" ""])
                        ("Stack Overflow" .
                         [simple-query "stackoverflow.com" "stackoverflow.com/search?q=" ""])
                        ("MDN" .
                         [simple-query "developer.mozilla.org" "developer.mozilla.org/en-US/search?q=" ""])
                        ("Clojars" .
                         [simple-query "clojars.org" "clojars.org/search?q=" ""])
                        ("Maven Central" .
                         [simple-query "search.maven.org" "search.maven.org/#search%7Cga%7C1%7C" ""])
                        ("Wikipedia" .
                         [simple-query "wikipedia.org" "wikipedia.org/wiki/" ""])
                        ("Google Groups" .
                         [simple-query "groups.google.com" "groups.google.com/groups?q=" ""])
                        ("Emacs Wiki" .
                         [simple-query "emacswiki.org" "emacswiki.org/cgi-bin/wiki/" ""])))
  :bind
  (("C-x g" . webjump)))

(use-package wgrep)

(use-package whitespace
  :bind
  (("C-c n" . whitespace-cleanup)
   ("C-c w" . whitespace-mode)))

(use-package winner
  :bind
  (("C-c [" . winner-undo)
   ("C-c ]" . winner-redo)))

(use-package with-editor
  :config
  (diminish 'with-editor-mode))

(use-package zoom-frm
  :bind
  (("C-x C-0" . zoom-frm-unzoom)
   ("C-x C--" . zoom-frm-out)
   ("C-x C-=" . zoom-frm-in)
   ("C-x C-+" . zoom-frm-in)))
