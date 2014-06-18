#! /usr/bin/octave -qf

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


function classdroid(features_file, results_file, confusion_file)
  addpath(sprintf('%s%s', getenv('MALINE'), '/lib/libsvm-3.17/matlab/'));

  % Reading Input Files
  [N dim ratio random dataWeight dataWeightLabels] = readDataFile(features_file);

  data = dataWeight;
  dataLabels = dataWeightLabels;

  total_data = [data dataLabels];

  # Erase previous content
  fid = fopen(results_file, 'w');
  fclose(fid);

  random = 0;
  for ratio = 50:40:90
    if (ratio == 50) && (random == 0)

      fid = fopen(results_file, 'a');
      fprintf(fid, '%%Ratio: 50 - Random = 0\n');
      fclose(fid);

      file = fopen(confusion_file);
      fprintf(file, '%%Ratio: 50 -  Random = 0\n');
      fclose(file);

      for i = 1:2
	if(i > 1)
	  [testing_data, testing_labels, training_data, training_labels] = make_datasets(total_data, ratio, random);
	else
	  [training_data, training_labels, testing_data, testing_labels] = make_datasets(total_data, ratio, random);
	end
	
	printf('%%Calculating[50 ratio] - Iteration[%d]\n', i);
	svmClassification(training_data, training_labels, testing_data, testing_labels, results_file, confusion_file);
      end
    else
	for index = 1:2
	  random = index - 1;
	  size = 50;
	  if random == 0
	    size = 1;
	  end

	  fid = fopen(results_file, 'a');
	  fprintf(fid, '%%Ratio: 90 -  Random: %d\n', random);
	  fclose(fid);

	  file = fopen(confusion_file, 'a');
	  fprintf(file, '%%Ratio: 90 -  Random: %d\n', random);
	  fclose(file);

	  for i = 1:size
	    [training_data, training_labels, testing_data, testing_labels] = make_datasets(total_data, ratio, random);
	    
	    disp('Calculating...');
	    svmClassification(training_data, training_labels, testing_data, testing_labels, results_file, confusion_file);
	  end
	end
    end
  end
end

% Splits data into training and testing data sets
%
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

function [accuracy] = svmClassification(training_data, training_labels, testing_data, testing_labels, results_file, confusion_file)
  printf("Linear Kernel\n");
  kernel_type = sprintf('-q -t 0');
  [accuracy, model] = svm(training_data, training_labels, testing_data, testing_labels, kernel_type, confusion_file);
  printf( "# of class[%d]\n", model.nr_class);

  fid = fopen(results_file, 'a');
  fprintf(fid, '%f ', accuracy(1));
  fclose(fid);
  
  printf("Polynomial Kernel\n");
  for i = 1:4
    kernel_type = sprintf('-q -t 1 -d %d', i);
    [accuracy model confusion] = svm(training_data, training_labels, testing_data, testing_labels, kernel_type, confusion_file);
    printf( "# of class[%d] - Kernel Degree[%d]\n", model.nr_class, i);

    fid = fopen(results_file, 'a');
    fprintf(fid, '%f ', accuracy(1));
    fclose(fid);
  end

  fid = fopen(results_file, 'a');
  fprintf(fid, '\n');
  fclose(fid);
end

function [accuracy, model, confusion] = svm(training_data, training_labels, testing_data, testing_labels, kernel_type, confusion_file)
  model = svmtrain(training_labels, training_data, kernel_type);
  [predicted_labels, accuracy, decision_values] = svmpredict(testing_labels, testing_data, model);
  size = length(testing_labels)
  confusion = zeros(2);
  for i = 1:size
    if testing_labels(i) == predicted_labels(i)
       j = testing_labels(i) + 1;
       confusion(j, j) = confusion(j, j) + 1;
    else
      j = testing_labels(i) + 1;
      k = predicted_labels(i) + 1;
      confusion(k, j) = confusion(k, j) + 1;
    endif
  end
  [testing_labels predicted_labels];
  confusion;
  file = fopen(confusion_file, 'a');
  fprintf(file, '%f %f\n', confusion(1, :));
  fprintf(file, '%f %f\n', confusion(2, :));
  fclose(file);
end

function [N dim ratio random dataWeight dataWeightLabels] = readDataFile(filename)
  data = [];
  fid = fopen(filename, 'r');
  N = fscanf(fid, '%d', [1 1]);
  dim = fscanf(fid, '%d', [1 1]);
  ratio = fscanf(fid, '%d', [1 1]);
  random = fscanf(fid, '%d', [1 1]);
  for i = 1:N
    data(i, :) = fscanf(fid, '%f ', [1 dim]);
    fscanf(fid, '\n');
  end
  dataWeight = data(:, 1:(dim - 1));
  dataWeightLabels = data(:, dim);
end

arg_list = argv ();
classdroid(arg_list{1}, arg_list{2}, arg_list{3})

%%% Local Variables: ***
%%% mode:octave ***
%%% comment-start: "%"  ***
%%%  End: ***

