SOURCES = cilMutate.ml
OBJECTS = $(SOURCES:.ml=.cmo)
EXES = $(OBJECTS:.cmo=)

OS=$(shell uname)
ifeq ($(OS),Linux)
	OS=LINUX
endif
ifeq ($(OS),Darwin)
	OS=DARWIN
endif
ifneq ($(CIL),)
	OCAML_OPTIONS = -I $(CIL)/obj/x86_$(OS)
else
  ifneq ($(shell type ocamlfind 2> /dev/null),)
	OCAML_OPTIONS = -I $(shell ocamlfind query cil)
  else
    ifeq ($(MAKECMDGOALS),)
	$(error Please set the CIL environment variable)
    else
      ifneq ($(filter-out clean,$(MAKECMDGOALS)),)
	$(error Please set the CIL environment variable)
      endif
    endif
  endif
endif
OCAMLC = ocamlc -g $(OCAML_OPTIONS)
OCAMLOPT = ocamlopt -w Aelzv $(OCAML_OPTIONS)

all: cil-mutate
.PHONY: clean install

%.cmo: %.ml
	$(OCAMLC) -c -g $*.ml

%: %.cmo
	$(OCAMLOPT) -o $@ cil.cmxa

cil-mutate: cilMutate
	mv $< $@

clean:
	rm -f $(EXES) $(OBJECTS) cil-mutate

install: $(EXES)
	mkdir -p $(DESTDIR)/bin
	install -D $< $(DESTDIR)/bin
