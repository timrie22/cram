(in-package :su-real)

;; @author Luca Krohm
;; @TODO failurehandling
(defun pick-up (&key
                  ((:collision-mode ?collision-mode))
                  ((:collision-object-b ?collision-object-b))
                  ((:collision-object-b-link ?collision-object-b-link))
                  ((:collision-object-a ?collision-object-a))
                  ((:move-base ?move-base))
                  ((:prefer-base ?prefer-base))
                  ((:straight-line ?straight-line))
                  ((:align-planes-left ?align-planes-left))
                  ((:align-planes-right ?align-planes-right))
                  ((:precise-tracking ?precise-tracking))
                  ((:object-type ?object-type))
                  ((:goal-pose ?goal-pose))
                  ((:object-size ?object-size))
                  ((:object-shape ?object-shape))
                  ((:object-name ?object-name))
                  ((:from-above ?from-above))
                  ((:sequence-goal ?sequence-goal))
                &allow-other-keys)
  "Receives parameters from action-designator, and then executes the corresponding motions"
  (declare (type boolean ?move-base ?prefer-base ?straight-line ?precise-tracking
                 ?align-planes-left ?align-planes-right))
  (cpl:with-retry-counters ((manip-retries 1))
    (cpl:with-failure-handling
        ((common-fail:gripper-closed-completely (e)
           (roslisp:ros-warn (suturo-pickup grasp-object)
                             "Some manipulation failure happened: ~a"
                             e)
           (cpl:do-retry manip-retries
             (roslisp:ros-warn (suturo-pickup grasp-object) "Retrying...")
             (exe:perform (desig:a motion
                        (type :retracting)
                        (collision-mode ?collision-mode)
                        (object-name ?object-name)))
             (su-demos::perc-robot)
             ;; add "looking" to old object-position before perceiving again
             (let* ((?source-object-desig
                      (desig:an object
                                (type ?object-type)))
                    ;; detect object and save the return value
                    (?object-desig
                      (exe:perform (desig:an action
                                             (type detecting)
                                             (object ?source-object-desig)))))
               (roslisp:with-fields 
                   ((?pose
                     (cram-designators::pose cram-designators:data))) 
                   ?object-desig
                 (setf ?goal-pose ?pose)))
             (cpl:retry))))
      
      (unless ?sequence-goal
        (let ((?object-height (cl-transforms:z ?object-size))
              (?context `(("action" . "grasping")
                          ("from_above" . ,?from-above))))
          (exe:perform (desig:a motion
                                (type aligning-height)
                                (collision-mode ?collision-mode)
                                (collision-object-b ?collision-object-b)
                                (collision-object-b-link ?collision-object-b-link)
                                (collision-object-a ?collision-object-a)
                                (allow-base ?move-base)
                                (prefer-base ?prefer-base)
                                (straight-line ?straight-line)
                                (align-planes-left ?align-planes-left)
                                (align-planes-right ?align-planes-right)
                                (precise-tracking ?precise-tracking)
                                (goal-pose ?goal-pose)
                                (context ?context)
                                (object-height ?object-height)
                                (object-name ?object-name)))
          
          (exe:perform (desig:a motion
                                (type gripper-motion)
                                (:open-close :open)
                                (effort 0.1)))
          (let ((?context `(("action" . "grasping")
                            ("from_above" . ,?from-above))))
            
            (exe:perform (desig:a motion
                                  (type reaching)
                                  (collision-mode ?collision-mode)
                                  (goal-pose ?goal-pose)
                                  (object-size ?object-size)
                                  (object-shape ?object-shape)
                                  (object-name ?object-name)
                                  (context ?context))))

          (sleep 2)
          
          (cpl:pursue
            (cpl:seq
              (exe:perform (desig:a motion
                                    (type gripper-motion)
                                    (:open-close :close)
                                    (effort 0.1)))
              (sleep 1)
              (su-demos::call-text-to-speech-action "I was able to grasp the object"))
           (unless ?from-above
            (cpl:seq
              (exe:perform
               (desig:an action
                         (type monitoring-joint-state)
                         (joint-name "hand_l_proximal_joint")))
              (su-demos::call-text-to-speech-action "Failed to grasp the object, retrying")
              (sleep 1)
              (cpl:fail 'common-fail:gripper-closed-completely
                        :description "Object slipped"))))
      
      
          (exe:perform (desig:a motion
                                (type :lifting)
                                (collision-mode ?collision-mode)
                                (collision-object-b ?collision-object-b)
                                (collision-object-b-link ?collision-object-b-link)
                                (collision-object-a ?collision-object-a)
                                (allow-base ?move-base)
                                (prefer-base ?prefer-base)
                                (straight-line ?straight-line)
                                (align-planes-left ?align-planes-left)
                                (align-planes-right ?align-planes-right)
                                (precise-tracking ?precise-tracking)
                                (object-name ?object-name)))

          (exe:perform (desig:a motion
                                (type :retracting)
                                (collision-mode ?collision-mode)
                                (collision-object-b ?collision-object-b)
                                (collision-object-b-link ?collision-object-b-link)
                                (collision-object-a ?collision-object-a)
                                (allow-base ?move-base)
                                (prefer-base ?prefer-base)
                                (straight-line ?straight-line)
                                (align-planes-left ?align-planes-left)
                                (align-planes-right ?align-planes-right)
                                (precise-tracking ?precise-tracking)
                                (object-name ?object-name)))))
      
      (when ?sequence-goal
        (exe:perform (desig:a motion
                                (type gripper-motion)
                                (:open-close :open)
                                (effort 0.1)))
        
        (let ((?motions (list :aligning-height :reaching))
              (?object-height (cl-transforms:z ?object-size)))
          (print "sequence1")
          ;;(break)
          (exe:perform
           (desig:an action
                     (type sequence-goal)
                     (action "grasping")
                     (motions ?motions)
                     (goal-pose ?goal-pose)
                     (object-size ?object-size)
                     (from-above ?from-above)
                     (object-height ?object-height)
                     (object-name "test"))))
        ;;(break)
          
          (cpl:pursue
            (cpl:seq
              (exe:perform (desig:a motion
                                    (type gripper-motion)
                                    (:open-close :close)
                                    (effort 0.1)))
              (sleep 1)
              (su-demos::call-text-to-speech-action "Managed to grasp the object"))
            (cpl:seq
              (exe:perform
               (desig:an action
                         (type monitoring-joint-state)
                         (joint-name "hand_l_proximal_joint")))
              (su-demos::call-text-to-speech-action "Failed to grasp the object, retrying")
              (sleep 1)
              ;; (cpl:fail 'common-fail:gripper-closed-completely
              ;;           :description "Object slipped"
              ))
          (print "sequence2")
          ;;(break)
          (let ((?motions (list :lifting :retracting)))
            (exe:perform
             (desig:an action
                       (type sequence-goal)
                       (action "grasping")
                       (motions ?motions)
                       (reference-frame "hand_gripper_tool_frame")
                       (object-name "test"))))))))

