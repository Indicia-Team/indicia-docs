Record Details 2
----------------

Provides a customisable view of a single record, ideal for linking to "Explore" reports.

If you install the `Metatag and Metatag: Open Graph <https://www.drupal.org/project/metatag>`_
modules, Record Details pages will add location, image and title metadata to the page which can be
picked up in links to Facebook and other social media.

This form provides a configurable way to create a view page for a record. The following
controls are available in its user interface:

User Interface
~~~~~~~~~~~~~~

The content of the generated page is entirely driven by the *User interface > Form
structure* configuration. Like other Indicia customisable page types, the *Form Structure*
is a text area in which you can place tokens which are replaced by controls when the page
is viewed. You can intersperse the control tokens with HTML to build a custom layout if
required.

Controls are represented by their name in square brackets and must be the only thing on
their line. They are followed by any number of parameters on the subsequent lines which
start with @, are followed by the property name then equals then the value. The list of
properties associated with a control stops as soon as something else is found which is not
A property definition. Property names and values are normally on one line but if a large
property value is required you can wrap the value in an XML comment (<!-- ... -->). For
example::

  [myControl]
  @myProperty=foo
  @myLongProperty=<!--
    bar
    baz
  -->

Controls availabe are as follows:

[record details]
""""""""""""""""

Draws the record details section of the page, including a list of attribute name/value pairs
including custom attributes. Options include:

  * fieldsToExcludeIfLoggedOut - array of field names to skip if the user is anonymous.
  * outputFormatting - set to true to enable auto-formatting HTML for new lines and hyperlinks in
    text custom attribute values.

[photos]
""""""""

Outputs a set of photo thumbnails for the record, with click to show the original image in a popup.

[sample photos]
"""""""""""""""

Outputs a set of photo thumbnails for the record's sample, with click to show the original image in
a popup.

[parent sample photos]
""""""""""""""""""""""

[map]
"""""

A map showing the record.

[comments]
""""""""""

[previous determinations]
"""""""""""""""""""""""""

[occurrence associations]
"""""""""""""""""""""""""

[login]
"""""""

[block]
"""""""

A control for rendering a Drupal block.

Options are:
* @title - output a block title.
* @module - machine name of the module providing the block.
* @block - machine name of the block.

[buttons]
"""""""""

A set of buttons for actions relating to the record.

Options available are:
* buttons - array containing 'edit' to include the edit button, 'explore' for the explore link
  button, 'species details' for the species details page link. Defaults to all buttons.
* classes - associative array of each button name (edit, explore or record), with the value being
  the class to apply to the button if overriding the default.