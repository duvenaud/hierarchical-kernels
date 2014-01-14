function K = covBox(hyp, x, z, i)

% Squared Exponential covariance function with conditional embedding
% distance measure. The covariance function is parameterized as:
%
% k(x^p,x^q) = sf^2 * exp(-0.5*d(x^p, x^q)^2) 
%
% where d^2 =  0                      if   x^p == NaN and x^q == NaN
%              (x, 0) - (rho, omega)  if   x^p == NaN xor x^q == NaN
%              (x^p - x^q)^2          otherwise
%
% where
% sf^2 is the signal variance,
% rho is location of the default value along the line,
% omega is the distance to the default value from the line.
%
% hyp = [ log(omega)
%         log(rho)
%         log(sf)  ]
%
% Joint work with Kevin Swersky, Jasper Snoek, Frank Hutter and Mike Osborne.
%
% David Duvenaud
% Jan 2014


if nargin<2, K = '3'; return; end                  % report number of parameters
if nargin<3, z = []; end                                   % make sure, z exists
xeqz = numel(z)==0; dg = strcmp(z,'diag') && numel(z)>0;        % determine mode

omega = hyp(1);                               
rho = hyp(2);                                               
sf2 = exp(2*hyp(3));                                           % signal variance


assert(size(x,2) == 1);  % Only handles 1D input for now.

if xeqz
    z = x;
end

x = x(:);
z = z(:);

% Use projection into 2D to compute kernel.
xproj = [x, zeros(size(x,1), 1)];
zproj = [z, zeros(size(z,1), 1)];

num_x_missing = sum(isnan(x));
num_z_missing = sum(isnan(z));

% Missing points get both coordinates set to default.
xproj(isnan(x),:) = [rho .* ones(num_x_missing,1), omega .* ones(num_x_missing,1)];
zproj(isnan(z),:) = [rho .* ones(num_z_missing,1), omega .* ones(num_z_missing,1)];

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
    onemissing = double(bsxfun(@xor, isnan(x), isnan(z')));
    K = -sf2*exp(-K/2) .* onemissing .* omega;
  elseif i==2   % rho
    %onethere = x;
    %onethere(isnan(x)) = z(isnan(x));
    xdists = rho - x;  xdists(isnan(x)) = 1;
    zdists = rho - z;  zdists(isnan(z)) = 1;
    onemissing = double(bsxfun(@xor, isnan(x), isnan(z')));
    
    K = -sf2*exp(-K/2) .* onemissing .* (xdists * zdists');
  elseif i==3   % sf2
    K = 2*sf2*exp(-K/2);    
  else
    error('Unknown hyperparameter')
  end
end
