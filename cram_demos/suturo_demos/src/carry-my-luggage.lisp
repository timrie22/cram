(in-package :su-demos)

;; ;; @author Vanessa Hassouna
;; (defvar *human-detect-fluent-status*
;;   (cpl:make-fluent :name :human-detect-fluent-status) "Now u see me now u dont")
;; (defvar *human-detect-fluent-position*
;;   (cpl:make-fluent :name :human-detect-fluent-position) "Now u see me now u dont")
;; (defvar *hsr-pose-fluent*
;;   (cpl:make-fluent :name :hsr-pose-fluent) "I am here")


;; (defvar *percept-subscriber* nil)
;; (defvar *percept-follow-subscriber* nil)
;; (defvar *hsr-pose-subscriber* nil)

;; (defun clean-cml ()
;;   (setf *percept-subscriber* nil))

;; (defun init-human-detect-status ()
;;   (setf *human-detect-fluent-status* nil)
;;   (setf *percept-subscriber* nil)
;;   (setf *percept-subscriber*
;;         (roslisp:subscribe "robokudovanessa/query/result"
;;                                                      "robokudo_msgs/QueryActionResult"
;;                                                      #'perceptresult)))

;; (defun init-human-pose-detect ()
;;   (setf *human-detect-fluent-position* nil)
;;   (setf *percept-follow-subscriber* nil)
;;   (setf *percept-follow-subscriber*
;;         (roslisp:subscribe "/robokudovanessa/human_position"
;;                                                      "geometry_msgs/PointStamped"
;;                                                      #'humanpose)))

;; (defun init-hsr-pose ()
;;   (setf *hsr-pose-fluent* nil)
;;   (setf *hsr-pose-subscriber* nil)
;;   (setf *hsr-pose-subscriber*
;;         (roslisp:subscribe "/hsrb/base_pose"
;;                            "geometry_msgs/PoseStamped"
;;                                                      #'hsrpose)))


;; (defun perceptresult (msg)
;;   (roslisp:with-fields
;;       ((?result (status status)))
;;       msg
;;     (setf (cpl::value *human-detect-fluent-status*) ?result)))

;; (defun humanpose (msg)
;;   (roslisp:with-fields ((?position (point)))
;;       msg
;;     ;;todo change to ?position
;;   (setf (cpl::value *human-detect-fluent-position*) msg)))

;; (defun hsrpose (msg)
;;    (roslisp:with-fields ((?pose (pose)))
;;        msg
;;   (setf (cpl::value *hsr-pose-fluent*) ?pose)))





  
(defun cml-demo (&key (step 0) (talk T) (is-start T))
  (let ((percept-pub (roslisp::advertise "/robokudovanessa/query/goal"
                                         "robokudo_msgs/QueryActionGoal"))
        (human-detect-fluent-status
          (cpl:make-fluent :name :human-detect-fluent-status))
        (human-detect-fluent-position
          (cpl:make-fluent :name :human-detect-fluent-position))
        (hsr-pose-fluent
          (cpl:make-fluent :name :hsr-pose-fluent)))
    (flet ((perceptresult (msg)
             (roslisp:with-fields
                 ((?result (status status)))
                 msg
               (setf (cpl::value human-detect-fluent-status) ?result)))

           (humanpose (msg)
               (setf (cpl::value human-detect-fluent-position) msg))

           (hsrpose (msg)
             (roslisp:with-fields ((?pose (pose)))
                 msg
               (setf (cpl::value hsr-pose-fluent) ?pose))))

      (roslisp:subscribe "/hsrb/base_pose"
                         "geometry_msgs/PoseStamped"
                         #'hsrpose)
      (roslisp:subscribe "/robokudovanessa/human_position"
                         "geometry_msgs/PointStamped"
                         #'humanpose)
      (roslisp:subscribe "robokudovanessa/query/result"
                         "robokudo_msgs/QueryActionResult"
                         #'perceptresult)

      (if is-start
          (progn (talk-request "Hey, I am Toya i will help you to carry your Luggage." talk)
                 ;;(park-robot)
                 (talk-request "I am now searching for a human" talk))
          (talk-request "I lost you, please stop" talk))
      
      (block human-init
        ;;how to know human
        (loop until (not (or (eq (cpl::value human-detect-fluent-status) 4)
                             (eq (cpl::value human-detect-fluent-status) nil)))
              do
                 (roslisp::publish-msg percept-pub )
                 (talk-request "Please step in front of me so I can recognize you" talk)
                 (sleep 1.5))
        
        (when is-start
          (talk-request "I was able to recognize you, Can you please give me the bag?" talk)
                                        ;(human-assist talk))
          )
        
        (talk-request "I will now follow you, please dont move to fast." talk)
        (let ((stop-condition t)
              
              (home-pose (cl-tf:make-pose-stamped "map" 0
                                                  (cl-tf:make-3d-vector 0 0 0)
                                                  (cl-tf:make-quaternion 0 0 0 1))))
          (cpl::pursue
            (cpl::seq
              (exe:perform
               (desig:an action
                         (type monitoring-joint-state)
                         (joint-name "wrist_flex_joint")))
              (talk-request "I think we arrived I hope my service was satisfactory!" talk)
              (exe:perform (desig:a motion
                                    (type gripper-motion)
                                    (:open-close :open)
                                    (effort 0.1)))
              (setf stop-condition t))
            (cpl::seq
              (loop until (or (eq (cpl::value human-detect-fluent-status) 4)
                              (eq (cpl::value human-detect-fluent-status) nil))
                    do
                       (let* ((nav-goal (relative-angle-to (cpl::value human-detect-fluent-position)
                                                           (cpl::value hsr-pose-fluent))))

                         (cpl::pursue
                           (progn (sleep 1)
                                  (cpl::wait-for (cpl::pulsed human-detect-fluent-position)))
                           (progn
                             ;; (par 
                             (call-nav-action-ps nav-goal)))))
              (setf stop-condition nil)))
          
          (unless stop-condition
            (cml-demo :is-start nil))
                                      (call-nav-action-ps home-pose))
          
        ))))

        
       
 
;; (defun cml-follow (&key (talk T))
;;   (cpl::pursue
;;     (cpl::seq
;;       (exe:perform
;;        (desig:an action
;;                  (type monitoring-joint-state)
;;                  (joint-name "wrist_flex_joint")))
;;       (talk-request "I think we arrived I hope my service was satisfactory!" talk)
;;       (exe:perform (desig:a motion
;;                             (type gripper-motion)
;;                             (:open-close :open)
;;                             (effort 0.1)))
;;       t)
;;     (cpl::seq
;;       (loop until (or (eq (cpl::value *human-detect-fluent-status*) 4)
;;                       (eq (cpl::value *human-detect-fluent-status*) nil))
;;             do
;;                (let* ((nav-goal (relative-angle-to (cpl::value *human-detect-fluent-position*)
;;                                                    (cpl::value *hsr-pose-fluent*))))

;;                  (cpl::pursue
;;                    (progn (sleep 1)
;;                           (cpl::wait-for (cpl::pulsed *human-detect-fluent-position*)))
;;                    (progn
;;                      ;; (par 
;;                      (call-nav-action-ps nav-goal)))))
;;       nil)))



 
(defun pose-msg->transform (msg)
  "Returns a transform proxy that allows to transform into the frame
given by x, y, and theta of `msg'."
  (roslisp:with-fields ((?x (x position))(?y (y position))
                        (?qx (x orientation))
                        (?qy (y orientation))
                        (?qz (z orientation))
                        (?qw (w orientation)))
      msg
    (cl-transforms:make-transform
     (cl-transforms:make-3d-vector ?x ?y 0)
     (cl-transforms:make-quaternion ?qx ?qy ?qz ?qw)
     )))
 
(defun relative-angle-to (goal pose-msg)
  "Given a `pose-msg' as a turtlesim-msg:pose and a `goal' as cl-transforms:3d-vector,
calculate the angle by which the pose has to be turned to point toward the goal."

  (roslisp:with-fields ((?x (x Point))(?y (y Point)))
      goal
    (let* ((transformpoint
             (cl-tf::make-point-stamped "map" 0
                                        (cl-tf::make-3d-vector ?x ?y 0)))
           (goalpose
             (cl-tf::transform-point-stamped
              cram-tf::*transformer*
              :point transformpoint :target-frame "/odom")))
      
      (roslisp:with-fields ((?x (x ))(?y (y )))
          
          goalpose
        (let* (
               (point (cl-transforms:make-3d-vector ?x ?y 0))
               (diff-pose (cl-transforms:transform-point
                           (cl-transforms:transform-inv
                            (pose-msg->transform pose-msg))
                           point))
               (atanerin   (/ (atan
                            (cl-transforms:y diff-pose)
                            (cl-transforms:x diff-pose)) 2)))
          (cl-tf::make-pose-stamped "odom" 0
                                    (cl-tf:make-3d-vector ?x ?y 0)
                                    (cl-tf:axis-angle->quaternion
                                     (cl-tf:make-3d-vector 0 0 1) atanerin)))))))



