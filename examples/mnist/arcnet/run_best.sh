#!/bin/sh
# This gets 2.61% error on SVHN.
deepnet=/ais/gobi3/u/kswersky/Conferences/NIPS2013/bayesian-optimization/code/spearmint/deepnet/deepnet
python ${deepnet}/trainer.py 3layer_conv2_best.pbtxt train.pbtxt eval.pbtxt
python analyze_results.py /ais/gobi3/u/kswersky/data/svhn/models/3layer_conv_run5_BEST train.pbtxt /ais/gobi3/u/kswersky/data/svhn/results
