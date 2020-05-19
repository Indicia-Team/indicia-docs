Elasticsearch Report Helper
***************************

This class provides functionality for generating reports and maps which use Elasticsearch
as a datasource rather than the Indicia PostgreSQL database directly. For information on
setting up Elasticsearch for Indicia see https://github.com/Indicia-Team/support_files/tree/master/Elasticsearch
and :doc:`../../../developing/rest-web-services/elasticsearch`.

The functionality is based on the principle of a source (a connector to Elasticsearch
data) plus one or more output controls which provide various views of the data via the
source. Output controls include data grids, maps and downloads. When constructing a page
it is possible to build dashboard style functionality by having several sources, e.g. one
for raw data and one for aggregated data, plus several output controls per source.

This helper can be accessed:

  * Using the :doc:`../prebuilt-forms/dynamic-elasticsearch` prebuilt form.
  * Directly from PHP code.

Examples are given for how to use the controls from the prebuilt form's Form Structure
setting because that is the most common way of using them. They can be converted to PHP
code as follows::

  [source]
  @id=sorted-data
  @sort={"id":"desc"}

becomes:

.. code-block:: php

  <?php
  echo ElasticsearchReportHelper::source([
    'id' => 'sorted-data',
    'sort' => '{"id":"desc"}',
  ]);

Note that when using PHP directly you should also call the
`ElasticsearchReportHelper::enableElasticsearchProxy()` method as well to ensure that the
required configuration for accessing Elasticsearch is added to he page.

.. tip::

  A good way to use this documentation is to study the examples given for each control
  and cross-reference to the list of options. Once you've grasped the basics of each
  control's usage, the list of advanced options provides further configuration
  possibilities.

Initialisation methods
======================

.. _elasticsearch-report-helper-enableElasticsearchProxy:

ElasticsearchReportHelper::enableElasticsearchProxy
---------------------------------------------------

Prepares the page for interacting with the Elasticsearch proxy.

If coding in PHP directly, this method should be called before adding any other
ElasticsearchReportHelper controls to the page. It is not necessary to call
`enableElasticsearchProxy` if using the prebuilt form.

Data access control methods
===========================

Methods provided for accessing Elasticsearch data by this helper are listed below:

.. _elasticsearch-report-helper-source:

ElasticsearchReportHelper::source
---------------------------------

The `source` control acts as a link from other controls on the page to a set of data from
Elasticsearch. Think of the `source` as a way of defining the output of a query - by
default a list of occurrence records but it can also generate data for aggregated reports,
e.g. a count of records and species by country or record counts by species.

A `source` can declare it's own query filtering (in addition to those specified on the
page) and can also define an Elasticsearch aggregation if needed. On its own, a `source`
control does nothing. It's only when another output control is linked to it that data
will be fetched and shown on the page.

When configuring a `source` control the list of available document field names can be
found in the `document structure documentation
<https://github.com/Indicia-Team/support_files/blob/master/Elasticsearch/document-structure.md>`_.

Typical configuration examples
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A minimally configured source which lists Elasticsearch documents (each describing an
occurrence)::

  [source]
  @id=docs-list

A source which provides geohashed data ready for heat mapping (change the mode to
'mapGridSquare' for grid square based maps)::

  [source]
  @id=map-geohash-output
  @mode=mapGeoHash

A source which lists species using a composite aggregation::

  [source]
  @id=species-list
  @mode=compositeAggregation
  @uniqueField=taxon.accepted_taxon_id
  @fields=[
    "taxon.kingdom",
    "taxon.order",
    "taxon.family",
    "taxon.accepted_name"
  ]

A source which provides data aggregated to show species counts by recorder using an
Elasticsearch term aggregation. In this example, because of the potentially high
number of recorders to aggregate on we use an alternative sort aggregation for this
column which reduces the precision and associated memory requirements::

  [source]
  @id=recorder-summary
  @sort={"event.recorded_by.keyword":"desc"}
  @mode=termAggregation
  @uniqueField=event.recorded_by
  @size=30
  @aggregation=<!--{
    "species_count": {
      "cardinality": {
        "field": "taxon.species_taxon_id"
      }
    }
  }-->
  @sortAggregation=<!--{
    "species_count": {
      "cardinality": {
        "field": "taxon.species_taxon_id",
        "precision_threshold": 100
      }
    }
  }-->

Options
^^^^^^^

The following options are available:

**aggregation**

In `termAggregation` or `compositeAggregation` mode, provide a list of aggregations which
provide the output for additional columns in the dataset in JSON format. See
https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations.html.
You can use Kibana to build an aggregation then inspect the request to extract the
required JSON data. The value provided should be a JSON object where the property names
are the keys given for each aggregation (i.e. the contents of the "aggregations" or "aggs"
element in your query).

The value for `@aggregation` can contain tokens which are replaced at runtime. Tokens are
of the format `{{ name }}` where the `name` can be one of the following:

  * indicia_user_id - the user's warehouse user ID.
  * a parameter from the URL query string.

When using termAggregation or compositeAggregation mode, the keys of this object represent
additional calculated fields that will be added to the output dataset. Normally this means
a single bucket aggregation per key but nested aggregations can be expanded into table
columns using a `dataGrid` control.

**fields**

An array of document field names to include in the output when using `termAggregation` or
`compositeAggregation` mode. This list is for the non-aggregated fields, for calculated
aggregated data fields use the `@aggregation` option.

**id**

All `source` controls require a unique ID which allows other data bound controls to
refer to it.

**mode**

Set the `@mode` option to define the overall behaviour of the `source`.

An Indicia occurrence document in Elasticsearch contains several pieces of spatial data.
The ones which are relevant to aggregated data are the `location.point` field which
contains a latidude and longitude, plus the `location.grid_square` fields which contain
the center of the covering grid square in 1km, 2km and 10km sizes.

