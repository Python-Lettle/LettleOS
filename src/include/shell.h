#ifndef __SHELL_H__
#define __SHELL_H__

#include <string>
#include <mm.h>

class Shell
{
private:
	MemoryManager memBlock;
public:
	Shell();
	~Shell();

	int exec(std::string);

};

#endif
