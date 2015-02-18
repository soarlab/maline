#!/bin/bash

for c in 32 512 2048 8192 32768
do
    for g in 0.03125 0.0078125 0.00048828125 2 8
    do

	# Fold 1
	svm-train -s 0 -t 2 -c $c -g $g -b 1 -h 0 feature-matrix-graph.sparse.scale.training.1 feature-matrix-graph.sparse.scale.training.1.rbf.$c.$g.model && svm-predict -b 1 feature-matrix-graph.sparse.scale.testing.1 feature-matrix-graph.sparse.scale.training.1.rbf.$c.$g.model feature-matrix-graph.sparse.scale.testing.1.$c.$g.out >> feature-matrix-graph.sparse.scale.1.$c.$g.out &
	
	# Fold 2
	svm-train -s 0 -t 2 -c $c -g $g -b 1 -h 0 feature-matrix-graph.sparse.scale.training.2 feature-matrix-graph.sparse.scale.training.2.rbf.$c.$g.model && svm-predict -b 1 feature-matrix-graph.sparse.scale.testing.2 feature-matrix-graph.sparse.scale.training.2.rbf.$c.$g.model feature-matrix-graph.sparse.scale.testing.2.$c.$g.out >> feature-matrix-graph.sparse.scale.2.$c.$g.out &
	
	# # Fold 3
	# svm-train -s 0 -t 2 -c $c -g $g -b 1 -h 0 feature-matrix-graph.sparse.scale.training.3 feature-matrix-graph.sparse.scale.training.3.rbf.$c.$g.model && svm-predict -b 1 feature-matrix-graph.sparse.scale.testing.3 feature-matrix-graph.sparse.scale.training.3.rbf.$c.$g.model feature-matrix-graph.sparse.scale.testing.3.$c.$g.out >> feature-matrix-graph.sparse.scale.3.$c.$g.out &
	
	# # Fold 4
	# svm-train -s 0 -t 2 -c $c -g $g -b 1 -h 0 feature-matrix-graph.sparse.scale.training.4 feature-matrix-graph.sparse.scale.training.4.rbf.$c.$g.model && svm-predict -b 1 feature-matrix-graph.sparse.scale.testing.4 feature-matrix-graph.sparse.scale.training.4.rbf.$c.$g.model feature-matrix-graph.sparse.scale.testing.4.$c.$g.out >> feature-matrix-graph.sparse.scale.4.$c.$g.out &
	
	# # Fold 5
	# svm-train -s 0 -t 2 -c $c -g $g -b 1 -h 0 feature-matrix-graph.sparse.scale.training.5 feature-matrix-graph.sparse.scale.training.5.rbf.$c.$g.model && svm-predict -b 1 feature-matrix-graph.sparse.scale.testing.5 feature-matrix-graph.sparse.scale.training.5.rbf.$c.$g.model feature-matrix-graph.sparse.scale.testing.5.$c.$g.out >> feature-matrix-graph.sparse.scale.5.$c.$g.out &
    done
done
