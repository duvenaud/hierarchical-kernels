#!/bin/sh
#
# the next line is a "magic" comment that tells codine to use bash
#$ -S /bin/bash
#
# This script should be what is passed to qsub; its job is just to run one matlab job.

/usr/local/apps/matlab/matlabR2007a/bin/matlab -nodisplay -nojvm -logfile "matlab_log_$1_$2_$3_$4_$5.txt" -r "ls; cd /home/mlg/dkd23/git/hierarchical-kernels/source/; ls; run_one_experiment($1, $2, $3, $4, $5, '../../../results/jan-14-fear/'); exit" 
                                                                                                                                                                          #method_number, dataset_number, K, fold, seed, outdir
