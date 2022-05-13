#!make

INC_BASE=$(SDKTARGETSYSROOT)/usr/include/
INC_USBGX=$(INC_BASE)usbgx

INC_FLAGS=-I$(INC_BASE) -I$(INC_USBGX)

all: main.cpp
	$(CXX) $(CXXFLAGS) $(INC_FLAGS) -Og main.cpp -g -o hello.bin 
clean:
	rm -f hello.bin
