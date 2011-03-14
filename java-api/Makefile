OZ_SRCS = adhocParser
OZ_EXEC = socketServer
JAVA_SRC = Client

OZF = $(foreach source, $(OZ_SRCS), src_$(source))
OZX = $(foreach exec, $(OZ_EXEC), exe_$(exec))
JAVA= $(foreach jsource, $(JAVA_SRC), jsrc_$(jsource))

all: $(OZF) $(JAVA) $(OZX) 
	
src_%:
	ozc -c $(subst src_,,$@).oz -o $(subst src_,,$@).ozf

exe_%:
	ozc -x $(subst exe_,,$@).oz -o $(subst exe_,,$@)

jsrc_%:
	javac $(subst jsrc_,,$@).java

clean:
	rm -f *ozf
	rm -f *class
	rm -f socketServer
	rm -f tester

.PHONY: all clean