* docs (default) - retrieve a set of Elasticsearch documents.
* mapGeoHash - aggregates retrieved data using an Elasticsearch `geohash_grid` aggregation
  based on the `location.point` field value, suitable for providing data to a heat map
  layer. The precision of the aggregation is automatically controlled depending on the map
  zoom.
* mapGridSquare - aggregates retrieved data using an Elasticsearch `terms` aggregation on
  `location.grid_square` field values. These contain the centres of grid squares covering
  the record at 1km, 2km and 10km resolution. The default behaviour is to automatically
  select the grid square size depending on map zoom but this can be overriden by setting
  `@mapGridSquareSize` to the size of the required grid square in metres (10000, 2000 or
  1000).
* compositeAggregation - generates a composite aggregation from the `@uniqueField`,
  `@fields` and `@aggregation` settings. Similar to the `termAggregation` mode but with
  different restrictions. Composite aggregations have the following features:
    * Fast and efficient.
    * Can be sorted on the unique field or any of the other fields.
    * Does not support sorting by one of the aggregated outputs. This is a limitation of
      Elasticsearch.
    * Supports the next/previous buttons for paging in a `dataGrid`.
  A separate count aggregation is automatically added to the request when required in
  in order to provide proper information for a `dataGrid`'s pager, since composite
  aggregations cannot themselves include a total buckets count.
* termAggregation- generates a term aggregation from the `@uniqueField`, `@fields` and
  `@aggregation` settings. Similar to the `compositeAggregation` mode but with different
  restrictions. Term aggregations have the following features:
    * Can be sorted on any field or aggregated output.
    * Does not support the next/previous buttons for paging in a `dataGrid`.

**size**

Number of documents (each of which represents an occurrence) matching the current query to
return. This might be the size of each page in a report grid for example. When `@mode` is
set to `compositeAggregation` or `termAggregation` the size passed here is used to
determine the number of aggregation buckets to retrieve and the number of documents to
retrieve is set to zero.

**sort**

Sets the default sort order of the source. Object where the properties are the field
names to sort by and the values are either "asc" or "desc" as appropriate. E.g.::

  [source] @id=sorted-data @sort={"id":"desc"}

If using composite or term aggregation mode and sorting by an aggregate column, then the
name given should be the name of the aggregate, not the name of the underlying field in
the document. In these modes it is also possible to specify either the field specified in
the `unique_field` option or any of the fields specified in the additional `fields` array
option.

**uniqueField**

Used when the mode is `compositeAggregation` or `termAggregation`. Name of a field in the
Elasticsearch document which has one unique value per row in the output. This will
typically be a field containing an ID or key, for example when each row represents a taxon
you might set `uniqueField` to `taxon.accepted_taxon_id`, or when each row represents a
sample it could be set to `event.event_id`.

Setting this value allows the source control to:
* use the cardinality of this field as a quick way to count the output, since counting is
  not directly possible using a composite aggregation.
* For terms aggregations, this field is used as the outermost terms aggregation. Other
  non-aggregated fields will be attached to the output using a top hits aggregation (see
  https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-metrics-top-hits-aggregation.html)

Advanced options
^^^^^^^^^^^^^^^^

**filterPath**

By default, requests for documents from Elasticsearch contain the entire document stored
for each occurrence record. This can result in larger network packets than necessary
especially where only a few fields are required. The filter path allows configuration of
the fields returned for each document using the Elasticsearch response filter.

Use this option with care, since you need to understand the structure of the response and
which parts are essential to the operation of the controls using the data. In the
following example, data for a `dataGrid` are limited to information relating to the total
row count and occurrence event::

  [source]
  @id=grid-data
  @filterPath=hits.total,hits.hits._source.event

  [dataGrid]
  @source=grid-data

As the example uses the default columns which includes taxon and location based values,
some data columns in the grid will be empty. Removing `hits.total` from the value will
cause a JavaScript error since this would remove essential information required for grid
operation.

See https://www.elastic.co/guide/en/elasticsearch/reference/7.0/common-options.html#common-options-response-filtering.

**from**

In `docs` mode, optional number of documents to offset by. Defaults to 0 and is normally
controlled by a `dataGrid`'s paging behaviour.

**initialMapBounds**

When this source provides data to load onto a map, set to true to use this source's
dataset to define the bounds of the map on initial loading. This option is automatically
set when using one of the map aggregation modes.

**filterBoolClauses**

A JSON definition of clauses to add to an Elasticsearch bool query
(https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-bool-query.html).
The property names should therefore be one of `must`, `filter`, `should`, `must_not` and
they can be nested to support complex logic. For example::

  @filterBoolClauses=<!--{
    "must_not":[
      {"query_type": "term","field": "identification.verification_status","value":"R"}
    ]
  }

**filterSourceGrid**

If set to the ID of a grid on the same page which is linked to a different source, then
this `[source]` can apply an additional filter to the returned data depending on the
selected row. In this case you should also set the following:

  * `@filterSourceField` to determine which field/column in the output dataset to use as a
    source for the filter value. This is normally the same as the field name in
    Elasticsearch but will be different if the value is being obtained from an aggregation
    bucket.
  * `@filterField` to determine the name of the field in Elasticsearch to match the filter
    value against.

For example you might have a 2 grids and a map where the map shows all the verified records
of the species selected in the grid. This requires 2 `[source]` controls, a `[dataGrid]`
and a `[leafletMap]`::

  [source]
  @id=grid-data
  @size=30

  [source]
  @id=mapData
  @filterSourceGrid=records-grid
  @filterSourceField=taxon.accepted_taxon_id
  @filterField=taxon.accepted_taxon_id
  @mode=mapGeoHash

  [dataGrid]
  @id=records-grid
  @source=grid-data
  @columms=

  [leafletMap]
  @id=map
  @source=<!--{
    "map-data": "Verified records of selected species"
  }-->

