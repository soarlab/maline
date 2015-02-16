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
#include <boost/algorithm/string/split.hpp>
#include <boost/algorithm/string/classification.hpp>
#include <boost/iostreams/filtering_stream.hpp>
#include <boost/lexical_cast.hpp>

using namespace boost::algorithm;

int main(int argc, char **argv)
{
  int N, dim, ratio, rnd;
  std::string line;

  if(argc < 3) {
    printf("Usage: %s FILENAME DESTDIR\n", argv[0]);
    exit(-1);
  }

  std::string filename;
  filename.append(argv[2]);
  filename.append("/");
  filename.append(argv[1]);
  filename.append(".sparse");
  std::ofstream outfile(filename.c_str());
  if(!outfile.is_open()) {
    std::cerr << "Couldn't open " << filename << std::endl;
    exit(-1);
  }

  std::ifstream file(argv[1], std::ios_base::in);
  boost::iostreams::filtering_istream in;
  in.push(file);
  std::getline(in, line); 
  sscanf(line.c_str(),"%d %d", &N, &dim);
  std::getline(in, line); 
  sscanf(line.c_str(),"%d", &ratio);
  std::getline(in, line); 
  sscanf(line.c_str(),"%d", &rnd);
  //std::cout << N << " - " << dim << " - " << ratio << " - " << rnd << '\n';
  for(; std::getline(in, line); ) {
    //std::cout << "Processed line " << line.size() << "\n";

    std::vector<std::string> tokens;
    split(tokens, line, is_any_of(" ")); // here it is

    std::string str;
    str.reserve(line.size() * 2);  
    int i = 1;
    for(std::vector<std::string>::const_iterator iter = tokens.begin(); iter + 1 != tokens.end(); ++iter) {
      if ((*iter).compare("0.000000") != 0) {
	//std::cout << *iter << '\n';
	std::stringstream ss;
	ss << i;
	str.append(ss.str() + ":" + *iter + " ");
      }
      i++;
    }
    std::string last = *(tokens.end() - 1);
    str = last + " " + str;
    //std::cout << last << "\n";
    outfile << str << "\n";
  }
  outfile.close();
}
