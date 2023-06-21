(in-package :su-demos)

;; @author Tim Rienits
;;
;; Perceives and picks up items from a table and places them inside a diswasher object in the urdf file.
;; Thereafter, it places the dishwasher tab inside as well.
;;
(defun clean-the-table-demo ()

  ;; Initialize all variables, destionation poses are hardcoded for now.
  (let ((table "left_table:table:table_front_edge_center")
  ;;       (dishwasher "imaginary_dishwasher:dishwasher_tray_2_bottom")
  ;;       (?object-height-cutlery 0.23d0)
  ;;       (?object-height 0.25d0)
  ;;       (?spoon-pose (cl-tf:make-pose-stamped "map" 0.0  (cl-tf:make-3d-vector 1.3 1.64 0.22) (cl-tf:make-quaternion 0 0 0 1)))
  ;;       (?fork-pose (cl-tf:make-pose-stamped "map" 0.0  (cl-tf:make-3d-vector 1.32 1.64 0.22) (cl-tf:make-quaternion 0 0 0 1)))
  ;;       (?knife-pose (cl-tf:make-pose-stamped "map" 0.0  (cl-tf:make-3d-vector 1.34 1.64 0.22) (cl-tf:make-quaternion 0 0 0 1)))
  ;;       (?plate-pose (cl-tf:make-pose-stamped "map" 0.0  (cl-tf:make-3d-vector 1.2 1.35 0.22) (cl-tf:make-quaternion 0 0 0 1)))
  ;;       (?mug-pose (cl-tf:make-pose-stamped "map" 0.0  (cl-tf:make-3d-vector 1.3 1.33 0.22) (cl-tf:make-quaternion 0 0 0 1)))
  ;;       (?bowl-pose (cl-tf:make-pose-stamped "map" 0.0  (cl-tf:make-3d-vector 1.2 1.51 0.22) (cl-tf:make-quaternion 0 0 0 1)))
  ;;       (?tab-pose (cl-tf:make-pose-stamped "map" 0.0  (cl-tf:make-3d-vector 1.33 1.4 0.22) (cl-tf:make-quaternion 0 0 0 1))))
  )
  ;;   ;; Puts the HSR into its default pose.
     ;;(park-robot)

    ;;   ;; Move to table to perceive objects.
    ;;todo this pose is still bad
     ;;(urdf-move-to table)

  ;;   ;; Puts the HSR into a pose which is suited to perceive objects.
  ;;   (perc-robot)

  ;; Perceives the objects on the table, saves them in a list.
  (let* ((?source-object-desig (desig:all object (type :everything)))
         
         (?list-of-objects
           (exe:perform (desig:all action
                                   (type detecting)
                                   (object ?source-object-desig))))
        ) 
 
    )))




(defun extract-percept-msg-obj-type-to-string (?list-of-objects)
   (mapcar (lambda (percept-object)
                     (roslisp:with-fields
                         ((description
                           (cram-designators:description)))
                         percept-object
                       (cl::write-to-string
                        (second
                         (second description)))))
                   ?list-of-objects))










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

  
