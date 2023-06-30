(in-package :gpsr-demo)

;;(defun parse-msgs)
(defstruct (plan-details
            (:constructor create-plan-details
                (plan object-name object-type person-name person-type
                 object-attribute ;; smth like right-most object
                 person-action color number from-location to-location
                 from-room to-room)))
  plan
  object-name
  object-type
  person-name
  person-type
  object-attribute ;; smth like right-most object
  person-action
  color
  number
  from-location
  to-location
  from-room
  to-room)


(defun plan-details-string-list (?plan-details-struct)
  (concatenate 'string "~% plan: " (string (plan-details-plan ?plan-details-struct))
               "~% object-name: " (string (plan-details-object-name ?plan-details-struct))
               "~% object-type: " (string (plan-details-object-type ?plan-details-struct))
               "~% person-name: " (string (plan-details-person-name ?plan-details-struct))
               "~% person-type: " (string (plan-details-person-type ?plan-details-struct))
               "~% object-attribute: " (string (plan-details-object-attribute ?plan-details-struct))
               "~% person-action: " (string (plan-details-person-action ?plan-details-struct))
               "~% color: " (string (plan-details-color ?plan-details-struct))
               "~% number:" (string (plan-details-number ?plan-details-struct))
               "~% from-location: " (string (plan-details-from-location ?plan-details-struct))
               "~% to-location: "(string (plan-details-to-location ?plan-details-struct))
               "~% from-room: "(string (plan-details-from-room ?plan-details-struct))
               "~% to-room: " (string (plan-details-to-room ?plan-details-struct))))
        