;; @author Luca Krohm
;; @TODO failurehandling
(defun place (&key
                ((:collision-mode ?collision-mode))
                ((:collision-object-b ?collision-object-b))
                ((:collision-object-b-link ?collision-object-b-link))
                ((:collision-object-a ?collision-object-a))
                ((:move-base ?move-base))
                ((:prefer-base ?prefer-base))
                ((:straight-line ?straight-line))
                ((:align-planes-left ?align-planes-left))
                ((:align-planes-right ?align-planes-right))
                ((:precise-tracking ?precise-tracking))
                ((:goal-pose ?goal-pose))
                ((:object-size ?object-size))
                ((:from-above ?from-above))
                ((:neatly ?neatly))
                ((:sequence-goal ?sequence-goal))
              &allow-other-keys)
  "Receives parameters from action-designator, and then executes the corresponding motions"
  (declare (type boolean ?move-base ?prefer-base ?straight-line ?precise-tracking
                 ?align-planes-left ?align-planes-right))
  (unless ?sequence-goal
  (let ((?object-height (cl-transforms:z ?object-size))
        (?context `(("action" . "placing")
                    ("from_above" . ,?from-above))))
    (exe:perform (desig:a motion
                          (type aligning-height)
                          (collision-mode ?collision-mode)
                          (collision-object-b ?collision-object-b)
                          (collision-object-b-link ?collision-object-b-link)
                          (collision-object-a ?collision-object-a)
                          (allow-base ?move-base)
                          (prefer-base ?prefer-base)
                          (straight-line ?straight-line)
                          (align-planes-left ?align-planes-left)
                          (align-planes-right ?align-planes-right)
                          (precise-tracking ?precise-tracking)
                          (goal-pose ?goal-pose)
                          (object-height ?object-height)
                          (context ?context))))
  
  (let ((?context `(("action" . "placing")
                    ("from_above" . ,?from-above))))
    (exe:perform (desig:a motion
                        (type reaching)
                        (collision-mode ?collision-mode)
                        (goal-pose ?goal-pose)
                        (object-size ?object-size)
                        (from-above ?from-above)
                        (context ?context))))

  (when ?neatly
    (exe:perform (desig:a motion
                          (type placing)
                          (collision-mode ?collision-mode)
                          (collision-object-b ?collision-object-b)
                          (collision-object-b-link ?collision-object-b-link)
                          (collision-object-a ?collision-object-a)
                          (allow-base ?move-base)
                          (prefer-base ?prefer-base)
                          (straight-line ?straight-line)
                          (align-planes-left ?align-planes-left)
                          (align-planes-right ?align-planes-right)
                          (precise-tracking ?precise-tracking)
                          (goal-pose ?goal-pose))))

  (exe:perform (desig:a motion
                        (type gripper-motion)
                        (:open-close :open)
                        (effort 0.1)))
  
  (exe:perform (desig:a motion
                        (type :retracting)
                        (collision-mode ?collision-mode)
                        (collision-object-b ?collision-object-b)
                        (collision-object-b-link ?collision-object-b-link)
                        (collision-object-a ?collision-object-a)
                        (allow-base ?move-base)
                        (prefer-base ?prefer-base)
                        (straight-line ?straight-line)
                        (align-planes-left ?align-planes-left)
                        (align-planes-right ?align-planes-right)
                        (precise-tracking ?precise-tracking))))

  (when ?sequence-goal
    (let ((?motions (list :aligning-height :reaching))
          (?object-height (cl-transforms:z ?object-size)))
      (print "sequence1")
      ;;(break)
      (exe:perform
       (desig:an action
                 (type sequence-goal)
                 (action "placing")
                 (motions ?motions)
                 (goal-pose ?goal-pose)
                 (object-size ?object-size)
                 (from-above ?from-above)
                 (object-height ?object-height)
                 (object-name "test"))))
    
    (when ?neatly
      (exe:perform (desig:a motion
                            (type placing)
                            (collision-mode ?collision-mode)
                            (collision-object-b ?collision-object-b)
                            (collision-object-b-link ?collision-object-b-link)
                            (collision-object-a ?collision-object-a)
                            (allow-base ?move-base)
                            (prefer-base ?prefer-base)
                            (straight-line ?straight-line)
                            (align-planes-left ?align-planes-left)
                            (align-planes-right ?align-planes-right)
                            (precise-tracking ?precise-tracking)
                            (goal-pose ?goal-pose))))
    (exe:perform (desig:a motion
                          (type gripper-motion)
                          (:open-close :open)
                          (effort 0.1)))
    
    (exe:perform (desig:a motion
                          (type :retracting)
                          (collision-mode ?collision-mode)
                          (collision-object-b ?collision-object-b)
                          (collision-object-b-link ?collision-object-b-link)
                          (collision-object-a ?collision-object-a)
                          (allow-base ?move-base)
                          (prefer-base ?prefer-base)
                          (straight-line ?straight-line)
                          (align-planes-left ?align-planes-left)
                          (align-planes-right ?align-planes-right)
                          (precise-tracking ?precise-tracking)))))


