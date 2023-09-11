ASCIIDOCTOR = asciidoctor
ASCIIDOCTOR_PDF = $(ASCIIDOCTOR)-pdf
REVSNIP = $(SPEC)/autogenerated/revision.adoc-snippet
TARGETS = riscv-ffh.pdf
TARGETS += riscv-ffh.html
TARGETS += $(REVSNIP)
COMMITDATE ?= $(shell git show -s --format=%ci | cut -d ' ' -f 1)
GITVERSION ?= $(shell git describe --tag)
SPEC=$(shell pwd)
COMMITDATE=$(shell git show -s --format=%ci | cut -d ' ' -f 1)
GITVERSION=$(shell git describe --tag)

.PHONY: all
all: $(TARGETS)

%.html: %.adoc $(REVSNIP)
	$(ASCIIDOCTOR) -d book -b html $<

%.pdf: %.adoc $(IMAGES) docs-resources/themes/riscv-pdf.yml $(REVSNIP)
	$(ASCIIDOCTOR_PDF) \
	--attribute=mathematical-format=svg \
	-a toc \
	-a compress \
	-a revnumber=${GITVERSION} \
	-a revdate=${COMMITDATE} \
	-a pdf-style=docs-resources/themes/riscv-pdf.yml \
	-a pdf-fontsdir=docs-resources/fonts \
	--require=asciidoctor-mathematical \
	-o $@ $<

$(SPEC)/autogenerated:
	-mkdir $@

$(SPEC)/autogenerated/revision.adoc-snippet: Makefile $(SPEC)/autogenerated
	echo ":revdate: ${COMMITDATE}" > $@-tmp
	echo ":revnumber: ${VERSION}-${GITVERSION}" >> $@-tmp
	diff $@ $@-tmp || mv $@-tmp $@

.PHONY: clean
clean:
	rm -f $(TARGETS)

.PHONY: install-debs
install-debs:
	sudo apt-get install pandoc asciidoctor ditaa ruby-asciidoctor-pdf

.PHONY: install-rpms
install-rpms:
	sudo dnf install ditaa pandoc rubygem-asciidoctor rubygem-asciidoctor-pdf