Can also be set to a JSON array of table IDs, in which case the @filterSourceField and
@filterField parameters should also be JSON arrays of matching fields names, allowing the
datasource to obtain it's filter data from more than one dataGrid. In this case, the last
grid row clicked on is applied as a filter.

**filterSourceField**

See the description of `filterSourceGrid` above.

**filterField**

See the description of `filterSourceGrid` above.

**filterBoundsUsingMap**

This option is automatically set when using one of the map modes. If manually setting up
the aggregation and the source is for a geohash aggregation used to populate a map layer
then you probably don't want the aggregation to calculate for the entire world view. For
example, a heat map aggregation should increase its precision as you zoom the map in. In
this case, set a filter for the geo_bounding_box to an empty object (`{}`). This will
then automatically populate with the map's bounding box.

For example::

  [source]
  @id=recordsGeoHash
  @size=0
  @aggregation=<!--
    {
      "filter_agg": {
        "filter": {
          "geo_bounding_box": {}
        },
        "aggs": {
          "2": {
            "geohash_grid": {
              "field": "location.point",
              "precision": 4
            },
            "aggs": {
              "3": {
                "geo_centroid": {
                  "field": "location.point"
                }
              }
            }
          }
        }
      }
    }
  -->
  @filterBoundsUsingMap=map

  [leafletMap]
  @id=map
  @layerConfig=<!--{
    "recordsHeatMap": {
      "title": "All records in current filter (heat map)",
      "source": "recordsGeoHash",
      "type":"heat",
      "style": {
        "gradient": {
          "0.4": "#fce7e2",
          "0.65": "#a6bddb",
          "1": "#2b8cbe"
        }
      }
    }
  }-->

Data output methods
===================

.. _elasticsearch-report-helper-customScript:

ElasticsearchReportHelper::customScript
---------------------------------------

A flexible output of ES data which uses a custom JavaScript function to build the HTML.

Options
^^^^^^^

**id**

Optional. Specify an ID for the `customScript` control allowing you to refer to it from
elsewhere, e.g. CSS. If not specified, then a unique ID is generated by the code which
cannot be relied on.

**source**

ID of the `[source]` control this `customScript` is populated from.

.. _elasticsearch-report-helper-dataGrid:

**functionName**

Name of a function that should be added to the JavaScript global `indiciaFns` which
formats the output. Takes 3 parameters:

* el - the element the output should be added to.
* sourceSettings - settings object for the source the control is linked to.
* response - the response from Elasticsearch to be formatted by the function.

.. _elasticsearch-report-helper-dataGrid:

ElasticsearchReportHelper::dataGrid
-----------------------------------

Generates an HTML table containing Elasticsearch data. The `dataGrid` control has built in
support for sorting, filtering, column configuration and pagination.

Table rows holding data have the class `data-row` to identify them within the code. They
also have a class added `selected` when the row is selected (e.g. showing the associated
feature on the map). For rows linking to raw Elasticsearch documents, as opposed to
aggregated data, there is a class `zero-abundance` added when the record is a record of
absence. Finally, additional classes can be added to rows using the `@rowClasses` option.

Typical configuration examples
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A minimal configuration for a `dataGrid` showing docs from a `source` with default
columns::

  [source]
  @id=grid-data

  [dataGrid]
  @source=grid-data

Another minimal configuration of a `dataGrid`, this time auto-generating it's columns
from a `source` in aggregation mode::

  [source]
  @id=species-list
  @mode=termAggregation
  @uniqueField=taxon.accepted_taxon_id
  @fields=<!--[
    "taxon.kingdom",
    "taxon.order",
    "taxon.family",
    "taxon.accepted_name"
  ]-->
  @aggregation=<!--{
    "records": {
      "cardinality": {
        "field": "id"
      }
    }
  }-->

  [dataGrid]
  @source=species-list

A `dataGrid` linked to a `source` with a composite aggregation, this time specifying the
columns to show::

  [source]
  @id=recorder-summary
  @sort={"event.recorded_by.keyword":"desc"}
  @mode=compositeAggregation
  @uniqueField=event.recorded_by
  @size=30
  @aggregation=<!--{
      "species_count": {
        "cardinality": {
          "field": "taxon.species_taxon_id"
        }
      }
  }-->
  @sortAggregation=<!--{
    "species_count": {
      "cardinality": {
        "field": "taxon.species_taxon_id",
        "precision_threshold": 100
      }
    }
  }-->

  [dataGrid]
  @id=recorders-grid
  @source=recorder-summary
  @columns=<!--[
    {"caption": "Recorder", "field": "event.recorded_by"},
    {"caption": "Records", "field": "doc_count"},
    {"caption": "Species", "field": "species_count"}
  ]-->

Options
^^^^^^^

**actions**

An array defining additional action buttons to include for each row in the grid in the
rightmost column. For example you might like an action button to navigate to a record edit
page.

Each action entry can have the following properties:

  * title - text to add to the button's title attribute, shown on hover as a tooltip.
  * iconClass - class to attach which should define the icon. Normally a FontAwesome class
    is used.
  * path - base path to the page to navigate to. Tokens will be replaced as follows:
    * {rootFolder} will be replaced by the root folder of the site, allowing links to be
      specified as "{rootFolder}path" where the path is a Drupal alias (without leading
      slash).
    * {language} will be replaced by the current user's 2 character selected language
      code.
    * Field values from the row's Elasticsearch document can be specified by putting the
      field name in square brackets, e.g. [taxon.taxon_name] or [id].
  * urlParams - additional parameters to add to the URL as key/value pairs. Can also
    contain field value replacements by putting the field name in square brackets.

Note that the title, path and urlParams properties can all contain field name replacement
tokens by putting the field name in square brackets. This can contain a list of field
names separated by OR in which case the first field name with a value will be used. This
is illustrated in the `top_sample_id` parameter in the example below.

