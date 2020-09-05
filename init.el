
(defun my-init-edit ()
  "Open the init file for editing."
  (interactive)
  (find-file (concat user-emacs-directory "init.el")))

(defun my-init-load ()
  "Load the init file."
  (interactive)
  (load-file (concat user-emacs-directory "init.el")))

(defun nix-find-executable (pkg executable)
  "Find the EXECUTABLE within the specified PKG."
  (interactive
   "spkg: \nsexecutable: \n")
  (string-trim
   (shell-command-to-string
    (concat "nix-shell -p " pkg " --run 'which " executable "'"))))

;; this is so annoying so get this out of here
(setq ring-bell-function 'ignore)

;; stop blinking
(blink-cursor-mode -1)

;; make specific directory for backups
(setq backup-by-copying t
      backup-directory-alist '(("." . "~/.emacs.d/backup/"))
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)


(setq-default truncate-lines nil)
(setq-default word-wrap t)

;; show relative line number

(setq-default display-line-numbers 'visual
	      display-line-numbers-widen t
	      display-line-numbers-current-absolute t)

;; make the current line bold
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(line-number-current-line ((t :weight bold))))

(require 'package)

;; packages are made available and installed using nix
(setq package-archives nil)

;; TODO not sure if this is required
(package-initialize)

(require 'use-package)
(setq use-package-always-ensure t)

;; personal info TODO offload this to another file
(setq user-full-name "Frederik Engels"
      user-mail-address "frederik.engels92@gmail.com")

;; mouse wheel more suitable for touchpad
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)

;; disable all unneeded bars

(menu-bar-mode -1)
(toggle-scroll-bar t)
(tool-bar-mode -1)

;; always have parenthesis mode on

(show-paren-mode 1)
(setq show-paren-style 'expression
      show-paren-delay 0)

;; TODO decide whether I need line numbers

(add-to-list 'default-frame-alist
	      '(font . "Fira Mono 11"))

;; use the shorter y/n

(fset 'yes-or-no-p 'y-or-n-p)

;; utf8 should be expected

(set-language-environment "UTF-8")

;; use-package section


(use-package delight)

(use-package which-key
  :defer 3
  :delight
  :commands which-key-mode
  :config
  (which-key-mode t))

(use-package paredit
  :disabled t
  :delight
  :hook
  (lisp-mode . paredit-mode)
  (common-lisp-mode . paredit-mode)
  (emacs-lisp-mode . paredit-mode)
  (scheme-mode . paredit-mode))

(use-package evil-paredit
  :disabled t
  :delight
  :after (paredit evil)
  :hook
  (paredit-mode . evil-paredit-mode))

(use-package lispy
  :disabled t
  :hook
  (lisp-mode . lispy-mode)
  (common-lisp-mode . lispy-mode)
  (emacs-lisp-mode . lispy-mode)
  (scheme-mode . lispy-mode))

(use-package lispyville
  :disabled t
  :hook
  (lispy-mode . lispyville-mode))

(use-package evil
  :commands (evil-mode)
  :init
  (setq evil-want-integration t
	evil-want-keybinding nil)
  (evil-mode))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-escape
  :after evil
  :delight
  :init
  (setq-default evil-escape-key-sequence (kbd "fd"))
  (setq-default evil-escape-delay 0.125)
  :config
  (evil-escape-mode))

(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

(use-package general
  :config
  (with-eval-after-load 'evil
    (progn
      (general-define-key
       :states 'motion
       ";" #'evil-ex
       ":" #'evil-repeat-find-char)
      (general-create-definer my-leader-def
	:states '(normal insert motion visual emacs)
	:keymaps 'override
	:prefix "SPC"
	:non-normal-prefix "M-SPC")
      (my-leader-def
	"SPC" '(counsel-M-x :which-key "M-x")

	"f" '(:ignore t :which-key "file")
	"ff" '(find-file :which-key "find")
	"fw" '(write-file :which-key "write")
	"fr" '(rename-file :which-key "rename")
	"fd" '(delete-file :which-key "delete")

	"fe" '(:ignore t :which-key "emacs")
	"fer" '(my-init-load :which-key "reload")
	"fec" '(my-init-edit :which-key "edit")

	"r" '(:ignore t :which-key "frame")
	"rr" '(make-frame :which-key "new")
	"rf" '(find-file-other-frame :which-key "find file")
	"rq" '(delete-frame :which-key "delete")

	"w" '(:ignore t :which-key "window")
	"wq" '(delete-window :which-key "delete")
	"wd" '(kill-buffer-and-window :which-key "delete buffer and window")

	"wh" '(windmove-left :which-key "left")
	"wl" '(windmove-right :which-key "right")
	"wj" '(windmove-down :which-key "down")
	"wk" '(windmove-up :which-key "up")

	"w=" '(balance-windows :which-key "balance")
	"w/" '(split-window-horizontally :which-key "split horizontal")
	"w-" '(split-window-vertically :which-key "split vertical")

	"b" '(:ignore t :which-key "buffer")
	"bb" '(ivy-switch-buffer :which-key "switch")
	"bh" '(previous-buffer :which-key "previous")
	"bl" '(next-buffer :which-key "next")
	"bq" '(kill-current-buffer :which-key "kill current buffer")

	"g" '(:ignore t :which-key "git")))))

(use-package golden-ratio
  :commands golden-ratio
  :init
  (with-eval-after-load 'evil
    (with-eval-after-load 'general
      (my-leader-def
	"wg" '(golden-ratio :which-key "golden ratio")))))

(use-package hydra
  :config
  (defhydra hydra-window-size (global-map "C-x w")
    "window size"
    ("=" enlarge-window "enlarge-v")
    ("-" shrink-window "shrink-v")
    ("+" enlarge-window-horizontally "enlarge-h")
    ("_" shrink-window-horizontally "enlarge-v")
    ("q" nil "quit")))

(use-package org
  :ensure org-plus-contrib
  :mode (("\\.org$" . org-mode))
  :init
  (setq org-agenda-files '("~/org/tasks.org"))
  (setq org-refile-targets '(()))
  :hook
  (org-mode . (lambda ()
		(setq fill-column 80)
		(auto-fill-mode)))
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (shell . t)
     (latex . t)))
  :init
  (with-eval-after-load 'general
    (my-leader-def
      "o" '(:ignore t :which-key "org")

      "o c" '(org-capture :which-key "capture")
      "o a" '(org-agenda :which-key "agenda")

      "o x" '(:ignore t :which-key "clock")
      "o x j" '(org-clock-jump-to-current-clock :which-key "current clock")
      "o x i" '(org-clock-in :which-key "clock in")
      "o x o" '(org-clock-out :which-key "clock out")))
  :bind (("C-c o c" . org-capture)
	 ("C-c o a" . org-agenda)
	 ("C-c o x j" . org-clock-jump-to-current-clock)))

(use-package org-journal
  :after org
  :bind (("C-c o j n" . org-journal-new-entry)
	 ("C-c o j y" . my-journal-yesterday))
  :init
  (with-eval-after-load 'general
    (my-leader-def
      "oj" '(:ignore t :which-key "journal")
      "ojn" '(org-journal-new-entry :which-key "today")
      "ojy" '(my-journal-yesterday :which-key "yesterday")))
  :init
  (setq org-journal-dir "~/org/journal/"
	org-journal-file-format "%Y%m%d")
  :preface
  (defun my-journal-get-yesterday ()
    "Gets the filename for yesterday's entry"
    (let* ((yesterday (time-subtract (current-time) (days-to-time 1)))
	   (daily-name (format-time-string "%Y%m%d" yesterday)))
      (expand-file-name (concat org-journal-dir daily-name))))
  (defun my-journal-yesterday ()
    "Open yesterday's journal entry"
    (interactive)
    (find-file (my-journal-get-yesterday))))

(use-package org-bullets
  :hook
  (org-mode . org-bullets-mode))

(use-package evil-org
  :after (evil org))

(use-package clang-format
  :bind
  (:map c-mode-base-map
	("C-c C-f" . clang-format-buffer)))

(use-package modern-cpp-font-lock
  :hook
  (c++-mode . modern-c++-font-lock-mode))

(use-package magit
  :bind (("C-x g". magit-status))
  :config
  (with-eval-after-load 'general
    (my-leader-def
      "gs" '(magit-status :which-key "magit status"))))

(use-package forge
  :after magit)

(use-package magit-gh-pulls
  :disabled t
  :after magit
  :hook
  (magit-mode . turn-on-magit-gh-pulls))

(use-package magit-gitflow
  :disabled t
  :after magit
  :hook
  (magit-mode . turn-on-magit-gitflow))

(use-package evil-magit
  :after evil)

(use-package git-commit)

(use-package git-timemachine
  :commands (git-timemachine)
  :bind (:map git-timemachine-mode-map
	      ("M-p" . git-timemachine-show-previous-revision)
	      ("M-n" . git-timemachine-show-next-revision)
	      ("C-c C-l" . git-timemachine-show-current-revision)
	      ("C-c C-n" . git-timemachine-show-nth-revision)
	      ("C-c C-q" . git-timemachine-quit)
	      ("C-c C-f" . git-timemachine-show-revision-fuzzy)
	      ("C-c C-m" . git-timemachine-show-commit)
	      ("C-c C-b" . git-timemachine-blame))
  :init
  (with-eval-after-load 'general
    (my-leader-def
      "gt" '(git-timemachine :which-key "timemachine"))))

(use-package gitignore-mode
  :mode "\.gitignore")

(use-package ivy
  :delight
  :config
  (setq ivy-height 20)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (setq ivy-display-style 'fancy)
  (ivy-mode t)
  (with-eval-after-load 'projectile
    (setq projectile-completion-system 'ivy))
  :bind (("C-x b" . ivy-switch-buffer)
	 ("C-x B" . ivy-switch-buffer-other-window))
  :bind (:map ivy-switch-buffer-map
	      ("C-k" . ivy-switch-buffer-kill)))

(use-package ivy-xref
  :init
  (setq xref-show-xrefs-function #'ivy-xref-show-xrefs))

(use-package counsel
  :delight
  :after ivy
  :config
  (counsel-mode))

(use-package ivy-rich
  :after ivy
  :config
  (ivy-rich-mode t))

(use-package swiper
  :delight
  :after ivy
  :init
  (global-unset-key (kbd "C-s"))
  :bind (("C-s C-s" . swiper))
  :config
  (with-eval-after-load 'evil
    (with-eval-after-load 'general
      (general-define-key
       :states 'motion
       "/" #'swiper))))

(use-package avy
  :disabled t
  :bind
  ("C-s C-c" . avy-goto-char)
  ("C-s C-l" . avy-goto-line)
  :config
  (with-eval-after-load 'evil
    (with-eval-after-load 'general
      (general-define-key
       :states 'motion
       "f" #'avy-goto-char
       "gl" #'avy-goto-line))))

(use-package ace-window
  :config
  (with-eval-after-load 'general
    (my-leader-def
      "ww" '(ace-window :which-key "ace")))
  (with-eval-after-load 'hydra
    (defhydra hydra-window-control (global-map "C-w")
      ("/" split-window-horizontally)
      ("-" split-window-vertically))))

(use-package ace-jump-mode
  :config
  (with-eval-after-load 'general
    (general-define-key
     "M-g l" '(ace-jump-line-mode :which-key "ace jump line")
     "M-g c" '(ace-jump-char-mode :which-key "find char"))))

(use-package projectile
  :delight
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :config
  (projectile-mode t)
  (setq projectile-enable-caching t)
  (add-to-list 'projectile-globally-ignored-directories "build")
  (add-to-list 'projectile-globally-ignored-file-suffixes ".o")
  (add-to-list 'projectile-globally-ignored-file-suffixes ".so")
  :init
  (with-eval-after-load 'general
    (my-leader-def
      "p" '(:ignore t :which-key "projectile")
      "pp" '(projectile-switch-project :which-key "switch project")
      "pq" '(projectile-switch-open-project :which-key "switch open project")
      "pa" '(projectile-find-other-file :which-key "find other file")
      "pI" '(projectile-ibuffer :which-key "ibuffer")
      "pf" '(projectile-find-file :which-key "find file")

      "ps" '(:ignore t :which-key "search")
      "psr" '(projectile-ripgrep :which-key "ripgrep")
      "pss" '(projectile-ag :which-key "ag")
      "psg" '(projectile-grep :which-key "grep"))))

;; don't forget to run M-x all-the-icons-install-fonts
;; I wanted to use this package to setup in combination with company-box but I'm not sure how so disabled for a while
(use-package all-the-icons
  :disabled t)

(use-package all-the-icons-ivy
  :disabled t
  :after
  (all-the-icons ivy)
  :config
  (all-the-icons-ivy-setup))

(use-package geiser)

(use-package powerline
  :disabled t
  :config
  (powerline-default-theme))

(use-package moe-theme
  :config
  (moe-dark))

(use-package company
  :delight
  :defer 3
  :config
  (setq company-minimum-prefix-length 1)
  (with-eval-after-load 'general
    (general-define-key
     "TAB" 'company-indent-or-complete-common))
  :hook
  (after-init . global-company-mode))

(use-package company-quickhelp
  :hook
  (company-mode . company-quickhelp-mode))

(use-package company-box
  :disabled t
  :hook
  (company-mode . company-box-mode))

(use-package company-lsp
  :after (company lsp-mode)
  :config
  (push 'company-lsp company-backends))

(use-package lsp-mode
  :commands lsp
  :init
  (setq lsp-prefer-flymake nil)
  :config
  (require 'lsp-clients)
  (with-eval-after-load 'general
    (my-leader-def
      "l" '(:ignore t :which-key "lsp")
      "lr" '(lsp-rename :which-key "rename")
      "lf" '(:ignore t :which-key "find")
      "lfd" '(lsp-find-definition :which-key "definition")
      "lfD" '(lsp-find-declaration :which-key "declaration")))
  :hook
  (rust-mode . lsp))

(use-package lsp-ui
  :hook
  (lsp-mode . lsp-ui-mode)
  (lsp-ui-mode . (lambda () (flycheck-popup-tip-mode -1)))
  :init
  (setq lsp-ui-flycheck-enable t)
  :config
  (with-eval-after-load 'general
    (my-leader-def
      "lu" '(:ignore t :which-key "lsp-ui"))))

(use-package ccls
  :disabled t
  :defer t
  :init
  (with-eval-after-load 'projectile
    (add-to-list 'projectile-globally-ignored-directories ".ccls-cache"))
  (defun lsp-ccls ()
    ;(require 'lsp-mode)
    ;(require 'ccls)
    (lsp))
  :hook
  (c-mode . (lsp-ccls))
  (c++-mode . (lsp-ccls)))

(use-package cquery
  :init
  (setq cquery-executable "cquery")
  (with-eval-after-load 'projectile
    (add-to-list 'projectile-globally-ignored-directories ".cquery-cache")
    (setq projectile-project-root-files-top-down-recurring
	  (append '("compile_commands.json"
		    ".cquery")
		  projectile-project-root-files-top-down-recurring)))
  :hook
  (c-mode . lsp-cquery-enable)
  (c++-mode . lsp-cquery-enable))

(use-package dap-mode
  :disabled t)

(use-package rust-mode
  :mode ("\\.rs\\'" . rust-mode))

(use-package cargo
  :mode ("Cargo\.toml" . cargo-minor-mode)
  :hook
  (rust-mode . cargo-minor-mode))

(use-package flycheck
  :config
  ;(global-flycheck-mode)
  (with-eval-after-load 'general
    (my-leader-def
      "c" '(:ignore t :which-key "flycheck")
      "cj" '(flycheck-next-error :which-key "next error")
      "ck" '(flycheck-previous-error :which-key "prev error")
      "cl" '(flycheck-list-errors :which-key "list errors"))))

(use-package flycheck-popup-tip
  :hook
  (flycheck-mode . flycheck-popup-tip-mode))

(use-package flycheck-rust
  :hook
  (rust-mode flycheck-rust-setup))
  
(use-package yasnippet
  :delight yas-minor-mode
  :bind
  :config
  (yas-load-directory (concat user-emacs-directory "snippets"))
  (yas-global-mode t))

(use-package gitignore-mode
  :mode ("\.gitignore"))

(use-package gitconfig-mode
  :mode ("\.gitconfig"))

(use-package lua-mode
  :mode "\\.lua\\'"
  :init
  (setq-default lua-indent-level 4))

(use-package yaml-mode
  :mode ("\\.ya?ml\\'" "\.clang-format"))

(use-package nix-update)

(use-package nix-sandbox)

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package cmake-mode
  :mode (("CMakeLists.txt" . cmake-mode)
	 ("\\.cmake\\'" . cmake-mode)))

(use-package meson-mode)

(use-package neotree)

(use-package csharp-mode
  :mode ("\\.cs$" . csharp-mode)
  :hook
  (csharp-mode . flycheck-mode))

(use-package omnisharp
  :hook
  (csharp-mode . omnisharp-mode)
  :config
  (with-eval-after-load 'company
    (add-to-list 'company-backends 'company-omnisharp)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(electric-pair-mode t)
 '(global-flycheck-mode t)
 '(package-selected-packages
   (quote
    (cquery neotree csharp-mode dap-mode meson-mode org-journal ivy-youtube http evil-collection request-deferred deferred toml restclient json-rpc jsonrpc company-quickhelp-mode evil-smartparens ace-jump-buffer flycheck-popup-tip moe-theme ace-jump ace-jump-mode org-bullets golden-ratio projectile-ripgrep ripgrep lua-mode org-evil cargo magit-gh-pulls magit-gitflow git-timemachine evil-surround lispyville lispy evil-paredit evil-magit powerline evil-escape all-the-icons-ivy all-the-icons company-box geiser general cmake-mode gitconfig-mode nix-sandbox lsp-clangd ivy-xref paredit nix-buffer flycheck nix-mode nix-update yaml-mode yasnippet ccls company-lsp company projectile ace-window ivy-rich counsel ivy gitignore-mode magit clang-format org-plus-contrib hydra evil which-key delight use-package))))