;; @author Luca Krohm
;; @TODO failurehandling
(defun open-door (&key
                    ((:collision-mode ?collision-mode))
                    ((:collision-object-b ?collision-object-b))
                    ((:collision-object-b-link ?collision-object-b-link))
                    ((:collision-object-a ?collision-object-a))
                    ((:move-base ?move-base))
                    ((:prefer-base ?prefer-base))
                    ((:straight-line ?straight-line))
                    ((:align-planes-left ?align-planes-left))
                    ((:align-planes-right ?align-planes-right))
                    ((:precise-tracking ?precise-tracking))
                    ((:handle-link ?handle-link))
                    ((:joint-angle ?joint-angle))
              &allow-other-keys)
  "Receives parameters from action-designator, and then executes the corresponding motions"
  (declare (type boolean ?move-base ?prefer-base ?straight-line ?precise-tracking
                 ?align-planes-left ?align-planes-right))

  (exe:perform (desig:a motion
                        (type gripper-motion)
                        (:open-close :open)
                        (effort 0.1)))

  (let ((?context `(("action" . "grasping"))))
    (exe:perform (desig:a motion
                          (type reaching)
                          (collision-mode ?collision-mode)
                          (collision-object-b ?collision-object-b)
                          (collision-object-b-link ?collision-object-b-link)
                          (collision-object-a ?collision-object-a)
                          (allow-base ?move-base)
                          (prefer-base ?prefer-base)
                          (straight-line ?straight-line)
                          (align-planes-left ?align-planes-left)
                          (align-planes-right ?align-planes-right)
                          (precise-tracking ?precise-tracking)
                          (object-name ?handle-link)
                          (context ?context))))
    
  (exe:perform (desig:a motion
                        (type gripper-motion)
                        (:open-close :close)
                        (effort 0.1)))

  (exe:perform (desig:a motion
                        (type pulling)
                        (arm :left)
                        (collision-object-b-link ?handle-link)
                        (joint-angle ?joint-angle)))

  (exe:perform (desig:a motion
                        (type gripper-motion)
                        (:open-close :open)
                        (effort 0.1)))
    
  (exe:perform (desig:a motion
                        (type :retracting)
                        (collision-mode ?collision-mode)
                        (collision-object-b ?collision-object-b)
                        (collision-object-b-link ?collision-object-b-link)
                        (collision-object-a ?collision-object-a)
                        (allow-base ?move-base)
                        (prefer-base ?prefer-base)
                        (straight-line ?straight-line)
                        (align-planes-left ?align-planes-left)
                        (align-planes-right ?align-planes-right)
                        (precise-tracking ?precise-tracking)
                        (tip-link t))))

;; @author Luca Krohm
(defun open-gripper (&key
                     ((:effort ?effort))
                     &allow-other-keys)
  (call-gripper-action (abs ?effort)))

;; @author Luca Krohm
(defun close-gripper (&key
                     ((:effort ?effort))
                     &allow-other-keys)
  (call-gripper-action (* -1 (abs ?effort))))

;; @author Luca Krohm
;; @TODO failurehandling
;; @TODO put the transforms etc into the designator, like its done in cram
(defun su-pour (&key
                  ((:collision-mode ?collision-mode))
                  ((:collision-object-b ?collision-object-b))
                  ((:collision-object-b-link ?collision-object-b-link))
                  ((:collision-object-a ?collision-object-a))
                  ((:object-size ?object-size))
                  ((:target-object ?target-object))
                  ((:target-size ?target-size))
                  ((:target-name ?target-name))
                &allow-other-keys)
  "Receives parameters from action-designator, and then executes the corresponding motions"

  (let* (;; pouring pose relative to the bowl.
         ;; (width of the bowl + pouring object) / -2
         ;; puts the target on the very lefthand side of the bowl
         ;; (height of the bowl + pouring object) / 2
         ;; puts the target just above the upper edge of the bowl
         (?relative-pour-pose (cl-transforms:make-3d-vector
                       0
                       (/ (+ (cl-transforms:y ?target-size)
                             (cl-transforms:y ?object-size))
                          2)
                       (/ (+ (cl-transforms:z ?target-size)
                             (cl-transforms:z ?object-size))
                          2)))
         ;; object pose to object transform
         (?object-transform (cl-tf:lookup-transform cram-tf:*transformer* "base_footprint" ?target-object));; (man-int::get-object-transform ?target-object))
         ;; rel pose to rel transform
         (?rel-pose-transform (cl-tf2::make-pose-stamped
                               "base_footprint" 0
                               ?relative-pour-pose
                               (cl-tf2::make-quaternion 0 0 0 1)))
         ;; moves the bowlpose like specified in ?relative-pour-pose, creating ?pour-pose-transform
         (?pour-pose-transform (cram-tf:apply-transform
                            (cl-tf:lookup-transform cram-tf:*transformer* "map" "base_footprint")
                            (cram-tf:apply-transform ?object-transform
                                                    (cram-tf:pose-stamped->transform-stamped
                                                     ?rel-pose-transform
                                                     "base_footprint"))))
         ;; pour transform to pour pose
         (?pour-pose (cram-tf:transform->pose-stamped
                       "map" 0
                       ?pour-pose-transform)))

    (let ((?height 0.2215)
          (?context `(("action" . "pouring"))))
      (exe:perform (desig:a motion
                            (type aligning-height)
                            (collision-mode ?collision-mode)
                            (goal-pose ?pour-pose)
                            (object-height ?height)
                            (object-name ?target-name))))

    (let ((?context `(("action" . "pouring"))))
      (exe:perform (desig:a motion
                            (type reaching)
                            (collision-mode ?collision-mode)
                            (goal-pose ?pour-pose)
                            (object-size ?object-size)
                            (object-name ?target-name)
                            (context ?context))))

    (exe:perform (desig:a motion
                          (type tilting)
                          (tilt-direction "right")
                          (tilt-angle 2.0d0)
                          (collision-mode ?collision-mode)))
                          

    (exe:perform (desig:a motion
                          (type tilting)
                          (tilt-angle 0.0d0)
                          (collision-mode ?collision-mode)))

    
    (exe:perform (desig:a motion
                        (type :retracting)
                        (collision-mode ?collision-mode)
                        (collision-object-b ?collision-object-b)
                        (collision-object-b-link ?collision-object-b-link)
                        (collision-object-a ?collision-object-a)))
    ))      

(defun sequence-goal (&key
                   ((:action ?action))
                   ((:motions ?motions))
                   ((:object-type ?object-type))
                   ((:goal-pose ?goal-pose))
                   ((:object-height ?object-height))
                   ((:object-size ?object-size))
                   ((:object-shape ?object-shape))
                   ((:object-name ?object-name))
                   ((:from-above ?from-above))
                   ((:target-object ?target-object))
                   ((:target-size ?target-size))
                   ((:target-name ?target-name))
                   ((:tilt-angle ?tilt-angle))
                   ((:reference-frame ?reference-frame))
                 &allow-other-keys)
  (let ((?motion-sequence          
           (mapcar (lambda (motion)
                     (let ((attribs (get-attributes motion))
                           (attr-list nil))
                       
                       (setf attr-list
                             (pairlis (mapcar (lambda (attr)
                                                (case attr
                                                  (:object-type "object_type")
                                                  (:goal-pose "goal_pose")
                                                  (:object-height "object_height")
                                                  (:object-size "object_size")
                                                  (:object-shape "object_shape")
                                                  (:object-name "object_name")
                                                  (:action "context")
                                                  (:target-object "target_object")
                                                  (:target-size "target_size")
                                                  (:target-name "target_name")
                                                  (:tilt-angle "tilt_angle")
                                                  (:reference-frame "reference_frame")))
                                              attribs)
                                      (mapcar (lambda (attr)
                                                (case attr
                                                  (:object-type ?object-type)
                                                  (:goal-pose `(("message_type" . "geometry_msgs/PoseStamped")
                                                                ("message" . ,(giskard::to-hash-table ?goal-pose))))
                                                  (:object-height  ?object-height)
                                                  (:object-size  `(("message_type" . "geometry_msgs/Vector3")
                                                                   ("message" . ,(giskard::to-hash-table ?object-size))))
                                                  (:object-shape  ?object-shape)
                                                  (:object-name ?object-name)
                                                  (:action (generate-context ?action :from-above ?from-above))
                                                  (:target-object ?target-object)
                                                  (:target-size ?target-size)
                                                  (:target-name ?target-name)
                                                  (:tilt-angle ?tilt-angle)
                                                  (:reference-frame ?reference-frame)))
                                              attribs)))

                         (case motion
                           (:aligning-height `("AlignHeight" . ,attr-list))
                           (:reaching `("Reaching" . ,attr-list))
                           (:lifting `("LiftObject" . ,attr-list))
                           (:retracting `("Retracting" . ,attr-list))
                           (:tilting `("Tilting" . ,attr-list)))))
                         
                   ?motions)))
    
    (print ?motion-sequence)
    (print "------------------")
    (print  (giskard::alist->json-string ?motion-sequence))
    ;;(break)
    (exe:perform (desig:a motion
                        (type :sequence-goal)
                        (collision-mode :allow-all)
                        (motion-sequence ?motion-sequence)))))

