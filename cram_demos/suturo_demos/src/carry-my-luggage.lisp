(in-package :su-demos)

;; @author Vanessa Hassouna

(defun cml-demo (&key (step 0) (talk T))
    (when (<= step 0)
      (talk-request "Hey, I am Toya i will help you to carry your Luggage.
I will now park myself." talk)
      (park-robot)
      (talk-request "Please step in front of me so I can recognize you" talk)
      ;;start seeing human nice
      ;;following his track
      ;;...
      ))
