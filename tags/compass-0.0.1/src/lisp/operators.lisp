(defun gas-pockets (ctree &optional (magic-number 500))
  (if (and (and (null (node-right ctree)) (null (node-left ctree)))
	   (> 2 (length (node-contents ctree)))
	   (> (node-variance ctree) magic-number))
      (let ((separated (separate (node-contents ctree))))
	(setf (node-right ctree)
	      (make-node :contents (first separated)
			 :variance (variance (first separated))))
	(setf (node-left ctree)
	      (make-node :contents (second separated)
			 :variance (variance (first separated))))))
  (unless (null (node-right ctree)) 
    (gas-pockets (node-right ctree)))
  (unless (null (node-left ctree))
    (gas-pockets (node-left ctree)))
  ctree)
      
(defun binary-chop (ctree)
  "Find the highest variance leaf node and cut it in two"
  (let ((highest-variance 0)
	leaf-rep)
    (labels ((walk (cnode)
	       (if (and (null (node-right cnode)) (null (node-left cnode)))
		   (if (> (node-variance cnode) highest-variance)
		       (progn 
			 (setf highest-variance (node-variance cnode))
			 (setf leaf-rep cnode))))
	       (unless (null (node-right cnode))
		 (walk (node-right cnode)))
	       (unless (null (node-left cnode))
		 (walk (node-left cnode)))))
      (walk ctree))
    (print leaf-rep)
    (print highest-variance)
    (let ((separated (separate (node-contents leaf-rep))))
      (setf (node-right leaf-rep) (make-node :contents (first separated)
					     :variance (variance (first separated))))
      (setf (node-left leaf-rep) (make-node :contents (second separated)
					    :variance (variance (second separated)))))
    ctree))

(defun dismember (ctree k)
  (let ((compass-tree ctree))
    (dotimes (n k)
      (setf compass-tree (binary-chop compass-tree))))
  compass-tree)