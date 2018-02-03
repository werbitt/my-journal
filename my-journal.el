;;; my-journal.el --- Micah's org-mode journal helpers

;; Copyright (C) 2014 Micah Werbitt

;; Author: Micah Werbitt <micah@werbitt.net>
;; Created: 13 June 2014
;; Version: 0.0.2

;;; Code:

(defvar my-journal-file "~/Sync/Journal/journal.org"
  "The path of the journal file.")

(defun my-journal-open (arg)
  "Open my journal, if no prefix arguments are provided start a new entry"
  (interactive "P")
  (find-file my-journal-file)
  (unless (car arg)
    (org-set-startup-visibility)
    (my-journal-new-entry)
    (recenter)))

;;;###autoload
(defun my-journal-insert-day-heading ()
  (interactive)
  (org-insert-heading)
  (insert (my-journal-date-heading-format (current-time))))

;;;###autoload
(defun my-journal-new-entry ()
  "Create a new journal entry.
If there's already a new journal entry for the day, then add to the end.
Narrow the buffer to the day's entry."
  (interactive)
  (let ((point-after-date-heading (my-journal-find-date-heading)))
    (if point-after-date-heading
        (progn
          (show-subtree)
          (org-forward-heading-same-level 1 'invisible-ok)
          (previous-line)
          (newline)
          (open-line 1))
      (progn
        (goto-char (point-min))
        (org-forward-heading-same-level 0 'invisible-ok)
        (my-journal-insert-day-heading)
        (newline 2)
        (open-line 1))))
  (org-narrow-to-subtree))

;;;###autoload
(defun my-journal-move-subtree-to-end ()
  (interactive)
  (and (ignore-errors (org-move-subtree-down 1)) (my-journal-move-subtree-to-end)))

;;;###autoload
(defun my-journal-date-heading-to-clipboard ()
  "If point is on a timestamp, then copy my date heading to the clipboard,
otherwise use today's date"
  (interactive)
  (let ((ts (or (and (org-at-timestamp-p)
		     (apply 'encode-time (org-parse-time-string (match-string 0))))
		(current-time))))
    (kill-new (my-journal-date-heading-format ts))))

;;;###autoload
(defun my-journal-date-heading-format (time)
  "Make a Journal heading from a timestamp.
A heading looks like this:
current-time -> Friday, September 20th 2013"
  (let ((day-of-month (nth 3 (decode-time time))))
    (concat
     (format-time-string "%A, %B " time)
     (number-to-string day-of-month)
     (my-journal-ordinal-suffix (nth 3 (decode-time time)))
     (format-time-string ", %Y" time))))

;;;###autoload
(defun my-journal-format-day-of-month (time)
  "Return the day of the month formatted with no padding and an ordinal suffix"
  (format-time-string "%e" time))

;;;###autoload
;; Stolen from 'strings.el' who stole it from 'diary.el' ('diary-ordinal-suffix').
(defun my-journal-ordinal-suffix (n)
  "Ordinal suffix for N.  That is, 'st', 'nd', 'rd', or 'th', as appropriate."
  (if (or (memq (% n 100) '(11 12 13)) (< 3 (% n 10)))
      "th"
    (aref ["th" "st" "nd" "rd"] (% n 10))))

;; Stolen from ergoemacs.org who stole it from Magnar Sveen
;; http://ergoemacs.org/emacs/modernization_elisp_lib_problem.html
;;;###autoload
(defun my-journal-trim-left (s)
  "Remove whitespace at the beginning of S."
  (if (string-match "\\`[ \t\n\r]+" s)
      (replace-match "" t t s)
    s))

;;;###autoload
(defun my-journal-find-date-heading (&optional time)
  "Find a date heading for a given datetime.
If none is specified, use today"
  (interactive)
  (let ((date (or time (current-time))))
    (goto-char (point-min))
    (save-restriction
      (when (re-search-forward
	     (concat "^[ /t]*\\*+[[:space:]]+"
		     (my-journal-date-heading-format date)) nil t)
	(goto-char (point))))))

(define-derived-mode my-journal-mode
  org-mode "Journal"
  "Major mode for my journal.")

(provide 'my-journal)

;;; my-journal.el ends here
