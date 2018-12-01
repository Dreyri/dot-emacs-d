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
  :hook
  (lisp-mode . lispy-mode)
  (common-lisp-mode . lispy-mode)
  (emacs-lisp-mode . lispy-mode)
  (scheme-mode . lispy-mode))

(use-package evil
  :commands (evil-mode)
  :init
  (evil-mode))

(use-package evil-escape
  :after evil
  :delight
  :init
  (setq-default evil-escape-key-sequence (kbd "fd"))
  (setq-default evil-escape-delay 0.125)
  :config
  (evil-escape-mode))

(use-package general
  :config
  (with-eval-after-load 'evil
    (general-define-key
     :states 'motion
     ";" #'evil-ex
     ":" #'evil-repeat-find-char)))

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
	 ("C-c o a" . org-agenda)
	 ("C-c o j" . org-clock-jump-to-current-clock)))

(use-package evil-org
  :after (evil org))

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
	      ("C-c C-b" . git-timemachine-blame)))

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
  :bind ("<C-return>" . ace-window))

(use-package projectile
  :delight
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :config
  (projectile-mode t)
  (setq projectile-enable-caching t)
  (add-to-list 'projectile-globally-ignored-directories '("build"
							  ".cquery_cached_index"))
  (add-to-list 'projectile-globally-ignored-file-suffixes '(".o"
							    ".so")))

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

(use-package company
  :delight
  :defer 3
  :hook
  (after-init . global-company-mode))

(use-package company-box
  :disabled t
  :hook
  (company-mode . company-box-mode))

(use-package company-lsp
  :after (company lsp-mode)
  :config
  (push 'company-lsp company-backends))

(use-package lsp-mode
  :defer t)

(use-package lsp-ui
  :hook
  (lsp-mode . lsp-ui-mode))

(use-package ccls
  :disabled t
  :commands lsp-ccls-enable
  :hook
  (c-mode-common . lsp-ccls-enable))

(use-package lsp-clangd
  :init
  (setq lsp-clangd-executable nil)
  (defun nix-find-clangd ()
    (nix-find-executable "clang_7" "clangd"))
  (defun nix-set-clangd ()
    (if (not lsp-clangd-executable)
	(setq lsp-clangd-executable (nix-find-clangd))))
  (defun nix-lsp-clangd-c-enable ()
    (interactive)
    (nix-set-clangd)
    (lsp-clangd-c-enable))
  (defun nix-lsp-clangd-c++-enable ()
    (interactive)
    (nix-set-clangd)
    (lsp-clangd-c++-enable))
  (defun nix-lsp-clangd-objc-enable ()
    (interactive)
    (nix-set-clangd)
    (lsp-clangd-objc-enable))
  (defun nix-lsp-clangd-objc++-enable ()
    (interactive)
    (nix-set-clangd)
    (lsp-clangd-objc++-enable))
  :hook
  (c-mode . nix-lsp-clangd-c-enable)
  (c++-mode . nix-lsp-clangd-c++-enable)
  (objc-mode . nix-lsp-clangd-objc-enable))


(use-package cquery
  :disabled t
  :commands lsp-cquery-enable
  :init
  (setq cquery-executable nil)
  (defun nix-find-cquery ()
    (interactive)
    (nix-find-executable "cquery" "cquery"))
  (defun nix-cquery-enable ()
    (interactive)
    (if (not cquery-executable)
	(setq cquery-executable (nix-find-cquery)))
    (lsp-cquery-enable))
  :hook
  (c-mode-common . nix-cquery-enable))

(use-package flycheck)
  
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

(use-package yaml-mode
  :mode ("\\.ya?ml\\'" "\.clang-format"))

(use-package nix-update)

(use-package nix-sandbox)

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package cmake-mode
  :mode (("CMakeLists.txt" . cmake-mode)
	 ("\\.cmake\\'" . cmake-mode)))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (lispy evil-paredit evil-magit powerline evil-escape all-the-icons-ivy all-the-icons company-box geiser general cmake-mode gitconfig-mode nix-sandbox lsp-clangd ivy-xref paredit nix-buffer flycheck nix-mode nix-update yaml-mode yasnippet ccls company-lsp company projectile ace-window ivy-rich counsel ivy gitignore-mode magit clang-format org-plus-contrib hydra evil which-key delight use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
