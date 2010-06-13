(defun k-means (k data)
  (k-means-prim k (make-array `(,(length data)
                                ,(length (first data)))
			      :initial-contents data)))		   

(defun k-means-prim (k data)
  "k-means: performs a k-means clustering."
  (let ((memberof (make-array (array-dimension data 0)
                              :initial-element nil))
	(oldmemberof (make-array (array-dimension data 0)
                                 :initial-element nil))
	(num.in.cluster (make-array k :initial-element 0))
	(centroids (make-array (list k (array-dimension data 1))
                               :initial-element 0))
	(distances (make-array (list (array-dimension data 0) k)
                               :initial-element nil))
	(tempmin nil)
	(finaldata
         (adjust-array data
                       (list (array-dimension data 0)
                             (+ (array-dimension data 1) 1)))))
    (dotimes (i (array-dimension data 0))
      (setf (aref memberof i) (mod i k))
      (setf (aref num.in.cluster (mod i k))
            (+ (aref num.in.cluster (mod i k)) 1)))
    (dotimes (i (array-dimension data 0))
      (dotimes (j (array-dimension data 1))
	(setf (aref centroids (aref memberof i) j)
	      (+ (/ (aref data i j)
		    (aref num.in.cluster (aref memberof i)))
		 (aref centroids (aref memberof i) j)))))
    (dotimes (iteration (array-dimension data 0) memberof)
      (if (equalp oldmemberof memberof)
	  (return memberof))
      (dotimes (i (array-dimension memberof 0))
	(setf (aref oldmemberof i) (aref memberof i)))
      (setf distances (set-distance-matrix2 data centroids))
      (dotimes (i (array-dimension distances 0))
	(setf tempmin (aref distances i 0))
	(dotimes (j (array-dimension distances 1))
	  (cond ((<= (aref distances i j) tempmin)
		 (setf tempmin (aref distances i j))
		 (setf (aref memberof i) j)))))
      (setf num.in.cluster (make-array k :initial-element 0))
      (dotimes (i (array-dimension memberof 0))
	(setf (aref num.in.cluster (aref memberof i))
              (+ (aref num.in.cluster (aref memberof i)) 1)))
      (setf centroids (make-array (list k (array-dimension data 1))
                                  :initial-element 0))
      (dotimes (i (array-dimension data 0))
	(dotimes (j (array-dimension data 1))
	  (setf (aref centroids (aref memberof i) j)
		(+ (/ (aref data i j)
		      (aref num.in.cluster (aref memberof i)))
		   (aref centroids (aref memberof i) j))))))
    (dotimes (i (array-dimension data 0))
      (setf (aref finaldata i (- (array-dimension finaldata 1) 1))
            (aref memberof i)))
    finaldata))

(defun set-distance-matrix2 (data1 data2)
  "set-distance-matrix2: Creates and returns an array 
   representing the distances between objects of two sets"
  (let ((distancearray
         (make-array (list (array-dimension data1 0)
                           (array-dimension data2 0)) :initial-element 0))
        (sum 0))
    (dotimes (i (array-dimension distancearray 0) distancearray)
      (dotimes (j (array-dimension distancearray 1))
        (setf sum 0)
        (dotimes (k (array-dimension data1 1))
          (setf sum (+ sum (expt (- (aref data1 i k) (aref data2 j k)) 2))))
        (setf (aref distancearray i j) (sqrt sum))))))

(defun array-to-list (a &optional (dims (array-dimensions a)) (start 0)) 
  (if (not dims) 
      (row-major-aref a start) 
      (let ((dim1 (first dims)) (more-dims (rest dims))) 
	(loop repeat dim1 
	   for j from start by (apply #'* more-dims) 
	   collect (array-to-list a more-dims j)))))

(defun meat-processor (k k-means-output)
  "Converts array k-means output into a list of clusters"
  (let* ((tbl-egs (array-to-list k-means-output))
	 (clusters))
    (dotimes (n k)      
      (let (temporary-storage)
	(dolist (eg tbl-egs)
	  (if (= (first (last eg)) n)
	      (push (rmnth (1- (length eg)) eg) temporary-storage)))
	(push temporary-storage clusters)))
    clusters))

(defun average-variance (clusters)
  ;; Variance automagically uses the class value (stored in the last
  ;; column of our effort datasets) 
  (let ((clusters (remove nil clusters))
	(sum 0))
    (dolist (cluster clusters)
      (setf sum (+ sum (variance cluster))))
    (/ sum (length clusters))))

(defun best-k (data)
  (let* ((best-so-far '(0 0)))
    ;; Give it 30 tries... if we ever get worse we stop clustering.
    (dotimes (try 30)
      (let ((current-avg (average-variance (meat-processor (1+ try) (k-means (1+ try) data))))
	    (current-k (1+ try)))
	(if (= (first best-so-far) 0)
	    (setf best-so-far (list current-avg current-k)))
	(if (< current-avg (first best-so-far))
	    (setf best-so-far (list current-avg current-k)))
	(if (> current-avg (first best-so-far))
	    (return))))
    (remove nil (meat-processor (second best-so-far) (k-means (second best-so-far) data)))))

(defun k=?-test (k data)
  (let* ((representative (random-element data))
	 (data (remove representative (copy-list data)))
	 (clusters (meat-processor k (k-means k data)))
	 (predicted (matching-cluster-median representative clusters)))
    (mre (first (last representative)) predicted)))

(defun k=?-bisecting-test (k data)
  (let* ((representative (random-element data))
	 (new-data (remove representative (copy-list data)))
	 (clusters (bisecting-k-means k new-data)))
    (mre (first (last representative))
	 (matching-cluster-median representative clusters))))

(defun best-k-test (data)
  (let* ((representative (random-element data))
	 (data (remove representative data))
	 (clusters (best-k data))
	 (predicted (matching-cluster-median representative clusters)))
    (mre (first (last representative)) predicted)))

(defun matching-cluster-median (this clusters &key (distance-func 'cosine-similarity))
  (let ((best-distance 99999)
	(best-cluster nil))
    (dolist (cluster clusters)
      (let ((current-distance (funcall distance-func this (centroid cluster))))
	(if (> best-distance current-distance)
	    (progn (setf best-distance current-distance)
		   (setf best-cluster cluster)))))
    (median (mapcar #'first (mapcar #'last best-cluster)))))

(defun instance-median (this that)
  (let (new-instance)
    (dotimes (n (length this))
      (if (numberp (first this))
	  (push (/ (+ (nth n this) (nth n that)) 2) new-instance)
	  (if (eql (nth n this) (nth n that))
	      (push (nth n this) new-instance)
	      (push (random-element (list (nth n this) (nth n that))) new-instance))))
    (reverse new-instance)))

(defun centroid (cluster &key (distance-func 'cosine-similarity))
  (if (= (length cluster) 1)
      (first cluster)
      (let* ((this (random-element cluster))
	     (cluster (remove this (copy-list cluster)))
	     (that (farthest-from this cluster :distance-func distance-func))
	     (cluster (remove that (copy-list cluster)))
	     (cluster (push this cluster))
	     (this (farthest-from that cluster :distance-func distance-func)))
	(instance-median this that))))

(defun bisecting-k-means (k data)
  (let* ((clusters (remove nil (meat-processor k (k-means k data))))
	 (largest (most-mixed-cluster clusters))
	 (new-clusters (meat-processor 2 (k-means 2 (nth largest clusters))))
	 (clusters (rmnth largest (copy-list clusters))))
    (push (nth 0 new-clusters) clusters)
    (push (nth 1 new-clusters) clusters)
    clusters))
    
(defun largest-cluster (clusters)
  (let ((largest 0))
    (dolist (cluster clusters)
      (if (> (length cluster) largest)
	  (setf largest (position cluster clusters))))
    largest))

(defun most-mixed-cluster (clusters)
  (let ((largest 0))
    (dolist (cluster clusters)
      (if (> (variance cluster) largest)
	  (setf largest (position cluster clusters))))
    largest))