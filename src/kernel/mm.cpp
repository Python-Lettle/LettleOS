#include <mm.h>
#include <iostream>
#include <string>

using namespace std;

MemoryManager::MemoryManager()
{
	this->capacity = DEFAULT_MEM_SIZE;
	this->memory = new BYTE[this->capacity];
	this->segs = new MemSeg[MAX_SEG];
}

MemoryManager::MemoryManager(int size)
{
	this->capacity = size;
	this->memory = new BYTE[this->capacity];
	this->segs = new MemSeg[MAX_SEG];
}

MemoryManager::~MemoryManager()
{
	// delete this->memory;
	this->capacity = 0;
	// delete this->segs;
}

void MemoryManager::showMemory()
{
	cout << "Total memory size: " << capacity << "Byte" << endl;
	
}
