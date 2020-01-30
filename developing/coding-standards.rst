****************
Coding standards
****************

At the moment this page is just a scratchpad for a few things you may find useful when
getting started as an Indicia developer.

A few words on coding standards. I don't want to bore you with excessive lists of
conventions that you must learn, but there are a handful of tips that will help us all get
along and work on each other's code without rewriting it every time we open a new code
file.

#. For version numbering we are using [http://semver.org/ Semantic Versioning].
#. Please take the time to look over your code and consider if it is well
   structured, readable and maintainable. It might be tempting to rush changes into the
   code but that will no doubt slow things down in the long run. That also means keep your
   method short, simple and break them up into several smaller methods if necessary.
   Generally speaking each method should fit on a single page when viewed on a typical
   monitor.
#. Line widths should be ideally less than 120 characters where possible.
#. Please comment code using the standards required of [http://www.phpdoc.org/
   phpDocumentor]. That will help us auto-generate all the documentation for the project.
#. Please adopt the following naming conventions in your PHP code:

   * ClassName
   * methodName
   * propertyName
   * function_name (meant for global functions)
   * $variable_name

#. Please also contribute to the documentation by cloning the
   [https://github.com/Indicia-Team/indicia-docs documentation repository] and submitting
   pull requests.
#. When writing SQL directly against the database, please avoid using SELECT `*` -
   the system will try to automatically convert geometry fields to WKT, but it can't do
   this if it doesn't know they're there. Also note that any field name ending in
   'geom' will be treated this way, so don't use that for any fields that aren't
   geometry data.
#. For PHP code, applying the Drupal community coding standards is a good starting point.
#. For JavaScript, we recommend using ESLint to apply coding standards to
   [https://github.com/airbnb/javascript Airbnb rules]. There is an .eslintrc configuration
   file in the root of the iform module code to assist with this and it is possible to
   configure many IDEs including VS Code, PhpStorm to apply ESLint automatically as you work.
