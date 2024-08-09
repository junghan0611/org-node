;;; org-node-obsolete.el --- Outta sight so I'm not tempted to clean them up -*- lexical-binding: t; -*-

(defvar org-node--obsolete-names
  '((org-node-eagerly-update-link-tables org-node-perf-eagerly-update-link-tables)
    (org-nodeify-entry org-node-nodeify-entry)
    (org-node-random org-node-visit-random)
    (org-node-slugify-as-url org-node-slugify-for-web)
    (org-node-new-by-roam-capture org-node-new-via-roam-capture)))

(defun org-node--warn-obsolete ()
  "Maybe print one-shot warnings, then become a no-op."
  (while-let ((row (pop org-node--obsolete-names)))
    (seq-let (old new removed-by) row
      (unless removed-by
        (setq removed-by "10 August 2024"))
      (when (boundp old)
        (if new
            (progn
              (lwarn 'org-node :warning "Your config sets old variable: %S, will be removed by %s.  New name: %S"
                     old removed-by new)
              (set new (symbol-value old)))
          (lwarn 'org-node :warning "Your config sets removed variable: %S" old)))
      (when (where-is-internal old)
        (if new
            (lwarn 'org-node :warning "Your config key-binds an old command name: %S.  Current name: %S"
                   old new)
          (lwarn 'org-node :warning "Your config key-binds a removed command: %S"
                 old))))))

(defmacro org-node--defobsolete (old new &optional interactive when removed-by)
  "Define OLD as a function that runs NEW.
Also, running OLD will emit a deprecation warning the first time.

If INTERACTIVE, define it as an interactive function.  But
remember, it is still not autoloaded.  Optional string WHEN says
when it was deprecated and REMOVED-BY when it may be removed."
  `(let (warned-once)
     (add-to-list 'org-node--obsolete-names '(,old ,new ,removed-by))
     (defun ,old (&rest args)
       (declare (obsolete ',new ,(or when "2024")))
       ,@(if interactive '((interactive)))
       (unless warned-once
         (setq warned-once t)
         (lwarn 'org-node :warning "Your config uses old function name: %S, which will be removed by %s.  New name: %S"
                ',old ,(or removed-by "30 August 2024") ',new))
       (apply ',new args))))

(org-node--defobsolete org-node-files org-node-list-files)

(provide 'org-node-obsolete)

;;; org-node-obsolete.el ends here
