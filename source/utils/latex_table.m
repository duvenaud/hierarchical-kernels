% Turns an array of results into a nice LaTeX table.
% This version also print error bars.
%
% Adapted from Ryan Turner's code.
%
% David Duvenaud
% May 2011
% ========================
function resultsToLatex4(filename, results, methodNames, metricNames, ...
  experimentName)

meanfunc = @mean;
stdfunc = @std;
results = permute(results, [ 3 2 1 ] );

meanScore = meanfunc(results, 3);
stds = stdfunc(results,1,3);   % 1 or 0 here? unbiasedness, etc.

file = fopen( filename, 'w');

for i = 1:length(methodNames)
    methodNames{i} = strrep(methodNames{i}, '_', ' ');
end

for i = 1:length(metricNames)
    metricNames{i} = strrep(metricNames{i}, '_', ' ');
end

% This is maximum digits left of the dot AFTER shifting the column over by
% the exponent from fixMatrix(). Note that MaxLeftDigits is not the same as
% maxSigFigs.
maxLeftDigits = 1;
maxClip = 10 ^ maxLeftDigits;

[methods metrics] = size(meanScore);
assert(length(methodNames) == methods);
assert(length(metricNames) == metrics);
maxClipCol = zeros(metrics, 1);

% argmin might have trouble if methods is singleton. TODO fix
[best, best_ix] = min(meanScore);
% nearbest keeps track of if we are significantly different from the best
% model.
nearbest = zeros( size(meanScore));
for ii = 1:methods  
    for jj = 1:metrics
        % run a paired ttest
        %if abs(meanScore(ii,jj) - best(jj)) <= stds(ii,jj) + stds(best_ix(jj), jj)
        h = ttest(results(ii,jj,:), results(best_ix(jj), jj, :));
        if isnan(h) || h == 0
            nearbest(ii,jj) = 1;
        end
    end
end
% Crop the error bars to two digits, shift everything to right exponent, and
% crop the scores to match the error bars.
%[meanScore, errorBar, exponent, prec] = fixMatrix(meanScore, errorBar);

% Print all the usual table header stuff
fprintf(file, '%% --- Automatically generated by resultsToLatex4.m ---\n');
fprintf(file, '%% Exported at %s\n', datestr(now()));
%fprintf(file, '\\begin{table}[h!]\n');
%fprintf(file, '\\caption{{\\small\n');
%fprintf(file, '%s\n', experimentName);
%fprintf(file, '}}\n');
%fprintf(file, '\\label{tbl:%s}\n', experimentName);
fprintf(file, '\\begin{center}\n');
fprintf(file, '\\begin{tabular}{l |%s}\n', repmat(' r', 1, metrics));

% first line
fprintf(file, 'Method');
for ii = 1:metrics
  fprintf(file, ' & \\rotatebox{0}{ %s } ', metricNames{ii});
  
  % We don't want the clip to be so small even the best method gets clipped
  orderMagBest = exp10(2+ceil(log10(max(min(meanScore(:, ii)), 0))));
  maxClipCol(ii) = max(maxClip, orderMagBest);
end
fprintf(file, ' \\\\ \\hline\n');

% for each method
for ii = 1:methods
  fprintf(file, methodNames{ii});
  for jj = 1:metrics
    printFormat = ['%4.3f'];
    
    %if best(jj) == ii
    if nearbest(ii, jj)
      %fprintf(file, [' & $\\mathbf{' printFormat '} \\pm %2.1f$'], ...
      fprintf(file, [' & $\\mathbf{' printFormat '}$'], ...
        meanScore(ii, jj));
    elseif meanScore(ii, jj) > maxClipCol(jj)
      fprintf(file, ' & $>$ %d', maxClipCol(jj));
    else
      %fprintf(file, [' & $' printFormat ' \\pm %2.1f$' ], ...
      fprintf(file, [' & $' printFormat '$' ], ...
        meanScore(ii, jj));
    end
  end
  fprintf(file, ' \\\\\n');
end

fprintf(file, '\\end{tabular}\n');
fprintf(file, '\\end{center}\n');
%fprintf(file, '\\end{table}\n');
fprintf(file, '%% End automatically generated LaTeX\n');
fclose(file);