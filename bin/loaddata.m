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

function loaddata2(foldername, outputfile)
  % Reading Input Files 

  [gN gDataWeight] = readFiles(sprintf('%s%s', foldername, '/goodware'));
  [mN mDataWeight] = readFiles(sprintf('%s%s', foldername, '/malware'));
  printf('Creating Labels...\n');
  dataWeightLabels = zeros(length(gDataWeight(:, 1)), 1);
  %% dataCountLabels = zeros(length(gDataCount(:, 1)), 1);
  dataWeightLabels = [dataWeightLabels; ones(length(mDataWeight(:, 1)), 1)];
  %% dataCountLabels = [dataCountLabels; ones(length(mDataCount(:, 1)), 1)];
  printf('Creating Data Matrix...\n');
  dataWeight = [gDataWeight; mDataWeight];
  %% dataCount = [gDataCount; mDataCount];

  printf('Creating Final...\n');
  dataWeightFinal = [dataWeight dataWeightLabels];
  %% dataCountFinal = [dataCount dataCountLabels];
  dim = size(dataWeightFinal);
  printf('Creating Last Matrix\n...');
  %% data = [dataWeightFinal; dataCountFinal];
  data = dataWeightFinal;

  printf('Creating data file...\n');
  fid = fopen(outputfile, 'w+');
  fprintf(fid, '%d ', dim);
  fprintf(fid, '90 ');
  fprintf(fid, '1');
  fprintf(fid, '\n');
  printf("Writing data...");
  for i = 1:size(data(:,1))
     fprintf(fid, '%f ', data(i, :));
     fprintf(fid, '\n');
  end
  fclose(fid);
end

function [N dataWeight] = readFiles(foldername)
  N = 0;
  dataWeight = [];
  filelist = readdir(foldername);
  for ii = 1:numel(filelist)
    ## skip special files . and ..
    if (regexp (filelist{ii}, "^\\.\\.?$"))
      continue;
    endif
    ## load your file
    path = sprintf('%s/%s', foldername, filelist{ii});
    printf('Reading file %s... ', filelist{ii});
    [localN, localDataWeight] = readDataFile(path);
    printf('done\n');
    dataWeight = [dataWeight; localDataWeight];
    N = localN;
  endfor
  printf('All files Done!\n');
end

function [N, dataWeight] = readDataFile(filename)
  file = fopen(filename);
  dim = fscanf(file, '%d', [1 1]);
  dataWeight = fscanf(file, '%f ', [dim dim]);
  dataWeight = dataWeight(:)';
  N = dim * dim;
  fclose(file);
end

arg_list = argv ();
loaddata2(arg_list{1}, arg_list{2})


%%% Local Variables: ***
%%% mode:octave ***
%%% comment-start: "%"  ***
%%%  End: ***
