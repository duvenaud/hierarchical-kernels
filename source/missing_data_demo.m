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
truefunc = @(x) 1./(1+exp(-(x - 0.5).*10));
censoring = @(y) y < 0.5;
noise_variance = 0.1;


% Generate the population
N = 100;
x = rand(N,1);   % x has to be bounded between 0 and 1.

% Create some data from the true model.
y = truefunc(x) + randn(N,1) .* sqrt(noise_variance);
censored_ixs = censoring(y);
censored_scores = y;
censored_scores(censored_ixs) = NaN;

n_xstar = 200;
xstar = linspace( 0, 1, n_xstar )';
xstar_censored = NaN(size(xstar));


% Set up the conditional model.
% kernel parameters
omega = 10;  rho = 0.2;  sf2 = 1;

covfunc = @covCond;
likfunc = @likGauss;
meanfunc = @meanConst;

hyp_cond.lik = log(noise_variance);
hyp_cond.cov = [log(omega);log(rho);log(sf2)];
hyp_cond.mean = mean(y);

%hyp = minimize(hyp, @gp, -100, @infExact, [], covfunc, likfunc, X1, Y1(:, n));

% Predict uncensored
[m s2] = gp(hyp_cond, @infExact, meanfunc, covfunc, likfunc, censored_scores, y, xstar);
% Predict censored
[m_c s2_c] = gp(hyp_cond, @infExact, meanfunc, covfunc, likfunc, censored_scores, y, xstar_censored);



figure(1);
plot( xstar, truefunc(xstar), 'g-' ); hold on;
plot( x, y, 'kx');
plot( x(censored_ixs), y(censored_ixs), 'rx');
plot( xstar, m, 'b-' );
plot( xstar, m_c, 'r-' );
legend({'True Function', 'Uncensored observations', 'Censored observations', 'Prediction if uncensored', 'Prediction if censored'}, ...
    'Location', 'Best');
set(gcf, 'color', 'white');
xlabel('True creditworthiness');
ylabel('Credit score');
title('Handling missing data');
