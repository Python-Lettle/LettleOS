#include <util.h>

using namespace std;

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

