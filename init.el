(defun my-edit-init ()
  "Open the init file for editing"
  (interactive)
  (find-file (concat user-emacs-directory "init.el")))

(defun my-edit-load ()
  "Load the init file"
  (interactive)
  (load-file (concat user-emacs-directory "init.el")))

(defun nix-find-executable (pkg executable)
  (interactive
   "spkg: \nsexecutable: \n")
  (string-trim
   (shell-command-to-string
    (concat "nix-shell -p " pkg " --run 'which " executable "'"))))

(setq ring-bell-function 'ignore)

(blink-cursor-mode nil)

(setq-default truncate-lines nil)
(setq-default word-wrap t)

(require 'package)
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
			 ("melpa" . "https://melpa.org/packages/")
			 ("org" . "http://orgmode.org/elpa/")))

;; TODO not sure if this is required
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; personal info TODO offload this to another file
(setq user-full-name "Frederik Engels"
      user-mail-address "frederik.engels24@gmail.com")

;; mouse wheel more suitable for touchpad
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)

;; TODO set backup folder and remove # files


;; disable all unneeded bars

(menu-bar-mode -1)
(toggle-scroll-bar t)
(tool-bar-mode -1)

;; TODO decide whether I need line numbers

(condition-case nil
    (set-frame-font "Fira Mono 11")
  (error nil))

(fset 'yes-or-no-p 'y-or-n-p)

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
  :delight t
  :hook
  (lisp-mode . paredit-mode)
  (common-lisp-mode . paredit-mode)
  (emacs-lisp-mode . paredit-mode)
  (scheme-mode . paredit-mode))
  
  
(use-package evil
  :commands evil-mode)

(use-package hydra)
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
  :config
  ()
  :bind (("C-c o c" . org-capture)
	 ("C-c o j" . org-clock-jump-to-current-clock)))

(use-package clang-format
  :init
  (setq clang-format-executable nil)
  (defun nix-find-clang-format-executable ()
    (interactive)
    (if (not clang-format-executable)
	(nix-find-executable "clang_7" "clang-format")
      clang-format-executable))
  (defun nix-clang-format-buffer ()
    (interactive)
    (if (not clang-format-executable)
	(setq clang-format-executable (nix-find-clang-format-executable)))
    (clang-format-buffer))
  :bind
  (:map c-mode-base-map
	("C-c C-f" . nix-clang-format-buffer)))

(use-package magit
  :bind (("C-x g". magit-status)))

(use-package gitignore-mode
  :mode "\.gitignore")

(use-package ivy
  :delight t
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

(use-package counsel
  :delight t
  :after ivy
  :config
  (counsel-mode))

(use-package ivy-rich
  :after ivy
  :config
  (ivy-rich-mode t))

(use-package swiper
  :delight t
  :after ivy
  :bind (("C-s" . swiper)))

(use-package ace-window
  :bind ("<C-return>" . ace-window))

(use-package projectile
  :delight t
  :config
  (projectile-mode t)
  (setq projectile-enable-caching t)
  (add-to-list 'projectile-globally-ignored-directories '("build"
							  ".cquery_cached_index"))
  (add-to-list 'projectile-globally-ignored-file-suffixes '(".o"
							    ".so")))

(use-package company
  :delight t
  :defer 3
  :hook
  (after-init . global-company-mode))

(use-package company-lsp
  :after (company lsp-mode)
  :config
  (push 'company-lsp company-backends))

(use-package lsp-mode
  :defer t)

(use-package ccls
  :disabled t
  :commands lsp-ccls-enable
  :hook
  (c-mode-common . lsp-ccls-enable))

(use-package cquery
  :commands lsp-cquery-enable
  :hook
  (c-mode-common . lsp-cquery-enable))

(use-package flycheck)
  
(use-package yasnippet
  :delight yas-minor-mode
  :bind
  :config
  (yas-load-directory (concat user-emacs-directory "snippets"))
  (yas-global-mode t))

(use-package yaml-mode
  :mode ("\\.ya?ml\\'" "\.clang-format"))

(use-package nix-update)

(use-package nix-mode
  :mode "\\.nix\\'")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (paredit nix-buffer flycheck nix-mode nix-update yaml-mode yasnippet ccls company-lsp company projectile ace-window ivy-rich counsel ivy gitignore-mode magit clang-format org-plus-contrib hydra evil which-key delight use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
