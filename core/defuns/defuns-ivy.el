;;; defuns-ivy.el

;; Show more information in ivy-switch-buffer; and only display
;; project/workgroup-relevant buffers.
(defun doom-ivy-get-buffers (&optional buffer-list)
  (let ((min-name 5)
        (min-mode 5)
        (proot (doom/project-root)))
    (mapcar
     (lambda (b) (format (format "%%-%ds %%-%ds %%s" min-name min-mode)
                    (nth 0 b)
                    (nth 1 b)
                    (or (nth 2 b) "")))
     (mapcar (lambda (b)
               (with-current-buffer b
                 (let ((buffer-name (buffer-name b))
                       (mode-name (symbol-name major-mode)))
                   (when (> (length buffer-name) min-name)
                     (setq min-name (+ (length buffer-name) 10)))
                   (when (> (length mode-name) min-mode)
                     (setq min-mode (+ (length mode-name) 3)))
                   (list
                    (concat
                     (propertize buffer-name
                                 'face (cond ((string-match-p "^ ?\\*" buffer-name)
                                              'font-lock-comment-face)
                                             ((not (string= proot (doom/project-root)))
                                              'font-lock-keyword-face)
                                             (buffer-read-only
                                              'error)))
                     (when (and buffer-file-name (buffer-modified-p))
                       (propertize "[+]" 'face 'doom-modeline-buffer-modified)))
                    (propertize mode-name 'face 'font-lock-constant-face)
                    (when buffer-file-name
                      (f-slash (abbreviate-file-name (f-dirname buffer-file-name))))))))
             (or buffer-list (doom/get-buffers))))))

(defun doom--ivy-select-buffer-action (buffer)
  (ivy--switch-buffer-action
   (s-chop-suffix
    "[+]"
    (substring buffer 0 (s-index-of "   " buffer)))))

;;;###autoload
(defun doom/ivy-switch-project-buffer (&optional all-p)
  "Displays open buffers in current project and workspace. If ALL-P, then show
all open buffers."
  (interactive)
  (ivy-read (format "%s buffers: " (if all-p "All" "Project"))
            (doom-ivy-get-buffers (if all-p (buffer-list)))
            :matcher #'ivy--switch-buffer-matcher
            :action #'doom--ivy-select-buffer-action
            :keymap ivy-switch-buffer-map
            :caller 'doom/ivy-switch-project-buffer))

;;;###autoload
(defun doom/ivy-switch-buffer ()
  "Displays all open buffers, across projects and workspaces."
  (interactive)
  (doom/ivy-switch-project-buffer t))

;;;###autoload
(defun doom/ivy-kill-ring ()
  (interactive)
  (ivy-read "Kill ring:" (--filter (not (or (< (length it) 3)
                                            (string-match-p "\\`[\n[:blank:]]+\\'" it)))
                                   (remove-duplicates kill-ring :test 'equal))))

;;;###autoload (autoload 'doom:ivy-recentf "defuns-ivy" nil t)
(evil-define-command doom:ivy-recentf (&optional bang)
  "Ex-mode interface for `ivy-recentf' and `projectile-recentf'."
  :repeat nil
  (interactive "<!>")
  (if bang (ivy-recentf) (projectile-recentf)))

;;;###autoload (autoload 'doom:ivy-swiper "defuns-ivy" nil t)
(evil-define-command doom:ivy-swiper (&optional search)
  (interactive "<a>")
  (swiper (or search (thing-at-point 'symbol))))

(defvar doom-ivy-ag-last-search nil)
;;;###autoload (autoload 'doom:ivy-ag-search "defuns-ivy" nil t)
(evil-define-operator doom:ivy-ag-search (beg end search regex-p &optional dir)
  "Preform a counsel search with SEARCH. If SEARCH is nil and in visual mode,
use the selection, otherwise activate live ag searching in helm.

If REGEX-P is non-nil, SEARCH will be treated as a regular expression.
DIR specifies the default-directory from which ag is run."
  :type inclusive :repeat nil
  (interactive "<r><a><!>")
  (let ((search (or search
                    (and (evil-visual-state-p)
                         (and beg end (rxt-quote-pcre (buffer-substring-no-properties beg end))))
                    doom-ivy-ag-last-search)))
    (setq doom-ivy-ag-last-search search)
    (counsel-ag search (or dir (f-slash (doom/project-root)))
                (concat "--nocolor --nogroup" (if regex-p " -Q")))))

;;;###autoload (autoload 'doom:ivy-ag-search-cwd "defuns-ivy" nil t)
(evil-define-operator doom:ivy-ag-search-cwd (beg end search regex-p)
  :type inclusive :repeat nil
  (interactive "<r><a><!>")
  (doom:ivy-ag-search beg end search regex-p default-directory))

;;;###autoload
(defun doom/ivy-tasks ()
  (interactive)
  ;; TODO Something a little nicer
  (counsel-ag " (TODO|FIXME|NOTE) " (doom/project-root)))

;;;###autoload
(defun doom*counsel-ag-function (string base-cmd extra-ag-args)
  "Advice to get rid of the character limit from `counsel-ag-function', which
interferes with my custom :ag ex command `doom:ivy-ag-search'."
  (when (null extra-ag-args)
    (setq extra-ag-args ""))
  (if (< (length string) 1)
      (counsel-more-chars 1)
    (let ((default-directory counsel--git-grep-dir)
          (regex (counsel-unquote-regex-parens
                  (setq ivy--old-re
                        (ivy--regex string)))))
      (let ((ag-cmd (format base-cmd
                            (concat extra-ag-args
                                    " -- "
                                    (shell-quote-argument regex)))))
        (if (file-remote-p default-directory)
            (split-string (shell-command-to-string ag-cmd) "\n" t)
          (counsel--async-command ag-cmd)
          nil)))))

;;;###autoload
(defun doom/counsel-ag-occur ()
  "Invoke the search+replace wgrep buffer on the current ag search results."
  (interactive)
  (require 'wgrep)
  (call-interactively 'ivy-occur))

(provide 'defuns-ivy)
;;; defuns-ivy.el ends here
