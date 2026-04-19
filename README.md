# cv-latex

A LaTeX-based CV build system that generates multiple output formats from a single source file.

## Sample Output

- [PDF](https://github.com/otvnvs/cv/blob/main/out/Resume_-_Ockert_van_Schalkwyk.pdf)
- [HTML](https://htmlpreview.github.io/?https://github.com/otvnvs/cv/blob/main/out/Resume_-_Ockert_van_Schalkwyk.html)
- [MD](https://github.com/otvnvs/cv/blob/main/out/Resume_-_Ockert_van_Schalkwyk.md)
- [TXT](https://github.com/otvnvs/cv/blob/main/out/Resume_-_Ockert_van_Schalkwyk.pdf.txt)

## Overview

The project compiles one `.tex` source into five output formats, each serving a different purpose:

- **PDF** — the primary human-readable document for recruiter submission
- **DOCX** — Microsoft Word output
- **ODT** — Open Office output
- **HTML** — a styled web version with a dark theme, suitable for hosting or sharing as a link
- **Markdown** — a portable, readable format suitable for GitHub, wikis, or further processing
- **TXT (detex)** — a plain text version stripped of all LaTeX markup, for direct paste into ATS submission forms
- **TXT (pdftotext)** — a layout-preserving plain text extraction from the PDF, for verifying what ATS systems will see when they parse the PDF directly

Having all five outputs from a single source ensures content stays in sync across every format with a single build command.

## Dependencies

- `pdflatex` — primary PDF compiler
- `htlatex` — LaTeX to HTML converter (part of TeX4ht)
- `pandoc` — LaTeX to Markdown converter
- `detex` — LaTeX markup stripper for plain text output
- `pdftotext` — PDF text extractor (part of poppler-utils)
- `evince` — PDF viewer (used by `make view`, substitutable)

## Build Targets

| Target | Command | Output |
|---|---|---|
| All formats | `make` or `make all` | PDF, DOCX, ODT, HTML, MD, TXT, PDF.TXT |
| PDF only | `make pdf` | `out/*.pdf` |
| DOCX only | `make docx` | `out/*.docx` |
| ODT only | `make odt` | `out/*.odt` |
| HTML only | `make html` | `out/*.html` |
| Markdown only | `make md` | `out/*.md` |
| Plain text (detex) | `make txt` | `out/*.txt` |
| Plain text (pdftotext) | `make pdftxt` | `out/*.pdf.txt` |
| Open PDF | `make view` | Opens in viewer |
| Clean outputs | `make clean` | Removes `out/` |

All outputs are written to `./out/`.

## Structure

```
.
├── Makefile
├── README.md
└── src/
    ├── Resume_-_Ockert_van_Schalkwyk.tex   # single source of truth
    └── custom.css                           # styles applied to HTML output
```

## ATS Considerations

The project is structured with ATS (Applicant Tracking System) parsing in mind:

- `pdflatex` is used directly rather than a `dvi → ps → pdf` pipeline, producing a PDF with proper Unicode ToUnicode maps that ATS text extractors can read correctly
- Hyphenation is disabled globally via `\usepackage[none]{hyphenat}` to prevent mid-word breaks in extracted text
- List bullets are rendered as plain hyphens (`-`) which survive all extraction pipelines
- Date ranges use `YYYY - YYYY` with a plain ASCII hyphen for reliable ATS date parsing
- PDF metadata (author, title, subject, keywords) is embedded via `hyperref`
- The `detex` plain text target provides a clean paste-ready version with no encoding ambiguity

## Notes

- `pdflatex` is run twice per build to allow internal references and layout to stabilise
- The HTML target uses `htlatex` with `custom.css` appended post-build for styling
- Temporary files produced by `htlatex` in the working directory are removed automatically after each HTML build
- The Markdown target uses `pandoc` reading `.tex` directly, preserving headings, bold, lists, and hyperlinks

---

## Feedback

### Strengths

**Single source of truth.** All five formats are derived from one `.tex` file. There is no risk of the PDF and the ATS submission copy diverging — a common problem when people maintain a Word document and a plain text version separately.

**ATS pipeline is genuinely well considered.** The switch from `ps2pdf` to `pdflatex`, the hyphenation disable, the plain hyphen bullets, and the explicit `YYYY - YYYY` date format are all deliberate and correct choices. Most people submitting LaTeX CVs do not think about any of this.

**Two independent text extraction paths.** Having both `detex` and `pdftotext` outputs is useful — one for submission, one for verification. Being able to inspect the `pdftotext` output directly tells you exactly what an ATS parser will see from the PDF, which online ATS scoring tools cannot reliably replicate.

**Embedded PDF metadata.** Most LaTeX CVs ship with empty or default metadata. Having author, title, subject, and keywords embedded in the PDF is a meaningful signal to any system that reads XMP data.

**CSS theming is self-contained.** Appending `custom.css` post-build rather than relying on `htlatex` default styles means the HTML output is independently styleable without touching the `.tex` source. The dark theme is distinctive and appropriate for a technical role.

**Makefile is clean and composable.** Individual targets mean you can rebuild only what changed. The double `pdflatex` run is correctly handled. `.PHONY` is correctly declared.

**Date-first format in experience entries.** Putting `YYYY - YYYY:` at the start of each subsection heading rather than right-aligning dates is an ATS-safe structural choice that also reads cleanly across all five output formats.

---

### Weaknesses

**`htlatex` is a fragile dependency.** It is part of TeX4ht which is old, inconsistently maintained, and produces verbose HTML with non-semantic class names like `cmbx-10` tied to internal font names. If the LaTeX source changes in certain ways the CSS selectors can silently break. The modern successor `make4ht` or using `pandoc` for HTML output as well would be more robust long-term.

**The Markdown header block is best-effort.** `pandoc` does a good job converting the body but the header — name, contact details, links — relies on LaTeX line break commands that do not translate idiomatically into Markdown. The result requires manual inspection after any structural change to the header.

**No error surfacing in the Makefile.** The `@` prefix suppresses all output. A `pdflatex` compile error will halt the build but the failure message may be buried. Removing `@` from the `pdflatex` lines, or adding a `|| cat $(OUTDIR)/$(NAME).log` fallback, would make failures significantly easier to diagnose.

**`htlatex` temp file cleanup is incomplete.** The cleanup block removes known temp files from the working directory by name but does not account for `.aux`, `.log`, and `.out` files that accumulate in `$(OUTDIR)` across builds from the `pdflatex` runs.

**CSS targets font-specific class names.** Rules like `.cmbx-12` and `.cmbx-10` are tied to `htlatex` internal font rendering class names which can change depending on the LaTeX font stack. Switching fonts in the `.tex` would silently break parts of the HTML styling with no warning.

**No version tracking or changelog.** Since this is a versioned document in a repository there is no record of what changed between versions. A simple `CHANGELOG.md` or git tags would make it easier to track when content was last updated, which matters when sending the CV to multiple employers over time.
