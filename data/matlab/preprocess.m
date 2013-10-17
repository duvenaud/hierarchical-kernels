% Combine all datasets.
%
% David Duvenaud
% Oct 2013.
close all;
clear all;

% Fix the seed of the random generators.
seed = 0;
randn('state',seed);
rand('state',seed);


datadir = 'arcnet/';
datafiles = dir([ datadir, '*.mat']);
outdir = '';

% Concatenate the data.
for dataset_ix = 1:length(datafiles)
    cur_dataset_name = [ datadir, datafiles(dataset_ix).name];
    cur_dataset = load(cur_dataset_name);
    
    if dataset_ix == 1
        X = cur_dataset.X;
        y = cur_dataset.y;
        D = cur_dataset.D;
    else
        X = [X; cur_dataset.X];
        y = [y; cur_dataset.y];
        D = [D; cur_dataset.D];
    end
end

save('concatenated.mat', 'X', 'y', 'D' );
orig_y = y;
y = log(y);
save('concatenated_log.mat', 'X', 'y', 'D' );
y = orig_y;


orig_X = X;
X(D == 0) = NaN;
save('concatenated_nan.mat', 'X', 'y', 'D' );

orig_y = y;
y = log(y);
save('concatenated_nan_log.mat', 'X', 'y', 'D' );
y = orig_y;



% Some exploratory data analysis
[N,dims] = size(X)

for d = 1:dims
    clf; plot(squeeze(X(:, d)), y, '.');
    title(d);
    pause;
end
