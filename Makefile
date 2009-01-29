MAKE=make

SUBDIRS=corecomp logger network timer

all: sublibs

sublibs:$(foreach subdir, $(SUBDIRS), sub_$(subdir))

cleanlibs:$(foreach subdir, $(SUBDIRS), subclean_$(subdir))

sub_%:
	$(MAKE) -C $(subst sub_,,$@) all

clean: cleanlibs
	rm -rf *ozf

subclean_%:
	$(MAKE) -C $(subst subclean_,,$@) clean

.PHONY: all
