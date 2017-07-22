(require 'cedille-mode-faces)

(eval-when-compile (require 'cl))


(defgroup cedille-highlight nil
  "Syntax highlighting for Cedille."
  :group 'cedille)

(defcustom cedille-highlight-mode 'default
  "Highlighting scheme used in Cedille-mode buffers."
  :type '(choice
	  (const :tag "Default"          default)
	  (const :tag "Language Level"   language-level)
	  (const :tag "Checking Mode"    checking-mode)
	  (const :tag "Implicit Hidden"  implicit-hidden)
	  )
  :group 'cedille-highlight)



(make-variable-buffer-local
 (defvar cedille-mode-highlight-face-map nil
   "Should be a mapping of qualities (strings) 
   to a mapping of values (strings) with faces (variables)"))



;; TODO: Check that MAP is appropriate
(defun set-cedille-mode-highlight-face-map (map)
  "Sets the  cedille-mode-highlight-face-map variable to MAP."
  (setq cedille-mode-highlight-face-map map))




;; Interactive Calls -------------------------------------------------------


(defun cedille-mode-highlight-default ()
  (interactive)
  "Sets the cedille-mode-highlight-face-map variable to 
   `cedille-mode-highlight-face-map-default' then highlights the file"
  (set-cedille-mode-highlight-face-map cedille-mode-highlight-face-map-default)
  (cedille-mode-highlight))

(defun cedille-mode-highlight-language-level ()
  (interactive)
  "Sets the cedille-mode-highlight-face-map variable to 
   `cedille-mode-highlight-face-map-language-level' then highlights the file"
  (set-cedille-mode-highlight-face-map cedille-mode-highlight-face-map-language-level)
  (cedille-mode-highlight))

(defun cedille-mode-highlight-checking-mode ()
  (interactive)
  "Sets the cedille-mode-highlight-face-map variable to
   `cedille-mode-highlight-face-map-checking-mode' then highlights the file"
  (set-cedille-mode-highlight-face-map cedille-mode-highlight-face-map-checking-mode)
  (cedille-mode-highlight))


;; Highlighting code -----------------------------------------------------

(defun cedille-mode-highlight ()
  "Highlights current buffer based on the
`ced-font-map'.  This will deactivate `font-lock-mode'."
  (with-silent-modifications
    (when cedille-mode-highlight-face-map
    ;(let ((modified (buffer-modified-p)))
	  ;(navi-on se-navigation-mode))
      (font-lock-mode -1)
      (mapcar 'cedille-mode-highlight-span (cdr cedille-mode-highlight-spans))
      (cedille-mode-update-overlays))))
     ; (set-buffer-modified-p modified)
      ;(when navi-on
	;(se-navigation-mode 1))))))

(defun cedille-mode-update-overlays ()
  "Updates error and hole overlays."
  (remove-overlays (point-min) (point-max) 'help-echo "error")
  (remove-overlays (point-min) (point-max) 'help-echo "hole")
  (overlay-recenter (point-max))
  (cedille-mode-highlight-error-overlay cedille-mode-error-spans)
  (cedille-mode-highlight-hole-overlay cedille-mode-error-spans))
  


(defun cedille-mode-highlight-span (span)
  (let ((face (cedille-mode-highlight-get-face span cedille-mode-highlight-face-map))
	(start (se-span-start span))
	(end (se-span-end span)))
    (when face
	(put-text-property start end 'face face nil))))

(defun cedille-mode-highlight-get-face (span map)
  (if (equal map nil)
      nil
    (let* ((val (get-span-data-value span (caar map)))
	   (face (cdr (assoc  val (cdar map)))))
      (if face face
	(cedille-mode-highlight-get-face span (cdr map))))))


(defun get-span-data-value (span quality)
  (let ((data (se-span-data span)))
    (cond
     ((string= quality "name") (se-span-name span))
     ;; ((string= quality "error") (if (cdr (assoc 'error data)) "error" nil)) 
     (t (cdr (assoc (intern quality) data))))))


(provide 'cedille-mode-highlight)
