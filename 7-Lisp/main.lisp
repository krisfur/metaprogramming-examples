;;;; Common Lisp, 1958-ish flavour.
;;;;
;;;; A macro is a function from code -> code that runs at
;;;; compile/read time. `define-json-serializer` takes a struct name
;;;; and a field list, and emits a real `defun` that builds the JSON
;;;; string. Same idea C macros reach for, but operating on parsed
;;;; s-expressions instead of token soup — so it's a real program,
;;;; not text substitution.

(defstruct user id name email active)

(defun json-value (v)
  (cond ((eq v t)      "true")
        ((eq v nil)    "false")
        ((stringp v)   (format nil "\"~A\"" v))
        ((numberp v)   (format nil "~A" v))
        (t             (format nil "\"~A\"" v))))

(defmacro define-json-serializer (struct-name &rest fields)
  (let* ((obj   (gensym "OBJ"))
         (parts (loop for f in fields
                      collect `(format nil "\"~A\":~A"
                                       ,(string-downcase (symbol-name f))
                                       (json-value (slot-value ,obj ',f))))))
    `(defun ,(intern (format nil "~A-TO-JSON" struct-name)) (,obj)
       (concatenate 'string
                    "{"
                    (format nil "~{~A~^,~}" (list ,@parts))
                    "}"))))

;; Expand to see the generated defun:
(format t ";; macroexpansion:~%~S~%~%"
        (macroexpand-1 '(define-json-serializer user id name email active)))

(define-json-serializer user id name email active)

(let ((u (make-user :id 42 :name "alice" :email "a@x.com" :active t)))
  (format t "~A~%" (user-to-json u)))
