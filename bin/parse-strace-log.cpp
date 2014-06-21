// Copyright 2013,2014 Marko Dimjašević, Simone Atzeni, Ivo Ugrina, Zvonimir Rakamarić

// This file is part of maline.

// maline is free software: you can redistribute it and/or modify it
// under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.

// maline is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.

// You should have received a copy of the GNU Affero General Public License
// along with maline.  If not, see <http://www.gnu.org/licenses/>.


#include <cassert>
#include <cerrno>
#include <csignal>
#include <cstdio>
#include <cstdlib>
#include <fcntl.h>
#include <unistd.h>
#include <map>
#include <set>
#include <sstream>
#include <string>
#include <vector>

using namespace std;

// Output file
FILE *f = NULL;

// missing-calls.txt
FILE *mf = NULL;


void
signal_callback_handler(int signum)
{
  if (f)
  {
                     /* l_type   l_whence  l_start  l_len  l_pid   */
    struct flock fl = { F_UNLCK, SEEK_SET, 0,       0,     0 };
    fl.l_pid = getpid();
    if (fcntl(fileno(f), F_SETLK, &fl) == -1)
    {
      perror("fcntl");
      exit(1);
    }
    fclose(f);
  }

  if (mf)
  {
                     /* l_type   l_whence  l_start  l_len  l_pid   */
    struct flock fl = { F_UNLCK, SEEK_SET, 0,       0,     0 };
    fl.l_pid = getpid();
    if (fcntl(fileno(mf), F_SETLK, &fl) == -1)
    {
      perror("fcntl");
      exit(1);
    }
    fclose(mf);
  }

  exit(signum);
}

class parser
{
private:
  string log_file_name;
  string output_file_name;
  string architecture;
  map<string, int> sys_call_map;
  vector<string> sys_calls_made;
  vector<vector<double> > dep_graph_weight;
  set<string> not_found_calls;

  vector<string> mysplit(string s, const char delim)
  {
    vector<string> res;
    string::size_type pos = 0;
    string::size_type old_pos = 0;
    string sub;
    bool flag = true;

    while(flag)
    {
      pos = s.find_first_of(delim, pos);
      if(pos == string::npos)
      {
	flag = false;
	pos = s.size();
      }
      sub = s.substr(old_pos, pos - old_pos);
      if (sub.size() > 1)
	res.push_back(sub);
      old_pos = ++pos;
    }

    return res;
  }

  string read_from_file(string filename)
  {
    string contents;

    FILE *fp = fopen(filename.c_str(), "r");
    if (fp)
    {
      fseek(fp, 0, SEEK_END);
      contents.resize(ftell(fp));
      rewind(fp);
      fread(&contents[0], 1, contents.size(), fp);
      fclose(fp);
      return contents;
    }
    throw(errno);
  }

  void import_sys_call_list()
  {
    string contents;

    string maline_path(getenv("MALINE") ? getenv("MALINE") : "");
    assert(maline_path != "");

    string sys_call_filename = maline_path + "/data/" + this->architecture + "-syscall.txt";  
    contents = this->read_from_file(sys_call_filename);

    vector<string> list_of_calls(this->mysplit(contents, '\n'));
    int i = 0;
    for(vector<string>::iterator it = list_of_calls.begin(); it != list_of_calls.end(); ++it, ++i)
      this->sys_call_map[*it] = i;
  }

  string extract_sys_call_name(string line)
  {
    static const string invalid_chars_str("<+-=?0");

    if (line[0] != '[')
      return "";

    vector<string> line_split = this->mysplit(line, ' ');
    if (line_split.size() < 4)
      return "";

    string sys_call = this->mysplit(line_split[3], '(')[0];
    
    if (invalid_chars_str.find(sys_call[0]) != string::npos || sys_call == "restart_syscall")
      return "";

    // strip underscores at the beginning
    while(sys_call.size() > 0 && sys_call[0] == '_')
      sys_call = sys_call.substr(1);

    return sys_call;
  }

public:
  parser(string log_file_name, string architecture)
  {
    this->log_file_name = log_file_name;
    this->architecture = architecture;
    this->import_sys_call_list();
    // strip .log from the end of the log file name and add .graph
    this->output_file_name = log_file_name.substr(0, log_file_name.size() - 4) + ".graph";
  }

