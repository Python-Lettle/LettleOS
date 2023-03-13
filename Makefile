
s = src
sk = $(s)/kernel

CC = g++

LettleOS: $(sk)/main.cpp
	$(CC) $< -o $@

all: LettleOS