function [predictions, log_prob_y, model] ...
    = separate_linear( Xtrain, ytrain, Xtest, ytest )
% Simple maximum-likelihood linear regression model as a sanity check.
%
% This version trains a different model for each number of layers.
% The layer is encoded in the first variable.
%
% David Duvenaud
% Oct 2013

predictions = NaN(size(ytest));
log_prob_y = NaN(size(ytest));

% Break data into levels
for l = 1:6
    % Must get rid of zeros just so we can map to integer levels.
    Xtrain(Xtrain(:,1) == 0, 1) = eps;
    Xtest(Xtest(:,1) == 0, 1) = eps;
    
    % Get the data just from this level.
    cur_train_ixs = ceil(Xtrain(:,1) .* 6) == l;
    cur_test_ixs = ceil(Xtest(:,1) .* 6) == l;
    sum(cur_train_ixs)
    
    % Get just the columns that actually have data.
    nonmissing_cols = all(~isnan(Xtrain(cur_train_ixs, :)),1)
    
    % And don't regress on the level, since that will be the same.
    nonmissing_cols(1) = 0;
    
    % Call the model on just this subset.
    [cur_predictions, cur_log_prob_y, cur_model] ...
        = linear( Xtrain(cur_train_ixs, nonmissing_cols), ytrain(cur_train_ixs), ...
                  Xtest(cur_test_ixs, nonmissing_cols), ytest(cur_test_ixs));
    predictions(cur_test_ixs) = cur_predictions;
    log_prob_y(cur_test_ixs) = cur_log_prob_y;
    model{l} = cur_model;
end



