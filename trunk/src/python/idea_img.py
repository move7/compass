#!/usr/bin/env python

import argparse
from arff import *
from statistics import *
from gridclus2 import *
from instance import *
from quadrant import *
from figure import *
import time
from util import *
from copy import deepcopy
from bore import *
from NaiveBayes import *
import random

class Timer:
    def __init__(self, operation):
        self.operation = operation
    def __enter__(self): self.start = time.time()
    def __exit__(self, *args): print self.operation, ",", time.time() - self.start
    
def main():
    random.seed(5)
    args = parse_options()

    title = args.train[0].split("/")[-1].split(".")[0]
    arff = Arff(args.train[0])
    
    #print "Running dataset %s, outputting to %s.png" % (title, title)
    for i in range(8):
        print "%d" % (i+1), title,",",len(arff.data*(i+1))
        with Timer("instance + data collection"):
            dc = DataCollection(arff.data*(i+1))
            ic = InstanceCollection(dc)
            ic.normalize_coordinates()
        
        k_fold = ic.k_fold_stratified_cross_val(args.stratified[0])
        
        test = k_fold[0]
        k_fold.remove(test)
        train = squash(deepcopy(k_fold))
        
        with Timer("logging coordinates"):
            trainXY = log_y(log_x(deepcopy(train)))
            testXY = log_y(log_x(deepcopy(test)))

        with Timer("quadrant creation"):
            quadrants = QuadrantTree(trainXY).leaves()
            
        with Timer("cluster creation"):
            clusters = GRIDCLUS(quadrants, args.accept[0])

    """
    print "Scoring clusters (with IDEA 1.0)..."
    for instance in trainXY:

        # Find closest cluster to test instance.
        closest_cluster = [sys.maxint, None]
        for i in range(len(clusters)):
            for quadrant in clusters[i].quadrants:
                tmp_distance = distance(instance.Coord(), quadrant.center())
                if tmp_distance < closest_cluster[0]:
                    closest_cluster[0] = tmp_distance
                    closest_cluster[1] = i

        # Points and associated classes for the closest cluster's quadrants.
        modified_train = []
        for quadrant in clusters[closest_cluster[1]].quadrants:
            modified_train.extend(quadrant.ClassCoords())
        
        # Classify the test instance
        got = classify(instance.Coord(), modified_train, "DEFECT")
        want = instance.datum[-1]
        
        # Increment the stat object appropriately using Evaluate
        clusters[closest_cluster[1]].stats.Evaluate(got, want)

        global_pre_test = DefectStats()
        pre_test_stats = list(DefectStats() for cluster in clusters)
        global_nb = DefectStats()

        
    print "Running standard learner (Naive Bayes)..."
    for instance in testXY:
        # Find closest cluster to test instance.
        closest_cluster = [sys.maxint, None]
        for i in range(len(clusters)):
            for quadrant in clusters[i].quadrants:
                tmp_distance = distance(instance.Coord(), quadrant.center())
                if tmp_distance < closest_cluster[0]:
                    closest_cluster[0] = tmp_distance
                    closest_cluster[1] = i

        # Points and associated classes for the closest cluster's quadrants.
        modified_train = []
        for quadrant in clusters[closest_cluster[1]].quadrants:
            modified_train.extend(quadrant.ClassCoords())
        
        # Classify the test instance
        got = classify(instance.Coord(), modified_train, "DEFECT")
        
        # Increment the stat object appropriately using Evaluate
        pre_test_stats[closest_cluster[1]].Evaluate(got, want)
        global_pre_test.Evaluate(got, instance.klass())

        global_nb.Evaluate(NaiveBayesClassify(instance.datum, [inst.datum for inst in trainXY], "DEFECT"), instance.klass())

    print "Culling clusters (with IDEA 1.0)..."
    clusters, culled_clusters = prune_clusters_classic(deepcopy(clusters), args.cull[0], "SCORE")
    
    global_test = DefectStats()
    test_stats = list(DefectStats() for cluster in clusters)

    print "Testing remaining clusters (with IDEA 1.0)..."
    for instance in testXY:
        
        # Find closest cluster to test instance.
        closest_cluster = [sys.maxint, None]
        for i in range(len(clusters)):
            for quadrant in clusters[i].quadrants:
                tmp_distance = distance(instance.Coord(), quadrant.center())
                if tmp_distance < closest_cluster[0]:
                    closest_cluster[0] = tmp_distance
                    closest_cluster[1] = i

        # Points and associated classes for the closest cluster's quadrants.
        modified_train = []
        for quadrant in clusters[closest_cluster[1]].quadrants:
            modified_train.extend(quadrant.ClassCoords())
                
        # Classify the test instance
        got = classify(instance.Coord(), modified_train, "DEFECT")
        want = instance.datum[-1]
        
        # Increment the stat object appropriately using Evaluate
        test_stats[closest_cluster[1]].Evaluate(got, want)
        global_test.Evaluate(got, want)

    global_test_culled = DefectStats()
    test_stats_culled = list(DefectStats() for cluster in culled_clusters)

    print "Testing removed clusters (with IDEA 1.0)..."
    for instance in testXY:
        
        # Find closest cluster to test instance.
        closest_cluster = [sys.maxint, None]
        for i in range(len(clusters)):
            for quadrant in culled_clusters[i].quadrants:
                tmp_distance = distance(instance.Coord(), quadrant.center())
                if tmp_distance < closest_cluster[0]:
                    closest_cluster[0] = tmp_distance
                    closest_cluster[1] = i

        # Points and associated classes for the closest cluster's quadrants.
        modified_train = []
        for quadrant in culled_clusters[closest_cluster[1]].quadrants:
            modified_train.extend(quadrant.ClassCoords())
                
        # Classify the test instance
        got = classify(instance.Coord(), modified_train, "DEFECT")
        want = instance.datum[-1]
        
        # Increment the stat object appropriately using Evaluate
        test_stats_culled[closest_cluster[1]].Evaluate(got, want)
        global_test_culled.Evaluate(got, want)
        
    print "Writing figure %s.png ..." % (title)
    fig = Figure(title, trainXY, quadrants, clusters, culled_clusters, global_test, global_pre_test, global_test_culled, global_nb)
    fig.write_png()
    """
    

def parse_options():
    """Place new options that you would like to be parsed here."""
    parser = argparse.ArgumentParser(description='Perform IDEA on given train and test sets.')
    parser.add_argument('--train',
                        dest='train',
                        metavar='FILE',
                        type=str,
                        nargs='+',
                        help='Specify arff file[s] from which to construct the training set.')
    parser.add_argument('--stratified',
                        dest='stratified',
                        default=None,
                        metavar='Train to test ratio, STRATIFIED on 1',
                        type=int,
                        nargs=1,
                        help='Specify a ratio for a stratified split scheme.\
                              Takes an integer to define ratio, STRATIFIED on 1, train to test ratio.')
    parser.add_argument('--accept',
                        dest='accept',
                        default=None,
                        metavar='FLOAT 0-1',
                        type=float,
                        nargs=1,
                        help='Specify the acceptance rate to use when generating clusters.')
    parser.add_argument('--cull',
                        dest='cull',
                        default=None,
                        metavar='FLOAT 0-1',
                        type=float,
                        nargs=1,
                        help='Specify the percentage of clusters to cull.')
    args = parser.parse_args()
    return args

if __name__ == "__main__":
    main()
