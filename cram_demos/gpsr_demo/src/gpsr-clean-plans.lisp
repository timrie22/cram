(in-package :gpsr-demo)

(defun fetch-plan (?plan-details)
  (roslisp:ros-info (fetch-plan) "Start fetching plan"))

(defun deliver-plan (?plan-details)
  (roslisp:ros-info (deliver-plan) "Start deliver plan"))

(defun search-plan (?plan-details)
  (roslisp:ros-info (search-plan) "Start searching plan"))

(defun navigate-plan (?plan-details)
  (roslisp:ros-info (navigate-plan) "Start navigating plan"))

(defun transport-plan (?plan-details)
  (roslisp:ros-info (transport-plan) "Start transport plan"))

(defun guide-plan (?plan-details)
  (roslisp:ros-info (guide-plan) "Start guide plan"))

(defun count-plan (?plan-details)
  (roslisp:ros-info (count-plan) "Start counting plan"))

(defun follow-plan (?plan-details)
  (roslisp:ros-info (follow-plan) "Start follow plan"))

(defun describe-plan (?plan-details)
  (roslisp:ros-info (describe-plan) "Start describe plan"))

(defun greet-plan (?plan-details)
  (roslisp:ros-info (greet-plan) "Start greet plan")
  (let* ((?name (plan-details-person-name ?plan-details))
         (?from-location (plan-detauls-from-location)))
    ;;parse ?from-location to knowrob
    ;;navigate to ?from-location
    ;;look for person
    (suturo-demos:call-text-to-speech-action (string ?name))

  ))

(defun nlu-fallback-plan (?plan-details)
  (roslisp:ros-info (fallback-plan) "Start fallback plan"))

