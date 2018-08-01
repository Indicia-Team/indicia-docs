# Makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
PAPER         =
BUILDDIR      = _build

# Internal variables.
PAPEROPT_a4     = -D latex_paper_size=a4
PAPEROPT_letter = -D latex_paper_size=letter
ALLSPHINXOPTS   = -d $(BUILDDIR)/doctrees $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) .
# the i18n builder cannot share the environment and doctrees with the others
I18NSPHINXOPTS  = $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) .

.PHONY: help clean html dirhtml singlehtml pickle json htmlhelp qthelp devhelp epub latex latexpdf text man changes linkcheck doctest gettext

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  html               to make standalone HTML files"
	@echo "  epub               to make an epub"
	@echo "  latex              to make LaTeX files, you can set PAPER=a4 or PAPER=letter"
	@echo "  latexpdf           to make LaTeX files and run them through pdflatex"
	@echo "  latexpdf-developer to make LaTeX files for Indicia Developer Training and run them through pdflatex"
	@echo "  latexpdf-advanced  to make LaTeX files for Indicia Advanced Training and run them through pdflatex"
	@echo "  changes            to make an overview of all changed/added/deprecated items"
	@echo "  linkcheck          to check all external links for integrity"
	@echo "  doctest            to run all doctests embedded in the documentation (if enabled)"

clean:
	-rm -rf $(BUILDDIR)/*

html:
	$(SPHINXBUILD) -b html $(ALLSPHINXOPTS) $(BUILDDIR)/html
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/html."

html-developer:
	$(SPHINXBUILD) -b html -t developer -c alternate-docs/developer $(ALLSPHINXOPTS) $(BUILDDIR)/html-developer
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/html-developer."

html-advanced:
	$(SPHINXBUILD) -b html -t advanced -c alternate-docs/advanced $(ALLSPHINXOPTS) $(BUILDDIR)/html-advanced
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/html-advanced."

epub:
	$(SPHINXBUILD) -b epub $(ALLSPHINXOPTS) $(BUILDDIR)/epub
	@echo
	@echo "Build finished. The epub file is in $(BUILDDIR)/epub."

latex:
	$(SPHINXBUILD) -b latex $(ALLSPHINXOPTS) $(BUILDDIR)/latex
	@echo
	@echo "Build finished; the LaTeX files are in $(BUILDDIR)/latex."
	@echo "Run \`make' in that directory to run these through (pdf)latex" \
	      "(use \`make latexpdf' here to do that automatically)."

latexpdf:
	$(SPHINXBUILD) -b latex $(ALLSPHINXOPTS) $(BUILDDIR)/latex
	@echo "Running LaTeX files through pdflatex..."
	$(MAKE) -C $(BUILDDIR)/latex all-pdf
	@echo "pdflatex finished; the PDF files are in $(BUILDDIR)/latex."

latexpdf-developer:
	$(SPHINXBUILD) -b latex -t developer -c alternate-docs/developer $(ALLSPHINXOPTS) $(BUILDDIR)/latex-developer
	@echo "Running LaTeX files through pdflatex..."
	$(MAKE) -C $(BUILDDIR)/latex-developer all-pdf
	@echo "pdflatex finished; the PDF files are in $(BUILDDIR)/latex-developer."

latexpdf-advanced:
	$(SPHINXBUILD) -b latex -t advanced -c alternate-docs/advanced $(ALLSPHINXOPTS) $(BUILDDIR)/latex-advanced
	@echo "Running LaTeX files through pdflatex..."
	$(MAKE) -C $(BUILDDIR)/latex-advanced all-pdf
	@echo "pdflatex finished; the PDF files are in $(BUILDDIR)/latex-advanced."

changes:
	$(SPHINXBUILD) -b changes $(ALLSPHINXOPTS) $(BUILDDIR)/changes
	@echo
	@echo "The overview file is in $(BUILDDIR)/changes."

linkcheck:
	$(SPHINXBUILD) -b linkcheck $(ALLSPHINXOPTS) $(BUILDDIR)/linkcheck
	@echo
	@echo "Link check complete; look for any errors in the above output " \
	      "or in $(BUILDDIR)/linkcheck/output.txt."

doctest:
	$(SPHINXBUILD) -b doctest $(ALLSPHINXOPTS) $(BUILDDIR)/doctest
	@echo "Testing of doctests in the sources finished, look at the " \
	      "results in $(BUILDDIR)/doctest/output.txt."
