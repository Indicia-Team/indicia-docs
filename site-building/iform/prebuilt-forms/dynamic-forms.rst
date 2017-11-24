General notes on dynamic forms
------------------------------

Flexible

Simple macro language

Extensions

Extension list
==============

Extensions are additional controls which can be embedded in any dynamic form's content
by copying the control's name in square brackets to a new line in the form structure,
with options specified on subsequent lines preceded by the @ symbol. The following shows
the syntax and demonstrates addition of a PDF generation button to a page:

.. code::

  [print.pdf]
  @format=landscape

[extra_data_entry_controls.person_autocomplete]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A control which provides autocomplete functionality to lookup against the list of people
who are users of this website, searching surname, firstname format. By default the value
returned by the control is the ID from the users table, but this can be overridden using
the @valueField option. The following options are available:

  * @fieldname - required

Here's an example of the control configuration::

  [extra_data_entry_controls.person_autocomplete]
  @fieldname=smpAttr:985
  @valueField=person_name
  @label=Collector
  @class=control-width-5
  @tooltip=Person who spots the fruitbody.
  @lockable=true

[extra_data_entry_controls.associated_occurrence]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following example shows a species input control with a
2nd control to inputting the associated occurrence.

  [species]
  [extra_data_entry_controls.associated_occurrence]
  @label=Associated organism
  @association_type_id=123
  @copy_attributes=4
  @fieldname=occurrence:associated_taxa_taxon_list_id
  @class=control-width-5
  @lockable=true

[misc_extensions.button_link]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[misc_extensions.text_link]
~~~~~~~~~~~~~~~~~~~~~~~~~~~

[misc_extensions.js_has_permission]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[misc_extensions.js_user_field]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[misc_extensions.data_entry_helper_control]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[misc_extensions.breadcrumb]
~~~~~~~~~~~~~~~~~~~~~~~~~~

[misc_extensions.read_only_input_form]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[misc_extensions.set_page_title]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[misc_extensions.enable_tooltips]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[misc_extensions.location_from_url]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[misc_extensions.group_link_popup]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[misc_extensions.area_picker]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Adds a drop down box to the page which lists areas on the maps (e.g. a list of countries).
When you choose an area in the drop down, the following happens:

  * The map on the page automatically pans and zooms to the chosen area.
  * The spatial reference system control, if present, automatically picks the best system
    for the chosen map area as defined in the map area data file.
  * If there are multiple graticules on the map, then only the one for the selected area
    of the map will show, the others are hidden.

The following options can be passed to this control:

  * @areas - Required - pass an array of area names to include in the drop down list. The
    area names provided must match those defined in the mapAreaData.js file (as described
    below).
  * @mapDataFile - optionally specify a different file to the default provided one
    defining the map areas. If you use this option, copy the file mapAreaData.js from the
    extensions folder to files/indicia/js rename and edit it there.

Other options available are the same as for data_entry_helper::select controls, e.g. use
the @label option to define the control's label.

[misc_extensions.localised_text]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A simple extension that allows text to be inserted into the form which will be passed
through the `lang::get()` function and therefore can be localised into different languages.
The following options can be passed to this control:

  * @text - Required - pass the text to localised.

[print.pdf]
~~~~~~~~~~~

Outputs a button for converting a page such as a report page to a PDF file. This control
currently has the following limitations:

  * May not work with maps.
  * When using charts (report_helper::report_charts), set the option @responsive to true
    to ensure the layout fits the page.
  * Will not support output of very large reports due to limitations in the size of an
    HTML canvas.

The following options can be passed to this control:

  * @format - portrait, landscape, or choose (default).
  * @includeSelector - selector for the page element which includes the content to be
    printed. This allows the PDF generation to ignore parts of the page such as
    navigation, sidebars and footers etc. Defaults to #content.
  * @excludeSelector - selector for any elements inside the element being printed which
    should be hidden.
  * @maxRecords - maximum number of records to load per report table. Default 200.
  * @fileName - default name given to download PDF files. Defaults to report.pdf.
  * @addToSelector - if specified, then the button generated will be added to the element
    matching this selector rather than emitted inline. This allows you to embed the PDF
    generation button anywhere on the page you want to.
  * @titleSelector - set to the selector used for the page title element to include in the
    report. Defaults to #page-title.
