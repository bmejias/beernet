MAKE = make
INSTALL = install
INSTALL_DATA = $(INSTALL) -m 644
DESTDIR = ../doc/
DOCS = changelog

all:
	@echo "Nothing to do. Documentation ready to be installed"	

install: check_destdir $(foreach doc, $(DOCS), install_$(doc))

check_destdir:
	if ! test -d $(DESTDIR); then mkdir $(DESTDIR); fi

install_%:
	$(INSTALL_DATA) $(subst install_,,$@) $(DESTDIR)

clean:
	@echo "Documentation sources clean"

.PHONY: all clean
