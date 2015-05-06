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

#include<iostream>
#include<fstream>
#include<cmath>
#include<cstdlib>

using namespace std;

int main(int argc, char const* argv[])
{

	ifstream myReadFile;
	myReadFile.open(argv[1]);
	char output[100];
	int nrow, ncol, x, y;

	int i=1, j=1;
	if (myReadFile.is_open()) {
		myReadFile >> nrow;
		myReadFile >> ncol;
		myReadFile >> x;
		myReadFile >> y;
		while (!myReadFile.eof()) {

			myReadFile >> output;

			if (j == ncol) {
				cout << i << " " << j << " " << output << endl;
				++i;
				j=1;
				continue;
			}

			if( atof(output) != 0 )
				cout << i << " " << j << " " << output << endl;

			++j;

		}
	}
	myReadFile.close();
	return 0;
}
