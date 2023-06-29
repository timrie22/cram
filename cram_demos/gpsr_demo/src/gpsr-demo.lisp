(in-package :gpsr-demo)

;;(suturo-real-hsr-pm:with-real-hsr-pm ....)
;;(roslisp:start-ros-node "alina-cram")

(defun stage1()
  (print "start")
  (nlp-feedback "3")
  (if (cpl:wait-for *nlp-feedback-fluent* :timeout 10);;TODO replace with wiating or smth... nlp should ping cram or so
      (nlp-feedback "START")
      (nlp-feedback "3"))
  (print "done")) ;;reset


(defun gpsr-demo(?challenge-amount)
  ;;(call-text-to-speech-action "Waiting for control command")
  

  ;;(cpl:wait-for *nlp-status-fluent*)
  
)

