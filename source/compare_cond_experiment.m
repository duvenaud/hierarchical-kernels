% Experiment to compare using a conditional kernel versus using seperate
% GPs for whether or not the data is missing.
%
% David Duvenaud
% Sept 2013.


% Fix the seed of the random generators.
seed = 1;
randn('state',seed);
rand('state',seed);

addpath(genpath('gpml'))
addpath(genpath('utils'))
addpath(genpath('methods'))



%outdir = '/scratch/results/18-oct-overnight-fear-backup/';
outdir = '/home/dkd23/results/jan-16-fear/';
mkdir(outdir);


[datafiles, methods] = define_datasets_and_methods();

methods{2} = @sep_box;
methods{1} = @separate_gp_ard;
methods(3:end) = [];

datafiles([ 1:2, 4:end]) = [];

K = 10;

for dataset_ix = 1:length(datafiles)
    for fold = 1;%:K;
        for method_ix = 1:numel(methods)
            run_one_fold( datafiles{dataset_ix}, methods{method_ix}, K, ...
                          fold, seed, outdir, false )
        end
    end
end

compile_all_results();
