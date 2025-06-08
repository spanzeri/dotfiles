;;; init.el --- Sam's-emacs-config -*- lexical-binding: t -*-

;;; Commentary:
;;==============================================================================
;; Sam's Emacs configuration
;;==============================================================================
;; Simple config, to make Emacs feels like neovim
;;; Code:

;; Increase garbage collector threshold to a really high number for smooth initialisation.

;; Return to a sensibile amount of memory used after init.
(setopt gc-cons-threshold (* 32 1024 1024))
(add-hook 'after-init-hook (lambda () (setopt gc-cons-threshold (* 2 1024 1024))))

;; Give a bit more memory for inter-process communication.
(setopt read-process-output-max (* 4 1024 1024))

;; Require emacs default package manager. We'll stick to built-ins packages and functionalities
;; as much as possible.
(require 'package)

;; Add melpa and org from the list of package archives.
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)

;; Make sure packages have been initialised.
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Provide a few configuration variables so that they are easy to find and change.
(defcustom sam-use-nerd-fonts t
  "Use nerd font symbols if not nil."
  :type 'boolean
  :group 'appearance)
(defcustom sam-active-frame-opacity 97
  "Opacity for the Emacs frame when focused."
  :type 'integer
  :group 'appareance)
(defcustom sam-inactive-frame-opacity 94
  "Opacity for the Emacs frame when unfocused."
  :type 'integer
  :group 'appareance)


;;======================================
;; Use package
;;======================================

;;; EMACS
;; Emacs configurations
(use-package emacs
  :ensure nil
  :custom
  (column-number-mode t)                      ;; Enable column number in the modeline
  (delete-selection-mode 1)                   ;; Replace selected text when typing
  (display-fill-column-indicator-column 100)  ;; Display fill column indicator at the 100th column
  (display-line-numbers-grow-only t)          ;; Keep the maximum line number size to avoid gutter size changes
  (display-line-numbers-width-start t)        ;; Display enough spaces to fit the line number for the entire buffer
  (history-length 32)                         ;; Set the number of commands to keep in the history
  (inhibit-startup-message t)                 ;; Don't show emacs default message
  (initial-scratch-message "")                ;; Empty the initial scratch buffer text
  (ispell-dictionary "en_US")                 ;; Set spelling dictionary
  (pixel-scroll-precision-mode t)             ;; Enable precise pixel scroll
  (ring-bell-function 'ignore)                ;; No audio or video bell
  (tab-width 4)                               ;; Tab width set to 4
  (treesit-font-lock-level 4)                 ;; Use advance font locking for treesit
  (truncate-lines t)                          ;; Enable line truncation on long lines
  (use-dialog-box nil)                        ;; Disable dialog boxes. Uses mini-buffer instead
  (use-short-answer t)                        ;; Use y and n instead of yes and no
  (tab-always-indent nil)                     ;; Pressing tab indents if in the indentation space, or insert a tab

  ;; Fix scrolling
  (redisplay-dont-pause t)
  (scroll-margin 8)
  (scroll-step 1)
  (scroll-conservatively 1000)
  (scroll-preserve-screen-position 1)

  :hook
  (prog-mode . display-line-numbers-mode)     ;; Display line number in programming buffers
  (prog-mode . display-fill-column-indicator-mode)

  :bind
  (("<escape>" . keyboard-escape-quit))

  :config
  ;; Use default wombat theme.
  (load-theme 'gruber-darker t)

  ;; Set the default font.
  (set-face-attribute 'default nil :family "Iosevka Sam" :height 140)

  ;; Set the frame transparency options
  (set-frame-parameter (selected-frame) 'alpha (list sam-active-frame-opacity sam-active-frame-opacity))
  (add-to-list 'default-frame-alist `(alpha . ,(list sam-inactive-frame-opacity sam-inactive-frame-opacity)))

  ;; On mac-os, make meta the modifier.
  (when (and (eq system-type 'darwin) (boundp 'mac-command-modifier))
    (setq mac-command-modifier 'meta))

  ;; Remove custom from init.el. Set a different file where to save custom variables, then try and
  ;; load it without any error or message if missing.
  (setq custom-file (locate-user-emacs-file ".custom.el"))
  (load custom-file 'noerror 'nomessage)

  :init
  (tool-bar-mode -1)
  (menu-bar-mode -1)

  (when scroll-bar-mode
    (scroll-bar-mode 1)
	(set-window-scroll-bars (minibuffer-window) 0 nil))

  (global-hl-line-mode 1)       ;; Always highlight current line
  (indent-tabs-mode -1)         ;; Use spaces instead of tabs
  (recentf-mode 1)              ;; Enable tracking of recently opened files
  (xterm-mouse-mode 1)          ;; Enable mouse support in terminal
  (file-name-shadow-mode 1)     ;; Enable shadowing of filenames

  ;; Remove underlining from active line
  (set-face-attribute hl-line-face nil :underline nil)

  ;; Set the default coding system for files to UTF-8.
  (modify-coding-system-alist 'file "" 'utf-8)

  ;; Add message to the scratch buffer after init.
  (add-hook 'after-init-hook
			(lambda ()
			  (message "Emacs has finished loading.")
			  (with-current-buffer (get-buffer-create "*scratch*")
				(insert (format
						 ";;======================================
;;     Welcome to Emacs!
;;======================================
;; Loading time : %s
;; Packages     : %s
;;======================================
"
						 (emacs-init-time)
						 (number-to-string (length package-activated-list))))))))

;;; ANSI COLOR
;; Color compilation output
(use-package ansi-color
  :ensure nil
  :hook
  (compilation-filter . ansi-color-compilation-filter))

;;; WHICH KEY
;; Display helpful pop-up with key completions
(use-package which-key
  :ensure nil
  :diminish
  :defer t
  :custom
  (whick-key-idle-delay 0.2)
  :hook (after-init . which-key-mode))

;;; ORG MODE
(use-package org
  :ensure nil
  :defer t)

;;; Flymake
;; Show errors and diagnostic
(use-package flymake
  :ensure nil
  :defer t
  :hook (prog-mode . flymake-mode)
  :custom
  (flymake-margin-indicator-string
   '((error "!»" compilation-error)
	 (warning "»" compilation-warning)
	 (note "»" compilation-info))))

;;; ELDOC
;; Inline documentation
(use-package eldoc
  :ensure nil
  :diminish
  :init
  (global-eldoc-mode))

;;; EGLOT
;; Lsp
(use-package eglot
  :ensure nil
  :diminish
  :hook (prog-mode . eglot-ensure))

;;; ===== EXTERNAL PACKAGES ============
;; Those packages are not builtin.
;;

;;; Diminish
;; Reduce the amount of clutter in the mode-line
(use-package diminish
  :ensure t)

;;; EVIL MODE
;; vim emulation mode.
(use-package evil
  :ensure t
  :diminish
  :custom
  (evil-want-integration t)
  (evil-want-keybinding nil)
  (evil-want-C-u-scroll t)
  (evil-want-C-i-jump t)
  (evil-split-window-below t)
  (evil-vsplit-window-right t)
  (wvil-want-fine-undo t)
  :config
  (evil-set-undo-system 'undo-redo)

  ;; Set leader key to space
  (evil-set-leader 'normal (kbd "SPC"))
  (evil-set-leader 'visual (kbd "SPC"))
  (evil-set-leader 'insert (kbd "M-SPC"))

  (defun find-file-maybe-in-project ()
	"Find file in project if there is a current one active.
 Otherwise, `ido-find-file`."
	(interactive)
	(if (project-current)
		(project-find-file)
	  (ido-find-file)))

  ;; Evil keybindings.
  (evil-define-key 'normal 'global (kbd "<leader>sf") 'find-file-maybe-in-project)
  ;; (evil-define-key 'normal 'global (kbd "<leader>sg") 'consult-grep)
  (evil-define-key 'normal 'global (kbd "<leader>sb") 'switch-to-buffer)
  (evil-define-key 'normal 'global (kbd "<leader>sB") 'switch-to-buffer-other-window)

  (evil-define-key 'normal 'global (kbd "<leader>ee") #'first-error)
  (evil-define-key 'normal 'global (kbd "<leader>en") #'next-error)
  (evil-define-key 'normal 'global (kbd "<leader>ep") #'previous-error)
  (evil-define-key 'normal 'global (kbd "C-h") #'evil-window-left)
  (evil-define-key 'normal 'global (kbd "C-j") #'evil-window-down)
  (evil-define-key 'normal 'global (kbd "C-k") #'evil-window-up)
  (evil-define-key 'normal 'global (kbd "C-l") #'evil-window-right)

  (defun compile-maybe-in-project ()
	"Try and run `project-compile`. If no project, run compile."
	(interactive)
	(if (project-current)
		(call-interactively #'project-compile)
	  (call-interactively #'compile)))

  (evil-define-key 'normal 'global (kbd "<leader>mm") #'compile-maybe-in-project)

  :init
  (evil-mode 1))

;;; EVIL COLLECTION
;; Evil mode integrated into more emacs functionalities.
(use-package evil-collection
  :ensure t
  :after evil
  :diminish
  :init (evil-collection-init))

;;; ORDERLESS
;; Fuzzy searching. Integrates well with corfu.
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-default nil)
  (completion-category-override '((file (styles partial-completion)))))

;;; CORFU
;; In-buffer, pop-up completion
(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-cycle t)
  (corfu-separator ?\s)
  :bind (:map corfu-map
			  ("C-y" . corfu-insert)
			  ("SPC" . corfu-insert-separator))
  :config
  ;; Define a evil key in corfu-map, or the evil mapping will be higher priority.
  (evil-define-key 'insert corfu-map (kbd "C-y") #'corfu-insert)
  (keymap-unset corfu-map "RET")

  :init
  (global-corfu-mode))

;;; TREESIT-AUTO
;; Automagically manage treesitter syntax.
(use-package treesit-auto
  :ensure t
  :config
  (global-treesit-auto-mode))

;;; INDENT-GUIDE
;; The `highlight-indent-guides` package provide visual indicators for indentation levels in
;; programming modes.
(use-package highlight-indent-guides
  :defer t
  :ensure t
  :hook (prog-mode . highlight-indent-guides-mode)
  :custom
  (highlight-indent-guides-method 'character)
  (highlight-indent-guides-auto-enabled nil)
  :config
  (set-face-foreground 'highlight-indent-guides-character-face "dim gray"))

;;; MAGIT
;; Git integration
(use-package magit
  :ensure t
  :defer t)

;;; XCLIP
;; Clipboard integration with the system
(use-package xclip
  :ensure t
  :defer t
  :hook
  (after-init . xclip-mode))

;;; VERTICO
(use-package vertico
  :ensure t
  :init
  (vertico-mode))

;;; MARGINALIA
(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

;;; NERD-ICONS
(use-package nerd-icons
  :ensure t
  :defer t)

(use-package nerd-icons-dired
  :ensure t
  :defer t
  :hook
  (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-completion
  :ensure t
  :after (:all nerd-icons marginalia)
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup)
  :config
  (nerd-icons-completion-mode))
 
(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :init
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;;; TODO
;; [ ] Check the evil configuration.
;;   [ ] Setup leader keys
;; [ ] Setup project
;; [ ] Setup lsp (eglot? lsp-mode?)
;;	 [ ] Possibly, setup dap?
;; [ ] GDB mode
;; [ ] Cleanup the code below to save Emacs frame

;; Save and reload geometry of emacs' frame

(defcustom frameg-file (expand-file-name ".emacs.frameg.el" user-emacs-directory)
  "Location where to store Emacs frame's last geometry."
  :type 'string
  :group 'frames)

(defun sam/save-frame-geom ()
  "Save the current frame geometry and position to a file."
  (interactive)
  (when (display-graphic-p)
    (let ((curr-frame (selected-frame)))
      (let ((frameg-left (frame-parameter curr-frame 'left))
	    (frameg-top (frame-parameter curr-frame 'top))
	    (frameg-width (frame-parameter curr-frame 'width))
	    (frameg-height (frame-parameter curr-frame 'height)))
	(with-temp-buffer
	  (make-local-variable 'make-backup-file)
	  (setq make-backup-file nil)
	  (insert
	   ";; This file stores the previous frame's geometry.\n"
	   ";; Last created: " (current-time-string) ".\n"
	   "(setq initial-frame-alist\n"
	   (format "        '((top . %d)\n" (max frameg-top 0))
	   (format "          (left . %d)\n" (max frameg-left 0))
	   (format "          (width . %d)\n" (max frameg-width 0))
	   (format "          (height . %d)))\n" (max frameg-height 0)))
	  (when (file-writable-p frameg-file)
		(write-file frameg-file)))))))

(defun sam/load-frame-geom ()
  "Load the frame geometry from the last session (if available and readable)."
  (interactive)
  (when (and (file-readable-p frameg-file)
	     (display-graphic-p))
    (load-file frameg-file)))

(add-hook 'after-init-hook #'sam/load-frame-geom)
(add-hook 'kill-emacs-hook #'sam/save-frame-geom)

(defun sam/first-install ()
  "Run the first time to ensure all the one-off installations are performed."
  (interactive)
  (message "Installing nerd icons fonts")
  (nerd-icons-install-fonts))

(provide 'init)
;;; init.el ends here
