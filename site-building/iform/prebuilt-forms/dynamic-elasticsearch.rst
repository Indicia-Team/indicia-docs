Elasticsearch outputs (customisable)
====================================


This prebuilt page is designed to provide a flexible combination of outputs from an
Elasticsearch instance, if one is configured and linked to the warehouse according to the
instructions at https://github.com/Indicia-Team/support_files/tree/master/Elasticsearch.
This approach can provide an extremely high performance reporting option where a warehouse
holds multiple millions of records. It also contains controls for viewing record details
and performing verification actions, providing an alternative approach to record
verification.

If you already have configured access to Elasticsearch via the warehouse's REST API, you
should know or be able to find out the following settings:

  * Endpoint - the path within the REST API's address which refers to your Elasticsearch
    access alias.
  * User - a code for your user in the REST API configuration.
  * Secret - a secret given for your user's access to the REST API Elasticsearch endpoint.
  * Warehouse ID prefix - the prefix inserted before occurrence ID to make a globally
    unique ID on the Elasticsearch cluster.

If you do not have the above available and therefore need to set up the REST API access
on the warehouse, then follow the instructions at
https://indicia-docs.readthedocs.io/en/latest/developing/rest-web-services/elasticsearch.html.

It would be beneficial to have a basic understanding of the Elasticsearch Query API before
proceeding.

Form configuration
------------------

The page offers standard configuration options for all Indicia pages powered by the IForm
module. The additional specific settings are described below.

Elasticsearch settings
^^^^^^^^^^^^^^^^^^^^^^

Start by filling in your Elasticsearch options as described above on the *Elasticsearch
settings* section of the Edit tab.

Filter settings
^^^^^^^^^^^^^^^

Permission settings
^^^^^^^^^^^^^^^^^^^

Here you can defined the name of the Drupal permission which a user must have in order to
be able to access the following kinds of data:

* My records download permission (records are limited to the records input by the logged
  in user).
* All records download permission (any records exposed by the Elasticsearch index alias
  configured on this page are available).
* Records in collated locality download permission (if a field called
  `field_location_collation` is in the user profile which contains a numeric ID of an
  indexed location, then limits the available records to those which intersect that
  location. Can be used to allow users with regional permissions to access the records in
  their area such as a Local Environmental Records Centre.)

Note that the default behaviour of an Elasticsearch page will be to request all records.
Therefore if your user does not have the permission you set for all records they will
not be able to access any data. If you want to use one of the permissions options other
than all records you can make the page request data with the appropriate permissions
filter by adding the `[permissionFilters]` control to the page. This outputs a drop down
control that allows the user to select from whichever options they have permission to use.
If there is only one option then the control is hidden.

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
a property definition. Property names and values are normally on one line but if a large
property value is required you can wrap the value in an XML comment (<!-- ... -->). For
example::

  [myControl]
  @myProperty=foo
  @myLongProperty=<!--
    bar
    baz
  -->

Common options
""""""""""""""

The following options are available for all the controls.

**@id**

**@attachToId**

If the page contains an element with this `id` then attaches the output to this element
rather than outputing a new `div` inline.

The following example shows how a single aggregation request can be injected as rows into
a table elsewhere on the page.

.. code-block::

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

The controls available for addition to the page are as follows:

[source]
""""""""

The source control acts as a link from other controls on the page to a set of data from
Elasticsearch. A source can declare it's own query restrictions (in addition to those
specified on the page) and can also declare an Elasticsearch aggregation if needed. On its
own, a `[source]` control does nothing. Its only when another output control is linked to
it that data will be fetched and shown on the page.

The following options are available:

**@id**

All `[source]` controls require a unique ID which allows other data bound controls to
refer to it.

**@size**

Number of documents matching the current query to return. Typically set this to zero for
aggregations where only summary data are required.

**@sort**

For non-aggregated output, object where the properties are the field names to sort by and
the values are either "asc" or "desc" as appropriate. Sets the initial sort order on the
table. E.g.::

  @sort={"id":"desc"}

**@from**

Number of documents to offset by. Defaults to 0.

**@filterPath**

Allows configuration of the Elasticsearch response filter, i.e. to limit the content
returned in the response. See https://www.elastic.co/guide/en/elasticsearch/reference/7.0/common-options.html#common-options-response-filtering.

**@initialMapBounds**

Set to true to use this source's dataset to define the bounds of the map on initial
loading.

