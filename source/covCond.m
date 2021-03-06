function K = covCond(hyp, x, z, i)

% Squared Exponential covariance function with conditional embedding
% distance measure. The covariance function is parameterized as:
%
% k(x^p,x^q) = sf^2 * exp(-0.5*d(x^p, x^q)^2) 
%
% where d^2 =  0                      if   x^p == NaN and x^q == NaN
%              omega^2                if   x^p == NaN xor x^q == NaN
%              omega^2*2*(1 - cos(pi*rho*(x^p - x^q)))     otherwise
%
% where
% sf^2 is the signal variance,
% rho is the length of the line,
% omega is the distance to central point.
%
% hyp = [ log(omega)
%         log(rho)
%         log(sf)  ]
%
% Based on a distance metric by Frank Hutter and Mike Osborne.  Joint work with
% Kevin Swersky and Jasper Snoek.
%
% David Duvenaud
% Sept 2013


if nargin<2, K = '3'; return; end                  % report number of parameters
if nargin<3, z = []; end                                   % make sure, z exists
xeqz = numel(z)==0; dg = strcmp(z,'diag') && numel(z)>0;        % determine mode

omega = exp(hyp(1));                                 % distance to central point
rho = exp(hyp(2));                                               % length of arc
sf2 = exp(2*hyp(3));                                           % signal variance


assert(size(x,2) == 1);  % Only handles 1D input for now.

if xeqz
    z = x;
end

% Use projection into 2D to compute kernel.
xproj = omega .*[ cos(pi*rho*x), sin(pi*rho*x)];
zproj = omega .*[ cos(pi*rho*z), sin(pi*rho*z)];

% Missing points get both coordinates set to zero.
xproj(isnan(xproj)) = 0;
zproj(isnan(zproj)) = 0;

% precompute squared distances
if dg                                                               % vector kxx
  K = zeros(size(xproj,1),1);
else
  if xeqz                                                 % symmetric matrix Kxx
    K = sq_dist(xproj');
  else                                                   % cross covariances Kxz
    K = sq_dist(xproj',zproj');
  end
end

if nargin<4                                                        % covariances
  K = sf2*exp(-K/2);
else                                                               % derivatives
  if i==1       % omega
    K = -sf2*exp(-K/2).*K;
  elseif i==2   % rho
    tempx = x; tempx(isnan(tempx)) = 0;
    tempz = z; tempz(isnan(tempz)) = 0;
    orig_proj = sqrt(sq_dist(tempx',tempz'));
    dd2drho = 2.*sin( pi.*rho*(orig_proj)) .* orig_proj .* pi .* omega^2;
    neithermissing = double(~isnan(x))*double(~isnan(z'));
    K = -0.5*sf2*exp(-K/2) .* dd2drho .*neithermissing .* rho;
  elseif i==3   % sf2
    K = 2*sf2*exp(-K/2);    
  else
    error('Unknown hyperparameter')
  end
end
