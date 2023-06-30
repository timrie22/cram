(in-package :su-real)

;; author Luca Krohm
(defun demo (demo)
  "Receives keyword 'demo' and executes the corresponding demo within the correct environment "

  (let ((plan nil))
    (case demo
      ;; saves the plan corresponding to the keyworld to be executed later
      (:clean (setf plan (list #'su-demos::clean-the-table-demo)))
      (:groceries (setf plan (list #'su-demos::storing-groceries-demo)))
      (:breakfast (setf plan (list #'su-demos::serve-breakfast-demo)))
      (:all (setf plan (list #'su-demos::storing-groceries-demo
                               #'su-demos::serve-breakfast-demo
                               #'su-demos::clean-the-table-demo)))
      (otherwise (roslisp:ros-error (run-demo)
                                    "Demo ~a is not a valid demo!"
                                    demo)))
    ;; starts the plan within the correct environment
    (with-hsr-process-modules
      (unwind-protect
           (mapc #'funcall plan)))))
