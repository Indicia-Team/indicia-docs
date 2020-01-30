.. _documentation:

*********************************
Contributing to the Documentation
*********************************

The documentation for Indicia is written in Restructured Text (RST). RST is fast, simple
and powerful (although you may like to contrast that with `another opinion
<https://emptysqua.re/blog/restructuredtext-in-pycharm-firefox-and-anger/>`_ which
describes it as 'permanently unlearnable' and 'a loathsome afterbirth expelled from the
same womb as XML and TeX'). If you look at a RST document, you'll see that the formatting
information is contained as part of the text itself, so the text does not actually look
like the final output. The document is then processed by a program called Sphinx to change
it into the final HTML page. Here is a quick example of what some simple RST text might
look like::

  **********
  Page title
  **********

  This is a bit of text, followed by a list of points:

    * Point 1
    * Point 2 with some **bold** text

Regrettably there are no WYSIWYG tools for writing the Sphinx style of RST so you have to
learn it like a programming language. A good starting point is to take a look at a
definition of `restructuredText (RST, reST) <http://sphinx.pocoo.org/rest.html>`_

The reason for subjecting ourselves to RST is that it can be easily converted to PDF and
Epub formats as well as HTML.

The Indicia documentation is stored in `a repository on GitHub
<https://github.com/Indicia-Team/indicia-docs>`_. You can fork this to make changes to the
documentation and submit them as pull requests. Once changes are merged in to the
repository, the administrator of the documentation website then converts the RST into HTML
for use on the public website. Currently the documents are hosted by `ReadTheDocs
<https://readthedocs.org/>`_ which links to the repository and performs the compilation to
HTML. The final url of the documentation is
http://indicia-docs.readthedocs.io/en/latest/contents.html

For additional information see

* :ref:`documentation-vscode`

* :ref:`documentation-tutorial`