The following action defines a button with a file icon that links to a species details
page with a URL that might look like:

`http://www.example.com/species-pages/Andrena%20cineraria?occurrence_id=123`

.. code-block:: none

  @actions=<!--[
    {
      "iconClass":"far fa-file-alt",
      "path":"{rootFolder}/species-pages/[taxon.taxon_name]",
      "title":"View species details",
      "urlParams":{
        "occurrence_id":"[id]",
        "top_sample_id":"[event.parent_sample_id OR event.event_id]"
      }
    }
  ]
  -->

**columns**

  An array of column definition objects for the grid's columns, with each object having
  the following properties:

  * caption - title for the column.
  * description - information displayed as a hint when hovering over the column title.
  * field - required - can be the name of a field in the Elasticsearch document (e.g.
    `metadata.created_by_id`) or one of the following special field names:

    * #associations# - a list of the species names linked to this record as associated
      occurrences.
    * #attr_value:<entity>:<id># - a single custom attribute value. Specify the entity
      name (event (=sample) or occurrence) plus the custom attribute ID as parameters.
    * #data_cleaner_icons# - icons representing the results of data cleaner rule checks.
    * #datasource_code# - outputs the website and survey ID, with tooltips to show the
      website and survey dataset name.
    * #event_date# - event (sample) date or date range.
    * #higher_geography:<type>:<field>:<format># - provides the value of a field from one
      of the associated higher geography locations. The following parameter options are
      available:
      * With no additional parameters, provides all available higher geography data.
      * With the first `<type>` parameter set to the location type term you want to
        retrieve (e.g. "Country") to provide all field values for that location type
        (i.e. the `id`, `name`, `code` and `type`).
      * Additionally provide a second `<field>` parameter to limit the response for the
        chosen type to a single field. This must be one of `id`, `name`, `code` or `type`.
      * The output will be formatted as readable text unless the optional third `<format>`
        parameter is set to `json` in which case JSON is returned.
    * #locality# - a summary of location information including the given location name
      and a list of higher geography locations.
    * #lat_lon# - a formatted latitude and longitude value.
    * #null_if_zero:<field># - returns the field value, unless 0 when will be treated as
      null.
    * #status_icons# - icons representing the record status, confidential, sensitive and
      zero_abundance status of the record.
    * Path to an aggregation's output when using aggregated data.

  When defining the path to a field in the Elasticsearch document, if the path contains
  aggregation buckets which holds an array, the index of the required bucket can be
  inserted in the path, for example `by_group.buckets.0.species_count.value`. Or, instead
  of an index a filter on the bucket contents can be used to select an item at any index
  by putting a key=value pair in square brackets, e.g.
  `by_group.buckets.[key=flowering plant].species_count.value`.

  * path - where fields are nested in the document response, it may be cleaner to set the
    field to the path to where to find the field in the document in this option. So,
    rather than set the field to `fieldlist.hits.hits.0._source.my_count_agg.value` for
    example, set the `path` to `fieldlist.hits.hits.0._source` and the field to
    `my_count_agg.value`, resulting in cleaner class names in the code among other
    benefits.
  * rangeField - name of a second field in the Elasticsearch document which defines a
    range when combined with the field's value. If the value of the field pointed to
    by `rangeField` is different to the value pointed to by `field` then the output will
    be of the form `value1 to value2`.
  * ifEmpty - string to output when the field value is empty. May contain HTML.
  * handler - for date and datetime fields, set to `date` or `datetime` to ensure correct
    formatting.
  * hideBreakpoints - Comma separated list of breakpoints. When a breakpoint is specified
    the column is hidden for pixel sizes between this breakpoint (or zero in the case of
    the smallest breakpoint) and the next highest breakpoint. So, setting a value of "sm"
    makes a column disappear between 760 and 992 pixels. Therefore it is more likely that
    you want to set it to "xs,sm" which means anything under 992 pixels. Following this
    logic, setting "lg" hides the column for any device over 1200 pixels.
    "xs,sm" to . The default breakpoints are:
    * xs: 480 (extra small)
    * sm: 760 (small)
    * md: 992 (medium)
    * lg: 1200 (large)
    These defaults can be set by specifying responsiveOptions.breakpoints.
  * dataType="date|numeric"

If not provided, the list of columns will default depending on the source settings.
When the source mode is an aggregation, all the fields and aggregation outputs are
included in the list of columns. When the source mode is docs, a principle attributes of
the occurrence record are included.

**cookies**

Set to false to disable use of cookies to remember the selected columns and their
ordering. Cookies are only enabled when there is a specific `id` option set for this grid.

**id**

Optional. Specify an ID for the `dataGrid` control allowing you to refer to it from
elsewhere, e.g. CSS. If not specified, then a unique ID is generated by the code which
cannot be relied on.

**includeColumnHeadings**

Set to false to disable column headings.

**includeFilterRow**

Set to false to disable the filter row at the top of the table.

**includePager**

Set to false to disable the pager row at the bottom of the table.

**includeMultiSelectTool**

Set to include a multi-select tool which enables tickboxes for each row. Normally used
to support multiple record verification.

**rowClasses**

An array of classes that will be included in the `class` attribute for each `<tr>` element
in the grid's body. Each may contain token replacements for the fields in the row's document by
wrapping the field name in square brackets. For example::

  @rowClasses=<!--[
    "table-row",
    "status-[identification.verification_status]"
  ]-->

Since rows always have a class called `data-row` the above configuration might output the
following:

.. code-block:: html

  <tr class="data-row table-row status-V">...</tr>

**scrollY**

Set to a CSS height in pixels (e.g. "800px") to display a scrollbar on the table body with
this as the maximum height. Allows the data to be scrolled whilst leaving the header
fixed. Set to a negative height (e.g. "-50px") to set the table body to occupy all
available space to the bottom of the screen minus the height given.

