Dynamic Reports
---------------

Dynamic Reports provides a highly configurable reporting page which uses a similar
technique to other dynamic forms to allow you to configure exactly what is output onto the
page. You can include maps, charts and data grids.

.. toctree::

  dynamic-reports/tutorial/dynamic-reports

Setting up a dynamic report page involves configuring the default view of the map (same
process as for other forms), providing a set of report parameter values in the **Report
Settings** section of the edit page, then using the **User Interface** section to define
how the page should be output. If you are starting from a new Indicia page, then in the
**Form Selection** section, set the **Form Category** to **Reporting** and the **Select
Form** drop down to **Reporting page (customisable)**.

Defining the form structure
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The **Form Structure** box, in the **User Interface** section of a dynamic report's
**Edit** tab, allows you to type free text to define the page output. This text is parsed
with 1 token per line and any unrecognised text is output as HTML into the page which
allows you to output static custom content of any nature. The structure of the page output
can be defined using the following tokens, which are shared with the :doc:`other dynamic
forms <dynamic-sample-occurrence>`.

* ``=<section>=`` - any text wrapped in equals signs defines a section on the page. This
  maps to a tab if using tabbed output mode.
* `|` - the pipe character, when alone on a line, defines that content in the current
  section preceding the pipe must go into one column, content following the pipe goes into
  a second column. CSS must be present on the page to layout the columns correctly.

Control content can then be added to the page by specifying square brackets around the
name of the control you want to output. The following controls are available:

* ``[params]`` - Outputs a parameters form for the report.
* ``[standard params]`` - Outputs a filter bar designed for setting up report parameters
  against reports which support filtering occurrences using the standard set of
  parameters.
* ``[map]`` - Outputs a report map.
* ``[reportgrid]`` - Outputs a grid of records for a report.
* ``[report download link]`` - Outputs a simple link for downloading a CSV file.
* ``[reportchart]`` - Outputs a chart of the output of a report (line, bar or pie).

You can provide options to each of the controls on the subsequent lines in the form
structure, by specifing option values in the form::

  @<option>=<value>

In all cases, specify the name of the report you want to use, using the @dataSource option
such as the following::

  [report_grid]
  @dataSource=library/totals/species_occurrence_image_counts

Other options are available in the API documentation for `report_map
<http://www.biodiverseit.co.uk/indicia/dev/docs/classes/report_helper.html#method_report_map>`_,
`report_grid <http://www.biodiverseit.co.uk/indicia/dev/docs/classes/report_helper.html#method_report_grid>`_
and `report_chart <http://www.biodiverseit.co.uk/indicia/dev/docs/classes/report_helper.html#method_report_chart>`_
controls.

If you ensure that the parameters of each report on a single page are the same, then you
can output a single [params] control using one of the reports as the @dataSource and the
parameters will be passed through to all the other reports. You might use this technique,
for example, to output a map of records, plus a list of records and a list of species
for the same input criteria on one page. Better still, if you are only using reports
which support the standardised set of parameters built into the Warehouse's report engine,
then you can use a single ``[standard params]`` control to filter all the reports and maps
on one page.

.. tip::

  If you enable the **High Volume Reporting** option on **Other IForm Settings** then the
  page content will be cached. When the page expires, reports will have a chance of being
  rebuilt if their own cache expires. You can control the number of seconds before each
  individual cached report expires using the ``@cacheTimout`` option.

Example configuration - iRecord's Explore page
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The **Explore - All records** page on `iRecord <http://www.brc.ac.uk/irecord>`_ uses a
dynamic report page with standard paramater reports. Here are the key details you'll need
to replicate this page on your site.

**Initial Map View & Base Map Layers**: set these configuration settings as required.

**Other Map Settings - Controls to add to the map**: set to::

  layerSwitcher
  panZoomBar
  drawPolygon
  drawLine
  drawPoint

**User Interface - Interface Style Option**: Tabs

**User Interface - Form Structure**: Set to the following, noting that the values for
``@taxon_list_id``, ``@indexedLocationTypeId`` and ``@otherLocationTypeId`` will need
to be changed if using a different Warehouse to iRecord::

  [standard_params]
  @allowSave=true
  @linkToMapDiv=map
  @taxon_list_id=15
  @filter-date_age=1 month
  @filter-indexed_location_id={profile_location}
  @filter-taxon_group_list={profile_taxon_groups}
  @indexedLocationTypeIds=[15,1370]
  @otherLocationTypeIds=[2412,2188]
  [map]
  @dataSource=library/occurrences/filterable_explore_list_mapping
  @dataSourceLoRes=library/occurrences/filterable_explore_list_mapping_lores
  =Records=
  [report_grid]
  @dataSource=library/occurrences/filterable_explore_list
  @rowId=occurrence_id
  =Species=
  [report_grid]
  @dataSource=library/taxa/filterable_explore_list
  @downloadLink=true
  @rowId=taxon_meaning_id
  @linkFilterToMap=false

**Report settings - Preset parameter values** assuming you want no additional custom
attributes to appear on the report and have a default data entry form at the
``enter-record-list`` path::

  smpattrs=
  occattrs=
  default_input_form=enter-record-list

You may also want to configure some action columns in the **Column configuration** to
link to other related pages such as record and species details or the record's edit page.

Using extension libraries
^^^^^^^^^^^^^^^^^^^^^^^^^

