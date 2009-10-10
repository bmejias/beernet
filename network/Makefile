MAKE=make
SRCS=Network Pp2p FailureDetector

all: $(foreach source, $(SRCS), src_$(source))

src_%:
	ozc -c $(subst src_,,$@).oz -o $(subst src_,,$@).ozf

tester: Tester.oz TestPlayers.oz
	ozc -c TestPlayers.oz -o TestPlayers.ozf
	ozc -x Tester.oz -o tester

testerdist: tester TesterDistNode.oz TesterDist.oz
	ozc -x TesterDistNode.oz -o testerDistNode
	ozc -x TesterDist.oz -o testerDist

testerfaildetector: TestFailDetNode.oz TestFailDet.oz
	ozc -x TestFailDetNode.oz -o testFailDetNode
	ozc -x TestFailDet.oz -o testFailDet

clean:
	rm -rf *ozf
	rm -rf tester
	rm -rf testerDist
	rm -rf testerDistNode
	rm -rf coordinator.tket

.PHONY: all clean
