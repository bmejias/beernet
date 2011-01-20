MAKE = make

SUBDIRS = corecomp dht logger messaging network pbeer son timer trappist utils

all: sublibs

install: installlibs

clean: cleanlibs
	rm -rf *ozf

sublibs:$(foreach subdir, $(SUBDIRS), sub_$(subdir))

installlibs:$(foreach subdir, $(SUBDIRS), subinstall_$(subdir))

cleanlibs:$(foreach subdir, $(SUBDIRS), subclean_$(subdir))

sub_%:
	$(MAKE) -C $(subst sub_,,$@) all

subinstall_%:
	$(MAKE) -C $(subst subinstall_,,$@) install

subclean_%:
	$(MAKE) -C $(subst subclean_,,$@) clean

.PHONY: all
