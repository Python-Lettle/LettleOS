#ifndef __MM_H__
#define __MM_H__

#include <util.h>

#define DEFAULT_MEM_SIZE 1024
#define MAX_SEG  100
#define MAX_PAGE 100


typedef struct MemPage
{
	int pageId;					// Page id in a segment
	int size;						// The page's length (Byte)
	BYTE* start;				// The page's start address
}MemPage;

typedef struct MemSeg
{
	int segId;					// Segment id
	BYTE* start;				// The start address of this segment
	int size;						// The seg's length (Byte)
	MemPage* pages;			// Memory page table (array: len=pageNum)
	int pageNum;				// The number of pages
}MemSeg;

class MemoryManager
{
private:
	BYTE * memory;
	int capacity;
	int segNum;
	MemSeg* segs;

public:
	MemoryManager();
	MemoryManager(int size);
	~MemoryManager();

	// Show the map of your memory.
	void showMemory();

	// size <= capacity
	void* malloc(int size);

	// size <= capacity
	void* realloc(int size);
};

#endif
