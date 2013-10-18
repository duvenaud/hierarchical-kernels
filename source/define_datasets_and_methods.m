function [datafiles, methods] = define_datasets_and_methods()
    

datafiles = {};
datafiles{end+1} = '../data/matlab/sanity_easy.mat';
datafiles{end+1} = '../data/matlab/sanity_hard.mat';
datafiles{end+1} = '../data/matlab/concatenated_nan.mat';
datafiles{end+1} = '../data/matlab/concatenated_nan_log.mat';


% define methods
methods = {};
methods{end+1} = @linear_nonan;
methods{end+1} = @gp_nonan;
methods{end+1} = @separate_gp_hierarchical;
methods{end+1} = @gp_hierarchical;
methods{end+1} = @separate_linear;
methods{end+1} = @separate_gp_ard;