**source**

ID of the `source` this dataGrid is populated from.

**sortable**

Set to false to disable sorting by clicking the sort indicator icons in the heading row.

Advanced options
^^^^^^^^^^^^^^^^

**applyFilterRowToSources**

If a filter row is present in the grid, then changing the filter row contents will
automatically apply the filter to the source the dataGrid is linked to. If any additional
sources should also be filtered (e.g. sources driving maps or charts from the same data)
then supply a JSON array of source IDs in this parameter.

**containerElement**

If you want to output the dataGrid in an existing element on the page with a known CSS
selector then specify the selector here. If the selector matches multiple elements then
only the first will be used.

**autoResponsiveCols** - set to true to automatically hide columns responsively when below
each breakpoint. Priority is set by position in the grid with columns on the right being
hidden first. Overrides `hideBreakpoints` setting for each column.

**autoResponsiveExpand** - set to true to automatically expand any additional information
beneath the row when cells are dropped due to responsive hide behaviour. Otherwise the
user has to click a + button to view the hidden information.

**availableColumns**

Defines which columns are available using the column configuration tool for the
`dataGrid`. By default all known columns are made available but you may wish to simplify
the list of columns in some circumstances. Specify an array of field names from the
Elasticsearch index.

**responsive**

Defaults to true but can be disabled by setting to false.

**responsiveOptions**

Options for responsive behaviour which will be passed to the Footable component that makes
the table responsive. Can include:

  * breakpoints - a JSON object where the properties are breakpoint names and the values
    are the number of pixels below which the breakpoint is triggered. The default is:

    .. code-block:: javascript

      {
        "xs": 480,
        "sm": 760,
        "md": 992,
        "lg": 1200
      }

.. _elasticsearch-report-helper-download:

ElasticsearchReportHelper::download
-----------------------------------

A button with associated progress display for generating downloadable zip files of CSV
data from an associated [source] control. Files are added to a list of downloads and are
kept available on the server for a period of time.

Typical configuration examples
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A minimal configuration to download a set of documents (occurrences)::

  [source]
  @id=data-to-download

  [download]
  @source=data-to-download

A download for a limited columns set::

  [source]
  @id=data-to-download

  [download]
  @source=data-to-download
  @columnsTemplate=
  @addColumns=<!--[
    {"caption": "Recorder", "field": "event.recorded_by"},
    {"caption": "Date", "field": "#event_date#"},
    {"caption": "Grid ref.", "field": "location.output_sref"},
    {"caption": "Taxon", "field": "taxon.accepted_name"}
  ]-->

A `download` using a `source` in term aggregation mode::

  [source]
  @id=recorder-summary
  @sort={"event.recorded_by.keyword":"desc"}
  @mode=termAggregation
  @uniqueField=event.recorded_by
  @size=30
  @aggregation=<!--{
      "species_count": {
        "cardinality": {
          "field": "taxon.species_taxon_id"
        }
      }
  }-->

  [download]
  @source=recorder-summary

A `download` using a `dataGrid` to define the columns in the resulting file::

  [source]
  @id=recorder-summary
  @sort={"event.recorded_by.keyword":"desc"}
  @mode=compositeAggregation
  @uniqueField=event.recorded_by
  @size=30
  @aggregation=<!--{
      "species_count": {
        "cardinality": {
          "field": "taxon.species_taxon_id"
        }
      }
  }-->
  @orderbyAggregation=<!--{
    "species_count": {
      "cardinality": {
        "field": "taxon.species_taxon_id",
        "precision_threshold": 100
      }
    }
  }-->

  [dataGrid]
  @id=recorders-grid
  @source=recorder-summary
  @columns=<!--[
    {
      "caption": "Recorder",
      "field": "event.recorded_by"
    },
    {"caption": "Records", "field": "doc_count"},
    {"caption": "Species", "field": "species_count"}
  ]-->

  [download]
  @linkToDataGrid=recorders-grid
  @caption=Grid download

Options
^^^^^^^

**addColumns**

Define additional columns to those defined in the template that you want to include in the
download file. An array which uses the same format as the 'dataGrid' '@columns' option.

**caption**

Button caption. Defaults to "Download" but will be translated.

**columnsTemplate**

Named set of columns on the server which will be included in the download file. Default is
"default" when the source is in `docs` mode, or blank for the aggregation modes. Options
are currently "default" or can be set to blank to disable loading a predefined set. Other
sets may be provided on the warehouse in future.

**id**

Optional. Specify an ID for the `download` control allowing you to refer to it from
elsewhere, e.g. CSS. If not specified, then a unique ID is generated by the code which
cannot be relied on.

**linkToDataGrid**

If specified, uses a dataGrid control to obtain the source and columns configuration.

**removeColumns**

Define columns from the selected column template to be removed from the CSV download. An
array of the column titles to remove.

**source**

ID of the [source] control that provides the data for download. Required unless the
**linkToDataGrid** option is specified.

**title**

Title attribute of the HTML button, displayed as a hint when the mouse hovers over it.
Defaults to "Run the download" but will be translated.

Advanced options
^^^^^^^^^^^^^^^^

**buttonContainerElement**

Set @buttonContainerElement to the CSS selector of a container if you want to output the
download button in a separate location on the page to the output control listing the
download files. For example to add the button to the footer of a [dataGrid] alongside
the pagination information::

  [download]
  @linkToDataGrid=recorders-grid
  @caption=Grid download
  @buttonContainerElement=#recorders-grid tfoot td

**containerElement**

If you want to output the download control in an existing element on the page with a known
CSS selector then specify the selector here. If the selector matches multiple elements
then only the first will be used.

.. _elasticsearch-report-helper-higherGeographySelect:

ElasticsearchReportHelper::higherGeographySelect
------------------------------------------------

