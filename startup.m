% Copyright Notice
%
% Copyright (C) 2024 CentraleSupelec
%
%    Authors: Romain Ait Abdelmalek-Lomenech <romain.ait@centralesupelec.fr> 
%             Julien Bect <julien.bect@centralesupelec.fr>

% Locate project root
root = fileparts (mfilename ('fullpath'));

% Add contrib-qsi to the path
% (this step also clones & initializes STK 2.8.1 if needed)
run (fullfile (root, 'algorithms', 'stk-contrib-qsi', 'startup.m'));

addpath (fullfile (root, 'sys'));
addpath (fullfile (root, 'testcases', 'volcano-case'));
addpath (fullfile (root, 'misc'));
