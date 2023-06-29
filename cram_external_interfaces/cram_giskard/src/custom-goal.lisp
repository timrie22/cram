(in-package :giskard)


(defun make-cml-action-goal (drive-back laser-distance-threshold)
    ;; (declare  (type cl-transforms-stamped:pose-stamped knob-pose)
    ;;           (type boolean grasp-type))
  (giskard::make-giskard-goal
   :joint-constraints (make-cml-constraint drive-back laser-distance-threshold)))

(defun ensure-cml-gripper-goal-input ()
)

(defun ensure-cml-gripper-goal-reached ()
)

(defun call-cml-action (&key
                          action-timeout
                          drive-back
                          laser-distance-threshold)
  (giskard::call-action
   :action-goal (make-cml-action-goal drive-back laser-distance-threshold)
   :action-timeout action-timeout)
  ;; :check-goal-function (lambda (result status)
  ;;                        ;; This check is only done after the action
  ;;                        ;; and never before, therefore check
  ;;                        ;; if result and status already exist.
  ;;                        (if (and result status)
  ;;                            (ensure-cml-goal-reached
  ;;                             box-pose)
  ;;                            :goal-not-achieved-yet)))
  )

(defun make-cml-constraint (drive-back laser-distance-threshold)
  ;; (declare  (type cl-transforms-stamped:pose-stamped goal-pose))
  (roslisp:make-message
   'giskard_msgs-msg:constraint
   :type
   "CarryMyBullshit"
   :parameter_value_pair
   (giskard::alist->json-string
    `(,@(when drive-back
          `(("drive_back"
             . 1)))
      ,@(when laser-distance-threshold
          `(("laser_distance_threshold"
             . ,laser-distance-threshold)))))))
