General notes on dynamic forms
------------------------------

Dynamic page types are labelled in the form picker as customisable. They all share a **Form
Structure** box in the **User Interface** section of the Edit tab. This uses a simple text format
which allows you to output controls onto the page in a fully flexible manner. The controls
available depend on the type of dynamic page you are creating and can be mixed with HTML for
complete control over the page layout.

Controls
========

Controls can be embedded into the output by wrapping the control name in square brackets, on its
own line, with no spaces beforehand.

Controls can have properties set by putting '@property=value' pairs on subsequent lines. For
example, on a data entry page type the following outputs a map with the `gridRefHints` option
enabled::

  [map]
  @gridRefHint=false

Where a property value needs to be spread over multiple lines, wrap it in XML comments <!-- -->
as follows::

  [download]
  @source=recordData
  @columnsTemplate=<!--[
    "easy-download",
    "mapmate"
  ]-->

If a control should only be displayed when the user has permission, a property `@permission` can
be used to specify the required permission::

  [download]
  @source=recordData
  @permission=can download

The permissions check can also allow a control to only be displayed when a user does not have the
given permission using the `@hideIfHasPermission` property::

  [dataGrid]
  @source=recordDataForAnonymousUsers
  @permission=logged in
  @hideIfHasPermission=true

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

A species input control for inputting an associated occurrence's species name. This
results in a 2nd occurrence being created when the form is saved and an
`occurrence_association` record joining the 2. The following options are available:

  * association_type_id - ID of the association type term to tag against the association.
  * copy_attributes - comma separated list of occurrence attribute IDs
    whose values are to be cloned from the main occurrence to the association.
  * taxon_list_id - ID of the species list to search if not the same as the main list
    configured for the form.
  * index - if there are multiple associated occurrence controls on the page, then give
    each a unique number in the index to allow them to function separately.
  * extraParams - parameters to pass through to the taxon_search service for species name
    lookup.

The following example shows a species input control with a 2nd control for inputting the
associated occurrence.

... code-block::

  [species]

  [extra_data_entry_controls.associated_occurrence]
  @label=Associated organism
  @taxon_list_id=3
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[misc_extensions.read_only_input_form]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[misc_extensions.set_page_title]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[misc_extensions.enable_tooltips]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[misc_extensions.location_from_url]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[misc_extensions.group_link_popup]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[misc_extensions.query_locations_on_map_click]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Add this control to a data entry form to enable detection of locations under a clicked map
point. Details of the found locations are then displayed in a `div` element on the page.
The following options are available:

  * id - HTML id attribute for the div which will contain the location details. A unique
    default will be assigned if not specified.
  * template - HTML to output for each intersecting location. Field value replacement
    tokens are specified as {{ fieldname }}. The following fields are available:

    * location_id
    * name
    * comment
    * location_type_id
    * location_type
    * centroid_sref
    * centroid_sref_system

  * locationTypeIds - an array of location type IDs to consider when looking for locations
    which intersect the click point.

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

[misc_extensions.redirect]
~~~~~~~~~~~~~~~~~~~~~~~~~~

Provides a method of causing a page to redirect, which can be combined with the `@permission` and
`@hideIfHasPermission` properties to control when the redirect occurs.

The following options can be passed to this control:

  * @path - required path to redirect to.
  * @params - array of query string keys and values to append. Any params which have a value in
    format {{ name }} are replaced by the parameter of the same name in the current page URL query
    string, or {{ indicia_user_id }} will be replaced by the logged in user's warehouse user ID.
  * @fragment - URL fragment which is added to the end of the URL being redirected to, after a '#'
    character.

For example, the following code could be placed on a record details page to redirect away to a
simpler version if the user is not logged in::

  [misc_extensions.redirect]
  @path=record-details/logged-out
  @params={"occurrence_id": "{{ occurrence_id }}"}
  @permission=logged in
  @hideIfHasPermission=true

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
  * @maxRecords - maximum number of records to load per report table. Default 200.
  * @fileName - default name given to download PDF files. Defaults to report.pdf.
  * @addToSelector - if specified, then the button generated will be added to the element
    matching this selector rather than emitted inline. This allows you to embed the PDF
    generation button anywhere on the page you want to.
  * @titleSelector - set to the selector used for the page title element to include in the
    report. Defaults to #page-title.

The control adds the `printing` CSS class to the page element whilst generating the PDF
output, allowing the customisation of the generation of PDF files.