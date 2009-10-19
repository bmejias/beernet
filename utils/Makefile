MAKE=make
SRCS=KeyRanges PbeerList Random RingList TextFile

all: $(foreach source, $(SRCS), src_$(source)) nanoStore

src_%:
	ozc -c $(subst src_,,$@).oz -o $(subst src_,,$@).ozf

nanoStore: nanoStore.oz
	ozc -x nanoStore.oz -o nanoStore

clean:
	rm -f *ozf
	rm -f nanoStore
	rm -f nano.tket

.PHONY: all clean
