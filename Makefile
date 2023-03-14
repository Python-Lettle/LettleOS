
s = src
sk = $(s)/kernel
inc = $(s)/include
t = target

CC = g++

CCPARAM = -I $(inc) -c

objs = $(t)/util.o $(t)/main.o $(t)/shell.o $(t)/mm.o

$(t)/mm.o: $(sk)/mm.cpp
	mkdir -p $(t)
	$(CC) $< $(CCPARAM) -o $@

$(t)/util.o: $(sk)/util.cpp
	mkdir -p $(t)
	$(CC) $< $(CCPARAM) -o $@

$(t)/main.o: $(sk)/main.cpp	
	mkdir -p $(t)
	$(CC) $< $(CCPARAM) -o $@

$(t)/shell.o: $(sk)/shell.cpp
	mkdir -p $(t)
	$(CC) $< $(CCPARAM) -o $@

LettleOS: $(objs)
	$(CC) $(objs) -o $@

all: LettleOS
