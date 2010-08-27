MAKE = make
SRCS = SymmetricReplication Trappist
SUBDIRS = twophase paxos valueset

all: $(foreach source, $(SRCS), src_$(source)) sublibs

sublibs:$(foreach subdir, $(SUBDIRS), sub_$(subdir))

cleanlibs:$(foreach subdir, $(SUBDIRS), subclean_$(subdir))

src_%:
	ozc -c $(subst src_,,$@).oz -o $(subst src_,,$@).ozf

sub_%:
	$(MAKE) -C $(subst sub_,,$@) all

tester: Tester.oz
	ozc -x Tester.oz -o tester

clean: cleanlibs
	rm -rf *ozf
	rm -rf tester

subclean_%:
	$(MAKE) -C $(subst subclean_,,$@) clean

.PHONY: all clean

