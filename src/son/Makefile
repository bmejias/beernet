MAKE=make

SUBDIRS=relaxed-ring

all: sublibs

install: installlibs

sublibs:$(foreach subdir, $(SUBDIRS), sub_$(subdir))

installlibs:$(foreach subdir, $(SUBDIRS), subinstall_$(subdir))

cleanlibs:$(foreach subdir, $(SUBDIRS), subclean_$(subdir))

src_%:
	ozc -c $(subst src_,,$@).oz -o $(subst src_,,$@).ozf

sub_%:
	$(MAKE) -C $(subst sub_,,$@) all

subinstall_%:
	$(MAKE) -C $(subst subinstall_,,$@) install

tester: Tester.oz
	ozc -x Tester.oz -o tester

clean: cleanlibs
	rm -rf *ozf
	rm -rf tester

subclean_%:
	$(MAKE) -C $(subst subclean_,,$@) clean

.PHONY: all clean
