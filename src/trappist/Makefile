MAKE = make
INSTALL = install
INSTALL_FUNCTOR = $(INSTALL) -m 644
DESTDIR = ../../lib/trappist/
SRCS = SymmetricReplication Trappist
SUBDIRS = twophase paxos valueset

all: $(foreach source, $(SRCS), src_$(source)) sublibs

install: check_destdir \
	$(foreach source, $(SRCS), install_$(source)) \
	installlibs

sublibs:$(foreach subdir, $(SUBDIRS), sub_$(subdir))

installlibs:$(foreach subdir, $(SUBDIRS), subinstall_$(subdir))

cleanlibs:$(foreach subdir, $(SUBDIRS), subclean_$(subdir))

check_destdir:
	if ! test -d $(DESTDIR); then mkdir $(DESTDIR); fi

install_%:
	$(INSTALL_FUNCTOR) $(subst install_,,$@).ozf $(DESTDIR)

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

