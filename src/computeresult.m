% computeresult

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


function computeresult()
  % Reading Input Files 
  [data50, confusionData50, data90, confusionData90, data_rand, confusionData_rand] = readDataFile(sprintf('%s%s', getenv('MALINE'), '/log/final-results.txt'), sprintf('%s%s', getenv('MALINE'), '/log/confusion.txt'));

  labels = ['Linear'; 'Poly deg 1'; 'Poly deg 2'; 'Poly deg 3'; 'Poly deg 4'];

  plot = bar(data50');
  %title('Cross Validation (50% Training Set/50% Testing Set)');
  l =  legend('Case 1', 'Case 2');
  set(l, "fontsize", 16);
  set(gca, 'ytick', [0:10:100]);
  set(gca, 'xtick', [1:5]);
  set(gca, 'xticklabel', labels);
  %ylabel('Accuracy (%)');
  %xlabel('Kernel Type');
  set(gca, 'fontsize', 16);
  print('cross_validation.svg', '-color', '-dsvg');

  means = mean(data_rand);
  dev = std(data_rand);

  printf('Confusion Matrix (50% data set)\n');
  confusionData50

  printf('Confusion Matrix (90% data set)\n');
  confusionData90

  labels = ['Linear'; 'Polyn. 1st'; 'Polyn. 2nd'; 'Polyn. 3rd'; 'Polyn. 4th'];
  printf('Random DataSet (90%%)\n');
  printf('Kernel Type\t| Mean\t\t| Dev\n');
  printf('--------------------------------------------------------\n');

  for i = 1:5
     printf('%s\t| %f\t| %f\n', labels(i, :), means(i), dev(i));
  end

  printf('Confusion Matrix\n');
  sum = zeros(2);
  for i = 1:10:500
    j = (2 * i) - 1;
    i
    confusionData_rand(i:i+1, :)
    sum = sum + confusionData_rand(i:i+1, :);
  end
  sum = sum / 50
end

function [data50, confusionData50, data90, confusionData90, data_rand, confusionData_rand] = readDataFile(filename1, filename2)
  printf('Reading result file...\n');
  file = fopen(filename1);
  fgets(file);
  data50 = fscanf(file, '%f ', [5 2]);
  data50 = data50';
  fgets(file);
  data90 = fscanf(file, '%f ', [5 1]);
  data90 = data90';
  fgets(file);
  data_rand = fscanf(file, '%f ', [5 50]);
  data_rand = data_rand';
  fclose(file);

  printf('Reading confusion file...\n');
  file = fopen(filename2);
  fgets(file)
  confusionData50 = [];
  for i = 1:10
    confusionData50 = [confusionData50; fscanf(file, '%f %f', [1 2])];
    confusionData50 = [confusionData50; fscanf(file, '%f %f\n', [1 2])];
  end
  fgets(file);
  confusionData90 = [];
  for i = 1:5
    confusionData90 = [confusionData90; fscanf(file, '%f %f', [1 2])];
    confusionData90 = [confusionData90; fscanf(file, '%f %f\n', [1 2])];
  end
  fgets(file);
  confusionData_rand = [];
  for i = 1:250
    confusionData_rand = [confusionData_rand; fscanf(file, '%f %f', [1 2])];
    confusionData_rand = [confusionData_rand; fscanf(file, '%f %f\n', [1 2])];
  end
  fclose(file);
end

%%% Local Variables: ***
%%% mode:octave ***
%%% comment-start: "%"  ***
%%%  End: ***
