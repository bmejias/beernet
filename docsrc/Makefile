MAKE = make
LATEX = pdflatex
DIATOPDF = diatopdf
INSTALL = install
INSTALL_DATA = $(INSTALL) -m 644
DESTDIR = ../doc/
DOCS = changelog

all: latex-doc diagrams

install: check_destdir $(foreach doc, $(DOCS), install_$(doc))

check_destdir:
	if ! test -d $(DESTDIR); then mkdir $(DESTDIR); fi

install_%:
	$(INSTALL_DATA) $(subst install_,,$@) $(DESTDIR)

latex-doc:
	$(LATEX) api.tex
	$(LATEX) api.tex

diagrams:
	$(DIATOPDF) architecture-detail.dia
	$(DIATOPDF) architecture-general.dia

clean:
	@echo "Documentation sources clean"

.PHONY: all clean
