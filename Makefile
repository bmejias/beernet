MAKE = make

help:
	@echo "Beernet's main Makefile" 
	@echo "To build and install Beernet, documentation and tools, run:\n"
	@echo "make"
	@echo "make install\n"
	@echo "To build each part independently run:\n"
	@echo "make doc\tto build documentation"
	@echo "make lib\tto build Beernet components"
	@echo "make bin\tto build Beernet tools\n"
	@echo "To install each part independently run:\n"
	@echo "make install-doc\t to install documentation"
	@echo "make install-lib\t to install Beernet components"
	@echo "make install-bin\t to install Beernet tools\n"
	@echo "To clean directories docsrc, src and tools, run:"
	@echo "make clean\n"
	@echo "a beer a day keeps the doctor away"	
	@echo "Beernet is released under the Beerware License (see file LICENSE)" 

all: doc lib bin

doc: 
	$(MAKE) -C docsrc all

lib: 
	$(MAKE) -C src all

bin: 
	$(MAKE) -C tools all

install: install-doc install-lib install-bin

install-doc:
	$(MAKE) -C docsrc install

install-lib:
	$(MAKE) -C src install

install-src:
	$(MAKE) -C tools install

clean:
	$(MAKE) -C docsrc clean
	$(MAKE) -C src clean
	$(MAKE) -C tools clean

.PHONY: all clean
