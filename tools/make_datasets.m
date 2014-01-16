% make_datasets.m - Splits data into training and testing
% data sets

% Copyright 2013,2014 Marko Dimjašević, Simone Atzeni, Ivo Ugrina, Zvonimir Rakamarić
%
% This file is part of maline.
%
% maline is free software: you can redistribute it and/or modify it
% under the terms of the GNU Affero General Public License as
% published by the Free Software Foundation, either version 3 of the
% License, or (at your option) any later version.
%
% maline is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Affero General Public License for more details.
%
% You should have received a copy of the GNU Affero General Public License
% along with maline.  If not, see <http://www.gnu.org/licenses/>.


% data - The data.
% training_data - The data for training.
% training_labels - The labels for each of the training samples.
% testing_data - The data for testing.
% testing_data - The labels for each of the testing samples.


function [training_data, training_labels, testing_data, testing_labels] = make_datasets(data, ratio, random)

  if random == 1
    printf('Randomly sort...\n');
    idxs = randperm(size(data,1));
    data = data(idxs,:);
    
    % Determine number of points in each set
    training_cnt=floor((ratio / 100) * size(data,1));

    [N dim] = size(data);   

    % Make data set
    training_data = data(1:training_cnt,(1:dim - 1));
    training_labels = data(1:training_cnt,dim);
    testing_data = data((training_cnt+1):end,(1:dim - 1));
    testing_labels = data((training_cnt+1):end,dim);
  else
    printf('Deterministic sort...\n');
    [N dim] = size(data)
    mSize = sum(data(:, dim));
    gSize = N - mSize;
    index = floor((ratio / 100) * gSize);
    training_data = data(1:index,(1:dim - 1));
    training_labels = data(1:index,dim);
    testing_data = data((index + 1):gSize,(1:dim - 1));
    testing_labels = data((index + 1):gSize,dim);
    index = floor((ratio / 100) * mSize);
    training_data = [training_data; data(gSize + 1:gSize + index,(1:dim - 1))];
    training_labels = [training_labels; data(gSize + 1:gSize + index,dim)];
    testing_data = [testing_data; data((gSize + index + 1):end,(1:dim - 1))];
    testing_labels = [testing_labels; data((gSize + index + 1):end,dim)];
  endif
end
