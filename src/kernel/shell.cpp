#include <iostream>
#include <string>
#include <vector>

using namespace std;

// Util function
vector<string> StringSplit(string, string);


// Shell function
bool initConsole();
bool destroyConsole();
int exec(string);

int main ()
{
	if (!initConsole()) return -1;

	int sign = 1;
	string cmd;
	while(sign) {
		// Input command
		cout << "root@localhost ~$ ";
		cin >> cmd;

		// Execute command
		sign = exec(cmd);
	}
	
	if (!destroyConsole()) return -1;

	return 0;
}

bool initConsole()
{
	cout << "Welcome to Lettle console!" << endl;
	return true;
}

int exec(string command)
{
	vector<string> cmd_arr = StringSplit(command, " ");
	string c = cmd_arr.at(0);

	if (c == "ls") {
		cout << "展示文件目录内容" << endl;
	} else if (c == "exit") {
		return 0;
	}

	return 1;
}

vector<string> StringSplit(string str, string split)
{
	int prev=0, now=str.find(split);
	vector<string> vec;
	while( prev < now ) {
		vec.push_back(str.substr(prev, now-prev));
		prev = now + 1;
		str = str.substr(prev);
		now = str.find(split);
	}
	if (prev != str.size()) {
		vec.push_back(str);
	}

	return vec;
}

bool destroyConsole()
{
	cout << "Bye bye~" << endl;
	return true;
}
