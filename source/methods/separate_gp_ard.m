function [predictions, log_prob_y, model] ...
    = separate_gp_ard( Xtrain, ytrain, Xtest, ytest )
% This version trains a different model for each number of layers.
%
% David Duvenaud
% Oct 2013

[predictions, log_prob_y, model] ...
    = separate_levels( @gp_ard, Xtrain, ytrain, Xtest, ytest );

