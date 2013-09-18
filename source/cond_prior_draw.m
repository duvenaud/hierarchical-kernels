% Draws a function from the conditional kernel prior.
%
% David Duvenaud
% Sept 2013.


% Fix the seed of the random generators.
seed = 0;
randn('state',seed);
rand('state',seed);

addpath(genpath('gpml'))



% Generate the population
N = 200;
x = linspace(0,1,N)';   % x has to be bounded between 0 and 1.
censored_ixs = 1:N < floor(N/2);
x(censored_ixs) = NaN;

% kernel parameters
omega = 10;  rho = 0.2;  sf2 = 1;
hyp_cond.cov = [log(omega);log(rho);log(sf2)];
noise_variance = 0.1;

% Sample a function.
K = covCond(hyp_cond.cov, x, x);
%imagesc(K);

f = mvnrnd( zeros(N,1), K);

plot(x(~censored_ixs), f(~censored_ixs), 'b-');

