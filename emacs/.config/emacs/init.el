;;
;; Sam's emacs config
;;

(defvar sam/fixed-font "SauceCodePro Nerd Font-13")
(defvar sam/variable-font "Noto Serif-13")
(defvar sam/no-line-num-modes '(text-mode-hook
								shell-mode-hook
								eshell-mode-hook
								term-mode-hook
								org-mode-hook
								help-mode-hook))

;; Startup performance
(setq gc-cons-threshold (* 50 1024 1024))
(defun sam/display-startup-time ()
  (message
   (format "Emacs loaded in %.3f seconds, with %d garbage collections"
		   (float-time (time-subtract after-init-time before-init-time))
		   gcs-done)))
(add-hook 'emacs-startup-hook #'sam/display-startup-time)

;; Package
(require 'package)
(setopt package-archives '(("melpa" . "https://melpa.org/packages/")
						   ("org" . "https://orgmode.org/elpa/")
						   ("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(require 'use-package)
(setopt use-package-always-ensure t)

(use-package no-littering)
(use-package diminish)

;; Emacs config
(use-package emacs
  :config
  (set-face-attribute 'default nil :font sam/fixed-font)
  (set-face-attribute 'fixed-pitch nil :font sam/fixed-font)
  (set-face-attribute 'variable-pitch nil :font sam/variable-font)
  ;; Cleanup custom from the init file
  (setopt custom-file (expand-file-name ".custom.el" user-emacs-directory))
  (when (file-exists-p custom-file)
    (load-file custom-file))
  (setq backup-directory-alist `(("." . ,(expand-file-name "tmp/backups/" user-emacs-directory))))
  (column-number-mode)
  ;; Relative line numbers
  (setopt display-line-numbers-type 'relative
	  display-line-numbers-width-start t
	  display-line-numbers-grow-only t)
  (global-display-line-numbers-mode t)
  (dolist (mode sam/no-line-num-modes)
    (add-hook mode (lambda () (display-line-numbers-mode 0))))
  ;; Improved scrolling
  (setopt scroll-conservatively 1
		  scroll-margin 8)
  ;; Remove all bells
  (setopt ring-bell-function (lambda ()))
  ;; Tabs
  (setopt tab-width 4)
  ;; Transparency
  (set-frame-parameter (selected-frame) 'alpha '(92 . 80))
  ;; UI cleanup and decoration
  (setopt fringe-mode 8)
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (when scroll-bar-mode
	(scroll-bar-mode -1))
  ;; Leave space alone in mini-buffer completions
  (dolist (minibuffer-mode (list minibuffer-local-completion-map
								 minibuffer-local-must-match-map
								 minibuffer-local-filename-completion-map))
	(define-key minibuffer-mode (kbd "SPC") #'self-insert-command))
  ;; Escape works as C-g
  (global-set-key (kbd "<escape>") 'keyboard-escape-quit)
  ;; Vertical mini-buffer mode
  (icomplete-vertical-mode +1)
  ;; Treesitter
  (setq major-mode-remap-alist '((c-mode . c-ts-mode)
								 (c++-mode . c++-ts-mode)
								 (c-or-c++-mode . c-or-c++-ts-mode)))
  (setq c-default-style '((java-mode . "java")
						  (awk-mode . "awk")
						  (other . "linux"))
		c-ts-mode-indent-style 'linux
		c-ts-mode-indent-offset 4)
  ;; Debugging
  (setopt gdb-many-windows t)
  ;; Column indicator
  (setopt display-fill-column-indicator-column 100)
  (defun sam/prog-hook ()
	"Hook for all programming modes"
	(display-fill-column-indicator-mode 1)
	(modify-syntax-entry ?_ "w"))
  (add-hook 'prog-mode-hook #'sam/prog-hook))

;; Colorise compilation buffer
(use-package ansi-color
  :hook (compilation-filter . ansi-color-compilation-filter))

;; LSP
(use-package eglot
  :after (evil)
  :hook (prog-mode . eglot-ensure)
  :config
  (evil-define-key 'normal eglot-mode-map "<leader>ca" #'eglot-code-actions))
									 
;; Evil mode
(use-package evil
  :custom
  (evil-split-window-below t)
  (evil-vsplit-window-right t)
  :init
  (setopt evil-want-keybinding nil
		  evil-want-C-u-scroll t
		  evil-want-C-i-jump t)
  :config
  ;; Leader key
  (evil-set-leader nil (kbd "SPC") t)
  (evil-set-leader nil (kbd "SPC") nil)
  ;; Keymap
  (evil-define-key 'normal 'global (kbd "<leader>bd") #'kill-buffer)
  (evil-define-key 'normal 'global (kbd "<leader>gc") #'comment-or-uncomment-region)
  (evil-define-key 'normal 'dired-mode-map (kbd "RET") #'dired-find-file)
  ;; Mode
  (evil-mode 1))

;; DAP
(use-package dap-mode
  :custom
  (dap-auto-configure-features '(sessions locals tooltip))
  :config
  (setq lsp-enable-dap-auto-configure nil))

;; Auto-completion
(use-package corfu
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-delay 0)
  (corfu-auto-prefix 2)
  (corfu-quit-no-match 'separator)
  :bind
  (:map corfu-map
		([remap evil-copy-from-above] . corfu-insert)
		("S-SPC" . corfu-insert-separator)
		("RET" . nil))
  :init
  (global-corfu-mode))

;; Theme
(use-package modus-themes
  :config
  (load-theme 'modus-vivendi-tinted t))

(use-package doom-modeline
  :config
  (doom-modeline-mode 1))

;; Better help pages
(use-package helpful)

;; Nicer minibuffer completion and extra informations
(use-package all-the-icons)

(use-package marginalia
  :config
  (marginalia-mode 1))

;; (use-package vertico
;;   :bind (:map vertico-map
;; 	      ("C-y" . vertico-insert))
;;   :config
;;   (vertico-mode 1))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package all-the-icons-completion
  :after (marginalia all-the-icons)
  :config
  (all-the-icons-completion-mode 1))

;; Which-key
(use-package which-key
  :diminish
  :config
  (which-key-mode 1)
  (setopt which-key-idle-delay 0.750))

;; Projectile
(use-package projectile
  :custom
  (projectile-project-search-path '("~/projects/" "~/unreal/" "d:/dev" "d:/dev/unreal"))
  :bind
  (:map projectile-mode-map
		("C-c p". projectile-command-map))
  :config
  (projectile-mode +1))

;; Startup screen
(use-package dashboard
  :config
  (dashboard-setup-startup-hook))

;; Keep packages up-to-date
(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))
