(defun variance (these)
  (if (= (length these) 0)
      0
      (if (= (length these) 1)
	  (first (last (first these)))
	  (let* ((classes (mapcar #'first (mapcar #'last these)))
		 (n (make-normal-from-list classes)))
	    (stdev n)))))


;(let ((n (make-normal-from-list these)))
; (stdev n)))
; For effort instances pass (mapcar #'first (mapcar #'last these))