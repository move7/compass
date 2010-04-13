(defun make-model-2 ()
  (make-ddp-model
   :o-weight (list 1)
   :m-cost (list 100 75 1250 2600 2000 900 2500 0 0 200 10000 1000 100 0 0 0 25 800 25 750 0 2000 100 25 25 2000 75 75 100 0 40)
   :r-apl (list 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1)
   :ro-impacts (list
		(make-ro-impact :r 1 :o 1 :impact 0.3)
		(make-ro-impact :r 2 :o 1 :impact 0.9)
		(make-ro-impact :r 4 :o 1 :impact 0.3)
		(make-ro-impact :r 10 :o 1 :impact 0.7)
		(make-ro-impact :r 15 :o 1 :impact 0.7)
		(make-ro-impact :r 17 :o 1 :impact 0.9)
		(make-ro-impact :r 18 :o 1 :impact 0.7)
		(make-ro-impact :r 19 :o 1 :impact 0.1)
		(make-ro-impact :r 20 :o 1 :impact 0.7)
		(make-ro-impact :r 21 :o 1 :impact 0.1)
		(make-ro-impact :r 22 :o 1 :impact 0.3)
		(make-ro-impact :r 25 :o 1 :impact 0.9)
		(make-ro-impact :r 26 :o 1 :impact 0.7)
		(make-ro-impact :r 28 :o 1 :impact 0.3)
		(make-ro-impact :r 29 :o 1 :impact 0.3)
		(make-ro-impact :r 30 :o 1 :impact 0.1)
		)
   :mr-effects (list
		(make-mr-effect  :m 4 :r 1 :effect 0.7)
		(make-mr-effect  :m 5 :r 1 :effect 0.1)
		(make-mr-effect  :m 6 :r 1 :effect 0.3)
		(make-mr-effect  :m 13 :r 1 :effect 0.1)
		(make-mr-effect  :m 16 :r 1 :effect 0.7)
		(make-mr-effect  :m 22 :r 1 :effect 0.3)
		(make-mr-effect  :m 23 :r 1 :effect 0.3)
		(make-mr-effect  :m 1 :r 2 :effect 0.3)
		(make-mr-effect  :m 2 :r 2 :effect 0.1)
		(make-mr-effect  :m 3 :r 2 :effect 0.3)
		(make-mr-effect  :m 4 :r 2 :effect 0.3)
		(make-mr-effect  :m 5 :r 2 :effect 0.3)
		(make-mr-effect  :m 6 :r 2 :effect 0.3)
		(make-mr-effect  :m 7 :r 2 :effect 0.3)
		(make-mr-effect  :m 11 :r 2 :effect 0.3)
		(make-mr-effect  :m 12 :r 2 :effect 0.7)
		(make-mr-effect  :m 22 :r 2 :effect 0.3)
		(make-mr-effect  :m 26 :r 2 :effect 0.9)
		(make-mr-effect  :m 31 :r 2 :effect 0.9)
		(make-mr-effect  :m 5 :r 3 :effect 0.1)
		(make-mr-effect  :m 5 :r 4 :effect 0.1)
		(make-mr-effect  :m 6 :r 4 :effect 0.9)
		(make-mr-effect  :m 13 :r 4 :effect 0.9999)
		(make-mr-effect  :m 23 :r 4 :effect 0.9)
		(make-mr-effect  :m 31 :r 4 :effect 0.9)
		(make-mr-effect  :m 2 :r 5 :effect 0.7)
		(make-mr-effect  :m 3 :r 5 :effect 0.3)
		(make-mr-effect  :m 7 :r 5 :effect 0.3)
		(make-mr-effect  :m 13 :r 6 :effect 0.9)
		(make-mr-effect  :m 2 :r 7 :effect 0.7)
		(make-mr-effect  :m 7 :r 7 :effect 0.4)
		(make-mr-effect  :m 12 :r 7 :effect 0.3)
		(make-mr-effect  :m 3 :r 8 :effect 0.1)
		(make-mr-effect  :m 7 :r 8 :effect 0.3)
		(make-mr-effect  :m 12 :r 8 :effect 0.7)
		(make-mr-effect  :m 11 :r 9 :effect 0.1)
		(make-mr-effect  :m 17 :r 9 :effect 0.3)
		(make-mr-effect  :m 18 :r 9 :effect 0.7)
		(make-mr-effect  :m 5 :r 10 :effect 0.3)
		(make-mr-effect  :m 26 :r 10 :effect 0.9)
		(make-mr-effect  :m 31 :r 10 :effect 0.3)
		(make-mr-effect  :m 4 :r 11 :effect 0.1)
		(make-mr-effect  :m 5 :r 11 :effect 0.1)
		(make-mr-effect  :m 13 :r 11 :effect 0.3)
		(make-mr-effect  :m 2 :r 15 :effect 0.1)
		(make-mr-effect  :m 5 :r 15 :effect 0.1)
		(make-mr-effect  :m 6 :r 15 :effect 0.1)
		(make-mr-effect  :m 13 :r 15 :effect 1)
		(make-mr-effect  :m 23 :r 15 :effect 0.3)
		(make-mr-effect  :m 1 :r 16 :effect 0.1)
		(make-mr-effect  :m 10 :r 16 :effect 0.7)
		(make-mr-effect  :m 15 :r 16 :effect 0.3)
		(make-mr-effect  :m 2 :r 17 :effect 0.1)
		(make-mr-effect  :m 5 :r 17 :effect 0.3)
		(make-mr-effect  :m 13 :r 17 :effect 0.3)
		(make-mr-effect  :m 23 :r 17 :effect 0.9)
		(make-mr-effect  :m 10 :r 18 :effect 0.1)
		(make-mr-effect  :m 13 :r 18 :effect 0.7)
		(make-mr-effect  :m 24 :r 18 :effect 0.9)
		(make-mr-effect  :m 1 :r 19 :effect 0.1)
		(make-mr-effect  :m 2 :r 19 :effect 0.3)
		(make-mr-effect  :m 3 :r 19 :effect 0.7)
		(make-mr-effect  :m 4 :r 19 :effect 0.1)
		(make-mr-effect  :m 5 :r 19 :effect 0.1)
		(make-mr-effect  :m 6 :r 19 :effect 0.3)
		(make-mr-effect  :m 7 :r 19 :effect 0.7)
		(make-mr-effect  :m 13 :r 19 :effect 0.3)
		(make-mr-effect  :m 31 :r 19 :effect 0.7)
		(make-mr-effect  :m 5 :r 20 :effect 0.3)
		(make-mr-effect  :m 8 :r 20 :effect 0.3)
		(make-mr-effect  :m 9 :r 20 :effect 0.7)
		(make-mr-effect  :m 20 :r 20 :effect 0.2)
		(make-mr-effect  :m 27 :r 20 :effect 0.7)
		(make-mr-effect  :m 3 :r 21 :effect 0.3)
		(make-mr-effect  :m 13 :r 21 :effect 0.1)
		(make-mr-effect  :m 26 :r 21 :effect 0.9)
		(make-mr-effect  :m 31 :r 21 :effect 0.3)
		(make-mr-effect  :m 5 :r 22 :effect 0.1)
		(make-mr-effect  :m 13 :r 22 :effect 0.9)
		(make-mr-effect  :m 22 :r 22 :effect 0.3)
		(make-mr-effect  :m 1 :r 23 :effect 0.1)
		(make-mr-effect  :m 2 :r 23 :effect 0.1)
		(make-mr-effect  :m 3 :r 23 :effect 0.1)
		(make-mr-effect  :m 6 :r 23 :effect 0.1)
		(make-mr-effect  :m 11 :r 23 :effect 0.1)
		(make-mr-effect  :m 12 :r 23 :effect 0.3)
		(make-mr-effect  :m 26 :r 23 :effect 0.3)
		(make-mr-effect  :m 2 :r 24 :effect 0.3)
		(make-mr-effect  :m 3 :r 24 :effect 0.3)
		(make-mr-effect  :m 19 :r 24 :effect 0.9)
		(make-mr-effect  :m 26 :r 24 :effect 0.7)
		(make-mr-effect  :m 5 :r 25 :effect 0.9)
		(make-mr-effect  :m 6 :r 25 :effect 0.7)
		(make-mr-effect  :m 22 :r 25 :effect 0.3)
		(make-mr-effect  :m 25 :r 25 :effect 0.9)
		(make-mr-effect  :m 13 :r 26 :effect 0.1)
		(make-mr-effect  :m 26 :r 26 :effect 0.1)
		(make-mr-effect  :m 27 :r 26 :effect 0.3)
		(make-mr-effect  :m 28 :r 26 :effect 0.7)
		(make-mr-effect  :m 29 :r 26 :effect 0.3)
		(make-mr-effect  :m 30 :r 26 :effect 0.7)
		(make-mr-effect  :m 31 :r 26 :effect 0.7)
		(make-mr-effect  :m 3 :r 27 :effect 0.1)
		(make-mr-effect  :m 12 :r 27 :effect 0.7)
		(make-mr-effect  :m 1 :r 28 :effect 0.7)
		(make-mr-effect  :m 2 :r 28 :effect 0.7)
		(make-mr-effect  :m 3 :r 28 :effect 0.3)
		(make-mr-effect  :m 7 :r 28 :effect 0.7)
		(make-mr-effect  :m 12 :r 28 :effect 0.3)
		(make-mr-effect  :m 13 :r 28 :effect 0.8)
		(make-mr-effect  :m 31 :r 28 :effect 0.3)
		(make-mr-effect  :m 1 :r 29 :effect 0.1)
		(make-mr-effect  :m 3 :r 29 :effect 0.1)
		(make-mr-effect  :m 7 :r 29 :effect 0.1)
		(make-mr-effect  :m 12 :r 29 :effect 0.7)
		(make-mr-effect  :m 13 :r 29 :effect 0.7)
		(make-mr-effect  :m 1 :r 30 :effect 0.3)
		(make-mr-effect  :m 2 :r 30 :effect 0.1)
		(make-mr-effect  :m 3 :r 30 :effect 0.1)
		(make-mr-effect  :m 4 :r 30 :effect 0.3)
		(make-mr-effect  :m 6 :r 30 :effect 0.7)
		(make-mr-effect  :m 7 :r 30 :effect 0.3)
		(make-mr-effect  :m 11 :r 30 :effect 0.1)
		(make-mr-effect  :m 12 :r 30 :effect 0.9)
		(make-mr-effect  :m 14 :r 30 :effect 0.7)
		(make-mr-effect  :m 21 :r 30 :effect 0.3)
		(make-mr-effect  :m 22 :r 30 :effect 0.3)
		(make-mr-effect  :m 31 :r 30 :effect 0.3)
		)
   )
)
		



