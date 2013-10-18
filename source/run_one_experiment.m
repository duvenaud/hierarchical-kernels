% This function is designed to call an experiment, where everything is
% indexed by integers so that it's easy to call from a shell script.
%
% David Duvenaud
% Oct 2013
% =================

function run_one_experiment(method_number, dataset_number, K, fold, seed, outdir)

% Set defaults.
if nargin < 1; method_number = 1; end
if nargin < 2; dataset_number = 1; end
if nargin < 3; K = 5; end
if nargin < 4; fold = 1; end
if nargin < 5; seed = 0; end
if nargin < 6; outdir = 'results/'; end

% If calling from the shell, all inputs will be strings, so we need to
% convert them to numbers.
if ischar(method_number); method_number = str2double(method_number); end
if ischar(dataset_number); dataset_number = str2double(dataset_number); end
if ischar(K); K = str2double(K); end
if ischar(fold); fold = str2double(fold); end
if ischar(seed); seed = str2double(seed); end

addpath(genpath('gpml'))
addpath(genpath('utils'))
addpath(genpath('methods'))


fprintf('Running one experiment...\n');

[datafiles, methods] = define_datasets_and_methods();
      

% Run experiment.
run_one_fold( datafiles{dataset_number}, methods{method_number}, ...
              K, fold, seed, outdir, 0 );

