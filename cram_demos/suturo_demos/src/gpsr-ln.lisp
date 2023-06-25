(in-package :su-demos)


(defparameter *list-of-plans*
  '(:fetch
    :deliver
    :search
    :navigate
    :transport
    :guide
    :count
    :follow
    :describe
    :greet
    :nlu_fallback)) 


(defun gpsr-subcribers()
  (nlplistener "NLPchatter")
  (planlistener "Planchatter")
  (hsrtospeak "hsrspeaker"))

(defvar *dialog-subscriber* nil)
(defvar *plan-subscriber* nil)
	
(defun planlistener (topic-name)
  (setf *dialog-subscriber* (roslisp:subscribe topic-name "gpsr_nlp/nlpCommands" #'subscriber-callback-function)))

;;;;;;;;;;;;;;;;;;;;;; 27 April
(defun nlplistener (topic-name)  
  (setf *plan-subscriber* (roslisp:subscribe topic-name "gpsr_nlp/nlpCommands" #'plan-callback-function)))


(defun plan-callback-function (message)
    
  (roslisp:with-fields (commands) message
    (let* ((?input commands)
           (?nlplistner-word (intern (string-upcase (aref ?input 0)) :keyword)))

      ;;(sleep 1)
      ;;(su-real:with-hsr-process-modules
      (when (eq ?nlplistner-word :DONE)        
        (navigate-to-location :nil :start-point);;; go to the initial position
        (cram-talker "DONE"))
      
      (when (eq ?nlplistner-word :START)
        (navigate-to-location :nil :start-point);;; go to the initial position
        (cram-talker "STARTING") 
        (print "GPSR starts"))
    
    (when (eq ?nlplistner-word :FAIL)
      (cram-talker "FAIL"))
		     
    (print ?nlplistner-word)
    ;;)
    )))

;;;;;;;;;;;;;;;;;;;;;;;;
(defun subscriber-callback-function (message)
  (roslisp:with-fields (commands) message
    (let* ((?test commands)
           (?plan (intern (string-upcase (aref *test* 0)) :keyword))
           (?objectname (intern (string-upcase (substitute #\- #\space (aref *test* 1))) :keyword))
           (?objecttype (intern (string-upcase (aref *test* 2)) :keyword))
           (?personname (intern (string-upcase (aref *test* 3)) :keyword))
           (?persontype (intern (string-upcase (aref *test* 4)) :keyword))
           (?attribute (intern (string-upcase (substitute #\- #\space (aref *test* 5))) :keyword))
           (?personaction (intern (string-upcase (substitute #\- #\space (aref *test* 6))) :keyword))
           (?color (intern (string-upcase (aref *test* 7)) :keyword))
           (?number (intern (string-upcase (aref *test* 8)) :keyword))
           (?fur-location1 (intern (string-upcase (substitute #\- #\space (aref *test* 9))) :keyword))
           (?fur-location2 (intern (string-upcase (substitute #\- #\space (aref *test* 10))) :keyword))
           (?room1 (intern (string-upcase (substitute #\- #\space (aref *test* 11))) :keyword))
           (?room2 (intern (string-upcase (substitute #\- #\space (aref *test* 12))) :keyword))

           ;;???
           (?previous-objectname nil)
           (?previous-objecttype nil)
           (?previous-personname nil)
           (?previous-personaction nil)
           (?previous-persontype nil)
           (?output nil))
           
      (print ?test)
      (cram-talker "plan")
      (dolist (?plan-type *list-of-plans*) ;;; find plans if it is present in the list or not (list of plans declared above)
        (when (eq ?plan-type ?plan)  ;;; TO DO Add condiation... if plan is not there in the list
          (print "plan found...")
          (sleep 1)
        
          ;;;; buffer knowledge.. 
          ;;;; buffer knowledge.. 
          (when (not (eq ?objectname :it))  ;;;; for buffer knowledege of previous object
            (setf ?previous-objectname ?objectname)
            (setf ?previous-objecttype ?objecttype))
          
          (when (eq (check-person-pronoun ?persontype) T)
            (setf ?previous-personname ?personname)
            (setf ?previous-personaction ?personaction)
            (setf ?previous-persontype ?persontype))
		
   ;;;;; Actions
 ;(su-real:with-hsr-process-modules

          (when (eq ?plan :navigate)
            (print "Performing navigation ...")
            ;;(setf ?output (naviagte-to-location *fur-location1* *room1*)) ;;; location-in-room or room 
            (setf ?output (navigate-to-location ?fur-location1 ?room1))
            (print "Navigation Plan Done ...")
            (cram-talker ?output))
          
          (when (eq ?plan :search)
            (print "Performing searching ...") ;; search for object/person on furniture/in a room
            (setf ?output (searching-object ?objectname ?personname ?persontype ?personaction ?fur-location1 ?room1)) 
            (print "searching Plan Done ...")
            (cram-talker ?output))
          
          (when (eq ?plan :fetch)
            (print "Performing fetching ...")
            (setf ?output (fetching-object ?objectname ?objecttype ?attribute ?fur-location1 ?room1)) ;; 14jn
            (print "Fetching Plan Done ...")
            (cram-talker ?output))

          (when (eq ?plan :deliver)
            (print "Performing delivering ...") ;;; deliver object to location/person
            (setf ?output (delivering-object ?objectname ?fur-location1 ?room1 (get-any-person-feature ?personname ?persontype ?personaction)))
            (print "Delivering Plan Done ...")
            (cram-talker ?output))
			
	    		
          (when (eq ?plan :transport)
            (print "Performing transport ...")
            (setf ?output (transporting-object ?objectname ?objecttype ?attribute ?room1 ?fur-location1 ?room2 ?fur-location2 ?personname ?persontype ?personaction)) ;;; person or second location/room
            (print "Transport Plan Done ...")
            (cram-talker ?output))
	    		
          (when (eq ?plan :guide)
            (print "Performing guiding ...")
            (setf ?output (guide-people ?personname ?room1 ?fur-location1)) ;; room or location
            (print "Guiding Plan Done ...")
            (cram-talker ?output))
          
          (when (eq ?plan :follow)
            (print "Performing following ...")
            (setf ?output (follow-people ?personname ?persontype ?personaction ?room1 ?fur-location1)) ;; room or locaion
            (print "Following Plan Done ...")
            (cram-talker ?output))
			
          (when (eq ?plan :count)
            (print "Performing following ...")
            (setf ?output (count-object-people ?objectname ?objecttype ?attribute ?personname ?persontype ?personaction ?room1 ?fur-location1)) ;; room or location
            (print "Following Plan Done ...")
            (cram-talker ?output))
          
          (when (eq ?plan :describe)
            (print "Performing following ...")
            (setf ?output (describe-something ?objectname ?objecttype ?attribute ?personname ?persontype ?personaction ?room1 ?fur-location1)) ;; room or location
            (print "Following Plan Done ...")
            (cram-talker ?output))
  			
          (when (eq ?plan :greet)
            (print "Performing following ...")
            (setf ?output (greet-person ?personname ?persontype ?personaction ?room1 ?fur-location1)) ;; room or location
            (print "Following Plan Done ...")
            (cram-talker ?output))
			
          (when (eq ?plan :nlu_fallback)
            (print "No plan foud ...")
            (cram-talker "fail"))
          )))))






