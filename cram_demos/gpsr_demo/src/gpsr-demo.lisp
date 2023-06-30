(in-package :gpsr-demo)

;;(suturo-real-hsr-pm:with-real-hsr-pm ....)
;;(roslisp:start-ros-node "alina-cram")

;;call (init-stage-1 AMOUNT-OF-TASKS) before this
(defun gpsr-demo()
  "This function is the main control function for gpsr.
It controls the flow of the program and the mapping of NLP to plans."
  ;;??? It might be an idea to move this into a different function also. dunno

  ;;step1 - init challenge
  ;;wait for door to be opened (see start-signal.lisp)
  ;;go to pre-defined location
  ;;look at / locate operator
  ;;TODO "Hello, I'm Toya. Please give me a task" < this should be in NLP?
  ;;(init-stage-1)
  ;; ~~~ NLP Processing ~~~
  (cpl:wait-for *plan-fluent*)

  ;;match plan-fluent, to plan
  (let* ((?plan (cpl:value *plan-fluent*))
         (?plan-details (cpl:value *plan-details-fluent*))) ;;struct
    (case ?plan
      (:fetch (fetch-plan ?plan-details))
      (:deliver (deliver-plan ?plan-details))
      (:search (search-plan ?plan-details))
      (:navigate (navigate-plan ?plan-details))
      (:transport (transport-plan ?plan-details))
      (:guide (guide-plan ?plan-details))
      (:count (count-plan ?plan-details))
      (:follow (follow-plan ?plan-details))
      (:describe (describe-plan ?plan-details))
      (:greet (greet-plan ?plan-details))
      (:nlu_fallback (nlu-fallback-plan ?plan-details))

      )))

