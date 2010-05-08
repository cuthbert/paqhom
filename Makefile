ENGLISH := eng-cover eng-main
SWEDISH := swe-cover swe-main

.PHONY: english
english: $(addsuffix .pdf,$(ENGLISH))

.PHONY: swedish
swedish: $(addsuffix .pdf,$(SWEDISH))

# turn .tex into .dvi files
%.dvi: %.tex; @latex $<

# turn .dvi into .pdf files
%.pdf: %.dvi; @dvipdf $<

# turn .dvi into .ps files
%.ps: %.dvi; @dvips $<

.PHONY: clean
clean:
	@rm -vf \
	    $(addsuffix .aux,$(ENGLISH) $(SWEDISH)) \
	    $(addsuffix .dvi,$(ENGLISH) $(SWEDISH)) \
	    $(addsuffix .log,$(ENGLISH) $(SWEDISH))

.PHONY: distclean
distclean: clean
	@rm -vf \
	    $(addsuffix .pdf,$(ENGLISH) $(SWEDISH)) \
	    $(addsuffix  .ps,$(ENGLISH) $(SWEDISH))

#[eof]
