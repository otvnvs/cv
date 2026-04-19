LATEX=pdflatex
OUTDIR=./out
NAME=Resume_-_Ockert_van_Schalkwyk
TEX=./src/$(NAME).tex
PDF=$(OUTDIR)/$(NAME).pdf
HTML=$(OUTDIR)/$(NAME).html
MD=$(OUTDIR)/$(NAME).md
TXT=$(OUTDIR)/$(NAME).txt
PDFTXT=$(OUTDIR)/$(NAME).pdf.txt
VIEWER=evince
PDFTOTEXT=pdftotext
CSS=./src/custom.css
all: $(PDF) $(TXT) $(HTML) $(PDFTXT) $(MD)
pdf: $(PDF)
txt: $(TXT)
pdftxt: $(PDFTXT)
html: $(HTML)
md: $(MD)

$(PDF): $(TEX)
	@mkdir -p $(@D)
	@$(LATEX) \
		--halt-on-error \
		-output-directory=$(OUTDIR) \
		"$(TEX)"
	# run twice to resolve internal references/layout
	@$(LATEX) \
		--halt-on-error \
		-output-directory=$(OUTDIR) \
		"$(TEX)"

# convert tex to txt using detex
$(TXT): $(TEX)
	@mkdir -p $(@D)
	@detex "$(TEX)" > $(TXT)

$(PDFTXT): $(PDF)
	@mkdir -p $(@D)
	@$(PDFTOTEXT) -layout -nopgbrk "$(PDF)" "$(PDFTXT)"

$(HTML): $(TEX) $(CSS)
	@mkdir -p $(@D)
	@htlatex "$(TEX)" ' ' ' ' -d$(OUTDIR)/
	@cat ./src/custom.css >> $(HTML:.html=.css)
	@rm -rf \
		$(NAME).4ct \
		$(NAME).4tc  \
		$(NAME).aux \
		$(NAME).css \
		$(NAME).dvi \
		$(NAME).html \
		$(NAME).idv \
		$(NAME).lg \
		$(NAME).log \
		$(NAME).tmp \
		$(NAME).xref \
		texput.log
	@rm -rf \
		$(OUTDIR)/$(NAME).aux \
		$(OUTDIR)/$(NAME).log \
		$(OUTDIR)/$(NAME).out

$(MD): $(TEX)
	@mkdir -p $(@D)
	@pandoc "$(TEX)" -f latex -t markdown -o "$(MD)"
view: $(PDF)
	$(VIEWER) "$(PDF)"

.PHONY: clean
clean:
	@rm -rf $(OUTDIR)