(defun take-pose (&key
                    ((:pose-keyword ?pose-keyword))
                    ((:head-pan ?head-pan))
                    ((:head-tilt ?head-tilt))
                    ((:arm-lift ?arm-lift))
                    ((:arm-flex ?arm-flex))
                    ((:arm-roll ?arm-roll))
                    ((:wrist-flex ?wrist-flex))
                    ((:wrist-roll ?wrist-roll))
                  &allow-other-keys)

  ;; example call
  ;; (exe:perform (desig:an action
  ;;                       (type taking-pose)
  ;;                       (pose-keyword nil)
  ;;                       (head-pan 0)
  ;;                       (head-tilt 0)
  ;;                       (arm-lift 0)
  ;;                       (arm-flex 0)
  ;;                       (arm-roll -1.5)
  ;;                       (wrist-flex -1.5)
  ;;                       (wrist-roll 0)))
  
  ;;added action just in case we want failurehandling later

  (exe:perform (desig:a motion
                        (type gripper-motion)
                        (:open-close :close)
                        (effort 0.1)))
  
  (exe:perform (desig:a motion
                        (type :taking-pose)
                        (collision-mode :allow-arm)
                        (pose-keyword ?pose-keyword)
                        (head-pan ?head-pan)
                        (head-tilt ?head-tilt)
                        (arm-lift ?arm-lift)
                        (arm-flex ?arm-flex)
                        (arm-roll ?arm-roll)
                        (wrist-flex ?wrist-flex)
                        (wrist-roll ?wrist-roll))))





;;;;;;;;;;;;;;;;;;;;; HELPER FUNCTIONS

(defun get-attributes (motion)
  (case motion
    (:aligning-height (list :action :goal-pose :object-height :object-name))
    (:reaching (list :action :goal-pose :object-size :object-name))
    (:lifting (list :object-name))
    (:retracting (list :object-name :reference-frame))
    (:tilting (list :tilt-angle))))
    
     

  
(defun generate-context (action &key from-above)
  (print "context")
  ;;(break)
  (let ((attr-list `(("action" . ,action))))
    (when from-above
      (setf attr-list (reverse (acons "from_above" from-above attr-list))))
    (print attr-list)))
