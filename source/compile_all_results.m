% Experiment to compare using a conditional kernel versus using seperate
% GPs for whether or not the data is missing.
%
% David Duvenaud
% Sept 2013.
function compile_all_results

% Fix the seed of the random generators.
seed = 1;
randn('state',seed);
rand('state',seed);

addpath(genpath('gpml'))
addpath(genpath('utils'))
addpath(genpath('methods'))

[datafiles, methods] = define_datasets_and_methods()

%outdir = '/scratch/results/17-oct-overnight-compare/';
outdir = '/scratch/results/18-oct-overnight-fear-backup/';

%outdir = '/home/dkd23/results/oct-18-fear/';



datadir = 'arcnet/'
K = 10;


% Now summarize results
log_likelihood_table = NaN( 5, length(datafiles), length(methods));
mse_table = NaN( 5, length(datafiles), length(methods));

folds = 1:K;%[1:2, 4:K] %1:K;

num_missing = 0;

for d_ix = 1:length(datafiles)
    cur_dataset = [ datadir, datafiles{d_ix}];
    [~, shortname] = fileparts(cur_dataset);
    fprintf('\nCompiling results for %s dataset...\n', shortname );   
    
    cur_data = load([ '../' cur_dataset]);
    cur_dataset_variance = var(cur_data.y);
    
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
                mse_table(fold, d_ix, m_ix) = mean( (results.predictions - results.actuals).^2 ) ./ cur_dataset_variance;% ./ std(results.actuals);

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


% Make the names nicer
dataset_names = shorten_names( dataset_names );
method_names = replace_method_names( method_names );


% Now make figures and tables.

meanfunc = @mean;
stdfunc = @std;

likelihoods = squeeze(meanfunc(log_likelihood_table,1));
fprintf('\n\n');
print_table( 'Log Likelihood', method_names, dataset_names, likelihoods' );
%if any(isnan(log_likelihood_table(:)))
%    warning('Some log likelihood entries missing!')
%end

mses = squeeze(meanfunc(mse_table,1));
stds = squeeze(stdfunc(mse_table,1));
fprintf('\n\n');
print_table( 'Normalized MSE', method_names, dataset_names, mses' );

%mset_table = mse_table([1,2,4:K], : ,:);
latex_table('../latex/tables/gpml-table.tex', mse_table, method_names, dataset_names, 'Normalized Mean Squared Error' );
%if any(isnan(mse_table(:)))
%    warning('Some Mean Squared Error entries missing!')
%end

%for f = folds
%    ratio(f,1:3) = mse_table(f,1,2:end)./mse_table(f,1,1);
%end
%errs = std(ratio,1);
%errorbar( mean(ratio,1), errs)
%bar(mses')
%errorbar(mses(1,:)', stds(1,:)')
end

function nicenames = shorten_names( names )
    for i = 1:length(names)
        nicenames{i} = names{i};
        nicenames{i} = strrep(nicenames{i}, 'concatenated_', 'NN ' );
        nicenames{i} = strrep(nicenames{i}, 'nan', ' ' );
        nicenames{i} = strrep(nicenames{i}, '_', ' ' );     
    end
end

function nicenames = replace_method_names( names )
    for i = 1:length(names)
        nicenames{i} = names{i};
        nicenames{i} = strrep(nicenames{i}, 'separate_linear', 'Separate Linear' );
        nicenames{i} = strrep(nicenames{i}, 'separate_gp_ard', 'Separate GP' );
        nicenames{i} = strrep(nicenames{i}, 'linear_nonan', 'Poor Man''s embedding Linear' );
        nicenames{i} = strrep(nicenames{i}, 'gp_ard_nonan', 'Poor Man''s embedding GP' );
        nicenames{i} = strrep(nicenames{i}, 'sep_hierarchical', 'Separate Hierarchical GP' );
        nicenames{i} = strrep(nicenames{i}, 'gp_hierarchical', 'Hierarchical GP' );
    end
end
