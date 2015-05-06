/*
 Copyright 2013,2014 Marko Dimjašević, Simone Atzeni, Ivo Ugrina, Zvonimir Rakamarić

 This file is part of maline.

 maline is free software: you can redistribute it and/or modify it
 under the terms of the GNU Affero General Public License as
 published by the Free Software Foundation, either version 3 of the
 License, or (at your option) any later version.

 maline is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License for more details.

 You should have received a copy of the GNU Affero General Public License
 along with maline.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <sstream>
#include <boost/algorithm/string/predicate.hpp>
#include <boost/algorithm/string/split.hpp>
#include <boost/algorithm/string/classification.hpp>
#include <boost/iostreams/filtering_stream.hpp>
#include <boost/lexical_cast.hpp>

using namespace boost::algorithm;

int main(int argc, char **argv)
{
  int N, ratio;
  int mSize, mTrainingSize, mTestingSize;
  int gSize, gTrainingSize, gTestingSize;

  std::string line;

  if(argc < 2) {
    printf("Usage: %s FILENAME RATIO\n", argv[0]);
    exit(-1);
  }


  std::istringstream buffer(argv[2]);
  buffer >> ratio;

  std::string filename1(argv[1]);
  std::stringstream s1;
  s1 << ratio;
  filename1.append(".training." + s1.str());
  std::ofstream training_file(filename1.c_str());
  if(!training_file.is_open()) {
    std::cerr << "Couldn't open " << filename1 << std::endl;
    exit(-1);
  }

  std::string filename2(argv[1]);
  std::stringstream s2;
  s2 << ratio;
  filename2.append(".testing." + s2.str());
  std::ofstream testing_file(filename2.c_str());
  if(!testing_file.is_open()) {
    std::cerr << "Couldn't open " << filename2 << std::endl;
    exit(-1);
  }

  std::ifstream file(argv[1], std::ios_base::in);
  boost::iostreams::filtering_istream in1;
  in1.push(file);
  mSize=0;
  gSize=0;
  for(; std::getline(in1, line); ) {
    //std::cout << "Processed line " << line.size() << "\n";
    if (boost::starts_with(line, "0"))
      gSize++;
    else
      mSize++;
  }

  gTrainingSize = (ratio * gSize) / 100;
  gTestingSize =  gSize - gTrainingSize;
  mTrainingSize = (ratio * mSize) / 100;
  mTestingSize =  mSize - mTrainingSize;

  printf("# Apps | goodware | malware | total\n");
  printf("Total | %d | %d | %d\n", gSize, mSize, gSize + mSize);
  printf("Training | %d | %d | %d\n", gTrainingSize, mTrainingSize, gTrainingSize + mTrainingSize);
  printf("Testing | %d | %d | %d\n", gTestingSize, mTestingSize, gTestingSize + mTestingSize);

  std::ifstream file2(argv[1], std::ios_base::in);
  boost::iostreams::filtering_istream in2;
  in2.push(file2);
  
  int i = 0;
  for(; std::getline(in2, line); ) {
    
    if(i < gTrainingSize) {
      training_file << line << "\n";
    } else if(i < gSize) {
      testing_file << line << "\n";
    } else if(i < gSize + mTrainingSize) {
      training_file << line << "\n";
    } else {
      testing_file << line << "\n";
    }
    
    i++;
  }
  
  training_file.close();
  testing_file.close();

  return 0;
}
