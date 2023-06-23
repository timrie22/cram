(in-package :su-demos)

; Perceives and picks up items from a table and places them inside a diswasher object in the urdf file.
;; Thereafter, it places the dishwasher tab inside as well.
;;
(defun clean-the-table-demo (&key (step 0) (talk T) (break nil))
                                        ;(when (<= step 0)
  (with-knowledge-result ()
      `("reset_user_data"))

  (with-knowledge-result ()
      `("init_clean_the_table_no_dishwasher"))
  (with-knowledge-result (table popcorntable)
      `(and ("has_urdf_name" object1 "left_table:table:table_front_edge_center")
            ("object_rel_pose" object1 "perceive" table)
            ("has_urdf_name" object2 "kitchen_table:table:table_front_edge_center")
            ("object_rel_pose" object2 "perceive" popcorntable))
    (talk-request "Hello I am Toya, i will now clean the table!" talk)
    ;;alwas park the robot before anything, so arm is not in the way
    (park-robot)
    (let* ((?source-object-desig nil)
           (?object-desig nil)
           (?current-object nil)
           (?found-metalmug nil)
           (?current-object-spoon nil)
           (?found-fork nil)
           (?found-knife nil)
           (?found-plasticknife nil)
           (?found-bowl nil)
           (?found-metalplate nil)
           (?current-object-from-above nil))

      ;;move to table
      (when (<= step 1)
        (talk-request "I will now move!" talk)
        (move-hsr (make-pose-stamped-from-knowledge-result table))
        (perc-robot))
      ;;perceive  and set 
      (when (<= step 2)
        (talk-request "I am now perceiving!" talk)
        (setf ?source-object-desig
              (desig:all object
                         (type :everything)))
        (setf ?object-desig
              (exe:perform (desig:an action
                                     (type detecting)
                                     (object ?source-object-desig)))))
      (when (<= step 3)
        (with-knowledge-result (nextobject)
            `("next_object" nextobject)

          (when break (break))
          
          
          (loop until (string= nextobject "I")
                do
                    (talk-request "I will now move!" talk)
                    (move-hsr (make-pose-stamped-from-knowledge-result table))
                   ;;set next object and current object
                   (let* ((?target-pose (get-target-pos-clean-up nextobject)))
                     (with-knowledge-result (result)
                         `("next_object" result)
                       (setf ?current-object nextobject)
                       (setf nextobject result))
                     
                     (print "1 ----loop and nextobject: ")
                     (print ?current-object)
                     (print nextobject)
                     
                     (when break (break))
                     
                     (with-knowledge-result (frame pose)
                         `(and ("object_shape_workaround" ,?current-object frame _ _ _)
                               ("object_pose" ,?current-object pose))
                            
                            ;;get object size (hardcoded) and object pose
                            ;;get target size comes from serve-breakfast...
                            (let ((?object-size (get-target-size ?current-object))
                                  (?object-pose nil)
                                  (?small-object-case (or (search "Fork" ?current-object)
                                                          (search "Spoon" ?current-object)
                                                          (search "PlasticKnife" ?current-object)
                                                          (search "Knife" ?current-object)
                                                          (search "Bowl" ?current-object))))
                              ;;but tricky trick, set bowl pose different and smallies ;;hardcoded stuff
                              (cond
                                ((search "Bowl" ?current-object)
                                 ;;bowl i moved to the y side to be able to grasp
                                 (setf ?object-pose
                                       (make-pose-stamped-from-knowledge-result-for-bowl pose)))
                                (?small-object-case
                                 (setf ?object-pose
                                       (make-pose-stamped-from-knowledge-result-for-smallies pose)))
                                (t
                                 (setf ?object-pose
                                       (make-pose-stamped-from-knowledge-result pose))))
                                 ;;true or nil depending on our let above
                              (setf ?current-object-from-above ?small-object-case)

                              (if (search "MetalPlate" ?current-object)
                                  (human-assist talk)
                                  (progn
                                    ;;pick up object
                                    ;;care from my site atm no failure handling failure handling should only be disabled when from-above
                                    ;; (let ((text-string (concatenate 'string "I will now pick-up: " (cl:write-to-string ?current-object))))
                                    (talk-request "I will now pick-up:" talk)

                                        ;(print (concatenate 'string "object-pose" ?object-pose))
                                        ;(print (concatenate 'string "object-size" ?object-size))
                                        ;(print (concatenate 'string "current-object-from-above" ?current-object-from-above))
                                    
                                    (when break (break))
                                    
                                    (exe:perform (desig:an action
                                                           (type picking-up)
                                                           (goal-pose ?object-pose)
                                                           (object-size ?object-size)
                                                           (from-above ?current-object-from-above)
                                                           (collision-mode :allow-all)))
                                    (park-robot)))
                              
                              
                              
                              (talk-request "I will now move, please be care!" talk)
                              ;; Calls knowledge to receive coordinates of the dinner table pose, then relays that pose to navigation
                              (move-hsr (make-pose-stamped-from-knowledge-result popcorntable))
                              
                              ;; places the object by executing the following motions:
                              ;; - preparing to place the object, by lifting the arm to an appropriate ?object
                              ;; - placing the object
                              ;; - opening the gripper, thus releasing the object

                              (talk-request "I will now place, please be care!" talk)
                              ;; ?frontal-placing and ?neatly are currently the same for each object, thats why i just use the same function until after the milestone
                              (print ?target-pose)
                              (break)
                              (exe:perform (desig:an action
                                                     (type :placing)
                                                     (goal-pose ?target-pose)
                                                     (object-size ?object-size)
                                                     (from-above t)
                                                     (neatly nil)
                                                     (collision-mode :allow-all)))
                              (park-robot)
                              )))))))))

(defun get-target-pos-clean-up (obj-name)
  ;;todo delete bowl out of here i think idk hehe
  ;; (when (or (search "Fork" obj-name)
  ;;           (search "Spoon" obj-name)
  ;;           (search "PlasticKnife" obj-name)
  ;;           (search "Knife" obj-name)
  ;;           (search "Bowl" obj-name))
    (cl-tf2::make-pose-stamped "map" 0
                               (cl-tf2::make-3d-vector 0.20 0.8 0.75)
                               (cl-tf2::make-quaternion 0 0 0 1)))

        ;))))))))))))
