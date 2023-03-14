/**
	* Created by Lettle on 2023/3/13
	* 简单使用 C++ 对 LettleOS Shell 大致蓝图的实现
	*/

#include <iostream>
#include <string>
#include <vector>
#include <shell.h>

using namespace std;

int main ()
{
	Shell shell;

	int sign = 1;
	string cmd;
	while(sign) {
		// Input command
		cout << "root@localhost ~$ ";
		cin >> cmd;

		// Execute command
		sign = shell.exec(cmd);
	}
	
	return 0;
}

