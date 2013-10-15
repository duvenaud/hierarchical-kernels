function test_hier_cov
% rand('state', 1234);
W = 0.3; % width hyperparameter
N = 1000; % # data points

num_cat = 5; % # categorical dimensions; first columns in x
num_values = 4; % # categorical values
num_allowing_values = 2; % values 1,...,num_allowing_values allow children to be active

num_cont = 10; % # categorical dimensions; last columns in x
L = 0; % lower bound for x
U = 1; % upper bound for x
D = num_cat + num_cont; % # dimensions

% Kernel functions defined through distance metrics.
k = @(D) exp(-0.5 * D.^2); % exponentiated quadratic
% k = @(D) exp(1 + D.^2/4).^-2; % rational quadratic
% k = @(D) (1 + sqrt(3)*D) .* exp(-sqrt(3) * D); % Matern 3/2

% Set random parents.
parents = zeros(D,0);
numparents = zeros(D,1);
for d=1:D
    for p=1:min(num_cat,d-1)
        if rand < 0.5
            numparents(d) = numparents(d)+1;
            parents(d,numparents(d)) = p;
        end
    end
end

% Sample N random points.
x(:,1:num_cat) = ceil(num_values*rand(N, num_cat));
x(:,num_cat+1:num_cat+num_cont) = rand(N, num_cont)*(U - L) + L;

% Compute which dimensions are active.
isactive_matrix = nan(N,D);
for i = 1:N
    for d=1:D
        isactive_matrix(i,d) = is_active(d, x(i,:), num_allowing_values, parents);
    end
end

% Compute distance.
Dist = zeros(N,N,D);
for i=1:N
    for j=1:N
        for d=1:D
            if isactive_matrix(i, d)
                if isactive_matrix(j, d)
                    if d <= num_cat
                        if x(i,d) ~= x(j,d)
                            Dist(i,j,d) = Dist(i,j,d) + W * sqrt(2); % both active, different categorical
                        end
                    else
                        Dist(i,j,d) = Dist(i,j,d) + W * sqrt(2) * sqrt(1 - cos( pi * (x(i,d)-x(j,d))/(U-L) ) ); % both active, continuous
                    end
                else
                    Dist(i,j,d) = Dist(i,j,d) + W; % one active, but not the other.
                end
            else
                if isactive_matrix(j, d)
                    Dist(i,j,d) = Dist(i,j,d) + W; % one active, but not the other.
                end
            end
        end
    end
end

% Some output.
parents
%x
%isactive_matrix

% We can make a kernel for each dimension and multiply the kernels.
K = nan(N,N,D);
for d=1:D
    K(:,:,d) = k(Dist(:,:,d));
    min_eig_from_individual_kernel = min(eig( K(:,:,d) ))
end
K_combined = prod(K,3);
min_eig_K_combined_correctly = min(eig( K_combined ))

% But we can't just add up the distances!
Dist_sum = sum(Dist,3);
min_eig_of_k_with_dist_sum_combined_wrongly = min(eig(k(Dist_sum))) % not PSD!


% Function computing whether a given dimension is active in a given x.
function result = is_active(dim, x, num_allowing_values, parents)

all_parents = parents(dim,:);
for i=1:length(all_parents)
    p = all_parents(i);
    if p==0 
        break; % variable has no more parents
    end
    if ~is_active(p, x, num_allowing_values, parents) 
        result = 0; % all parents must be active
        return
    end
    if x(p) > num_allowing_values
        result = 0; % all parents must have an allowing value
        return
    end
end
result = 1;