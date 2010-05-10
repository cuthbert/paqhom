ENGLISH := en-cover en-main
SWEDISH := sv-cover sv-main

.SECONDARY: $(addsuffix .dvi, $(ENGLISH) $(SWEDISH))

.PHONY: clean distclean english swedish
english: $(addsuffix .pdf,$(ENGLISH))
swedish: $(addsuffix .pdf,$(SWEDISH))

%.dvi: tex/*/%.tex        # LaTeX -> DVI
	@export TFMFONTS="tex/fonts:";                  \
	export TEXINPUTS="$(dir $<)include:tex/include:"; \
	echo -n | latex $<

%.pdf: %.dvi              # DVI -> PDF
	@export DVIPSFONTS="tex/fonts:"; \
	dvipdf $<

%.ps:  %.dvi              # DVI -> PS
	@export DVIPSFONTS="tex/fonts:"; \
	dvips  $<

clean:
	@rm -vf $(sort \
	    $(addsuffix .aux,$(ENGLISH) $(SWEDISH)) \
	    $(addsuffix .dvi,$(ENGLISH) $(SWEDISH)) \
	    $(addsuffix .log,$(ENGLISH) $(SWEDISH)) \
	)

distclean: clean
	@rm -vf $(sort \
	    $(addsuffix .pdf,$(ENGLISH) $(SWEDISH)) \
	    $(addsuffix  .ps,$(ENGLISH) $(SWEDISH)) \
	)

#[eof]
