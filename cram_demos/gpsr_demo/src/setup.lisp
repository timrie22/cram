(in-package :gpsr-demo)

(defun gpsr-init()
  (init-plan-subscriber)
  (init-plan-details-subscriber)
  (init-nlp-feedback-subscriber)
  ;(su-demos::init-text-to-speech-action-client) ;;maybe remove, not sure
  ;(hsrtospeak) ;;TODO remove probably? summarize talker and feedback?
)

(defun init-stage-1(&optional (?retry-counter 3))
  (roslisp:ros-info (GPSR-Init-Stage1) "Initializing connection to NLP...")
  (nlp-feedback "3")
  (if (cpl:wait-for *nlp-feedback-fluent* :timeout 10);;TODO replace with wiating or smth... nlp should ping cram or so
      (progn
        (nlp-feedback "START")
        (roslisp:ros-info (GPSR-Init-Stage1) "Connected to NLP."))
      (progn
        (roslisp:ros-info (GPSR-Init-Stage1) "Timeout. Retry...")
        (if (> ?retry-counter 0)
            (init-stage-1 (- ?retry-counter 1))
            (roslisp:ros-info (GPSR-Init-Stage1) "Failed to connect to NLP"))))
  
  (reset-fluents))
