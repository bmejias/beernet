MAKE = make
SRCS =
EXECS = pbeer

all: $(foreach source, $(SRCS), src_$(source)) $(EXECS)

pbeer: Pbeer.oz
	ozc -x Pbeer.oz -o pbeer

src_%:
	ozc -c $(subst src_,,$@).oz -o $(subst src_,,$@).ozf

clean:
	rm -rf *ozf
	rm -rf tester

.PHONY: all clean

