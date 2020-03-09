Elasticsearch Report Helper
===========================

This class provides functionality for generating reports and maps which use Elasticsearch
as a datasource rather than the Indicia PostgreSQL database directly. For information on
setting up Elasticsearch for Indicia see https://github.com/Indicia-Team/support_files/tree/master/Elasticsearch
and :doc:`../../../developing/rest-web-services/elasticsearch`.

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

Control elements
----------------

All output controls (data grids, maps etc) will output their content at the appropriate
location on the page into a `div` element whose ID matches the `id` option you specify.

If you want to override the creation of a container div and, instead, inject the control
content into an HTML element of your choice elsewhere on the page, then you can specify
the CSS id of that element in the `attachToId` option.

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
        "size": 10000,
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
  @attachToId=sampleAgg
  @source=sample-agg
  @repeatField=aggregations.per_sample.buckets
  @content=<tr><th>Count for {{ key }}</th><td>{{ doc_count }}</td></tr>

  [templatedOutput]
  @attachToId=sampleTotal
  @source=sample-agg
  @content=<div>Count of samples {{ aggregations.stats_per_sample.count }}</div>

  <table>
    <tbody id="sampleAgg">
    </tbody>
  </table>
  <div id="sampleTotal"></div>

You could also set `attachToId` to the id of a `div` element output elsewhere on the page,
e.g. part of the theme's header.

Initialisation methods
----------------------

.. _elasticsearch-report-helper-enableElasticsearchProxy:

ElasticsearchReportHelper::enableElasticsearchProxy
"""""""""""""""""""""""""""""""""""""""""""""""""""

Prepares the page for interacting with the Elasticsearch proxy.

If coding in PHP directly, this method should be called before adding any other
ElasticsearchReportHelper controls to the page. It is not necessary to call
`enableElasticsearchProxy` if using the prebuilt form.

Data access methods
-------------------

Methods provided by this helper are listed below:

.. _elasticsearch-report-helper-source:

ElasticsearchReportHelper::source
"""""""""""""""""""""""""""""""""

The `source` control acts as a link from other controls on the page to a set of data from
Elasticsearch. Think of the `source` as a way of defining your query - by default a
filtered list of occurrence records but it can also generate data for aggregated reports,
e.g. a count of records and species by country.

A source can declare it's own query filtering (in addition to those specified on the page)
and can also define an Elasticsearch aggregation if needed. On its own, a source control
does nothing. Its only when another output control is linked to it that data will be
fetched and shown on the page.

The following options are available:

**id**

All `source` controls require a unique ID which allows other data bound controls to
refer to it.

**size**

Number of documents (each of which represents an occurrence) matching the current query to
return. This might be the size of each page in a report grid, or set this to zero for
aggregations where only summary data are required.

**sort**

For non-aggregated output, object where the properties are the field names to sort by and
the values are either "asc" or "desc" as appropriate. Sets the initial sort order on the
table. E.g.::

  [source]
  @id=sorted-data
  @sort={"id":"desc"}

**from**

Optional number of documents to offset by. Defaults to 0.

**filterPath**

By default, requests for documents from Elasticsearch contain the entire document stored
for each occurrence record. This can result in larger network packets than necessary
especially where only a few fields are required. The filter path allows configuration of
the fields returned for each document using the Elasticsearch response filter.
See https://www.elastic.co/guide/en/elasticsearch/reference/7.0/common-options.html#common-options-response-filtering.

**initialMapBounds**

When this source provides data to load onto a map, set to true to use this source's
dataset to define the bounds of the map on initial loading.

**aggregation**

Use this property to declare one or more Elasticsearch aggregations in JSON format. See
https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations.html.
You can use Kibana to build an aggregation then inspect the request to extract the
required JSON data. The value provided should be a JSON object where the property names
are the keys given for each aggregation (i.e. the contents of the "aggregations" or "aggs"
element in your query).

The value for `@aggregation` can contain tokens which are replaced at runtime. Tokens are
of the format `{{ name }}` where the `name` can be one of the following:

  * indicia_user_id - the user's warehouse user ID.
  * a parameter from the URL query string.

