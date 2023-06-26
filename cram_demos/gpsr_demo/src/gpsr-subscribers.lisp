(in-package :gpsr-demo)

;;;initialize the subscribers to rasa and whisper and tts
;;TODO repalce tts with default

;;Plan= Start, Done, Fail aka. status plan
(defparameter *plan-subscriber* nil)
;;nlp-status= info about what nlp-status should be executed and with which parameters
(defparameter *nlp-status-subscriber* nil)

(defvar *plan-fluent* nil)
(defvar *nlp-status-fluent* nil)


(defun init-plan-subscriber ()
  (setf *plan-subscriber*
        (roslisp:subscribe "Planchatter" "gpsr_nlp/nlpCommands" #'plan-subscriber-cb-function))
  (cpl:make-fluent :name *plan-fluent* :value nil))

;;;ex dialog
(defun init-nlp-status-subscriber ()
  (setf *nlp-status-subscriber*
        (roslisp:subscribe "NLPchatter" "gpsr_nlp/nlpCommands" #'nlp-status-subscriber-cb-function))
  (cpl:make-fluent :name *nlp-status-fluent* :value nil))


(defun plan-subscriber-cb-function (?message)
  (roslisp:with-fields (commands) ?message
    (setf *plan-fluent* (intern (string-upcase (aref commands 0)) :keyword)))
  ;;results of this input can be: :DONE :START :FAIL
  (format t "command-fluent value: ~a" *plan-fluent*))
  

(defun nlp-status-subscriber-cb-function (?message)
  (setf *nlp-status-fluent* ?message)
  (format t "nlp-status-fluent value: ~a" *nlp-status-fluent*))
