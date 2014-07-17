;;; Emacs for the jaded vimmer
;;
;; Author: Henrik Lissner <henrik@lissner>
;; URL: https://github.com/hlissner/emacs.d
;;
;; These settings set up a very vim-like experience, with some of emacs goodness
;; squeezed in between the cracks.
;;
;;; Code:

(cd "~")                    ; Default directory, instead of /
;; (setq debug-on-error t)

;; Append homebrew's bin to emac's PATH
(setq exec-path (append exec-path '("/usr/local/bin")))

;; Global vars
(defvar my-dir (file-name-directory load-file-name))
(defvar my-core-dir (expand-file-name "init" my-dir))
(defvar my-modules-dir (expand-file-name "modules" my-dir))
(defvar my-themes-dir (expand-file-name "themes" my-dir))
(defvar my-elisp-dir (expand-file-name "elisp" my-dir))
(defvar my-tmp-dir (expand-file-name "tmp" my-dir))

;; Setup loadpaths
(add-to-list 'load-path my-core-dir)
(add-to-list 'load-path my-modules-dir)
(add-to-list 'load-path my-elisp-dir)
(add-to-list 'custom-theme-load-path my-themes-dir)

;; Font & color scheme
(load-theme 'brin t)
(defvar my-font "Ubuntu Mono-15")

;;;;;;;;;;;;;;;;;;;;;;;
;; Bootstrap
;;;;;;;;;;;;;;;;;;;;;;;

(dolist (module '(
      core               ; Emacs core settings
      core-packages      ; Package init & management
      core-ui            ; Look and behavior of the emacs UI
      core-editor        ; Text/code editor settings and behavior
      core-osx           ; OSX-specific settings & functions
      core-project       ; Project navigation settings & packages

      ;; Editor essentials
      mod-ac             ; Auto-complete engine & settings
      mod-git            ; GIT tools/settings
      mod-fly            ; Syntax and spell checkers
      ; mod-webdev         ; Webdev tools (sass, js, etc)
      ; mod-gamedev        ; Gamedev tools (C++, love2D, html5)
      ; mod-shell          ; Goodies for ansi-term

      ;; Must be last!
      core-keymaps       ; Global & local keybindings for all modes
      ))
  (require module))


;;;; Modes ;;;;;;;;;;;;;;;;;;;;;;;;

(associate-mode 'ruby-mode      '(".rb" "RakeFile"))
(associate-mode 'markdown-mode  '(".md" ".markdown" "README"))
(associate-mode 'scss-mode      '(".scss"))
(associate-mode 'org-mode       '(".org" ".gtd") t)
(associate-mode 'js2-mode       '(".js" ".json"))
(associate-mode 'web-mode       '(".html" ".htm" ".phtml" ".tpl" ".tpl.php" ".erb"))
; (associate-mode 'lua-mode ".lua")
;; (associate-mode 'yaml-mode ".yml")
;; (associate-mode 'python-mode ".py")