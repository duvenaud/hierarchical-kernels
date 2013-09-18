% Demo of using the Frank Hutter and Mike Osborne's conditional covariance 
% to handle missing data.
%
% The scenario is that we're estimating loan returns based on credit scores.
% However, the people with really low credit scores don't report them, so
% they're missing.
%
% David Duvenaud
% Sept 2013.


% Fix the seed of the random generators.
seed = 0;
randn('state',seed);
rand('state',seed);

addpath(genpath('gpml'))


% True function:
truefunc = @(x) 1./(1+exp(-(x - 0.5).*20));
censoring = @(y) y < 0.5;
true_noise_variance = 0.01;


% Generate the population
N = 200;
orig_x = rand(N,1);   % x has to be bounded between 0 and 1.

% Create some data from the true model.
y = truefunc(orig_x) + randn(N,1) .* sqrt(true_noise_variance);
censored_ixs = censoring(y);
obs_x = orig_x;
obs_x(censored_ixs) = NaN;

n_xstar = 200;
xstar = linspace( 0, 1, n_xstar )';
xstar_censored = NaN(size(xstar));


% Set up the conditional model.
% kernel parameters
omega = 1;  rho = 0.1;  sf2 = 1;
noise_variance = 0.1;

covfunc = @covCond;
likfunc = @likGauss;
meanfunc = @meanConst;

hyp_cond.lik = log(noise_variance);
hyp_cond.cov = [log(omega);log(rho);log(sf2)];
hyp_cond.mean = mean(y);

hyp_opt = minimize(hyp_cond, @gp, -100, @infExact, meanfunc, covfunc, likfunc, obs_x, y);

estimated_kernel_params = exp(hyp_opt.cov)
estimated_noise = exp(hyp_opt.lik)
estimated_mean = exp(hyp_opt.mean)


% Predict uncensored
[m, s2] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, obs_x, y, xstar);
% Predict censored
[m_c s2_c] = gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, obs_x, y, xstar_censored);


% Plot results.
light_blue = [227 237 255]./255;
light_red = [255 227 237]./255;
opacity = 1;
figure(1); clf; 

% Predictions if uncensored
jbfill( xstar', m' + 2.*s2', m' - 2.*s2', light_blue, 'none', 1, opacity); hold on;
h_pnc = plot( xstar, m, 'b-' ); hold on;

% Predictions if censored
jbfill( xstar', m_c' + 2.*s2_c', m_c' - 2.*s2_c', light_red, 'none', 1, opacity); hold on;
h_pc = plot( xstar, m_c, 'r-' ); hold on;

h_tf = plot( xstar, truefunc(xstar), 'g-' ); 
h_uo = plot( orig_x, y, 'kx');
h_co = plot( orig_x(censored_ixs), y(censored_ixs), 'rx');


legend([h_tf h_uo h_co h_pnc h_pc], {'True Function', 'Uncensored observations', 'Censored observations', 'Prediction if uncensored', 'Prediction if censored'}, ...
    'Location', 'Best');
set(gcf, 'color', 'white');
xlabel('True creditworthiness');
ylabel('Credit score');
title('Handling missing data');
