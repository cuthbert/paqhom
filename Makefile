ENGLISH := en-cover en-main
SWEDISH := sv-cover sv-main
GERMAN := de-cover de-main

.SECONDARY: $(addsuffix .dvi, $(ENGLISH) $(SWEDISH) $(GERMAN))

.PHONY: clean distclean english swedish
english: $(addsuffix .pdf,$(ENGLISH))
swedish: $(addsuffix .pdf,$(SWEDISH))
german: $(addsuffix .pdf,$(GERMAN))

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
	    $(addsuffix .aux,$(ENGLISH) $(SWEDISH) $(GERMAN)) \
	    $(addsuffix .dvi,$(ENGLISH) $(SWEDISH) $(GERMAN)) \
	    $(addsuffix .log,$(ENGLISH) $(SWEDISH) $(GERMAN)) \
	)

distclean: clean
	@rm -vf $(sort \
	    $(addsuffix .pdf,$(ENGLISH) $(SWEDISH) $(GERMAN)) \
	    $(addsuffix  .ps,$(ENGLISH) $(SWEDISH) $(GERMAN)) \
	)

#[eof]
