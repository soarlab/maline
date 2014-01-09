% classDroid
%
% authors: Simone Atzeni, Marko Dimjašević

function classdroid()
  addpath(sprintf('%s%s', getenv('MALINE'), '/lib/libsvm-3.17/matlab/'));

  % Reading Input Files
  [N dim ratio random dataWeight dataWeightLabels dataCount dataCountLabels] = readDataFile(sprintf('%s%s', getenv('MALINE'), '/data/feature_data.dat'));

  data = dataWeight;
  dataLabels = dataWeightLabels;
  %data = dataCount;
  %dataLabels = dataCountLabels;

  total_data = [data dataLabels];

  source('make_datasets.m');

  results_file_name = sprintf('%s%s', getenv('MALINE'), '/log/results.txt');

  # Erase previous content
  fid = fopen(results_file_name, 'w');
  fclose(fid);

  random = 0;
  for ratio = 50:40:90
    if (ratio == 50) && (random == 0)

      fid = fopen(results_file_name, 'a');
      fprintf(fid, '%%Ratio: 50 - Random = 0\n');
      fclose(fid);

      file = fopen(sprintf('%s%s', getenv('MALINE'), '/log/confusion.txt'), 'a');
      fprintf(file, '%%Ratio: 50 -  Random = 0\n');
      fclose(file);

      for i = 1:2
	if(i > 1)
	  [testing_data, testing_labels, training_data, training_labels] = make_datasets(total_data, ratio, random);
	else
	  [training_data, training_labels, testing_data, testing_labels] = make_datasets(total_data, ratio, random);
	end
	
	printf('%%Calculating[50 ratio] - Iteration[%d]\n', i);
	svmClassification(training_data, training_labels, testing_data, testing_labels, results_file_name);
      end
    else
	for index = 1:2
	  random = index - 1;
	  size = 50;
	  if random == 0
	    size = 1;
	  end

	  fid = fopen(results_file_name, 'a');
	  fprintf(fid, '%%Ratio: 90 -  Random: %d\n', random);
	  fclose(fid);

	  file = fopen(sprintf('%s%s', getenv('MALINE'), '/log/confusion.txt'), 'a');
	  fprintf(file, '%%Ratio: 90 -  Random: %d\n', random);
	  fclose(file);

	  for i = 1:size
	    [training_data, training_labels, testing_data, testing_labels] = make_datasets(total_data, ratio, random);
	    
	    %% size(training_data);
	    %% size(training_labels);
	    %% size(testing_data);
	    %% size(testing_labels);
	    
	    disp('Calculating...');
	    svmClassification(training_data, training_labels, testing_data, testing_labels, results_file_name);
	  end
	end
    end
  end
end

function [accuracy] = svmClassification(training_data, training_labels, testing_data, testing_labels, results_file_name)
  printf("Linear Kernel\n");
  kernel_type = sprintf('-q -t 0');
  [accuracy, model] = svm(training_data, training_labels, testing_data, testing_labels, kernel_type);
  printf( "# of class[%d]\n", model.nr_class);

  fid = fopen(results_file_name, 'a');
  fprintf(fid, '%f ', accuracy(1));
  fclose(fid);
  
  printf("Polynomial Kernel\n");
  for i = 1:4
    kernel_type = sprintf('-q -t 1 -d %d', i);
    [accuracy model confusion] = svm(training_data, training_labels, testing_data, testing_labels, kernel_type);
    printf( "# of class[%d] - Kernel Degree[%d]\n", model.nr_class, i);

    fid = fopen(results_file_name, 'a');
    fprintf(fid, '%f ', accuracy(1));
    fclose(fid);
  end

  fid = fopen(results_file_name, 'a');
  fprintf(fid, '\n');
  fclose(fid);
end

function [accuracy, model, confusion] = svm(training_data, training_labels, testing_data, testing_labels, kernel_type)
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
  file = fopen(sprintf('%s%s', getenv('MALINE'), '/log/confusion.txt'), 'a');
  fprintf(file, '%f %f\n', confusion(1, :));
  fprintf(file, '%f %f\n', confusion(2, :));
  fclose(file);
end

function [N dim ratio random dataWeight dataWeightLabels dataCount dataCountLabels] = readDataFile(filename)
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
 
  data = [];
  for i = 1:N
    data(i, :) = fscanf(fid, '%f ', [1 dim]);
    fscanf(fid, '\n');
  end
  fclose(fid);
  dataCount = data(:, 1:(dim - 1));
  dataCountLabels = data(:, dim);
end

%%% Local Variables: ***
%%% mode:octave ***
%%% comment-start: "%"  ***
%%%  End: ***
