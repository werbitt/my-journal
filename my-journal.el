;;; my-journal.el --- Micah's org-mode journal helpers

;; Copyright (C) 2014 Micah Werbitt

;; Author: Micah Werbitt <micah@werbitt.net>
;; Created: 13 June 2014
;; Version: 0.0.1

;;; Code:


(setq journal-file "~/Sync/Journal/journal.org")
(local-set-key (kbd "M--") '(insert "—"))

(defun mw-journal-start-entry ()
  "Start a new journal entry."
  (interactive)
  (find-file journal-file)
  (mw-journal-new-entry)
  (recenter))

(global-set-key (kbd "C-c j") 'mw-journal-start-entry)

;;;###autoload
(defun mw-journal-insert-day-heading ()
  (interactive)
  (org-insert-heading)
  (insert (mw-journal-date-heading-format (current-time))))

;;;###autoload
(defun mw-journal-new-entry ()
  (interactive)
  (let ((new-date-p (mw-journal-find-date-heading)))
    (or new-date-p
	(progn
	  (goto-char (point-min))
	  (org-forward-heading-same-level 0 'invisible-ok)
	  (mw-journal-insert-day-heading)))
    (show-subtree)
    (org-insert-subheading 't)
    (insert (format-time-string "[%H:%M]"))
    (mw-journal-move-subtree-to-end)
    (end-of-line)
    (newline)
    (if new-date-p (open-line 0) (open-line 1))))

;;;###autoload
(defun mw-journal-move-subtree-to-end ()
  (interactive)
  (and (ignore-errors (org-move-subtree-down 1)) (mw-journal-move-subtree-to-end)))

;;;###autoload
(defun mw-journal-date-heading-to-clipboard ()
  "If point is on a timestamp, then copy my date heading to the clipboard,
otherwise use today's date"
  (interactive)
  (let ((ts (or (and (org-at-timestamp-p)
		     (apply 'encode-time (org-parse-time-string (match-string 0))))
		(current-time))))
    (kill-new (mw-journal-date-heading-format ts))))

;;;###autoload
(defun mw-journal-date-heading-format (time)
  "Make a Journal heading from a timestamp.
A heading looks like this:
current-time -> Friday, September 20th 2013"
  (let ((day-of-month (nth 3 (decode-time time))))
    (concat
     (format-time-string "%A, %B " time)
     (number-to-string day-of-month)
     (mw-journal-ordinal-suffix (nth 3 (decode-time time)))
     (format-time-string ", %Y" time))))

;;;###autoload
(defun mw-journal-format-day-of-month (time)
  "Return the day of the month formatted with no padding and an ordinal suffix"
  (format-time-string "%e" time))

;;;###autoload
;; Stolen from 'strings.el' who stole it from 'diary.el' ('diary-ordinal-suffix').
(defun mw-journal-ordinal-suffix (n)
  "Ordinal suffix for N.  That is, 'st', 'nd', 'rd', or 'th', as appropriate."
  (if (or (memq (% n 100) '(11 12 13)) (< 3 (% n 10)))
      "th"
    (aref ["th" "st" "nd" "rd"] (% n 10))))

;; Stolen from ergoemacs.org who stole it from Magnar Sveen
;; http://ergoemacs.org/emacs/modernization_elisp_lib_problem.html
;;;###autoload
(defun mw-journal-trim-left (s)
  "Remove whitespace at the beginning of S."
  (if (string-match "\\`[ \t\n\r]+" s)
      (replace-match "" t t s)
    s))

;;;###autoload
(defun mw-journal-find-date-heading (&optional time)
  "Find a date heading for a given datetime.
If none is specified, use today"
  (interactive)
  (let ((date (or time (current-time))))
    (goto-char (point-min))
    (save-restriction
      (when (re-search-forward
	     (concat "^[ /t]*\\*+[[:space:]]+"
		     (mw-journal-date-heading-format date)) nil t)
	(goto-char (point))))))

(provide 'my-journal)

;;; my-journal.el ends here
