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

Data access methods
-------------------

Methods provided by this helper are listed below:

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

or:

.. code-block:: php

  <?php
  echo ElasticsearchReportHelper::source([
    'id' => 'sorted-data',
    'sort' => '{"id":"desc"}',
  ]);

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

ElasticsearchReportHelper::dataGrid
"""""""""""""""""""""""""""""""""""

Generates a table containing Elasticsearch data. The `dataGrid` control has built in
support for sorting, filtering, column configuration and pagination.

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

When linking a `dataGrid` to a `source` w
Options:

  * simple
  * composite

**columns**

  * field - can be the name of a field in the Elasticsearch document (e.g.
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
  * caption
  * description
  * handler
  * hide-breakpoints - Comma separated list of breakpoints. When a breakpoint is specified
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
  * data-type="date|numeric"

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
  * path - base path to the page to navigate to. Can contain the token {rootFolder} which
    will be replaced by the root folder of the site. Also, field values from the row's
    Elasticsearch document can be specified by putting the field name in square brackets.
  * urlParams - additional parameters to add to the URL as key/value pairs. Can also
    contain field value replacements by putting the field name in square brackets.

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
        "occurrence_id":"[id]"
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

**sortable**

Set to false to disable sorting by clicking the sort indicator icons in the heading row.

**scrollY**

Set to a CSS height in pixels (e.g. "800px") to display a scrollbar on the table body with
this as the maximum height. Allows the data to be scrolled whilst leaving the header
fixed.

**cookies**

Set to false to disable use of cookies to remember the selected columns and their
ordering.

ElasticsearchReportHelper::download
"""""""""""""""""""""""""""""""""""

A button with associated progress display for generating downloadable zip files of CSV
data from an associated [source] control. Files are added to a list of downloads and are
kept available on the server for a period of time.

Options available are:

**source**

ID of the [source] control that provides the data for download.

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

**removeColumns**

Define columns from the selected column template to be removed from the CSV download. An
array of the column titles to remove.