A select box for choosing from a list of higher geography boundaries (indexed locations).
May either act as a single control, or a linked set of select controls if multiple nested
location types are specified where child locations are linked to their parent via the
`parent_id` field in the databaes.

When a location is chosen, the map will show the boundary, pan and zoom to the boundary
and the results are filtered to records intersecting the boundary.

Locations must be from an indexed location layer. See :doc:`../../../administrating/warehouse/modules/spatial-index-builder`
for more info.

Options
^^^^^^^

**blankText**

Text shown for the option which corresponds to no location filter.

**label**

Attaches the given label to the control.

**locationTypeId**

Either a single ID of the location type of the locations to list, or an array of IDs of
location types where the locations are hierarchical (parent first). Each type ID must be
indexed by the spatial index builder module.

**readAuth**

Read authorisation tokens. Not required when used via the prebuilt form.

.. _elasticsearch-report-helper-leafletMap:

ElasticsearchReportHelper::leafletMap
-------------------------------------

A map panel which uses the leaflet library that can display occurrence data from
Elasticsearch in a variety of ways.

Typical configuration examples
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A heat map::

  [source]
  @id=map-data
  @mode=mapGeoHash

  [leafletMap]
  @layerConfig=<!--{
    "recordsHeatMap": {
      "title": "All records heat map",
      "source": "map-data",
      "type": "heat"
    }
  }-->


Options
^^^^^^^

**baseLayerConfig**

A JSON object defining the base layers to make available for addition to the map. Each
property is the title of a base layer which contains a sub-object with configuration for
that layer. The layer configuration options are:

* type - OpenStreetMap, OpenTopoMap, Google or WMS.
* config - a nested object containing configuration depending on the layer type.

For OpenStreetMap and OpenTopoMap, the config object is not used.

For Google layers, the config object can contain the following:

* subType - roadmap, satellite, terrain or hybrid.

For WMS layers, the config object can contain the following:

* sourceUrl - the URL of the WMS service if using type WMS.
* wmsOptions - any additional options to pass to the WMS web service, which will normally
  at least include a `layers` property.

Defaults to OpenStreetMap and OpenTopoMap.

Example configuration::

  @baseLayerConfig=<!--{
    "OpenStreetMap": {
      "type": "OpenStreetMap"
    },
    "Google Streets": {
      "type": "Google",
      "config": {
        "subType": "roadmap"
      }
    },
    "Google Satellite": {
      "type": "Google",
      "config": {
        "subType": "satellite"
      }
    },
    "Mundialis": {
      "type": "WMS",
      "config": {
        "sourceUrl": "http://ows.mundialis.de/services/service?",
        "wmsOptions": {
          "layers": "TOPO-OSM-WMS"
        }
      }
    }
  }-->

**cookies**

Set to false to disable use of cookies to remember the selected layers plus the current
map viewport. Cookies are only enabled when there is a specific `id` option set for this
map.

**id**

Optional. Specify an ID for the `leafletMap` control allowing you to refer to it from
elsewhere, e.g. CSS. If not specified, then a unique ID is generated by the code which
cannot be relied on.

**initialLat**

Latitude the map will pan to on initial load, if not overridden by a saved cookie or the
map being set up to display the bounding box of a report's output. Defaults to the
configuration setting for the IForm module.

**initialLng**

Longitude the map will pan to on initial load, if not overridden by a saved cookie or the
map being set up to display the bounding box of a report's output. Defaults to the
configuration setting for the IForm module.

**initialZoom**

Level the map will zoom to on initial load, if not overridden by a saved cookie or the
map being set up to display the bounding box of a report's output. Defaults to the
configuration setting for the IForm module.

**layerConfig**

A JSON object defining the foreground layers to add to the map. Each property is the ID
of a layer which contains a sub-object containing the configuration for that layer. The
layer objects can have the following properties:

  * title - Display title of the layer.
  * source - ID of a `source` that provides the data. This source can either provide
    un-aggregated raw data or one of the aggregation types defined for the
    `aggregationMapMode` setting for the `source`.
  * enabled - set to false if you want this layer to be initially hidden and only
    available via the layer switcher. Once enabled, the state of the layer will be
    remembered in a cookie unless cookies are explicitly disabled or the map has no
    specific `id` option set for this map.
  * type - one of the following:

      * circle - see `Leaflet circle <https://leafletjs.com/reference-1.5.0.html#circle>`_
      * square - see `Leaflet rectangle <https://leafletjs.com/reference-1.5.0.html#rectangle>`_
      * marker (default) - see
        `Leaflet marker <https://leafletjs.com/reference-1.5.0.html#marker>`_.
      * heat - heat map generated using `Leaflet.heat <http://leaflet.github.io/Leaflet.heat>`_.
      * geom - a polygon representing the record's original geometry.
      * WMS - A Web Mapping Service layer.

  * options - for circles, squares and markers, an object to pass to leaflet as options
    for the feature as described in the links for each feature type above, e.g.
    `fillOpacity` or `radius`.

    A special option called `size` can be specified for circles
    and squares which defines the size of the feature in metres (similar to radius but the
    latter is calculated as a number of pixels). For non-aggregated data, the size
    defaults to the `location.coordinate_uncertainty_in_meters` field value so features
    reflect their known accuracy. `Size` can be set to the special value
    `autoGridSquareSize` so that it matches the current map grid square aggregation as you
    zoom the map in, showing 10km features when zoomed out, then 2km, then 1km when zoomed
    in. This setting is automatic when using a map source mode.

    A special value called `metric` can be specified for any option. For non-aggregated
    data, this is the `location.coordinate_uncertainty_in_meters` value. For aggregated
    data, this value is set to an indication of the number of documents in the current
    bucket (i.e. the number of occurrences represented by the current feature). It is
    set to a scale from 0 - 20000, or for fillOpacity options it is set on a scale from
    0 - 1.

  * sourceUrl - the URL of the WMS service if using type WMS.
  * wmsOptions - any additional options to pass to the WMS web service.

