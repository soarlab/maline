#!/bin/bash

create_datasets_cv feature-matrix-graph.sparse.scale ../../folds.csv 1
create_datasets_cv feature-matrix-graph.sparse.scale ../../folds.csv 2
create_datasets_cv feature-matrix-graph.sparse.scale ../../folds.csv 3
create_datasets_cv feature-matrix-graph.sparse.scale ../../folds.csv 4
create_datasets_cv feature-matrix-graph.sparse.scale ../../folds.csv 5

# Fold 1
svm-train -s 0 -t 2 -c 32768 -g 0.0078125 -b 1 -h 0 feature-matrix-graph.sparse.scale.training.1 feature-matrix-graph.sparse.scale.training.1.rbf.model && svm-predict -b 1 feature-matrix-graph.sparse.scale.testing.1 feature-matrix-graph.sparse.scale.training.1.rbf.model feature-matrix-graph.sparse.scale.testing.1.out >> feature-matrix-graph.sparse.scale.1.out &

# Fold 2
svm-train -s 0 -t 2 -c 32768 -g 0.0078125 -b 1 -h 0 feature-matrix-graph.sparse.scale.training.2 feature-matrix-graph.sparse.scale.training.2.rbf.model && svm-predict -b 1 feature-matrix-graph.sparse.scale.testing.2 feature-matrix-graph.sparse.scale.training.2.rbf.model feature-matrix-graph.sparse.scale.testing.2.out >> feature-matrix-graph.sparse.scale.2.out &

# Fold 3
svm-train -s 0 -t 2 -c 32768 -g 0.0078125 -b 1 -h 0 feature-matrix-graph.sparse.scale.training.3 feature-matrix-graph.sparse.scale.training.3.rbf.model && svm-predict -b 1 feature-matrix-graph.sparse.scale.testing.3 feature-matrix-graph.sparse.scale.training.3.rbf.model feature-matrix-graph.sparse.scale.testing.3.out >> feature-matrix-graph.sparse.scale.3.out &

# Fold 4
svm-train -s 0 -t 2 -c 32768 -g 0.0078125 -b 1 -h 0 feature-matrix-graph.sparse.scale.training.4 feature-matrix-graph.sparse.scale.training.4.rbf.model && svm-predict -b 1 feature-matrix-graph.sparse.scale.testing.4 feature-matrix-graph.sparse.scale.training.4.rbf.model feature-matrix-graph.sparse.scale.testing.4.out >> feature-matrix-graph.sparse.scale.4.out &

# Fold 5
svm-train -s 0 -t 2 -c 32768 -g 0.0078125 -b 1 -h 0 feature-matrix-graph.sparse.scale.training.5 feature-matrix-graph.sparse.scale.training.5.rbf.model && svm-predict -b 1 feature-matrix-graph.sparse.scale.testing.5 feature-matrix-graph.sparse.scale.training.5.rbf.model feature-matrix-graph.sparse.scale.testing.5.out >> feature-matrix-graph.sparse.scale.5.out &