Here's an example aggregation that lists samples in the current filter::

  [source]
  @id=samples-data
  @size=0
  @aggregation=<!--
    {
      "samples": {
        "composite" : {
          "size": 50,
          "sources" : [
            { "event_id": { "terms" : { "field": "event.event_id" } } },
            { "date_start": { "terms" : { "field": "event.date_start" } } },
            { "date_end": { "terms" : { "field": "event.date_end" } } },
            { "output_sref": { "terms" : { "field": "location.output_sref.keyword" } } },
            { "recorded_by": { "terms" : { "field": "event.recorded_by.keyword" } } }
          ]
        },
        "aggs": {
          "count": {
            "cardinality": {
              "field": "taxon.accepted_taxon_id"
            }
          }
        }
      }
  }
  -->

**aggregationMapMode**

An Indicia occurrence document in Elasticsearch contains several pieces of spatial data.
The ones which are relevant to aggregated data are the `location.point` field which
contains a latidude and longitude, plus the `location.grid_square` fields which contain
the center of the covering grid square in 1km, 2km and 10km sizes.

When an aggregated source is used to provide map output, the following aggregation types
are supported:

* geoHash - a geo_hash aggregation on the location.point (default)
* gridSquare - an aggregation on `location.grid_square.srid` then one of the grid square
  centre fields to build an atlas style map based on grid squares.

The following example illustrates a `source` that provides data to a 10km grid square map:

.. code-block:: none

  [source]
  @id=mapData
  @size=0
  @initialMapBounds=true
  @filterBoundsUsingMap=map
  @aggregationMapMode=gridSquare
  @aggregation=<!--
    {
      "filter_agg": {
        "filter": {
          "geo_bounding_box": {}
        },
        "aggs": {
          "by_srid": {
            "terms": {
              "field": "location.grid_square.srid",
              "size": 1000,
              "order": {
                "_count": "desc"
              }
            },
            "aggs": {
              "by_square": {
                "terms": {
                  "field": "location.grid_square.10km.centre",
                  "size": 10000,
                  "order": {
                    "_count": "desc"
                  }
                }
              }
            }
          }
        }
      }
    }
  -->

  [map]
  @id=map
  @source=<!--{
    "mapData": "All records"
  }-->
  @styles=<!--{
    "mapData":{
      "type":"gridSquare",
      "options":{"color":"#333333","weight":1,"size":10000}
    }
  }-->

To make this map dynamic so the grid square size changes from 10km to 2km, then 1km as you
zoom in, change the field name for the grid square aggregation from
`location.grid_square.10km.centre` to `autoGridSquareField`.

**buildTableXY**

Where a source contains aggregations, this property can be used to autogenerate a table
of data from the response making usage of the data in output controls simpler. Specify
a JSON object where the property names are the names of the tables you wish to
autogenerate and each table name points to an array where the first element is the name
of the outer aggregation (used to generate X axes or columns) and the second is the name
of the inner aggregation (used to generate the Y axes or rows). The latter must be nested
within the former. The outer aggregation's keys will become the columns with an additional
column called 'key' which will contain the keys of the inner aggregation alongside the
generated data values for the row.

For example, where a `[source]` control has the following aggregation, it can create a
data table where the columns are record statuses and the rows are locations using this
`@buildTableXY` property value::

  @aggregation=<!--
  {
    "by_status": {
      "terms": {
        "field": "identification.verification_status",
        "size": 100,
        "order": {
          "_count": "desc"
        }
      },
      "aggs": {
        "by_loc": {
          "terms": {
            "field": "location.name.keyword",
            "size": 100,
            "order": {
              "_count": "desc"
            }
          }
        }
      }
    }
  }
  -->
  @buildTableXY=<!--
  {
    "table": ["by_status","by_loc"]
  }
  -->

Note that the generated table will always have a column called key which are the keys of
the inner aggregation (location names in this case).