**selectedFeatureStyle**

Object containint style options to apply to the selected feature. For example::

  @selectedFeatureStyle=<!--{
    "color": "#00FF00"
    "opacity": "0.6"
  }-->

**showSelectedRow**

To make the map highlight the feature associated with a selected row in a `dataGrid`, set
showSelectedRow to the `id` of that grid. The map will also zoom in to the feature when
the grid row is double clicked.

.. _elasticsearch-report-helper-permissionFilters:

ElasticsearchReportHelper::permissionFilters
--------------------------------------------

Output a selector for various high level permissions filtering options.

Permission sets available in the selector will depend on the permissions set on the
Permissions section of the Edit tab in combination with the settings passed in the
options parameter. Options available are:

  * my_records_permission - set to true to enable the option to filter for a user's own
    records.
  * all_records_permission - set to true to enable the option to filter for all records.
  * location_collation_records_permission - set to true to enable the option to filter for
    records in a location that the user has a Drupal permission to collate for (e.g. an
    LRC).

.. _elasticsearch-report-helper-recordDetails:

ElasticsearchReportHelper::recordDetails
----------------------------------------

A tabbed panel showing key details of the record. Includes a tab for record field values,
one for comments logged against the record and one to show the recorder's level of
experience for this and similar taxa.

Options available are:

**explorePath**

Path to an Explore all records page that can be used to show filtered records, e.g. the
records underlying the data on the experience tab. Optional.

**extraLocationTypes**

As for **locationTypes**, but will be shown in the Derived Info block at the bottom of the
pane rather than in the first block of attribute values. Therefore suitable for location
types with a lower priority.

**locationTypes**

The record details pane will show all indexed location types unless you provide an array
of the type names that you would like included, e.g. ["Country","Vice County"]. Optional.

**readAuth**

Read authorisation tokens. Not required when used via the prebuilt form.

**showSelectedRow**

ID of the grid whose selected row should be shown. Required.

.. _elasticsearch-report-helper-standardParams:

ElasticsearchReportHelper::standardParams
-----------------------------------------

A toolbar allowing the building of filters to be applied to the page's report data.

Options
^^^^^^^

**allowSave**

Set to false to disable saving of filters.

**indexedLocationTypeIds**

An array of location_type_id values to define the list of indexed location types to make
available for filtering. These are filtered by a higher geography query.

**otherLocationTypeIds**

An array of location_type_id values to define the list of non-indexed location types to
make available for filtering. These are filtered by a polygon query.

**sharing**

Which sharing mode to save and load filters for. Set to reporting, verification,
data_flow, editing, moderation or peer_review. Default reporting.

**taxon_list_id**

ID of the taxon list that species and other taxon names are selectable from.

Advanced options
^^^^^^^^^^^^^^^^

Other options are described in the PHP documentation for the
`client_helpers/prebuilt_forms/includes/reports.php` `report_filter_panel()` method.

.. _elasticsearch-report-helper-templatedOutput:

ElasticsearchReportHelper::templatedOutput
------------------------------------------

A flexible output of ES data which uses templates to build the HTML.

Typical configuration examples
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This example using templated output and the `@containerElement` option to build an HTML
table::

  [source]
  @id=sample-agg
  @size=0
  @aggregation=<!--{
    "per_sample": {
      "terms": {
        "field": "event.event_id",
        "min_doc_count": 5,
        "size": 30,
        "order": {
          "_count": "desc"
        }
      }
    },
    "stats_per_sample": {
      "stats_bucket": {
        "buckets_path": "per_sample._count"
      }
    }
  }-->

  [templatedOutput]
  @containerElement=#sample-table tbody
  @source=sample-agg
  @repeatField=aggregations.per_sample.buckets
  @content=<tr><th>Count for {{ key }}</th><td>{{ doc_count }}</td></tr>

  [templatedOutput]
  @containerElement=#sample-total
  @source=sample-agg
  @content=Count returned: {{ aggregations.stats_per_sample.count }}, average: {{ aggregations.stats_per_sample.avg }}

  <table id="sample-table">
    <tbody>
    </tbody>
  </table>
  <div id="sample-total"></div>

Options
^^^^^^^

**content**

HTML to output for each item. Replacements are field names {{ this.that }} within the path
specified by repeatField.

**footer**

A piece of HTML that will be inserted into a div at the bottom of the control when a
response is received.

**header**

A piece of HTML that will be inserted into a div at the top of the control when a response
is received.

**id**

Optional. Specify an ID for the `templatedOutput` control allowing you to refer to it from
elsewhere, e.g. CSS. If not specified, then a unique ID is generated by the code which
cannot be relied on.

**repeatField**

Where the response from Elasticsearch contains an array of values that should be repeated
in the output specify the path to the field containing the array here. A good example is
the `buckets` list for an aggregation. E.g. `aggregations.per_sample.buckets` allows
iteration over the response for an aggregation called `per_sample`.

**source**

ID of the `[source]` control this templatedOutput is populated from.

.. _elasticsearch-report-helper-urlParams:

ElasticsearchReportHelper::urlParams
------------------------------------

This control allows you to configure how the page uses parameters in the URL to filter the
output shown on the page. By default, the following filter parameters are supported:

  * taxa_in_scratchpad_list_id - takes the ID of a `scratcphad_list` as a parameter and
    creates a hidden filter parameter which limits the returned records to those of
    species in the scratchpad list. For example, a report page which lists scratchpad
    lists could have an action in the grid that links to an Elasticsearch outputs page
    passing the list ID as a parameter.
  * sample_id - takes the ID of a `sample` as a parameter and creates a hidden
    filter parameter which limits the returned records to those in the sample.
  * taxa_in_sample_id - takes the ID of a `sample` as a parameter and creates a hidden
    filter parameter which limits the returned records to those of taxa in the sample.
    Note that records will be included from other samples as long as they are for the same
    taxa.

