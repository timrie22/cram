(in-package :gpsr-demo)

;;;initialize the subscribers to rasa and whisper and tts
;;TODO repalce tts with default

;;Plan= Start, Done, Fail aka. status plan
(defparameter *plan-subscriber* nil)
;;nlp-status= info about what nlp-status should be executed and with which parameters
(defparameter *plan-details-subscriber* nil)
(defparameter *nlp-feedback-subscriber* nil)

(defparameter *plan-queue* '())

(defparameter *plan-fluent* (cpl:make-fluent :name :plan-fluent))
(defparameter *plan-details-fluent* (cpl:make-fluent :name :plan-details-fluent ))
(defparameter *nlp-feedback-fluent* (cpl:make-fluent :name :nlp-feedback-fluent ))

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
  ;;reset plan que when new plans get published onto this topic
  ;;(setf *plan-queue* nil)
  (format t "plan-fluent value: ~a ~%" *plan-fluent*))
  

(defun plan-details-subscriber-cb-function (?message)
  ;;do some formating on the input. create list of symbols
  (format t "plan-details msgs received: ~a ~%" ?message)
  (let* ((?input-list  (map 'list #'(lambda (item)
                                      (intern (string-upcase
                                               (substitute #\- #\space item)) :keyword))
                            ;;;iterate through items in the given list
                            (roslisp:with-fields (commands) ?message
                              commands)))
         ;;save the list in a struct
         ;;apply is used to pass values from list to create-plan-details function
         (?plan-struct (apply #'create-plan-details ?input-list)))
    (setf *plan-queue* (append (list ?plan-struct) *plan-queue*))
    (setf (cpl:value *plan-details-fluent*) ?plan-struct) ;;write struct into fluent
    
    ;;setf *plan-queue* (list ?plan-struct)))
    (format t "plan-details-fluent value: ~a ~%" *plan-details-fluent*)))


(defun nlp-feedback-subscriber-cb-function (?message)
  (setf (cpl:value *nlp-feedback-fluent*) ?message)
  ;;(nlp-feedback "START") ;;debugging
  (format t "nlp-feedback-fluent value: ~a ~%" *nlp-feedback-fluent*)
  (print "nlp is ready"))


;;; ---- debug utils ----
(defun reset-fluents()
  (setf (cpl:value *plan-fluent*) nil)
  (setf (cpl:value *plan-details-fluent*) nil)
  (setf (cpl:value *nlp-feedback-fluent*) nil))