  void extract_sys_calls()
  {
    string contents = this->read_from_file(this->log_file_name);
    string sys_call;
    vector<string> lines = this->mysplit(contents, '\n');

    for(vector<string>::iterator it = lines.begin(); it != lines.end(); ++it)
    {
      sys_call = this->extract_sys_call_name(*it);
      if (sys_call == "")
	continue;
      this->sys_calls_made.push_back(sys_call);
    }
  }

  double distance_function(int pos1, int pos2)
  {
    if (pos1 == pos2)
      return 0;

    return 1.0 / abs(pos1 - pos2);
  }

  void parse()
  {
    int i, j, index1, index2;
    string s1, s2;

    // initialize the matrix
    this->dep_graph_weight.resize(this->sys_call_map.size());
    for(i = 0; i < this->dep_graph_weight.size(); ++i)
    {
      this->dep_graph_weight[i].resize(this->sys_call_map.size());
      for(j = 0; j < this->dep_graph_weight[i].size(); ++j)
	this->dep_graph_weight[i][j] = 0;
    }

    // compute values based on the model
    for(i = 0; i < this->sys_calls_made.size(); ++i)
    {
      s1 = this->sys_calls_made[i];
      if (!this->sys_call_map.count(s1))
      {
	this->not_found_calls.insert(s1);
	continue;
      }
      index1 = this->sys_call_map[s1];

      for(j = i + 1; j < this->sys_calls_made.size(); ++j)
      {
	s2 = this->sys_calls_made[j];
	if (s1 == s2)
	  break;
	if (!this->sys_call_map.count(s2))
	{
	  this->not_found_calls.insert(s2);
	  continue;
	}

	index2 = this->sys_call_map[s2];
	this->dep_graph_weight[index1][index2] += this->distance_function(i, j);
	
      }
    }
  }

  void print()
  {
    ostringstream outs;
    int i, j;
    int size = this->dep_graph_weight.size();

    // write to a string stream first and then convert the stream to a
    // string to be written to a file
    outs.setf(ios::fixed, ios::floatfield);
    outs.precision(6);
    for(i = 0; i < size; ++i)
      for(j = 0; j < size; ++j)
    	outs << this->dep_graph_weight[i][j] << " ";

    f = fopen(this->output_file_name.c_str(), "w");
    if (f)
    {
                    /*   l_type   l_whence  l_start  l_len  l_pid   */
      struct flock fl = {F_WRLCK, SEEK_SET,   0,      0,     0 };
      fl.l_pid = getpid();
      if (fcntl(fileno(f), F_SETLKW, &fl) == -1)
      {
	perror("fcntl");
	exit(1);
      }
      fprintf(f, "%d\n", size * size);
      fprintf(f, "%s", outs.str().c_str());
    }
    else
      throw(errno);

    if (this->not_found_calls.size() > 0)
    {
      string maline_path(getenv("MALINE") ? getenv("MALINE") : "");
      assert(maline_path != "");

      outs.str("");
	
      for(set<string>::iterator it = this->not_found_calls.begin(); it != this->not_found_calls.end(); ++it)
	outs << it->c_str() << endl;

      mf = fopen((maline_path + "/missing-calls.txt").c_str(), "a");
      if (mf)
      {
                      /*   l_type   l_whence  l_start  l_len  l_pid   */
	struct flock fl = {F_WRLCK, SEEK_SET,   0,      0,     0 };
	fl.l_pid = getpid();
	if (fcntl(fileno(mf), F_SETLKW, &fl) == -1)
	{
	  perror("fcntl");
	  exit(1);
	}
	fprintf(mf, "%s", outs.str().c_str());
      }
      else
	throw(errno);
    }
  }
};

int main(int argc, char **argv)
{
  signal(SIGTERM, signal_callback_handler);
  signal(SIGTSTP, signal_callback_handler);
  signal(SIGINT, signal_callback_handler);
  signal(SIGQUIT, signal_callback_handler);

  // beside the program name there should be an input file and an
  // architecture type
  assert(argc == 3);
  string input_file(argv[1]);
  string architecture(argv[2]);

  // if a different architecture is ever to be supported, the
  // following assertion has to be updated
  assert(architecture == "i386");

  parser Parser = parser(input_file, architecture);
  Parser.extract_sys_calls();
  Parser.parse();
  Parser.print();

  return 0;
}