As well as the generic controls provided by the default dynamic report page, it is
possible to add extra controls or ready made report outputs onto the map by defining
an *extension* (which is a PHP file that resides in the ``prebuilt_forms/extensions``
folder that defines controls that can be output by any dynamic page). The following
additional controls are available for you to add to your report page, as defined by the
**event_reports** extension. These are particularly useful for reporting on events such
as bioblitzes. Events are normally filtered by providing a survey_id, date_from and
date_to report parameter via the **Report Settings** section of the page's Edit view. You
can also provide a report parameter called **input_form** to filter to the exact form used
for data entry, useful when a single survey defined on the warehouse contains the reports
for several events. For each control, you can override the report used using the
``@dataSource`` option.

* ``[event_reports.count_by_location_map]`` - outputs a map of locations participating in
  the event, with a label for each location showing the number of records or species. Some
  useful options for this control are:

  * ``@output=species`` - set this option to switch from showing a count of records to a
    count of species.
  * ``@zoomMapToOutput=false`` - set this option to disable auto-zooming the map to the
    locations in the report output.
  * ``clickableLayersOutputDiv``, ``clickableLayersOutputMode``,
    ``@clickableLayersOutputColumns`` can all be set to define the click functionality.
    See `report_map documentation
    <http://www.biodiverseit.co.uk/indicia/dev/docs/classes/report_helper.html#method_report_map>`_
    for details.
* ``[event_reports.totals_block]`` - outputs a block with the number of species, records
  and photos uploaded to the event so far. Set the following options if required:

  * ``@eventLabel`` - set to the name of the event.

* ``[event_reports.groups_pie]`` - shows a pie chart with a breakdown of all records by
  taxon group. Set the following options as required:

  * ``@width`` - the width of the chart panel in pixels.
  * ``@height`` - the height of the chart panel in pixels.

* ``[event_reports.photos_block]`` - outputs a block containing recent photos. Set the
  following options if required:

  * ``@limit`` - number of photos to show. Defaults to 10.

* ``[event_reports.trending_taxa_cloud]`` - outputs a `tag cloud
  <http://en.wikipedia.org/wiki/Tag_cloud>`_ of the recently input species. Set the
  following options if required:

  * ``@limit`` - set to the number of taxa to include in the cloud.

* ``[event_reports.trending_recorders_cloud]`` - - outputs a `tag cloud
  <http://en.wikipedia.org/wiki/Tag_cloud>`_ of the recorders who've recently contributed
  records. Set the following options if required:

  * ``@limit`` - set to the number of people to include in the cloud.

* ``[event_reports.species_by_location_league]`` - outputs a league table of the species
  found at each location in the event. Set the following options if required:

  * ``@limit`` - set to the number of locations to include. Defaults to 20.

* ``[event_reports.species_by_recorders_league]`` - outputs a league table of the species
  found by each recorder. Set the following options if required:

  * ``@limit`` - set to the number of recorders to include. Defaults to 20.

To illustrate this in action, here is the form structure configuration used for the
`2013 Garden BioBlitz <http://www.gardenbioblitz.org>`_ reporting::

  =Overview=
  [event_reports.count_by_location_map]
  @zoomMapToOutput=false
  @clickableLayersOutputDiv=map-click-info
  @clickableLayersOutputMode=div
  @clickableLayersOutputColumns={"name":"Vice County","value":"Records"}
  @cachetimeout=60
  |
  <div id="social-buttons">
  <span class='st_twitterfollow_hcount' displayText='Twitter Follow'
  st_username='GardenBioBlitz'></span>
  <span class='st_twitter_hcount' displayText='Tweet' st_title="Keep track of the first
  ever national Garden BioBlitz's progress"></span>
  <span class='st_facebook_hcount' displayText='Facebook'></span>
  <span class='st_plusone_hcount' displayText='Google +1' ></span>
  </div>
  <h3>Garden BioBlitz totals so far</h3>
  [event_reports.totals_block]
  @eventLabel=Garden BioBlitz
  @cachetimeout=20
  <h3>Breakdown of what's being recorded</h3>
  [event_reports.groups_pie]
  @width=350
  @height=350
  @cachetimeout=60
  <br/>
  <p>The map on the left shows the number of Garden BioBlitz sightings for each area
  across the United Kingdom.</p>
  <p>Click on the areas on the map to get details.</p>
  <div id="map-click-info"></div>
  =Trending=
  <p>Here are a few of the photos recently uploaded by Garden BioBlitzers. Can you find
  any of these in your garden?
  [event_reports.photos_block]
  @limit=9
  @cachetimeout=60
  |
  <h3>Trending species</h3>
  [event_reports.trending_taxa_cloud]
  @cachetimeout=60
  <h3>Trending recorders</h3>
  [event_reports.trending_recorders_cloud]
  @cachetimeout=60
  =League Tables=
  <h3>Counties League</h3>
  [event_reports.species_by_location_league]
  @cachetimeout=20
  @label=Vice Counties*
  <p class="helpText">*Vice counties are a version of the county boundaries which don't
  keep changing, so they are very useful for biological records.</a>
  |
  <h3>Recorders League</h3>
  [event_reports.species_by_recorders_league]
  @cachetimeout=20

Note the use of custom HTML to embed a third party social sharing solution onto the page.

You can `view this page in action <http://www.brc.ac.uk/iRecord/garden-bioblitz-info>`_.
