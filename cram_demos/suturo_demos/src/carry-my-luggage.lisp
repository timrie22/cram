(in-package :su-demos)

;; @author Vanessa Hassouna
(defvar *human-detect-fluent-status*
  (cpl:make-fluent :name :human-detect-fluent-status) "Now u see me now u dont")
(defvar *human-detect-fluent-position*
  (cpl:make-fluent :name :human-detect-fluent-position) "Now u see me now u dont")
(defvar *hsr-pose-fluent*
  (cpl:make-fluent :name :hsr-pose-fluent) "I am here")


(defvar *percept-subscriber* nil)
(defvar *percept-follow-subscriber* nil)
(defvar *hsr-pose-subscriber* nil)

(defun clean-cml ()
  (setf *percept-subscriber* nil))

(defun init-human-detect-status ()
  (setf *percept-subscriber*
        (roslisp:subscribe "robokudovanessa/query/result"
                                                     "robokudo_msgs/QueryActionResult"
                                                     #'perceptresult)))

(defun init-human-pose-detect ()
  (setf *percept-follow-subscriber*
        (roslisp:subscribe "/robokudovanessa/human_position"
                                                     "geometry_msgs/PointStamped"
                                                     #'humanpose)))

(defun init-hsr-pose ()
  (setf *hsr-pose-subscriber*
        (roslisp:subscribe "/hsrb/base_pose"
                           "geometry_msgs/PoseStamped"
                                                     #'hsrpose)))


(defun perceptresult (msg)
  (roslisp:with-fields
      ((?result (status status)))
      msg
    (setf (cpl::value *human-detect-fluent-status*) ?result)))

(defun humanpose (msg)
  (roslisp:with-fields ((?position (point)))
      msg
    ;;todo change to ?position
  (setf (cpl::value *human-detect-fluent-position*) msg)))

(defun hsrpose (msg)
   (roslisp:with-fields ((?pose (pose)))
       msg
  (setf (cpl::value *hsr-pose-fluent*) ?pose)))





  
(defun cml-demo (&key (step 0) (talk T))
  (let ((percept-pub (roslisp::advertise "/robokudovanessa/query/goal"
                                         "robokudo_msgs/QueryActionGoal")))
    (init-human-detect-status)
    (init-human-pose-detect)
    (init-hsr-pose)
    (when (<= step 0)
      (talk-request "Hey, I am Toya i will help you to carry your Luggage.
I will now park myself." talk)
      (park-robot)
      (talk-request "Please step in front of me so I can recognize you" talk)
      (block human-init
        ;;how to know human
        (loop until (not (or (eq (cpl::value *human-detect-fluent-status*) 4)
                             (eq (cpl::value *human-detect-fluent-status*) nil)))
            do
            (roslisp::publish-msg percept-pub )
            (talk-request "Please step in front of me so I can recognize you" talk)
            (sleep 2))
      
        (talk-request "I was able to recognize you, Can you please give me the bag?" talk)
                                        (human-assist talk)
        (talk-request "I will now follow you, please dont move to fast. Please wave when i lost you" talk)

        ;(cpl::wait-for (cpl::pulsed *human-detect-fluent-position*))
        (loop until (or (eq (cpl::value *human-detect-fluent-status*) 4)
                        (eq (cpl::value *human-detect-fluent-status*) nil))
              do
                 (let* ((nav-goal (relative-angle-to (cpl::value *human-detect-fluent-position*)
                                                     (cpl::value *hsr-pose-fluent*)
                                                     )))

                   (cpl::pursue
                     (progn (sleep 1)
                            (cpl::wait-for (cpl::pulsed *human-detect-fluent-position*)))
                     (progn
                       (print nav-goal)
                              (call-nav-action-ps-cml nav-goal))
                     ))

                 
                )))))


;;start seeing human nice
;;following his track
;;...




(defun call-nav-action-ps-cml (pose-stamped)
  "Receives stamped pose `pose-stamped'. Calls the navigation client and passes the given pose-stamped to it."  
  (setf pose-stamped (cl-tf:copy-pose-stamped pose-stamped :origin
                                              (cl-tf:copy-3d-vector
                                               (cl-tf:origin pose-stamped)
                                               :z 0.0)))
  (multiple-value-bind (result status)
      (let ((actionlib:*action-server-timeout* 20.0)
            (the-goal (cl-tf:to-msg
                       pose-stamped)))
        (print "within navi")
        (print pose-stamped)
        ;;publish the pose the robot will navigate to
        (publish-marker-pose pose-stamped :g 1.0)
        (actionlib:call-goal
         (get-nav-action-client)
         (make-nav-action-goal the-goal)))
    (roslisp:ros-info (nav-action-client)
                      "Navigation action finished.")
    ;; (case status
    ;;   (:succeeded (call-text-to-speech-action "Goal reached successfully!"))
    ;;   (otherwise (call-text-to-speech-action "Something went wrong!")))
    (format t "result : ~a" status)
    (values result status)))


 
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
  ;; (let ((goalpose
  ;;         (cl-tf::transform-pose-stamped
  ;;          cram-tf::*transformer*
  ;;          :pose goal :target-frame "/odom")))
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
               (atanerin   (atan
                            (cl-transforms:y diff-pose)
                            (cl-transforms:x diff-pose))))
          (cl-tf::make-pose-stamped "odom" 0
                                    (cl-tf:make-3d-vector ?x ?y 0)
                                    (cl-tf:axis-angle->quaternion
                                     (cl-tf:make-3d-vector 0 0 1) atanerin)))))))



