function [predictions, log_prob_y, model] = gp_ard( Xtrain, ytrain, Xtest, ytest )

inference = @infExact;
likfunc = @likGauss;
hhp = common_gp_parameters();     % Use a common set of hyper-hyper-priors.
[N,D] = size(Xtrain);

covfunc = { 'covSEard' };   
%meanfunc = {'meanSum',{'meanConst','meanLinear'}};
meanfunc = {'meanConst'};

% Randomly draw hyperparameters.
%hyp.mean = [0; ones(D,1)];
hyp.mean = 0;
hyp.lik = ones(1,eval(likfunc())).*log(hhp.noise_scale);    
log_lengthscales = log(hhp.length_scale.*gamrnd(hhp.gamma_a, hhp.gamma_b,1,D));
log_variance = log(hhp.sd_scale);
hyp.cov = [ log_lengthscales, log_variance ];
max_iters = hhp.max_iterations

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
 
