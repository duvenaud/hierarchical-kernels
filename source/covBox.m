function K = covBox(hyp, x, z, i)

% Squared Exponential covariance function with conditional embedding
% distance measure. The covariance function is parameterized as:
%
% k(x^p,x^q) = sf^2 * exp(-0.5*d(x^p, x^q)^2) 
%
% where d^2 =  0                      if   x^p == NaN and x^q == NaN
%              (x/ell - default_x/ell)^2 + default_dist^2  if   x^p == NaN xor x^q == NaN
%              (x^p - x^q)^2/ell^2          otherwise
%
% where
% sf^2 is the signal variance,
% default_x is location of the default value along the line,
% default_dist is the distance to the default value from the line.
%
% hyp = [ default_x
%         default_dist
%         log(ell)
%         log(sf)  ]
%
% Joint work with Kevin Swersky, Jasper Snoek, Frank Hutter and Mike Osborne.
%
% David Duvenaud
% Jan 2014


if nargin<2, K = '4'; return; end                  % report number of parameters
if nargin<3, z = []; end                                   % make sure, z exists
xeqz = numel(z)==0; dg = strcmp(z,'diag') && numel(z)>0;        % determine mode

default_x = hyp(1);                               
default_dist = hyp(2);  
ell = exp(hyp(3));
sf2 = exp(2*hyp(4));                                           % signal variance


assert(size(x,2) == 1);  % Only handles 1D input for now.


if xeqz
    z = x;
end
x = x(:)./ell;
z = z(:)./ell;

% Use projection into 2D to compute kernel.
xproj = [x, zeros(size(x,1), 1)];
zproj = [z, zeros(size(z,1), 1)];

num_x_missing = sum(isnan(x));
num_z_missing = sum(isnan(z));

% Missing points get both coordinates set to default.
xproj(isnan(x),:) = [default_x .* ones(num_x_missing,1) ./ ell, default_dist .* ones(num_x_missing,1)];
zproj(isnan(z),:) = [default_x .* ones(num_z_missing,1) ./ ell, default_dist .* ones(num_z_missing,1)];

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
  if i==1       % default_x
    xdists = x - default_x./ ell;  xdists(isnan(x)) = 1;
    zdists = z - default_x./ ell;  zdists(isnan(z)) = 1;
    onemissing = double(bsxfun(@xor, isnan(x), isnan(z')));      
    K = sf2*exp(-K/2) .* onemissing .* (xdists * zdists') ./ ell;
  elseif i==2   % default_dist
    onemissing = double(bsxfun(@xor, isnan(x), isnan(z')));  
    K = -sf2*exp(-K/2) .* onemissing .* default_dist;%(xdists * zdists');
  elseif i==3   % ell
      K2 = sq_dist(xproj(:,1)', zproj(:,1)');   % K without default_dist
      K = sf2*exp(-K/2).*K2;
  elseif i==4   % sf2
    K = 2*sf2*exp(-K/2);    
  else
    error('Unknown hyperparameter')
  end
end