Where the aggregations are deeply nested, the second value passed to the `@buildTableXY`
property can be comma separated to provide the nesting path to drill down into for the
rows. Here's an example::

  [source]
  @id=aggData
  @size=0
  @aggregation=<!--
    {
      "by_status": {
        "terms": {
          "field": "identification.verification_status",
          "size": 10,
          "order": {
            "_count": "desc"
          }
        },
        "aggs": {
          "by_nested": {
            "nested": {
              "path": "location.higher_geography"
            },
            "aggs": {
              "filtered": {
                "filter" : {
                  "match" : {
                    "location.higher_geography.type": "Butterfly Conservation branch"
                  }
                },
                "aggs": {
                  "by_loc": {
                    "terms": {
                      "field": "location.higher_geography.name.keyword",
                      "size": 200,
                      "order": {
                        "_key": "asc"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  -->
  @buildTableXY=<!--{
    "table": ["by_status","by_nested,filtered,by_loc"]
  }-->

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
  @id=gridData
  @size=30

  [source]
  @id=mapData
  @size=0
  @filterSourceGrid=records-grid
  @filterSourceField=taxon.accepted_taxon_id
  @filterField=taxon.accepted_taxon_id
  @aggregation=<!--
    {
      "filter_agg": {
        "filter": {
          "geo_bounding_box": {}
        },
        "aggs": {
          "geo_agg": {
            "geohash_grid": {},
            "aggs": {
              "point_agg": {
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

  [dataGrid]
  @id=records-grid
  @source=gridData
  @columms=

  [leafletMap]
  @id=map
  @source=<!--{
    "mapData": "Verified records of selected species"
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

If source is for a geohash aggregation used to populate a map layer then you probably
don't want the aggregation to calculate for the entire world view. For example, a heat
map aggregation should increase its precision as you zoom the map in. In this case, set a
filter for the geo_bounding_box to an empty object (`{}`). This will then automatically
populate with the map's bounding box.

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
-------------------

.. _elasticsearch-report-helper-customScript:

ElasticsearchReportHelper::customScript
""""""""""""""""""""""""""""""""""""""""""

A flexible output of ES data which uses a custom JavaScript function to build the HTML.

Options available are:

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

ElasticsearchReportHelper::dataGrid
"""""""""""""""""""""""""""""""""""

Generates a table containing Elasticsearch data. The `dataGrid` control has built in
support for sorting, filtering, column configuration and pagination.

Table rows holding data have the class `data-row` to identify them within the code. They
also have a class added `selected` when the row is selected (e.g. showing the associated
feature on the map). For rows linking to raw Elasticsearch documents, as opposed to
aggregated data, there is a class `absence-record` added when the record is a record of
absence. Finally, additional classes can be added to rows using the `@rowClasses` option.

The following options are available:

**id**

Optional. Specify an ID for the `dataGrid` control allowing you to refer to it from
elsewhere, e.g. CSS. If not specified, then a unique ID is generated by the code which
cannot be relied on.

**attachToId**

If you want to output the dataGrid in an existing element on the page with a known CSS ID
then specify that ID here. This must match the `id` option if specified.

**source**

ID of the `source` this dataGrid is populated from.

**sourceTable**

Where the linked `[source]` control builds a table from it's aggregations (using
`@buildTableXY`, this can be set to the name of the table to use that table's output as
the source of data for this dataGrid.

**aggregation**

When linking a `dataGrid` to a `source`, specify the nature of the aggregation.
Options:

  * simple
  * composite

**columns**

  * field - required - can be the name of a field in the Elasticsearch document (e.g.
    `metadata.created_by_id`) or one of the following special field names:

    * #status_icons#
    * #data_cleaner_icons#
    * #event_date#
    * #higher_geography#
    * #locality#
    * #lat_lon#
    * #datasource_code#

  * rangeField - name of a second field in the Elasticsearch document which defines a
    range when combined with the field's value. If the value of the field pointed to
    by `rangeField` is different to the value pointed to by `field` then the output will
    be of the form `value1 to value2`.
  * ifEmpty - string to output when the field value is empty. May contain HTML.
  * caption - title for the column.
  * description
  * handler
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

**availableColumns**

Defines which columns are available using the column configuration tool for the
`dataGrid`. By default all known columns are made available but you may wish to simplify
the list of columns in some circumstances. Specify an array of field names from the
Elasticsearch index.

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

**includeColumnHeadings**

Set to false to disable column headings.

**includeFilterRow**

Set to false to disable the filter row at the top of the table.

**includePager**

Set to false to disable the pager row at the bottom of the table.

**includeMultiSelectTool**

Set to include a multi-select tool which enables tickboxes for each row. Normally used
to support multiple record verification.

**applyFilterRowToSources**

If a filter row is present in the grid, then changing the filter row contents will
automatically apply the filter to the source the dataGrid is linked to. If any additional
sources should also be filtered (e.g. sources driving maps or charts from the same data)
then supply a JSON array of source IDs in this parameter.

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

**autoResponsiveCols** - set to true to automatically hide columns responsively when below
each breakpoint. Priority is set by position in the grid with columns on the right being
hidden first. Overrides `hideBreakpoints` setting for each column.

**autoResponsiveExpand** - set to true to automatically expand any additional information
beneath the row when cells are dropped due to responsive hide behaviour. Otherwise the
user has to click a + button to view the hidden information.

**sortable**

Set to false to disable sorting by clicking the sort indicator icons in the heading row.

**scrollY**

Set to a CSS height in pixels (e.g. "800px") to display a scrollbar on the table body with
this as the maximum height. Allows the data to be scrolled whilst leaving the header
fixed. Set to a negative height (e.g. "-50px") to set the table body to occupy all
available space to the bottom of the screen minus the height given.

**cookies**

Set to false to disable use of cookies to remember the selected columns and their
ordering. Cookies are only enabled when there is a specific `id` option set for this grid.

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

.. _elasticsearch-report-helper-download:

ElasticsearchReportHelper::download
"""""""""""""""""""""""""""""""""""

A button with associated progress display for generating downloadable zip files of CSV
data from an associated [source] control. Files are added to a list of downloads and are
kept available on the server for a period of time.

Options available are:

**source**

ID of the [source] control that provides the data for download.

**aggregation**

simple|composite

**attachToId**

Alternative `id` of a CSS element to output the control into as described previously.

**columnsTemplate**

Named set of columns on the server which will be included in the download file. Options
are currently "default" or can be set to blank to disable loading a predefined set. Other
sets may be provided on the warehouse in future.

**addColumns**

Define additional columns to those defined in the template that you want to include in the
download file. An associative array where the keys are the titles of each column and the
values are strings which either hold the name of a field in the Elasticsearch occurrence
document, or a definition of special processing that is required.

Special processing options available are as follows:

* `[attr value](entity=<entity>,id=<id>)` - returns an attribute value (or semi-colon
   separated list if multiple), for the entity defined by `<entity>` and for attribute ID
   defined by `<id>`.
* `[date string]` - converts event.date_from and event.date_to to a readable date string.
* `[higher geography](field=<field>,text=<text>,type=<type>)` - Converts
   location.higher_geography to a string. Configurable output by passing parameters:

    * `<type>` - limit output to this location type term.
    * `<field>` - limit output to content of this field (name, id, type or code).
    * `<text>` - set to true to convert the resultant JSON to text.

   E.g. pass type=Country, field=name, text=true to convert to a plaintext Country name.
* `[media]` - concatenates media to a semi-colon separated string. Each item is
  represented by the path (within the warehouse upload folder), followed by '|', the
  caption, then '|' then the licence code if present.
* `[null if zero](field=<fieldname>)` - returns the value given in the field identified by
  `<fieldname>`, or null if the value is zero.

**removeColumns**

Define columns from the selected column template to be removed from the CSV download. An
array of the column titles to remove.

.. _elasticsearch-report-helper-higherGeographySelect:

ElasticsearchReportHelper::higherGeographySelect
""""""""""""""""""""""""""""""""""""""""""""""""

A select box for choosing from a list of higher geography boundaries (indexed locations).
May either act as a single control, or a linked set of select controls if multiple nested
location types are specified where child locations are linked to their parent via the
`parent_id` field in the databaes.

When a location is chosen, the map will show the boundary, pan and zoom to the boundary
and the results are filtered to records intersecting the boundary.

Locations must be from an indexed location layer. See :doc:`../../../administrating/warehouse/modules/spatial-index-builder`
for more info.

Options are:

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
"""""""""""""""""""""""""""""""""""""

A map panel which uses the leaflet library that can display occurrence data from
Elasticsearch in a variety of ways.

Options available are:

**id**

Optional. Specify an ID for the `leafletMap` control allowing you to refer to it from
elsewhere, e.g. CSS. If not specified, then a unique ID is generated by the code which
cannot be relied on.

**cookies**

Set to false to disable use of cookies to remember the selected layers plus the current
map viewport. Cookies are only enabled when there is a specific `id` option set for this
map.

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

**showSelectedRow**

To make the map highlight the feature associated with a selected row in a `dataGrid`, set
showSelectedRow to the `id` of that grid. The map will also zoom in to the feature when
the grid row is double clicked.

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
    in.

    A special value called `metric` can be specified for any option. For non-aggregated
    data, this is the `location.coordinate_uncertainty_in_meters` value. For aggregated
    data, this value is set to an indication of the number of documents in the current
    bucket (i.e. the number of occurrences represented by the current feature). It is
    set to a scale from 0 - 20000, or for fillOpacity options it is set on a scale from
    0 - 1.

  * sourceUrl - the URL of the WMS service if using type WMS.
  * wmsOptions - any additional options to pass to the WMS web service.

.. _elasticsearch-report-helper-permissionFilters:

ElasticsearchReportHelper::permissionFilters
""""""""""""""""""""""""""""""""""""""""""""

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
""""""""""""""""""""""""""""""""""""""""

A tabbed panel showing key details of the record. Includes a tab for record field values,
one for comments logged against the record and one to show the recorder's level of
experience for this and similar taxa.

Options available are:

**showSelectedRow**

ID of the grid whose selected row should be shown. Required.

**explorePath**

Path to an Explore all records page that can be used to show filtered records, e.g. the
records underlying the data on the experience tab. Optional.

**locationTypes**

The record details pane will show all indexed location types unless you provide an array
of the type names that you would like included, e.g. ["Country","Vice County"]. Optional.

**extraLocationTypes**

As for **locationTypes**, but will be shown in the Derived Info block at the bottom of the
pane rather than in the first block of attribute values. Therefore suitable for location
types with a lower priority.

**readAuth**

Read authorisation tokens. Not required when used via the prebuilt form.

.. _elasticsearch-report-helper-standardParams:

ElasticsearchReportHelper::standardParams
"""""""""""""""""""""""""""""""""""""""""

A toolbar allowing the building of filters to be applied to the page's report data.

Options available are:

**allowSave**

Set to false to disable saving of filters.

**sharing**

Which sharing mode to save and load filters for. Set to reporting, verification,
data_flow, editing, moderation or peer_review. Default reporting.

**taxon_list_id**

ID of the taxon list that species and other taxon names are selectable from.

**indexedLocationTypeIds**

An array of location_type_id values to define the list of indexed location types to make
available for filtering. These are filtered by a higher geography query.

**otherLocationTypeIds**

An array of location_type_id values to define the list of non-indexed location types to
make available for filtering. These are filtered by a polygon query.

Other options are described in the PHP documentation for the
`client_helpers/prebuilt_forms/includes/reports.php` `report_filter_panel()` method.

.. _elasticsearch-report-helper-templatedOutput:

ElasticsearchReportHelper::templatedOutput
""""""""""""""""""""""""""""""""""""""""""

A flexible output of ES data which uses templates to build the HTML.

Options available are:

**id**

Optional. Specify an ID for the `templatedOutput` control allowing you to refer to it from
elsewhere, e.g. CSS. If not specified, then a unique ID is generated by the code which
cannot be relied on.

**source**

ID of the `[source]` control this templatedOutput is populated from.

**repeatField**

Where the response from Elasticsearch contains an array of values that should be repeated
in the output specify the path to the field containing the array here. A good example is
the `buckets` list for an aggregation. E.g. `aggregations.per_sample.buckets` allows
iteration over the response for an aggregation called `per_sample`.

**content**

HTML to output for each item. Replacements are field names {{ this.that }} within the path
specified by repeatField.

**header**

A piece of HTML that will be inserted into a div at the top of the control when a response
is received.

**footer**

A piece of HTML that will be inserted into a div at the bottom of the control when a
response is received.

.. _elasticsearch-report-helper-urlParams:

ElasticsearchReportHelper::urlParams
""""""""""""""""""""""""""""""""""""

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

Options can include:

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

An example where a page is configured to filter by `&genus=...` in the URL::

  [urlParams]
  @fieldFilters=<!--{
    "genus": {
      "name": "taxon.genus"
    }
  }-->

.. _elasticsearch-report-helper-userFilters:

ElasticsearchReportHelper::userFilters
""""""""""""""""""""""""""""""""""""""

Provides a drop down populated with the user's saved report filters. Selecting a filter
applies that filter to the current page's outputs.

Options available are:

  * @sharingCode - type of task the filters to load are for. Default R.
  * @definesPermissions

.. _elasticsearch-report-helper-verificationButtons:

ElasticsearchReportHelper::verificationButtons
""""""""""""""""""""""""""""""""""""""""""""""

Outputs a panel containing action buttons for verification tasks, including changing the
record status, querying the record and accessing the record edit page. Effectively allows
an Elasticsearch report page to be converted into a verification tool.

Options available are:

**id**

ID of the HTML element. If not specified, a unique ID will be autogenerated which cannot
be relied on.

**showSelectedRow**

Specify the element ID of a `[dataGrid]` control which the buttons will source the
selected row from.

**editPath**

If a Drupal page path for a generic edit form is specified then a button is added to allow
record editing.

**viewPath**

If a Drupal page path for a record details page is specified then a button is added to
allow record viewing.

Using the Elasticsearch controls

Using controls directly from JS
-------------------------------

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