;; (let ((table "left_table:table:table_front_edge_center")

;;       ;;empty list will be filled with objects
;;       (list-of-objects-found (list ))
;;       ;;special cases cause vanessa is to lazy to use knowledge
;;       (found-plate nil)
;;       (found-mug nil))
;;   ;;   ;; Puts the HSR into its default pose.
;;   (when (<= step 0)
;;     (talk-request "Hey, I am Toya i will now clean up the table" talk)
;;     (talk-request "I will now drive to the Table" talk)
;;     (park-robot)

;;     ;; Move to table to perceive objects.
;;     (urdf-move-to table)

;;     ;; Puts the HSR into a pose which is suited to perceive objects.
;;     (perc-robot))

;;   (when (<= step 1)
;;     (talk-request "I am now perceiving" talk)
;;     ;; Perceives the objects on the table, saves them in a list.
;;     (let* ((?source-object-desig (desig:all object (type :everything)))
;;            (?list-of-objects
;;              (exe:perform (desig:all action
;;                                      (type detecting)
;;                                      (object ?source-object-desig)))))
;;       ;;extracting the msg to objects-types and makes a list out of it
;;       (setf list-of-objects-found
;;             (extract-percept-msg-obj-type-to-string ?list-of-objects)))

;;     (talk-request  "I found the following items: " talk)

;;     ;;loop over the list of items, setf if special case like plate or cup appears
;;     (mapcar (lambda (object)
;;               (progn
;;                 (talk-request object talk)
;;                 (when (search "PLATE" object)
;;                   (setf found-plate t))
;;                 (when (search "MUG" object)
;;                   (setf found-mug t))))
;;             list-of-objects-found))

;;   (when (<= step 2)
;;     (when found-mug
;;       (talk-request  "I will try to grasp the cup" talk)
;;       (let ((?mug-pose
;;               (create-pose (with-knowledge-result (pose)
;;                                `(and ("has_type" objname ,(su-demos::transform-key-to-string :metalmug))
;;                                      ("object_pose" objname pose))
;;                              pose)))
;;             (?object-size (get-target-size "Mug")))
;;         (exe:perform (desig:an action
;;                                (type picking-up)
;;                                (goal-pose ?mug-pose)
;;                                (object-size ?object-size)
;;                                (collision-mode :allow-all)))
;;         )))))

;; (when (<= step 2)
;;       ;;human assist first time, will call for plate if found
;;       (human-assist "I will need some help from the human,i will now move my arm, please be care: "
;;                     talk found-plate found-cup)
;;       ;;put stuff on plate please human
;;       (when found-plate
;;         (talk-request  "Now i have a special request:
;; Please put all the small items safely on the plate.
;; When you are done poke the white part of my hand." talk)
;;         ;;monitoring to know when human is done
;;         ;;TO-DO: change the joint?
;;         (exe:perform
;;          (desig:an action
;;                    (type monitoring-joint-state)
;;                    (joint-name "wrist_flex_joint")))))

;;     (when (<= step 3))
;;     ;;move to tray
;;     ;;place
;;     ;;repeat step 0 (perceive....)
;;     ;;end
;;     ))












;; ;; Get and place spoon.
;; (park-robot)

;;(urdf-move-to dishwasher)

;; ;; Robot opens its hand so an object can be given to it.
;; (wait-for-human-signal)

;; (su-place ?spoon-pose ?object-height-cutlery)

;; ;; Create the Object (being inside the Dishwasher now) using knowledge.
;; (create-knowledge-object :spoon ?spoon-pose)

;; ;; Get and place fork.
;; (park-robot)

;; (urdf-move-to dishwasher)

;; (wait-for-human-signal)

;; (su-place ?fork-pose ?object-height-cutlery)

;; (create-knowledge-object :fork ?fork-pose)

;; ;; Get and place knife.
;; (park-robot)

;; (urdf-move-to dishwasher)

;; (wait-for-human-signal)

;; (su-place ?knife-pose ?object-height-cutlery)

;; (create-knowledge-object :knife ?knife-pose)

;; ;; Get and place metalplate.
;; (park-robot)

;; (urdf-move-to dishwasher)

;; (wait-for-human-signal)

;; (su-place ?plate-pose ?object-height-cutlery)

;; (create-knowledge-object :metalplate ?plate-pose)

;; ;; Get and place bowl.
;; (park-robot)

;; (urdf-move-to dishwasher)

;; (wait-for-human-signal)

;; (su-place ?bowl-pose ?object-height-cutlery)

;; (create-knowledge-object :bowl ?bowl-pose)

;; ;; Get and place mug.
;; (park-robot)

;; (urdf-move-to dishwasher)

;; (wait-for-human-signal)

;; (su-place ?mug-pose ?object-height-cutlery)

;; (create-knowledge-object :metalmug ?mug-pose)

;; (print "I finished putting all the items inside the dishwasher. Will now put the dishwasher tab inside.")

;; ;; Get and place tab.
;; (park-robot)

;; (urdf-move-to dishwasher)

;; (wait-for-human-signal)

;; (su-place ?tab-pose ?object-height-cutlery)

;; (create-knowledge-object :dishwashertab ?tab-pose)

;; (park-robot)

;; (print "Placed the dishwasher tab inside. Demo finished."))))



;;@author Tim Rienits
;;
;; Uses an action Designator to pick up an object.
;;
;; ?pose - The pose of the object to be picked up.
;;
;; ?size - The size of the object to be picked up.
;;
(defun su-pick-up (?pose ?size)
   (exe:perform (desig:an action
                          (type picking-up)
                          (object-pose ?pose)
                          (object-size ?size)
                          (collision-mode :allow-all)))

  )

;;@author Tim Rienits
;;
;; Uses an action Designator to place an object.
;;
;; ?pose - The pose where the object should be placed.
;;
;; ?height - The height of the object to be placed.
;;
(defun su-place (?pose ?height)
    (exe:perform (desig:an action
                           (type :placing)
                           (target-pose ?pose)
                           (object-height ?height)
                           (frontal-placing NIL)
                           (collision-mode :allow-all)))

  )

;;@author Felix Krause
;; Extracts the pose from an Object Designator.
(defun extract-pose (object)
  (roslisp:with-fields 
      ((?pose
        (cram-designators::pose cram-designators:data))) 
      object    
    ?pose))

;;@author Felix Krause
(defun extract-type (object)
  (roslisp:with-fields 
      ((?type
        (cram-designators::object-identifier cram-designators:data))) 
      object    
     (intern (string-trim "-1" ?type) :keyword)))

;;@author Tim Rienits
;; The hardcoded poses, where objects are to be placed into the dishwasher.
(defun get-hardcoded-place-poses ()
  (list (cl-tf:make-pose-stamped "map" 0.0  (cl-tf:make-3d-vector 1.18 1.3 0.22) (cl-tf:make-quaternion 0 0 0 1))
        (cl-tf:make-pose-stamped "map" 0.0  (cl-tf:make-3d-vector 1.18 1.5 0.22) (cl-tf:make-quaternion 0 0 0 1))
        (cl-tf:make-pose-stamped "map" 0.0  (cl-tf:make-3d-vector 1.18 1.7 0.22) (cl-tf:make-quaternion 0 0 0 1))))

;;@author Tim Rienits
;; The hardcoded poses, where objects are to be placed into the dishwasher.
(defun get-object-types ()
  (list :spoon :fork :knife))

;;@author Tim Rienits
;; The hardcoded pose where the dishwasher tab should be placed.
(defun get-hardcoded-tab-pose ()
  (cl-tf:make-pose-stamped "map" 0.0  (cl-tf:make-3d-vector 1.2 1.3 0.2) (cl-tf:make-quaternion 0 0 0 1)))


;;@author Tim Rienits
;; Moves the HSR to urdf-object by querying the pose of it in Knowledge.
(defun urdf-move-to (urdf-object)
  
 (with-knowledge-result (result)
        `(and ("has_urdf_name" object ,urdf-object)
              ("object_rel_pose" object "perceive" result))
      (move-hsr (make-pose-stamped-from-knowledge-result result)))
  )

;;@author Tim Rienits
;; Moves the HSR to urdf-object by querying the pose of it in Knowledge.
(defun create-knowledge-object (?type ?pose)
  
 (with-knowledge-result (name)
          `("create_object" name ,(transform-key-to-string ?type)  ;;TODO Extract keyword
                            ,(reformat-stamped-pose-for-knowledge ?pose)
                            (list ("shape" ("box" 0.145 0.06 0.22)))))
  )

;;@author Tim Rienits
(defun get-next-object-clean-the-table ()
  (with-knowledge-result (result)
      `("next_object" result)
    result))

;;@author Tim Rienits
;; Tests if object is cutlery (spoon, fork, knife) and instead of picking it up, it gets it handed instead.
(defun do-you-even-cutlery (object)
  
  (when (or (equal (extract-type object) :spoon)
            (equal (extract-type object) :fork)
            (equal (extract-type object) :knife))

    (wait-for-human-signal)

    )
  )

  
