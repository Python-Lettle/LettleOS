#include <iostream>
#include <shell.h>
#include <util.h>

using namespace std;

int Shell::exec(string command)
{
	vector<string> cmd_arr = StringSplit(command, " ");
	string c = cmd_arr.at(0);

	if (c == "ls") {
		std::cout << "展示文件目录内容" << std::endl;
	} else if (c == "exit") {
		return 0;
	} else if (c == "memshow") {
		memBlock.showMemory();
	}

	return 1;
}

Shell::Shell() : memBlock(20, 1)
{
	std::cout << "Welcome to Lettle console!" << std::endl;
}

Shell::~Shell()
{
	std::cout << "Bye bye~" << std::endl;
}
