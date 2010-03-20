MAKE=make
SRCS=Pbeer
SUBDIRS=relaxed-ring messaging

all: sublibs srcs

sublibs:$(foreach subdir, $(SUBDIRS), sub_$(subdir))

srcs: $(foreach source, $(SRCS), src_$(source))

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
