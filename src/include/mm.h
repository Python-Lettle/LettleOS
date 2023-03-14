#ifndef __MM_H__
#define __MM_H__

#include <util.h>

#define DEFAULT_MEM_SIZE 1024
#define MAX_SEG  100
#define MAX_PAGE 100


typedef struct MemPage
{
	int pageId;					// Page id in a segment
	int state;					// The state of the page
	int size;						// The page's length (KB)
	BYTE* start;				// The page's start address
}MemPage;

// Segment Table Item
typedef struct MemSeg
{
	int segId;					// Segment id
	int state;					// The state of the segment
	BYTE* start;				// The start address of this segment
	int size;						// The seg's length (KB)
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
	int pageSize;				// Each page size (KB)

public:
	MemoryManager();
	MemoryManager(int,int);
	~MemoryManager();

	// Show the map of your memory.
	void showMemory();

	// size <= capacity
	void* malloc(int size);

	// size <= capacity
	void* realloc(int size);
};

#endif
