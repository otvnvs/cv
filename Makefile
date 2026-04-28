LATEX=pdflatex
OUTDIR=./out
NAME=Resume_-_Ockert_van_Schalkwyk
TEX=./src/$(NAME).tex
PDF=$(OUTDIR)/$(NAME).pdf
HTML=$(OUTDIR)/$(NAME).html
MD=$(OUTDIR)/$(NAME).md
DOCX=$(OUTDIR)/$(NAME).docx
ODT=$(OUTDIR)/$(NAME).odt
TXT=$(OUTDIR)/$(NAME).txt
PDFTXT=$(OUTDIR)/$(NAME).pdf.txt
VIEWER=evince
PDFTOTEXT=pdftotext
CSS=./src/custom.css
all: $(PDF) $(TXT) $(HTML) $(PDFTXT) $(MD) $(DOCX) $(ODT)
pdf: $(PDF)
txt: $(TXT)
pdftxt: $(PDFTXT)
html: $(HTML)
md: $(MD)
docx: $(DOCX)
odt: $(ODT)

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
	@cp $(HTML) ./index.html
	@cp $(HTML) ./index.html
	@cp ./src/custom.css $(NAME).css

$(MD): $(TEX)
	@mkdir -p $(@D)
	@pandoc "$(TEX)" -f latex -t markdown -o "$(MD)"
	@cp "$(MD)" ./README.md

$(DOCX): $(TEX)
	@mkdir -p $(@D)
	@pandoc "$(TEX)" -f latex -t docx -o "$(DOCX)"

$(ODT): $(TEX)
	@mkdir -p $(@D)
	@pandoc "$(TEX)" -f latex -t odt -o "$(ODT)"

view: $(PDF)
	$(VIEWER) "$(PDF)"

.PHONY: clean
clean:
	@rm -rf $(OUTDIR)
