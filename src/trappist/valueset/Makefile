MAKE=make
SRCS=ValueSet-TM ValueSet-TP

all: $(foreach source, $(SRCS), src_$(source))

src_%:
	ozc -c $(subst src_,,$@).oz -o $(subst src_,,$@).ozf

tester: Tester.oz
	ozc -x Tester.oz -o tester

clean:
	rm -rf *ozf
	rm -rf tester

.PHONY: all clean

