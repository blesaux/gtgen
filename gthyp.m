%% gthyp.m
% A script for generating gound-truth masks for multi-spectral images
%
% Copyright (C) <2015> Bertrand Le Saux & Adrien Lagrange
% Comments to: bertrand.le_saux@onera.fr
%
% This program is free software: you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of  MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% If used for published research work, please cite:
% Adrien Lagrange, Bertrand Le Saux, Anne Beaupere, Alexandre Boulch,
% Adrien Chan-Hon-Tong, Stéphane Herbin, Hicham Randrianarivo, Marin
% Ferecatu, "Benchmarking classification of Earth-observation data:
% from learning explicit features to convolutional networks", Proc. of
% IGARSS 2015.

%% load hypX image
clear all;
close all;


path = './';
datName = 'SalinasA.mat';
load([path datName]);
dat=double(salinasA);
dat=dat/max(dat(:));

%% display
figure(1);
if exist('./mask.mat', 'file') == 2
    %% current local mask
    load('./mask.mat');

    % paintMask(ortho,mask);
    paintMaskNd( dat, mask );
else
    %% no existing mask
    paintMaskNd( dat );
end