**@aggregation**

Use this property to declare one or more Elasticsearch aggregations in JSON format. See
`https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations.html`_.
You can use Kibana to build an aggregation then inspect the request to extract the
required JSON data. The value provided should be a JSON object where the property names
are the keys given for each aggregation (i.e. the contents of the "aggregations" or "aggs"
element in your query).

The value for `@aggregation` can contain tokens which are replaced at runtime. Tokens are
of the format `{{ name }}` where the name can be one of the following:
* indicia_user_id - the user's warehouse user ID.
* a parameter from the URL query string.

**@aggregationMapMode**

When an aggregated source is used to provide map output, the following aggregation types
are supported:

* geoHash - a geo_hash aggregation on the location.point (default)
* gridSquare - an aggretion on location.grid_square.srid then one of the grid square
  centre fields to build an atlas style map based on grid squares.

.. code-block::

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

**@buildTableXY**

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

**@filterSourceGrid**

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

**@filterSourceField**

**@filterField**

**@filterBoolClauses**

**@filterBoundsUsingMap**

'id',
      'from',
      'size',
      'aggregation',
      'buildTableXY',
      'initialMapBounds',
      'filterBoolClauses',
      'filterSourceGrid',
      'filterField',
      'filterBoundsUsingMap',

[indiciaSource]
"""""""""""""""

.. todo::

  Implement an indiciaSource control to make this code data source independent.

[dataGrid]
""""""""""

The following options are available:

**@source**

ID of the `[source]` control this dataGrid is populated from.

**@sourceTable**

Where the linked `[source]` control builds a table from it's aggregations (using
`@buildTableXY`, this can be set to the name of the table to use that table's output as
the source of data for this dataGrid.

**@aggregation**

Options:
  * simple
  * composite

**@columns**
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
  * multiselect
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


**@availableColumns**

**@availableColumns**

**@actions**

**@includeColumnHeadings**

**@includeFilterRow**

**@includePager**

**@applyFilterRowToSources**

If a filter row is present in the grid, then changing the filter row contents will
automatically apply the filter to the source the dataGrid is linked to. If any additional
sources should also be filtered (e.g. sources driving maps or charts from the same data)
then supply a JSON array of source IDs in this parameter.

**@responsive**

Defaults to true but can be disabled by setting to false.

**@responsiveOptions**

Options for responsive behaviour which will be passed to the Footable component that makes
the table responsive. Can include:
* breakpoints - a JSON object where the properties are breakpoint names and the values are
  the number of pixels below which the breakpoint is triggered. The default is:
  ```json
  {
    "xs": 480,
    "sm": 760,
    "md": 992,
    "lg": 1200
  }
  ```

**@sortable**

**@scrollY**

Set to a CSS height in pixels (e.g. "800px") to display a scrollbar on the table body with
this as the maximum height. Allows the data to be scrolled whilst leaving the header
fixed.

**@cookies**

[leafletMap]
""""""""""""

Options available are:

**@cookies**

**@initialLat**

**@initialLng**

**@initialZoom**

**@showSelectedRow**

**@layerConfig**

A JSON object defining the data driven layers to add to the map. Each property is the ID
of a layer which contains a sub-object containing the configuration for that layer. The
layer objects can have the following properties:

* source - ID of a source that provides the data.
  @todo Document different aggregation types that are supported.
*

the objects contained in each property define the styling of the layer for that source.
The style objects have the following properties:

* type - the type of feature to add to the map. One of:
  * circle
  * square
  * heat
  * marker (default).
* options - object to pass to leaflet as options for the feature. For circle and square
  feature types, set any option to "metric" to use the calculated metric as a value for
  that option. Supports fillOpacity, size and radius at the moment. Size is available as
  alternative to radius, where size is the full width of the object typically used for
  grid square sizing.

