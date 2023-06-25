(in-package :su-demos)

(defparameter *hsr-speaker-subscriber* nil)

(defun cram-talker (command)
  "Periodically print a string message on the /chatter topic"
  (let ((pub (roslisp:advertise "CRAMpub" "std_msgs/String")))
    
    (roslisp:publish-msg pub :data (format nil command))))
         

(defun hsrtospeak (topic-name)
  (setf *hsr-speaker-subscriber* (roslisp:subscribe topic-name "std_msgs/String" #'hsrspeaks-callback-function)))

(defun hsrspeaks-callback-function (message)
  (roslisp:with-fields (data) message  
    (let ((?tospeak data))
      (print ?tospeak)
      (call-text-to-speech-action ?tospeak)
      )))

;;(defun startgpsr (topic-name) ;;; 9 june
  ;;  (setf *start-subscriber* (roslisp:subscribe topic-name "gpsr_nlp/nlpCommands" #'startgpsr-callback-function)))
    
;;(defun startgpsr-callback-function (message) ;;9 june
	;;(roslisp:with-fields (commands) message
 
      ;;   (print (intern (string-upcase (aref commands 0)) :keyword))
        ;; (when (eq (intern (string-upcase (aref commands 0)) :keyword) :START)
         ;;	(navigate-to-location :nil :start-point)
			;;(print "its start")

	  ;; )))
