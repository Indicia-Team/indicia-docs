Location details
----------------

Provides a customisable view of a single location.

If you install the `Metatag and Metatag: Open Graph <https://www.drupal.org/project/metatag>`_
modules, Record Details pages will add location, image and title metadata to the page which can be
picked up in links to Facebook and other social media.

This form provides a configurable way to create a view page for a location. The following
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

[location details]
""""""""""""""""""

Draws the location details section of the page, including a list of attribute name/value pairs
including custom attributes. Options include:

  * fieldsToExcludeIfLoggedOut - array of field names to skip if the user is anonymous.
  * outputFormatting - set to true to enable auto-formatting HTML for new lines and hyperlinks in
    text custom attribute values.
  * title - defaults to true, outputs a block title. Set to a string to override the title or false
    to remove it.

[photos]
""""""""

Outputs a set of photo thumbnails for the location, with click to show the original image in a
popup.

[map]
"""""

A map showing the location's boundary.

[block]
"""""""

A control for rendering a Drupal block.

Options are:

  * @title - output a block title.
  * @module - machine name of the module providing the block.
  * @block - machine name of the block.

[buttons]
"""""""""

A set of buttons for actions relating to the location.

Options available are:

  * buttons - array containing 'edit' to include the edit button, 'explore' to include an explore
    link or 'record' to include a link to a recording form for the site. Other options may be added
    in future. The 'record' button requires an option @enterRecordsPath set to the path of a form
    page for entering a list of records at this location. The form should use the
    [location url param] control to allow it to use the location_id parameter passed to the form.
    Defaults to edit and explore buttons.
  * classes - associative array of each button name (edit, explore or record), with the value being
    the class to apply to the button if overriding the default.
  * title - set to a string to output a block title. Default false.

[subsites]

A report grid containing subsites.

Options available are:

  * title - default to true. Set to a string to override the title, or false to remove it.
  * addChildrenEditFormPaths - Allows addition of buttons for adding a child site. A JSON object
    where the property names are button labels and the values are paths, e.g.::

      @addChildrenEditFormPaths=<!--{
        "Add a habitat": "built-environment-sites/habitats/edit",
        "Add a feature": "built-environment-sites/features/edit"
      }-->

    Paths should point to an "Enter a location (customisable)" with the "Link the location to a
    parent" option checked.
  * columns - report_grid @columns option setting, if overriding the default.
  * dataSource - report to use if overriding the default. Should accept a `parent_location_id`
    parameter for filtering.