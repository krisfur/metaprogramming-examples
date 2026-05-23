;;;; Common Lisp, 1958-ish flavour.
;;;;
;;;; A macro is a function from code -> code that runs at
;;;; compile/read time. `defjson` takes a name and a typed field list
;;;; and emits BOTH the `defstruct` AND a serializer with per-field
;;;; formatting resolved at expansion time from one source form.
;;;; The "single list, multiple artefacts" trick C reaches for with
;;;; X-macros, but operating on parsed s-expressions instead of token
;;;; soup, so the macro is a real program over the AST.

(defun format-field (obj field)
  "Compile-time helper: emit the code that formats one field at runtime."
  (destructuring-bind (name type) field
    (let ((key  (string-downcase (symbol-name name)))
          (slot `(slot-value ,obj ',name)))
      (ecase type
        (integer `(format nil "\"~A\":~A"   ,key ,slot))
        (string  `(format nil "\"~A\":\"~A\"" ,key ,slot))
        (boolean `(format nil "\"~A\":~A"   ,key (if ,slot "true" "false")))))))

(defmacro defjson (name &rest fields)
  (let ((obj (gensym "OBJ")))
    `(progn
       (defstruct ,name ,@(mapcar #'first fields))
       (defun ,(intern (format nil "~A-TO-JSON" name)) (,obj)
         (concatenate 'string
                      "{"
                      (format nil "~{~A~^,~}"
                              (list ,@(mapcar (lambda (f) (format-field obj f))
                                              fields)))
                      "}")))))

;; Expand to see the generated struct + defun
(format t ";; macroexpansion:~%~S~%~%"
        (macroexpand-1 '(defjson user
                          (id     integer)
                          (name   string)
                          (email  string)
                          (active boolean))))

(defjson user
  (id     integer)
  (name   string)
  (email  string)
  (active boolean))

(let ((u (make-user :id 42 :name "alice" :email "a@x.com" :active t)))
  (format t "~A~%" (user-to-json u)))
