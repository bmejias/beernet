MAKE = make
SRCS = SymmetricReplication Trappist
SUBDIRS = twophase paxos valueset

all: $(foreach source, $(SRCS), src_$(source)) sublibs

sublibs:$(foreach subdir, $(SUBDIRS), sub_$(subdir))

src_%:
	ozc -c $(subst src_,,$@).oz -o $(subst src_,,$@).ozf

sub_%:
	$(MAKE) -C $(subst sub_,,$@) all

tester: Tester.oz
	ozc -x Tester.oz -o tester

clean:
	rm -rf *ozf
	rm -rf tester

.PHONY: all clean

