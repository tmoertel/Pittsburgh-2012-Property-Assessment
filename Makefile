# This a Makefile.  Run "make" from the command line to have the
# GNU Make program read this file and use the rules within it to
# perform the statistical analyses and generate the resulting
# charts and other outputs.
#
# Tom Moertel <tom@moertel.org>
# 2012-01-28


analysis = analysis.R
charts := out/pgh-2012-assm-property-tax-increases-ecdf.pdf
data := $(wildcard data/*)

default: all
.PHONY: default

.PHONY: all
all: $(charts)

$(charts): .analysis

.analysis: $(analysis) $(data)
	./$(analysis)
	touch .analysis

.PHONY: clean
clean:
	rm -f $(charts)