For example, a report page which lists samples or scratchpad lists could have an action
in the grid that links to an Elasticsearch outputs page passing the ID as a parameter.

Additional filters can be configured via the `fieldFilters` option.

Typical configuration examples
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

An example where a page is configured to filter by `&genus=...` in the URL::

  [urlParams]
  @fieldFilters=<!--{
    "genus": {
      "name": "taxon.genus"
    }
  }-->

Options
^^^^^^^

**fieldFilters**

Use this option to override the list of simple mappings from URL parameters to
Elasticsearch index fields. Pass an array keyed by the URL parameter name to accept, where
the value is an array of configuration items where each item defines how that parameter is
to be interpreted. Therefore multiple filters may result from a single parameter. Each
configuration item has the following data values:

  * name - Elasticsearch field name to filter
  * type - optional. If set to `integer` then validates that the field supplied is an
    integer. Other data types may be supported in future.
  * process - optional. possible values are:

    * taxonIdsInScratchpad - the value is used as a scratchpad_list_id which is used to
      look up a list of taxa. The value is replaced by a list of taxon.taxon_ids for
      filtering to the entire list.
    * taxonIdsInSample - the value is used as a sample_id which is used to look up a
      list of taxa. The value is replaced by a list of taxon.taxon_ids for filtering to
      the entire list.

    If the process is not specified then the value is used as is.

.. _elasticsearch-report-helper-userFilters:

ElasticsearchReportHelper::userFilters
--------------------------------------

Provides a drop down populated with the user's saved report filters. Selecting a filter
applies that filter to the current page's outputs.

Options
^^^^^^^

**definesPermissions**

Set to true if this control is to load permission filters such as those which define a
verification context.

**sharingCode**

Code indicating the type of task the filters to load are for. Default R (=reporting).

.. _elasticsearch-report-helper-verificationButtons:

ElasticsearchReportHelper::verificationButtons
----------------------------------------------

Outputs a panel containing action buttons for verification tasks, including changing the
record status, querying the record and accessing the record edit page. Effectively allows
an Elasticsearch report page to be converted into a verification tool.

Options
^^^^^^^

**editPath**

If a Drupal page path for a generic edit form is specified then a button is added to allow
record editing.

**id**

ID of the HTML element. If not specified, a unique ID will be autogenerated which cannot
be relied on.

**showSelectedRow**

Specify the element ID of a `[dataGrid]` control which the buttons will source the
selected row from.

**viewPath**

If a Drupal page path for a record details page is specified then a button is added to
allow record viewing.

Positioning of control elements
===============================

All output controls (data grids, maps etc) will output their content at the appropriate
location on the page into a `div` element whose ID matches the `id` option you specify.

If you want to override the creation of a container div and, instead, inject the control
content into an HTML element of your choice elsewhere on the page, then you can specify
the CSS selector of that element in the `@containerElement` option.

The following example shows how a single aggregation request can be injected as rows into
a table elsewhere on the page::

  [source]
  @id=sample-agg
  @size=0
  @aggregation=<!--{
    "per_sample": {
      "terms": {
        "field": "event.event_id",
        "min_doc_count": 5,
        "size": 30,
        "order": {
          "_count": "desc"
        }
      }
    },
    "stats_per_sample": {
      "stats_bucket": {
        "buckets_path": "per_sample._count"
      }
    }
  }-->

  [templatedOutput]
  @containerElement=#sample-table tbody
  @source=sample-agg
  @repeatField=aggregations.per_sample.buckets
  @content=<tr><th>Count for {{ key }}</th><td>{{ doc_count }}</td></tr>

  [templatedOutput]
  @containerElement=#sample-total
  @source=sample-agg
  @content=<div>Count of samples {{ aggregations.stats_per_sample.count }}</div>

  <table id="sample-table">
    <tbody>
    </tbody>
  </table>
  <div id="sample-total"></div>

You could also set `@containerElement` to the selector of a `div` element output elsewhere
on the page, e.g. part of the theme's header.

Using controls directly from JS
===============================

As all the functionality in the ElasticsearchReportHelper's output controls is driven by
JavaScript in the client, it is possible to write JS directly with minimal PHP. `source`
controls are defined by appending an object containing the options to the
`indiciaData.esSources` array. Other controls are provided as jQuery plugins where the
plugin name is 'idc' plus the method name, e.g. `ElasticsearchReportHelper::leafletMap`
is represented by the jQuery plugin `idcLeafletMap`. The option are passed as a parameter.

Example code:

**HTML**

.. code-block:: html

  <div id="dataGrid1" class="idc-output idc-output-dataGrid"></div>

**JavaScript**

.. code-block:: javascript

  jQuery(document).ready(function docReady($) {
    indiciaData.esSources.push({
      id: 'source-league',
      size: 0,
      aggregation: {
        recorder_agg: {
          terms: {
            field: "event.recorded_by.keyword",
            size: 100,
            order: {
              _count: "desc"
            }
          },
          aggs: {
            species_count: {
              cardinality: {
                field: "taxon.species_taxon_id"
              }
            }
          }
        }
      }
    });
    $('#dataGrid1').idcDataGrid({
      id: 'dataGrid1',
      source: {'source-league': 'League table'},
      aggregation: simple,
      columns: [
        {"caption":"Recorder name", "field":"key"},
        {"caption":"Number of records", "field":"doc_count"},
        {"caption":"Number of species", "field":"species_count.value"}
      ]
    });
    indiciaFns.populateDataSources();
  });

**PHP**

.. code-block:: php

  <?php

  iform_load_helpers(['ElasticsearchProxyHelper']);
  ElasticsearchReportHelper::enableElasticsearchProxy();
  handle_resources();

  ?>