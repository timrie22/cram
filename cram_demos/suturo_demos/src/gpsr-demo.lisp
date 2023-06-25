(in-package :su-demos)

;;(suturo-real-hsr-pm:with-real-hsr-pm ....)

(defun gpsr-init()
  (init-nlp-status-subscriber)
  (init-plan-subscriber)
  (hsrtospeak) ;;TODO remove probably? summarize talker and feedback?
  (nlp-feedback "STARTING"))

(defun gpsr-demo()
  (call-text-to-speech-action "Waiting for control command")
  (cpl:wait-for *control-fluent*)
  
)
