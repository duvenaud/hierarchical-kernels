% Experiment to compare using a conditional kernel versus using seperate
% GPs for whether or not the data is missing.
%
% David Duvenaud
% Sept 2013.


% Fix the seed of the random generators.
seed = 0;
randn('state',seed);
rand('state',seed);

addpath(genpath('gpml'))
addpath(genpath('utils'))
addpath(genpath('methods'))

datadir = '../data/matlab/';
%datafiles = dir([ datadir, '*.mat']);
datafiles = {};
datafiles{end+1} = 'concatenated_nan.mat';
datafiles{end+1} = 'concatenated_nan_log.mat';

outdir = '/scratch/results/17-oct-compare/';

% Load the data.
dataset_ix = 1;
%dataset = [ datadir, datafiles(dataset_ix).name];
%cur_data = load( dataset );

%[N,D] = size(cur_data.X);

% define methods
methods = {};
%methods{end+1} = @linear;
methods{end+1} = @separate_linear;
methods{end+1} = @separate_gp_ard;
%methods{2} = @gp_ard;

K = 2;

for dataset_ix = 1:length(datafiles)
    dataset = [ datadir, datafiles{dataset_ix}]
    for fold = 1:K;
        for method_ix = 1:numel(methods)
            run_one_fold( dataset, methods{method_ix}, K, fold, seed, outdir, false )
        end
    end
end


% Now summarize results
log_likelihood_table = NaN( K, length(datafiles), length(methods));
mse_table = NaN( K, length(datafiles), length(methods));

folds = 1:K;

num_missing = 0;

for d_ix = 1:length(datafiles)
    cur_dataset = [ datadir, datafiles{d_ix}];
    [~, shortname] = fileparts(cur_dataset);
    fprintf('\nCompiling results for %s dataset...\n', shortname );   
    
    dataset_names{d_ix} = shortname;
    for m_ix = 1:length(methods)        
        train = methods{m_ix};
        method_names{m_ix} = func2str(train);
        
        for fold = folds
            try
                % Load the results.
                filename = run_one_fold( cur_dataset, train, K, fold, seed, outdir, true );
                %fprintf('Loading %s', filename );
                results = load( filename );               

                log_likelihood_table(fold, d_ix, m_ix) = mean( results.loglik );
                mse_table(fold, d_ix, m_ix) = mean( (results.predictions - results.actuals).^2 );

                if ~isfinite(mean( results.loglik ))
                    fprintf('N');   % Failed because of a Nan or Inf.
                else
                    fprintf('O');   % Run went OK
                end
            catch 
                %disp(lasterror);
                fprintf('X');       % Never even finished.
                num_missing = num_missing + 1;

                % Stop here and run this to see why it failed:
                %run_one_experiment(m_ix, d_ix, K, fold, 0, seed, outdir)
            end                
        end
        fprintf('\n');
        

        %fold_has_nans = any(isnan(best_log_likelihood_table(folds,d_ix,:)), 3);
        %if fold_has_nans
        %end
    end

    % Make the comparison fair by removing a fold if any methods have a NaN
    % in it.
    %best_log_likelihood_table( has_likelihood & squeeze(any(isnan(best_log_likelihood_table(folds,d_ix,:)), 1)), d_ix, :) = NaN;
    %best_mse_table( any(isnan(best_mse_table(folds,d_ix,:)), 1), d_ix, :) = NaN;
    %best_accuracy_table( any(isnan(best_accuracy_table(folds,d_ix,:)), 1), d_ix, :) = NaN;        
end


% Now make figures and tables.

meanfunc = @mean;
stdfunc = @std;

likelihoods = squeeze(mean(log_likelihood_table,1));
fprintf('\n\n');
print_table( 'Log Likelihood', dataset_names, method_names, likelihoods );
if any(isnan(log_likelihood_table(:)))
    warning('Some log likelihood entries missing!')
end

mses = squeeze(mean(mse_table,1));
fprintf('\n\n');
print_table( 'Mean Squared Error', dataset_names, method_names, mses );
if any(isnan(mse_table(:)))
    warning('Some Mean Squared Error entries missing!')
end