[templatedOutput]
"""""""""""""""""

**@source**

ID of the `[source]` control this templatedOutput is populated from.

**@content**

Replacements are field names {{ this.that }} within the path specified by repeatField.

**@repeatField**

Where the response from Elasticsearch contains an array of values that should be repeated
in the output specify the path to the field containing the array here. A good example is
the `buckets` list for an aggregation. E.g. `aggregations.per_sample.buckets` allows
iteration over the response for an aggregation called `per_sample`.

**@header**

A piece of HTML that will be inserted into a div at the top of the control when a response
is received.

**@footer**

A piece of HTML that will be inserted into a div at the bottom of the control when a
response is received.

*Filter controls*

*HTML inputs*

Attributes, diff query types
    $fieldQueryTypes = ['term', 'match', 'match_phrase', 'match_phrase_prefix'];
    $stringQueryTypes = ['query_string', 'simple_query_string'];

* data-es-nested for nested fields.
* data-es-query
* data-es-bool-clause

*[userFilters]*

* @sharingCode - type of task the filters to load are for. Default R.
* @definesPermissions

`[verificationButtons]`

Outputs a panel containing action buttons for verification tasks, including changing the
record status, querying the record and accessing the record edit page.

Options available are:

* **@id** - ID of the HTML element. If not specified, a unique ID will be autogenerated.
* **@showSelectedRow** - specify the element ID of a `[dataGrid]` control which the buttons
  will source the selected row from.
* **@editPath** - if a Drupal page path for a generic edit form is specified then a button
  is added to allow record editing.
* **@viewPath** if a Drupal page path for a record details page is specified then a
  button is added to allow record viewing.

[download]
""""""""""

A button with associated progress display for generating downloadable zip files of CSV
data from an associated [source] control. Files are added to a list of downloads and are
kept available on the server for a period of time.

Options available are:

* **@source**

[higherGeographySelect]
"""""""""""""""""""""""

A select box for choosing an indexed location. When the user chooses a location, the map
will show the boundary, pan and zoom to the boundary and filter the results.

Locations must be from an indexed location layer. See :doc:`../../../administrating/warehouse/modules/spatial-index-builder`
for more info.

Options available are:

* **@label** - Attaches the given label to the control.
* **@blankText** - Text shown for the option which corresponds to no location filter.
* **@locationTypeId** - The ID of the locations layer to pick locations from.

[recordDetails]
"""""""""""""""

A tabbed panel showing key details of the record. Includes a tab for record field values,
one for comments logged against the record and one to show the recorder's level of
experience for this and similar taxa.

Options available are:

**@showSelectedRow**

ID of the grid whose selected row should be shown. Required.

**@explorePath**

Path to an Explore all records page that can be used to show filtered records, e.g. the
records underlying the data on the experience tab. Optional.

**@locationTypes**

The record details pane will show all indexed location types unless you provide an array
of the type names that you would like included, e.g. ["Country","Vice County"]. Optional.

**@allowRedetermination**

If true then provides tools for changing the detemination of the viewed record. Optional,
default false.

[urlParams]
"""""""""""

This control allows you to configure how the page uses parameters in the URL to filter the
output shown on the page.

It currently only enables a parameter `taxon_scratchpad_list_id`
which takes the ID of a `scratcphad_list` as a parameter and creates a hidden filter
parameter which limits the returned records to those in the scratchpad list. For example,
a report page which lists scratchpad lists could have an action in the grid that links to
an Elasticsearch outputs page passing the list ID as a parameter.

By default, the following filter parameters are supported:

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

Additional filters can be configured via the @fieldFilters option.

Options can include:

  * @fieldFilters - use this option to override the list of simple mappings from URL
    parameters to Elasticsearch index fields. Pass an array keyed by the URL parameter
    name to accept, where the value is an array of configuration items where each item
    defines how that parameter is to be interpreted. Therefore multiple filters may result
    from a single parameter. Each configuration item has the following data values:

    * name - Elasticsearch field name to filter
    * type - optional. If set to integer then validates that the field supplied is an
      integer. Other data types may be supported in future.
    * process - optional. possible values are:

      * taxonIdsInScratchpad - the value is used as a scratchpad_list_id which is used to
        look up a list of taxa. The value is replaced by a list of taxon.taxon_ids for
        filtering to the entire list.
      * taxonIdsInSample - the value is used as a sample_id which is used to look up a
        list of taxa. The value is replaced by a list of taxon.taxon_ids for filtering to
        the entire list.

Using controls directly
=======================

Example code:

.. code-block:: php

  <div id="dataGrid1" class="idc-output idc-output-dataGrid"></div>

  <?php

  require_once iform_client_helpers_path() . 'ElasticsearchProxyHelper.php';
  iform_load_helpers([]);
  ElasticSearchProxyHelper::enableElasticsearchProxy();
  helper_base::$javascript .= <<<JS
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
  JS;
  handle_resources();
  ?>