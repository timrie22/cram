;;;
;;; Copyright (c) 2022, Arthur Niedzwiecki <aniedz@cs.uni-bremen.de>
;;; Copyright (c) 2023, Vanessa Hassouna <hassouna@cs.uni-bremen.de>
;;; All rights reserved.
;;;
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions are met:
;;;
;;;     * Redistributions of source code must retain the above copyright
;;;       notice, this list of conditions and the following disclaimer.
;;;     * Redistributions in binary form must reproduce the above copyright
;;;       notice, this list of conditions and the following disclaimer in the
;;;       documentation and/or other materials provided with the distribution.
;;;     * Neither the name of the Institute for Artificial Intelligence/
;;;       Universitaet Bremen nor the names of its contributors may be used to
;;;       endorse or promote products derived from this software without
;;;       specific prior written permission.
;;;
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
;;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;;; POSSIBILITY OF SUCH DAMAGE.

(in-package :hsr-sim-pms)

(defun grip (which-gripper action-type &key max-effort)
  T)

(cpm:def-process-module empty-gripper-pm (motion-designator)
  (destructuring-bind (command action-type which-gripper &optional max-effort)
      (desig:reference motion-designator)
    (ecase command
      (cram-common-designators:move-gripper-joint
       (grip which-gripper action-type :max-effort max-effort)))))

(prolog:def-fact-group empty-gripper-pm (cpm:matching-process-module
                                         cpm:available-process-module)

  (prolog:<- (cpm:matching-process-module ?motion-designator empty-gripper-pm)
    (or (desig:desig-prop ?motion-designator (:type :gripping))
        (desig:desig-prop ?motion-designator (:type :moving-gripper-joint))
        (desig:desig-prop ?motion-designator (:type :opening-gripper))
        (desig:desig-prop ?motion-designator (:type :closing-gripper))))

  (prolog:<- (cpm:available-process-module ?pm)
    (prolog:bound ?pm)
    (prolog:once (prolog:member ?pm (empty-gripper-pm)))
    (prolog:not (cpm:projection-running ?_))))
