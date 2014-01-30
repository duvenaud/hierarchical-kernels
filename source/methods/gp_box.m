function [predictions, log_prob_y, model] = gp_box(  Xtrain, ytrain, Xtest, ytest, hyp )

% Implements a multivariate box kernel.
%
%
% David Duvenaud, Jasoer Snoek, Frank Hutter, Mike Osborne, Kevin Swersky
% Oct 2013

hhp = common_gp_parameters();     % Use a common set of hyper-hyper-priors.
[N,D] = size(Xtrain);

% Easy part of model set up:
meanfunc = {'meanConst'};
inference = @infExact;
likfunc = @likGauss;
hyp.mean = 0;
hyp.lik = ones(1,eval(likfunc())).*log(hhp.noise_scale);    

% Set up hypers.
default_x = 0;  default_dist = 0;

% These should be initialized identically gp_ard.
log_lengthscales = log(hhp.length_scale.*gamrnd(hhp.gamma_a, hhp.gamma_b,1,D));
log_variance = log(hhp.sd_scale);

covcond_hypers = [repmat( [default_x; default_dist], 1, D); ...
                  log_lengthscales; ...
                  repmat( log_variance, 1, D)];

% Now construct the kernel.  It will be a product covBox.
list_of_covconds = cell(1, D);
for i = 1:D
    list_of_covconds{i} = { 'covMask', { i, 'covBox'}};
end
covfunc = { 'covProd', list_of_covconds };
hyp.cov = covcond_hypers;

max_iters = hhp.max_iterations;

% Save intialize hyperparameters.
model.init_hypers = hyp;        

% Fit the model.
[cur_hyp, nlZ] = minimize(hyp, @gp, -max_iters, ...
               inference, meanfunc, covfunc, likfunc, Xtrain, ytrain);

model.hypers = cur_hyp;
model.hhp = hhp;
model.marginal_log_likelihood_train = -nlZ(end);
model.marginal_log_likelihood_test = ...
    -gp(model.hypers, inference, meanfunc, covfunc, likfunc, Xtest, ytest);


% Make predictions.
[ymu, ys2, predictions, fs2, log_prob_y] = ...
    gp(model.hypers, inference, meanfunc, covfunc, likfunc, Xtrain, ytrain, Xtest, ytest);
