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

% Map the level bins to discrete values
num_levels = 6;
X(X(:,1) == 0, 1) = eps;
X(:, 1) = (ceil(X(:,1) .* num_levels)./num_levels);
length(unique(X(:,1)))

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


% Now make versions of the data with half as much data.
load concatenated_nan.mat
X = X(1:2:end, :);
D = D(1:2:end, :);
y = y(1:2:end);
save('concatenated_nan_half.mat', 'X', 'y', 'D' );

load concatenated_nan_log.mat
X = X(1:2:end, :);
D = D(1:2:end, :);
y = y(1:2:end);
save('concatenated_nan_log_half.mat', 'X', 'y', 'D' );



% Some exploratory data analysis
[N,dims] = size(X)

for d = 1:dims
    clf; plot(squeeze(X(:, d)), y, '.');
    title(d);
    pause;
end
