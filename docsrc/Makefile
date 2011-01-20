MAKE = make
DEST = ../doc/
DOCS = changelog

all:
	@echo "Nothing to do. Documentation ready to be installed"	

install: $(foreach doc, $(DOCS), copy_$(doc)) 

copy_%:
	@cp -f $(subst copy_,,$@) $(DEST)

clean:
	@echo "Documentation sources clean"

.PHONY: all clean
