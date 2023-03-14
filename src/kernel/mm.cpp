#include <mm.h>
#include <iostream>
#include <string>

using namespace std;

MemoryManager::MemoryManager()
{
	this->capacity = DEFAULT_MEM_SIZE * 1024; // 100 KB
	this->pageSize = 1 * 1024;					// 1KB
	this->memory = new BYTE[this->capacity];
	this->segs = new MemSeg[MAX_SEG];
}

MemoryManager::MemoryManager(int capa, int page_size)
{
	this->capacity = capa * 1024;							// capa KB
	this->pageSize = page_size * 1024;				// page_size KB
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
	cout << "Total memory size: " << capacity << " KB" << endl;
	cout << "Page size: "	<< pageSize << " KB" << endl;
}

void* malloc(int size)
{
}

void* realloc(int size)
{
}

