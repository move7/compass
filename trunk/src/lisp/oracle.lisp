(defun data-oracle (data &key (s 2) (m 4) (a 1) (b 1) (c 1) (d 1)
		    (min-cluster-size 4) (printing? nil) (reorders 20) (era0 3) 
		    (datfile "file.dat") (plotfile "file.plot"))
  (let* ((data (shuffle-n data reorders))
	 ;; Build a compass tree with the first half of the data to
	 ;; serve as the oracle.
	 (compass-oracle (variance-prune
			  (compass (first-half data)
				   :distance-func 'euclidean-distance)
			  :alpha 1.1 :beta 1.1))

	 ;; Use the second half as the incoming data.
	 (data (second-half data))
	 (eras (era data :n 5)) ;; Which era size is best?

	 ;; The first X eras will be used to make an initial compass
	 ;; tree.
	 (compass-tree (compass (condense-lists (subseq eras 0 era0))
				:distance-func 'euclidean-distance))

	 ;; Remove the starter eras from the list of eras.
	 (eras (subseq eras era0))
	 mdmres
	 maxvs
	 points
	 everything)

    ;; Incremental insertion procedure which puts each new instance
    ;; where it belongs in the scheme of things.
    (labels ((insert (c-node instance)
	       ;; Put the new instance into c-node's contents.
	       (setf (node-contents c-node)
		     (push instance (node-contents c-node)))
	       ;; Update variance.
	       (setf (node-variance c-node)
		     (variance (node-contents c-node)))
	       ;; Determine which child the new instance belongs to,
	       ;; if c-node has children at all.
	       (if (and (null (node-right c-node)) (null (node-left c-node)))
		   ;; c-node has no children, return with what we've got.
		   (return-from insert)
		   (if (or (null (node-right c-node)) (null (node-left c-node)))
		       (if (null (node-right c-node))
			   (insert (node-left c-node) instance)
			   (insert (node-right c-node) instance))
		       ;; Node has two children, so decide
		       ;; which to give the new child.
		       (if (> (euclidean-distance
			       instance
			       (centroid (node-contents (node-right c-node))))
			      (euclidean-distance
			       instance
			       (centroid (node-contents (node-left c-node)))))
			   (insert (node-left c-node) instance)
			   (insert (node-right c-node) instance)))))
	     (insert-via-class (c-node instance class)
	       ;; Put the new instance into c-node's contents.
	       (setf (node-contents c-node)
		     (push instance (node-contents c-node)))
	       ;; Update variance.
	       (setf (node-variance c-node)
		     (variance (node-contents c-node)))
	       ;; Determine which child the new instance belongs to
	       ;; using class information, if c-node has children at
	       ;; all.
	       (if (and (null (node-right c-node)) (null (node-left c-node)))
		   (return-from insert-via-class)
		   (if (or (null (node-right c-node)) (null (node-left c-node)))
		       (if (null (node-right c-node))
			   (insert-via-class (node-left c-node) instance class)
			   (insert-via-class (node-right c-node) instance class))
		       ;; Node has two children, so decide which to
		       ;; give the new child.
		       (if (> (abs (- class (median
					     (mapcar #'first
						     (mapcar #'last
							     (node-contents (node-right c-node)))))))
			      (abs (- class (median
					     (mapcar #'first
						     (mapcar #'last
							     (node-contents (node-left c-node))))))))
			   (insert-via-class (node-left c-node) instance class)
			   (insert-via-class (node-right c-node) instance class)))))
	     ) ;; End labels definitions.

      ;; Walk through each era, while slowly building a second compass
      ;; tree. Once per era, greedily pick the most interesting one,
      ;; label it using the first compass tree and reposition it.

      (dolist (this-era eras)
	;; Push the whole era into the tree.
	(dolist (instance this-era)
	  (insert compass-tree instance))
	;; Using some heuristic within, find some interesting
	;; instances to classify (magic number) and then place them
	;; once we have the class information.
	(dolist (instance (devious-instances-2 compass-tree s m))
	  (remove-from-tree instance compass-tree)
	  (insert-via-class compass-tree instance (compass-teak-prebuilt instance compass-oracle)))
	;; Seems like we should attack high variance leaves as well...
	;; What I'm doing here is re-compassing the highest 50% of
	;; leaves with high variance.
;	(setf compass-tree (variance-prune compass-tree :alpha 1.1 :beta 1.1))
	(push (max-variance compass-tree) maxvs)
	(setf compass-tree (variance-prune compass-tree :alpha 1.1 :beta 1.1 :maxvs maxvs))
	(setf compass-tree (re-compass compass-tree))
	(if (< (position this-era eras) (1- (length eras)))
	    (let ((test-era (nth (1+ (position this-era eras)) eras)))
	      (push (test-era-on-tree test-era compass-tree) mdmres)))
	)
      (if printing?
	  (progn
	    (with-open-file (stream datfile
				    :direction :output
				    :if-exists :supersede
				    :if-does-not-exist :create )
	      (setf mdmres (reverse (copy-list mdmres)))
	      (let ((counter 0))
		(dolist (mdmre mdmres)
		  (format stream "~A ~A~%"
			  (1+ counter) mdmre)
		  (push (make-point :x (1+ counter) :y mdmre) points)
		  (setf counter (1+ counter)))))
	    (with-open-file (stream plotfile
				    :direction :output
				    :if-exists :supersede
				    :if-does-not-exist :create )
	      (format stream "set terminal png~%")
	      (format stream "set output '~A.png'~%" datfile)
	      (format stream "set title 'Nasa93 A:~5,2f B: ~5,2f C: ~5,2f D:~5,2f'~%" a b c d)
	      (format stream "set xlabel 'ERA'~%")
	      (format stream "set ylabel 'MDMRE'~%")
	      (format stream "set xrange [0:~A]~%" (length eras))
	      (format stream "set yrange [0:~A]~%" (ceiling (max (first mdmres))))
	      (format stream "set xtics 1~%")
	      (format stream "set ytics 5~%")
	      (format stream "plot '~A' notitle  with linespoints lt 3 lw 4 pt 7~%" datfile))
	    (format t "~A,~A,~A,~A,~A~%" a b c d (auc points))
;	      (if (> (first mdmres) (first (last mdmres)))
;		  (format t "IMROVED BY: ~A~%" (- (first mdmres) (first (last mdmres))))
;		  (format t "WORSENED BY: ~A~%" (- (first (last mdmres)) (first mdmres))))
	      ))
      (strip-danglers compass-tree))))

(defun test-era-on-tree (era ctree)
  "Return the MDMRE for testing this era against this compass-tree."
  (let (mres)
    (dolist (instance era)
      (push (compass-teak-prebuilt instance ctree) mres))
    (median mres)))

(defun devious-instances (ctree-node)
  "Find some interesting instances from the current compass tree and
   put them in the naughty-list."
  (let ((magic-number (sqrt (max-variance ctree-node)))
	naughty-list)
    (labels ((walk (c-node)
	       (if (and (not (null (node-right c-node)))
			(not (null (node-left c-node))))
		   (if (< (abs (- (node-variance (node-right c-node))
				  (node-variance (node-left c-node))))
			  magic-number)
		       (progn; (format t "RV ~5,2f LV ~5,2f :: RM ~5,2f vs LM ~5,2f~%"
				;      (node-variance (node-right c-node))
				 ;     (node-variance (node-left c-node))
				  ;    (median (mapcar #'first (mapcar #'last (node-contents (node-right c-node)))))
				   ;   (median (mapcar #'first (mapcar #'last (node-contents (node-left c-node))))))
			     ; (format t "~A~%" (centroid (condense-lists (list (node-contents (node-right c-node)) (node-contents (node-left c-node))))))
			      (push (centroid (condense-lists (list (node-contents (node-right c-node)) (node-contents (node-left c-node))))) naughty-list))))
	       (unless (null (node-right c-node))
		 (walk (node-right c-node)))
	       (unless (null (node-left c-node))
		 (walk (node-left c-node)))))
      (walk ctree-node))
    naughty-list))

(defun devious-instances-2 (ctree-node &optional (s 2) (m 4) (a 1) (b 1) (c 1) (d 1))
  (let* ((sibling-pairs (all-sibling-pairs ctree-node))
	 (ranked (sort-ranked-pairs (rank-pairs sibling-pairs a b c d)))
	 naughty-list)
    (dotimes (n s)
      (let ((pair (condense-lists (extract-max-pair ranked))))
	(dotimes (j m)
	  (let ((c (centroid pair)))
	    (setf pair (remove c (copy-list pair)))
	    (push c naughty-list)))))
    (remove nil naughty-list)))

(defun devious-instances-3 (ctree-node &optional (s 2) (m 4))
  (let ((sibling-pairs (all-sibling-pairs ctree-node))
	randomly-selected-pairs
	naughty-list)
    (dotimes (i s)
      (let ((pair (random-element sibling-pairs)))
	(setf sibling-pairs (remove pair (copy-list sibling-pairs)))
	(push (condense-lists pair) randomly-selected-pairs)))
    (dolist (pair randomly-selected-pairs)
      (dotimes (j m)
	(let ((instance (random-element pair)))
	  (setf pair (remove instance (copy-list pair)))
	  (push instance naughty-list))))
    naughty-list))
	
(defun generate-instances (this that n)
  "Give me n instances between this and that."
  (let (new-instances)
    (dotimes (i n)
      (push (favored-median this that (my-random-int n) (my-random-int n)) new-instances))
    new-instances))

(defun extract-max-pair (ranked)
  (let ((max-rank 0) max-pair)
    (dohash (key value ranked)
      (if (< max-rank value)
	  (progn (setf max-rank value)
		 (setf max-pair key))))
    (remhash max-pair ranked)
    max-pair))

(defun all-sibling-pairs (ctree-node)
  (let (pairs)
    (labels ((walk (c-node)
	       (if (has-both-children c-node)
		   (push (list (node-contents (node-right c-node))
			       (node-contents (node-left c-node))) pairs))
	       (unless (null (node-left c-node))
		 (walk (node-left c-node)))
	       (unless (null (node-right c-node))
		 (walk (node-right c-node)))))
      (walk ctree-node))
    pairs))

(defun rank-pairs (pairs &optional (a 1) (b 1) (c 1) (d 1)) ;; Magical tuning constants
  (let ((ranked (make-hash-table)))
    (dolist (pair pairs)
      (if (null (gethash pair ranked))
	  (setf (gethash pair ranked)
		(/ (sqrt (+ (* a (expt (- (median (map-last (first pair)))
					  (median (map-last (second pair)))) 2))
			    (* b (expt (1- (/ (+ (variance (first pair))
						 (variance (second pair))) 2)) 2))
			    (* c (expt (/ (+ (length (first pair))
					     (length (second pair))) 2) 2))
			    (* d (expt (intra-cluster-measure pair) 2))))
		   (sqrt 4)))))
    ranked))

(defun sort-ranked-pairs (ranked)
  (let ((sum-of-all-r 0))
    (dohash (key value ranked)
      (setf sum-of-all-r (+ sum-of-all-r value)))
    (dohash (key value ranked)
      (setf (gethash key ranked) (/ value sum-of-all-r))))
  ranked)

(defun map-last (l)
  (mapcar #'first (mapcar #'last l)))

(defun has-both-children (c-node)
  (if (and (not (null (node-right c-node)))
	   (not (null (node-left c-node))))
      T
      nil))

(defun remove-from-tree (instance ctree-node)
  "Walk the path from root to leaf in which this instance resides and
   delete it at each step."
  (labels ((walk (c-node)
	     (if (= (length (node-contents c-node)) 1)
		 (setf c-node nil)
		 (progn
		   ;(print instance)
		   ;(print c-node)
		   (setf (node-contents c-node) (remove instance (node-contents c-node)))
		   (setf (node-variance c-node) (variance (node-contents c-node)))))
	     (unless (null c-node)
	       (unless (null (node-right c-node))
		 (if (member instance (node-contents (node-right c-node)))
		     (walk (node-right c-node))))
	       (unless (null (node-left c-node))
		 (if (member instance (node-contents (node-left c-node)))
		     (walk (node-left c-node)))))))
    (walk ctree-node))
  ctree-node)

;(defun re-compass (ctree-node)
;  (let ((maxv (max-leaf-variance ctree-node))
;	(maxs (max-leaf-size ctree-node))
;	(sv (first-half (sorted-leaf-variance ctree-node)))
;	(preverse (copy-node ctree-node)))
;    (labels ((walk (c-node)
;	       ;; Based on difference in children variance.
;	       (if (and
;		    (and (not (null (node-right c-node)))
;			 (not (null (node-left c-node))))
;		    (> (abs (- (node-variance (node-left c-node))
;			       (node-variance (node-right c-node))))
;		       500)) ;; Some value?
;		   ;; Based on max variance.
;	       (if (= (node-variance c-node) maxv)
;	       ;; Based on max size.
;	       (if (= (length (node-contents c-node)) maxs)
;	       ;; Based on the highest 50% of variance.
;	       (if (and (member (node-variance c-node) sv)
;			(> (length (node-contents c-node)) 4))
;		   (let ((new-node (compass (node-contents c-node)
;					    :distance-func 'euclidean-distance)))
;		     (setf c-node new-node))
;		   (progn
;		     (unless (null (node-right c-node))
;		       (walk (node-right c-node)))
;		     (unless (null (node-left c-node))
;		       (walk (node-left c-node)))))))
;      (walk ctree-node)))
;  ctree-node)

(defun re-compass (ctree)
  (labels ((walk (c-node)
	     (unless (null (node-right c-node))
	       (if (and (> (length (node-contents (node-right c-node))) 4)
			(not (has-both-children (node-right c-node))))
		   (setf (node-right c-node)
			 (compass (node-contents (node-right c-node))
				  :distance-func 'euclidean-distance))))
	     (unless (null (node-left c-node))
	       (if (and (> (length (node-contents (node-left c-node))) 4)
			(not (has-both-children (node-left c-node))))
		   (setf (node-left c-node)
			 (compass (node-contents (node-left c-node))
				  :distance-func 'euclidean-distance))))
	     (unless (null (node-right c-node))
	       (walk (node-right c-node)))
	     (unless (null (node-left c-node))
	       (walk (node-left c-node)))))
    (walk ctree)
    ctree))

(defun an-interesting-instance-1 (data k)
  ;; Find the two clusters with the most distant centroids.
  (let ((clusters (meat-processor k (k-means k data)))
	farthest-two
	(best-dist 0))
    (dolist (cluster clusters)
      (let ((other-clusters (remove cluster (copy-list clusters))))
	(dolist (other-cluster other-clusters)
	  (if (< best-dist (euclidean-distance
			    (centroid cluster)
			    (centroid other-cluster)))
	      (progn
		(setf farthest-two (list cluster other-cluster))
		(setf best-dist (euclidean-distance
				 (centroid cluster)
				 (centroid other-cluster))))))))
    (centroid (condense-lists farthest-two))))

(defun oracle-test (&optional (datasets *DATASETS*)
		    &key (distance-func 'euclidean-distance) (normalize? NIL) (s 2) (m 4))
  (let ((sets (copy-list datasets))
	compass oracle variants)
    (dolist (set sets)
      (let ((projects (table-egs (funcall set))))

	(if normalize?
	    (setf projects (normalize projects)))

	;; Compass
	(let (tmp big-tmp)
	  (dotimes (n 20)
	    (dotimes (k (length projects))
	      (push (compass-teak (nth k projects) projects 1.1 1.1 :distance-func distance-func) tmp))
	    (push tmp big-tmp)
	    (setf tmp nil))
	  (push big-tmp compass))

	;; Oracle
	(let (tmp big-tmp)
	  (dotimes (n 20)
	    (dotimes (k (length projects))
	      (push (oracle-teak (nth k projects) projects 1.1 1.1 :s s :m m :distance-func distance-func) tmp))
	    (push tmp big-tmp)
	    (setf tmp nil))
	  (push big-tmp oracle))
	))

    (push (reverse oracle) variants)
    (push (reverse compass) variants)

    (dolist (set sets)
      (let* ((applicable-variants (mapcar #'(lambda (x) (nth (position set sets) x)) variants)))

	(format t "~A~%" set)

	(dotimes (n (length applicable-variants))
	  (let* ((current-variant (nth n applicable-variants))
		 (other-variants
		  (remove (nth n applicable-variants) (copy-list applicable-variants)))
		 (win 0)(tie 0)(loss 0))
	    (dolist (variant other-variants)
	      (dotimes (k (length variant))
		(let ((wilcox (wilcoxon (nth k current-variant) (nth k variant))))
		  (if (= wilcox 1)
		      (incf tie)
		      (let ((cur-med (median (nth k current-variant)))
			    (var-med (median (nth k variant))))
			(if (< cur-med var-med)
			    (incf win)
			    (incf loss)))))))
	    (format t "~A " (if (= n 0) "ORACLE"
				(if (= n 1) "COMPASS")))
	    (format t "WIN: ~A TIE: ~A LOSS: ~A MDMRE: ~5,4f~%" win tie loss (median (condense-lists current-variant)))))))))

(defun oracle-teak (this projects alpha beta &key (s 2) (m 4) (distance-func 'cosine-similarity))
  (let* ((test this)
	 (projects (remove test projects))
	 (oracle-tree (data-oracle projects :s s :m m))
	 (pruned-tree (variance-prune oracle-tree :alpha alpha :beta beta))
	 (actual (first (last test)))
	 (predicted 0))

    (labels ((walk (c-node)
	       (if (< (node-variance c-node)
		      (weighted-variance c-node))
		   (setf predicted (median (mapcar #'first (mapcar #'last (node-contents c-node)))))
		   (if (or (null (node-right c-node))
			   (null (node-left c-node)))
		       (progn
			 (unless (null (node-right c-node))
			   (walk (node-right c-node)))
			 (unless (null (node-left c-node))
			   (walk (node-left c-node))))
		       (if (> (weighted-variance (node-right c-node))
			      (weighted-variance (node-left c-node)))
			   (walk (node-left c-node))
			   (walk (node-right c-node)))))))
      (walk pruned-tree))
    (mre actual predicted)))
