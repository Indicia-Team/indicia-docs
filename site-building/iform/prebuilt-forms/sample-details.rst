Sample details
--------------

Provides a customisable view of a single sample.

If you install the `Metatag and Metatag: Open Graph <https://www.drupal.org/project/metatag>`_
modules, Record Details pages will add location, image and title metadata to the page which can be
picked up in links to Facebook and other social media.

This form provides a configurable way to create a view page for a sample. The following
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

[sample details]
""""""""""""""""

Draws the sample details section of the page, including a list of attribute name/value pairs
including custom attributes. Options include:

  * fieldsToExcludeIfLoggedOut - array of field names to skip if the user is anonymous.
  * outputFormatting - set to true to enable auto-formatting HTML for new lines and hyperlinks in
    text custom attribute values.

[sample photos]
"""""""""""""""

Outputs a set of photo thumbnails for the sample, with click to show the original image in a popup.

[parent sample photos]
""""""""""""""""""""""

Outputs a set of photo thumbnails for the sample's parent sample (e.g. the transect for a transect
section), with click to show the original image in a popup.

[map]
"""""

A map showing the sample.

[login]
"""""""

[records grid]
""""""""""""""

A report grid of records recorded as part of this sample.

[records list]
""""""""""""""

[sample details]
""""""""""""""""

[buttons]
"""""""""

Options available are:

  * buttons - array containing 'edit' to include the edit button. Other options may be added in
    future.
  * classes - associative array of each button name (edit, explore or record), with the value being
    the class to apply to the button if overriding the default.
  * title - set to a string to output a block title. Default false.