(in-package :gpsr-demo)

;;;initialize the subscribers to rasa and whisper and tts
;;TODO repalce tts with default

;;Plan= Start, Done, Fail aka. status plan
(defparameter *plan-subscriber* nil)
;;nlp-status= info about what nlp-status should be executed and with which parameters
(defparameter *plan-details-subscriber* nil)
(defparameter *nlp-feedback-subscriber* nil)


(defvar *plan-fluent* (cpl:make-fluent :name :plan-fluent))
(defvar *plan-details-fluent* (cpl:make-fluent :name :plan-details-fluent ))
(defvar *nlp-feedback-fluent* (cpl:make-fluent :name :nlp-feedback-fluent ))

;;; ---- init ----

(defun init-plan-subscriber ()
  (setf *plan-subscriber*
        (roslisp:subscribe "PlanList" "gpsr_nlp/nlpCommands" #'plan-subscriber-cb-function))
  (roslisp:ros-info (NLP-Plan-Subscriber) "NLP Plan Subscriber created."))


(defun init-plan-details-subscriber ()
  (setf *plan-details-subscriber*
        (roslisp:subscribe "Planchatter" "gpsr_nlp/nlpCommands" #'plan-details-subscriber-cb-function))
  (roslisp:ros-info (Plan-Details-Subscriber) "Plan Details Subscriber created."))

(defun init-nlp-feedback-subscriber ()
  (setf *nlp-feedback-subscriber*
        (roslisp:subscribe "NLPfeedback" "std_msgs/String" #'nlp-feedback-subscriber-cb-function))
  (roslisp:ros-info (NLP-Feedback-Subscriber) "NLP Feedback Subscriber created."))

;;; ---- Callbacks ----

(defun plan-subscriber-cb-function (?message)
  (roslisp:with-fields (commands) ?message
    (setf (cpl:value *plan-fluent*) (intern (string-upcase (aref commands 0)) :keyword)))
  ;;results of this input can be: :DONE :START :FAIL
  (format t "plan-fluent value: ~a" *plan-fluent*))
  

(defun plan-details-subscriber-cb-function (?message)
  (setf (cpl:value *plan-details-fluent*) ?message)
  (format t "plan-details-fluent value: ~a" *plan-details-fluent*))


(defun nlp-feedback-subscriber-cb-function (?message)
  (setf (cpl:value *nlp-feedback-fluent*) ?message)
  ;;(nlp-feedback "START") ;;debugging
  (format t "nlp-feedback-fluent value: ~a" *nlp-feedback-fluent*)
  (print "nlp is ready"))


;;; ---- debug utils ----
(defun reset-fluents()
  (setf *plan-fluent* (cpl:make-fluent :name :plan-fluent))
  (setf *plan-details-fluent* (cpl:make-fluent :name :plan-details-fluent))
  (setf *nlp-feedback-fluent* (cpl:make-fluent :name :nlp-feedback-fluent)))

