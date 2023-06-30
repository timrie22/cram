(in-package :giskard)


(defun make-cml-action-goal (drive-back
                             laser-distance-threshold
                             clear-path
                             footprint-radius
                             last-distance-threshold
                             height-for-camera-target
                             laser-avoidance-max-x)
    ;; (declare  (type cl-transforms-stamped:pose-stamped knob-pose)
    ;;           (type boolean grasp-type))
  (giskard::make-giskard-goal
   :joint-constraints (make-cml-constraint drive-back
                                           laser-distance-threshold
                                           clear-path
                                           footprint-radius
                                           last-distance-threshold
                                           height-for-camera-target
                                           laser-avoidance-max-x)))

(defun ensure-cml-gripper-goal-input ()
)

(defun ensure-cml-gripper-goal-reached ()
)

(defun call-cml-action (&key
                          action-timeout
                          drive-back
                          laser-distance-threshold
                          clear-path
                          footprint-radius
                          last-distance-threshold
                          height-for-camera-target
                          laser-avoidance-max-x)
  (giskard::call-action
   :action-goal (make-cml-action-goal drive-back
                                      laser-distance-threshold
                                      clear-path
                                      footprint-radius
                                      last-distance-threshold
                                      height-for-camera-target
                                      laser-avoidance-max-x)
   :action-timeout action-timeout)
  ;; :check-goal-function (lambda (result status)
  ;;                        ;; This check is only done after the action
  ;;                        ;; and never before, therefore check
  ;;                        ;; if result and status already exist.
  ;;                        (if (and result status)
  ;;                            (ensure-cml-goal-reached
  ;;                             box-pose)
  ;;                            :goal-not-achieved-yet)))re
  )

(defun make-cml-constraint (drive-back
                            laser-distance-threshold
                            clear-path
                            footprint-radius
                            last-distance-threshold
                            height-for-camera-target
                            laser-avoidance-max-x)
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
             . ,laser-distance-threshold)))
      ,@(when clear-path
          `(("clear_path"
             . ,clear-path)))
      ,@(when footprint-radius
          `(("footprint_radius"
             . ,footprint-radius)))
      ,@(when last-distance-threshold
          `(("last_distance_threshold"
             . ,last-distance-threshold)))
      ,@(when height-for-camera-target
          `(("height_for_camera_target"
             . ,height-for-camera-target)))
      ,@(when laser-avoidance-max-x
          `(("laser_avoidance_max_x"
             . ,laser-avoidance-max-x)))
      
      ))))
