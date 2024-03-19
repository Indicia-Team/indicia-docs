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

ElasticsearchReportHelper::enableElasticsearchProxy
---------------------------------------------------

Prepares the page for interacting with the Elasticsearch proxy.

If coding in PHP directly, this method should be called before adding any other
ElasticsearchReportHelper controls to the page. It is not necessary to call
`enableElasticsearchProxy` if using the prebuilt form. The response is a boolean value which will
be true if the Elasticsearch proxy was successfully enabled. The response should be checked and the
false response handled appropriately, e.g. by displaying a "Service unavailable" message.

Data access control methods
===========================

Methods provided for accessing Elasticsearch data by this helper are listed below:

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

Sources normally retrieve documents from Elasticsearch where each document represents a single
occurrence record. It is also possible to configure an Elasticsearch index to hold documents which
represent single samples.

When configuring a `source` control the list of available document field names can be
found in the `occurrences document structure documentation
<https://github.com/Indicia-Team/support_files/blob/master/Elasticsearch/docs/occurrences-document-structure.md>`_
or the `samples document structure documentation
<https://github.com/Indicia-Team/support_files/blob/master/Elasticsearch/docs/samples-document-structure.md>`_.

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
element in your query). The aggregation names given should not have a leading hyphen as
these names are reserved.

The value for `@aggregation` can contain tokens which are replaced at runtime. Tokens are
of the format `{{ name }}` where the `name` can be one of the following:

  * indicia_user_id - the user's warehouse user ID.
  * a parameter from the URL query string.

When using termAggregation or compositeAggregation mode, the keys of this object represent
additional calculated fields that will be added to the output dataset. Normally this means
a single bucket aggregation per key but nested aggregations can be expanded into table
columns using a `dataGrid` control.

**disabled**

Set to true to prevent the source from populating. You can then use JavaScript to change the
setting:

.. code-block:: js

  var src = indiciaData.esSourceObjects['source_id'];
  src.settings.disabled = false;
  src.populate();

**endpoint**

If this source should use an Elasticsearch API endpoint (as configured in the warehouse's REST API)
that is different from the page's default, then set the endpoint name in this option. Note that the
endpoint must also be listed under the "Alternative endpoints" configuration option on the page's
Edit tab.

**fields**

An array of document field names to include in the output when using `termAggregation` or
`compositeAggregation` mode. This list is for the non-aggregated fields, for calculated
aggregated data fields use the `@aggregation` option.

In addition to standard document field names, it is possible to include a custom attribute
value in the list of available fields using the same format as for table columns, i.e.
`#attr_value:<type>:<id>#` where `<type>` is event (sample), parent_event (sample
identified by `samples.parent_id`) or occurrence and `<id>` is the attribute ID.

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
  layer, or for drawing rectangular grid cells which scale according to the map resolution.
  See https://en.wikipedia.org/wiki/Geohash. Set the type of the map layer's `@layerConfig`
  to `heat` or `geom` if you want to draw the rectangle for the geohash grid cells.
* mapGridSquare - aggregates retrieved data using an Elasticsearch `terms` aggregation on
  `location.grid_square` field values. These contain the centres of grid squares covering
  the record at 1km, 2km and 10km resolution. The default behaviour is to automatically
  select the grid square size depending on map zoom but this can be overriden by setting
  `@mapGridSquareSize` to the size of the required grid square in metres (10000, 2000 or
  1000). The mapGridSquare option is similar to the mapGeoHash option with layer configured
  to type geom, except that the mapGridSquare option uses an exact square grid based on 1000,
  2000 or 10,000m grid squares, whereas the mapGeoHash grid option grid is based on rectangles of
  varying aspect ratio, but works at more different resolutions.
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
    * Can be sorted on any numeric or date field or any aggregated output.
    * Can not be sorted on a text field's direct value.
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

**switchToGeomsAt**

If the mode is `mapGridSquare`, then this can be set to a zoom level after which the layer
will switch to show the geometries of the records as they were input, rather than the grid
square or circle containing the record. Otherwise a record will only ever show at a maximum
1km precision. The 1km layer starts showing at zoom level 11, so a setting of around 13 is
a good starting point.

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
they can be nested to support complex logic. Each top level property contains an array of
objects defining a filter, with properties `query_type`, `field`, `nested` and `value`. Query
types supported currently are:

  * match_all
  * match_none
  * term
  * match
  * match_phrase
  * match_phrase_prefix
  * exists

For example::

  @filterBoolClauses=<!--{
    "must_not":[
      {"query_type": "term","field": "identification.verification_status","value":"R"}
    ]
  }-->

By default every source will include filters that exclude confidential records and records which
are not released. You can supply alternative clauses to override the default. To include all
records whether confidential or not, a special value is required as follows::

  @filterBoolClauses=<!--{
    "must":[
      {"query_type": "term","field": "metadata.confidential","value":"all"}
    ]
  }-->


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

**proxyCacheTimeout**

To enable caching of the Elasticsearch content loaded on a page's initial load, set
`@proxyCacheTimeout=n` where n is the number of seconds after which the cached content will expire
and therefore will refresh. Although performance of Elasticsearch is normally excellent, if a
public facing reporting page is likely to receive a high volume of hits (e.g. the output of a
citizen science project) then it can be pragmatic to set this value to prevent rapid identical
Elasticsearch queries. A value of 300 would set the cache expiry to 5 minutes for example. Note
that once a cached item expires, the chances of it refreshing on a page request are randomised,
meaning that if there are multiple queries issued by a page, then they won't all get refreshed on
the same page hit.

Caching occurs in the Elasticsearch proxy layer and only applies to the initial load of each data
source when the page loads. Subsequent hits are likely to be filtered AJAX requests so caching
would not be relevant.

Data output methods
===================

ElasticsearchReportHelper::cardGallery
--------------------------------------

Outputs a gallery of record cards.

Options
^^^^^^^

**actions**

Optional array defining additional action buttons to include for each card. For more information
see the description of the **actions** option for the `dataGrid` control.

**columns**

List of report data fields that will be output in the card below the image. Syntax is the same as
the **columns** option for the `dataGrid` control.

**id**

Optional. Specify an ID for the `cardGallery` control allowing you to refer to it from
elsewhere, e.g. CSS. If not specified, then a unique ID is generated by the code which
cannot be relied on.

**includeFieldCaptions**

Set to true to include the caption for each field shown below the photo, according to the
**columns** option.

**includeFullScreenTool**

Set to false to disable the tool button for enabling full screen mode.

**includeMultiSelectTool**

Set to true to include a multi-select tool button which enables tickboxes for each card.
Normally used to support multiple record verification.

**includePager**

Set to false to disable the pager row at the bottom of the table.

**includeSortTool**

Set to false to disable the tool button for specifying the sort order.

**keyboardNavigation**

Set to true to allow use of the following keyboard shortcuts:
* arrow keys to navigate the selected card in the gallery.
* i to show the first image in the current row as a popup.

**sortable**

Alias for **includeSortTool**.

**source**

ID of the `[source]` control this `cardGallery` is populated from. Typically the source will limit
the data in the response to records with media using `@filterBoolClauses` as in the following
example::

  [source]
  @id=photos-data
  @size=30
  @sort={"id": "desc"}
  @filterBoolClauses=<!--{
    "must":[
      {"query_type": "exists", "field": "occurrence.media.path", "nested":"occurrence.media"}
    ]
  }-->

  [cardGallery]
  @id=card-gallery
  @source=photos-data

ElasticsearchReportHelper::controlLayout
---------------------------------------

A control for managing layout, e.g. for verification pages.

Options
^^^^^^^

**alignTop**

**alignBottom**

**breakpoint**

**id**

Optional. Specify an ID for the `customScript` control allowing you to refer to it from
elsewhere, e.g. CSS. If not specified, then a unique ID is generated by the code which
cannot be relied on.

**setHeightPercent**

**setOriginY**

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

**functionName**

Name of a function that should be added to the JavaScript global `indiciaFns` which
formats the output. Takes 3 parameters:

* el - the element the output should be added to.
* sourceSettings - settings object for the source the control is linked to.
* response - the response from Elasticsearch to be formatted by the function.

**template**

Template for the content to add to the output div. Defaults to empty.

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

  * title - text to add to the button's title attribute, shown on hover as a tooltip. Required.
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
  * tokenDefaults - allows a default value to be specified where the document doesn't hold
    a value for the field used in a token replacement for an action's path. E.g.::

      "tokenDefaults":{
        "[metadata.input_form]": "edit-generic-record"
      }

  * urlParams - additional parameters to add to the URL as key/value pairs. Can also
    contain field value replacements by putting the field name in square brackets.
  * hideIfFromOtherWebsite - set to true to hide the action button if the row is for a record
    input on another website that shares its records to this website.
  * hideIfFromOtherUser - set to true to hide the action button if the row is for a record
    input by another user.
  * onClickFn - set to the name of a JavaScript function that has been added to the `indiciaFns`
    object which will be run when the action is clicked. This is an alternative to setting a link
    path using the other options. The function will receive 2 parameters, the Elasticsearch
    document object and the table row element.

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
  * field - required - can be the name of a field in the Elasticsearch document, e.g.
    `metadata.created_by_id`, or one of the following special field names (case-sensitive):

    * #associations# - a list of the species names linked to this record as associated
      occurrences.
    * #attr_value:<entity>:<id># - a single custom attribute value. Specify the entity name (event
      (=sample), parent_event (sample identified by `samples.parent_id`) or occurrence plus the
      custom attribute ID as parameters. Note that if requesting an event attribute value, the
      parent events attribute values will also be included in the output, so when requesting an
      attribute value it is not necesssary to know if the value will be stored at the event or
      parent level. If you only want the event attribute and want to exclude the parent event
      attribute then you can add a third parameter like `#attr_value:<entity>:<id>:noparent#`.
    * #coalesce:<field list># - takes a comma separated list of Elasticsearch document field
      specifiers in the parameters. Returns the value of the first field in the list which has a
      value. For example `#coalesce:event.parent_event_id,event.event_id#` will return the parent
      sample's ID for a structured record (e.g. a transect with section sub-samples) but the
      single sample's ID for a casual record that has no parent sample.
    * #constant:<value># - outputs a static value. Pass an empty string if you need an empty
      column.
    * #data_cleaner_icons# - icons representing the results of data cleaner rule checks.
    * #datasource_code:<format># or #datasource_code# - This outputs a datasource identifier
      optionally composed from any of the following six elements (corresponding tokens are
      shown in parentheses): website title (`<wt>`),
      website id (`<wi>`), survey dataset title (`<st>`), survey dataset id (`<si>`),
      recording group title (`<gt>`), recording group id (`<gi>`). The format consists
      of a string containing one or more of the element tokens and any other characters
      requried, e.g. `#datasource_code:<wt>-<gt>#`. If no format is specified, the following default
      is used: `<wi> (<wt>) | <si> (<st>)`. A group may not always be present. When it is not
      then `<gt>` and `<gi>` are replaced by empty strings. You can place any number of non-token
      characters before trailing group tokens within curly braces. Where a group is not present
      the characters between the braces are not output. For example `<wt> | <st> {|} <gt>` will
      ouput `website-title | survey-dataset-title | group-title` where a group is present
      but otherwise just  `website-title | survey-dataset-title` - the training "|" is removed.
      Curly braces are always removed from the output.
    * #datetime:<field>:<format># - converts a specified field, which must be of the
      date/time type, to a given format. Specify formats using standard
      `PHP format strings. (https://www.php.net/manual/en/datetime.format.php)`_
      If you want to use colons in the format string, e.g. `Y-m-d H:i:s`, they must
      be escaped to avoid confusion with colons in the rest of the field definition,
      e.g. `#datetime:metadata.created_on:Y-m-d H\:i\:s#`.
    * #event_date:<format># or #event_date# - where no format
      is specified, the event (sample) date or date range is output in a standard format.
      If the format is set to `mapmate`, the date or date range is formatted in a way
      that MapMate can handle for imports.
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
      * If the third parameter can be set to `mapmate` where a vice county code is being
        retrieved in which case if there is more than one VC code, or no VC code, associated
        with the record, the output value is set to zero.

    * #lat:<format>:<precision># or #lat# - a formatted latitude value. If specified, `<format>` can
      be one of:

      * "decimal" - a decimal latitude is returned with negative values for locations
        south of the equator. Decimal places given by <precision>, default is all available.
      * "nssuffix" - a latitude rounded to n decimal places with a suffix of
        "N" or "S" location in relation to the equator. Decimal places given by <precision>, default
        is 3.

    * #lat_lon# or #lat_lon:<precision># - a formatted latitude and longitude value with number
      each rounded to n decimal places plus a suffix indicating location in relation to the equator
      and Greenwich meridian. Decimal places given by <precision>, default is 3.
    * #life_stage:<format># - the value of the `occurrence.life_stage` field formatted as specified.
      Currently there is only one format - `mapmate` - which translates values to
      values acceptable to MapMate, e.g. `adult female` to `Adult`.
    * #locality# - a summary of location information including the given location name
      and a list of higher geography locations.
    * #lon:<format>:<precision># or #lon# - a formatted longitude value. If specified, `<format>`
      can be one of:

      * decimal - a decimal longitude is returned with negative values for locations
        west of the Greenwich meridian. Decimal places given by <precision>, default is all
        available.
      * ewsuffix - a longitude rounded to n decimal places with a suffix of
        "E" or "W" location in relation to the Greenwich meridian. Decimal places given by
        <precision>, default is 3.

    * #null_if_zero:<field># - returns the field value, unless 0 when will be treated as
      null.
    * #occurrence_media# - returns thumbnails for the occurrence's uploaded media with
      built in click to view at full size functionality.
    * #organism_quantity:<format># - returns the value of the `occurrence.organism_quantity`
      field formatted as specified. The value of `<format>` can
      be one of:

        * "integer" - the value is only returned if it is an integer.
        * "exclude-integer" - the value is only returned if it is not an integer.
        * "mapmate" - returns the value if it is an integer (other than zero). If the value
          is a zero, or if the value of `occurrence.zero_abundance` is not false, then
          a value of `-7` is returned (used by MapMate to indicate negative records).

    * #query:<format># - the record query status formatted as specified.
      The unmodified field `identification.query` outputs a single letter code.
      Currently there is only one format - `astext` - which translates codes to
      meaningful text,  `Q` to `Queried`, `A` to `Answered`.
    * #sex:<format># - the value of the `occurrence.sex` field formatted as specified.
      Currently there is only one format - `mapmate` - which translates codes to
      values acceptable to MapMate, e.g. `female` to `f` and `mixed` to `g`.
    * #sref_system:<field>:<format># - a formatted spatial reference system.
      The field must indicate a spatial reference system, e.g. `location.input_sref_system`.
      Currently there is only one format - `alphanumeric` - which replaces any values where
      the spatial reference system is stored as a numberic EPSG code with the recognised
      text equivalent (`4326` becomes `WGS84` and `27700` becomes `OSGB36`).
    * #status_icons# - icons representing the record status, confidential, sensitive and
      zero_abundance status of the record.
    * #taxon_label# - a label for the taxon. This combines the accepted name and vernacular where
      available. The rank is prefixed for higher taxa.
    * '#template:<template># - a text template for the value. Can contain Elasticsearch document
      field names in square brackets which will be replaced by the respective values from the
      document. For example `#template:Species name <strong>[taxon.accepted_name]</strong>`.
      Any HTML in the template will be stripped when this template is used for a field in a
      download. If a 2nd parameter is provided, this should be the path to a nested Elasticsearch
      object such as `occurrence.media`. This will cause the template to be repeated for each
      nested object and fields within the object will also be available as replacement tokens.
      For example `#template:<li>[path]</li>:occurrence.media#`.
    * #verification_status:<format># - the record verification status formatted as specified.
      The unmodified field `identification.verification_status` outputs a single letter code.
      Currently there is only one modifer - `astext` - which translates codes to
      meaningful text, e.g. `V` to `Accepted`, `C` to `Unconfirmed` etc.
    * #verification_substatus:<format># - the record verification substatus formatted as specified.
      The unmodified field `identification.verification_substatus` outputs a single letter code.
      Currently there is only one modifer - `astext` - which translates codes to
      meaningful text, e.g. `1` to `Correct`, `2` to `Considered correct` etc.
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
    formatting if the date is displaying as a numeric value. This is not normally required
    as document fields should format correctly. For aggregations such as min or max date
    (which do generate a numeric value), specifying the `format` option in the aggregation
    to provide a correctly formatted value is preferable because this approach will also
    apply within downloaded datasets, whereas using the handler only affects the output
    of the data cell in the `[dataGrid]`.
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

**includeColumnSettingsTool**

Set to false to disable the tool button for showing the column settings popup.

**includeFilterRow**

Set to false to disable the filter row at the top of the table.

**includeFullScreenTool**

Set to false to disable the tool button for enabling full screen mode.

**includeMultiSelectTool**

Set to true to include a multi-select tool button which enables tickboxes for each row.
Normally used to support multiple record verification.

**includePager**

Set to false to disable the pager row at the bottom of the table.

**keyboardNavigation**

Set to true to allow use of the following keyboard shortcuts:
* up and down arrow keys to navigate the selected row in the grid.
* i to show the first image in the current row as a popup.

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
  @linkToDataControl=recorders-grid
  @caption=Grid download

A download returning data in a format like that provided before Elasticsearch::

  [source]
  @id=data-to-download

  [download]
  @source=data-to-download
  @columnsTemplate=easy-download
  @caption="Download backward-compatible format"

A download with a format selector::

  [source]
  @id=data-to-download

  [download]
  @source=data-to-download
  @columnsTemplate=["default","easy-download", "mapmate"]

Options
^^^^^^^

**addColumns**

Define additional columns to those defined in the template that you want to include in the
download file. An array which uses the same format as the `dataGrid` `@columns` option.

**caption**

Button caption. Defaults to "Download" but will be translated. Can include HTML, e.g. a
Font Awesome icon if supported by your theme::

  @caption=Download <span class="fas fa-file-download"></span>

**columnsTemplate**

Named template that defines set of columns on the server which will be included in the download file.
If an array of template names is provided in this parameter then a control is shown allowing the
user to choose the template to use. The default value is
"default" when the source is in `docs` mode, or blank for the aggregation modes. Options
are currently "default", "easy-download" and "mapmate".
It can be set to blank to disable
loading a predefined set. Other sets may be provided on the warehouse in future.

The "default" format (corresponding to
"Standard download format" in the download control's format selection drop-down) provides
a standard set of download fields.

The "easy-download" format (corresponding to "Backward-compatible format" in the
download control's format selection drop-down) produces a set of columns and formats
which is very close to that provided
by downloads before the use of Elasticsearch by Indicia.

The "mapmate" format (corresponding to "Mapmate-compatible format" in the
download control's format selection drop-down) produces a set of columns and formats
that should allow for easy import into MapMate. Note that as well as the mandatory
fields specified by `MapMate <https://www.mapmate.co.uk/guide/page19.htm>`_
a number of additional columns are added which could potentially help with evaluation
or further manipulation of the records before importing into MapMate.

**id**

Optional. Specify an ID for the `download` control allowing you to refer to it from
elsewhere, e.g. CSS. If not specified, then a unique ID is generated by the code which
cannot be relied on.

**linkToDataControl**

If specified, uses a dataGrid control to obtain the source and columns configuration. Columns
specified in **addColumns** will be appended to the end.

**removeColumns**

Define columns from the selected column template to be removed from the CSV download. An
array of the column titles to remove.

**source**

ID of the [source] control that provides the data for download. Required unless the
**linkToDataControl** option is specified.

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
  @linkToDataControl=recorders-grid
  @caption=Grid download
  @buttonContainerElement=#recorders-grid tfoot td

**containerElement**

If you want to output the download control in an existing element on the page with a known
CSS selector then specify the selector here. If the selector matches multiple elements
then only the first will be used.

ElasticsearchReportHelper::groupIntegration
-------------------------------------------

Links a reporting page to a recording group (activity). Applies a group_id filter to the data,
either loading from the URL parameter or a preset ID. Optionally outputs a summary of the group
and its pages.

Options
^^^^^^^

**group_id**

ID of the group to load data for, if fixed. If not set, then the group ID is obtained from a URL
parameter called `group_id`.

**missingGroupIdBehaviour**

Defines what happens if a group ID is not provided either via a parameter or URL parameter. Default
is "error" but can be set to "showAll" to allow the page to appear unfiltered.

**showGroupSummary**

If true, then a group summary panel is displayed including the group logo, title and description.

**showGroupPages**

If true, then a list of available group page links is shown.

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
    remembered in a cookie unless cookies are explicitly disabled
    or the map has no specific `id` option set for this map.
  * forceEnabled - set to true if you want this layer to be enabled whenever the page
    is initiased. This will override the value stored in a cookie.
  * type - one of the following:

      * circle - see `Leaflet circle <https://leafletjs.com/reference-1.5.0.html#circle>`_
      * square - see `Leaflet rectangle <https://leafletjs.com/reference-1.5.0.html#rectangle>`_
      * marker (default) - see
        `Leaflet marker <https://leafletjs.com/reference-1.5.0.html#marker>`_.
      * heat - heat map generated using `Leaflet.heat <http://leaflet.github.io/Leaflet.heat>`_.
      * geom - a polygon representing the record's original geometry. If the source used is set to
        mode mapGeoHash, then the geometry output will be the square covering the geohash grid
        cell.
      * WMS - A Web Mapping Service layer.

  * style - for circles, squares and markers, an object to pass to leaflet as options
    for the feature as described in the links for each feature type above, e.g.
    `fillOpacity` or `radius`.

    A special style option called `size` can be specified for circles
    and squares which defines the size of the feature in metres (similar to radius but the
    latter is calculated as a number of pixels). For non-aggregated data, the size
    defaults to the `location.coordinate_uncertainty_in_meters` field value so features
    reflect their known accuracy. `Size` can be set to the special value
    `autoGridSquareSize` so that it matches the current map grid square aggregation as you
    zoom the map in, showing 10km features when zoomed out, then 2km, then 1km when zoomed
    in. This setting is automatic when using a map source mode.

    A special value called `metric` can be specified for any style option. For non-aggregated
    data, this is the `location.coordinate_uncertainty_in_meters` value. For aggregated
    data, this value is set to an indication of the number of documents in the current
    bucket (i.e. the number of occurrences represented by the current feature). It is
    set to a scale from 0 - 20000, or for fillOpacity options it is set on a scale from
    0 - 1.

  * labels - set to "hover" to enable hover-hints for records on the map, including the taxon name,
    date and recorder. Set to "permanent" to show them all the time.
  * sourceUrl - the URL of the WMS service if using type WMS.
  * wmsOptions - any additional options to pass to the WMS web service.

**selectedFeatureStyle**

Object containing style options to apply to the selected feature. For example::

  @selectedFeatureStyle=<!--{
    "color": "#00FF00"
    "opacity": "0.6"
  }-->

**showSelectedRow**

To make the map highlight the feature associated with a selected row in a `dataGrid`, set
showSelectedRow to the `id` of that grid. The map will also zoom in to the feature when
the grid row is double clicked.

ElasticsearchReportHelper::mediaFilter
--------------------------------------

Outputs a select control for filtering to show records that either do or don't have any
media/photos. Synchronises with the similar control on the Quality pane of the filter builder.

ElasticsearchReportHelper::permissionFilters
--------------------------------------------

Output a selector for various high level permissions filtering options.

Permission sets available in the selector will depend on the permissions set on the
Permissions section of the Edit tab in combination with the settings passed in the
options parameter. Options available are:

  * all_records_permission - set to the name of a Drupal permission which the user must
    have to enable the option to access all records.
  * includeFiltersForGroups - adds options for downloading records explicitly added to the
    user's groups (activities). The user's own records are always available; in addition
    group administrators can download the entire set of records for the group.
  * includeFiltersForSharingCodes - allows filters which define a user's permissions, such
    as a set of verifiable records, to be included in the list of options. JSON array
    containing the sharing codes that are supported for filters which are available for
    the user and where `defines_permissions=true`. Defaults to an empty array so none are
    loaded. Possible options are 'R', 'V', 'D', 'M', 'P'.
  * label - label given to the control. Default "Records to access".
  * location_collation_records_permission - set to the name of a Drupal permission which the user must
    have to enable the option to filter for records in a location that the user has a
    Drupal permission to collate for (e.g. an LRC). To use this option, the user profile
    must have a field called `location_collation` which contains the ID of an indexed
    location from the Indicia `locations` table.
  * my_records_permission - set to the name of a Drupal permission which the user must
    have to enable the option to filter for a user's own records.
  * useSharingPrefix - when `@includeFiltersForSharingCodes` is used to include filters
    which define sets of records a user can access, setting this to true will include a
    prefix for the entry in the selection list to clarify the sharing code (Verification,
    Download, Reporting etc).
  * notices - a JSON object with one or more keys that are matched against the start of the
    text of the selected item in the permissions filter control. If a match is found, then
    the value stored against the key - which can be an HTML string - is displayed below the
    selection control. In the folloinw example if a filter is selected in the control which
    starts with the text "LERC download - ", then the specified HTML is displayed below
    the control::

      @notices=<!--{
        "LERC download - ": "<p><b>For LERC downloads, you must abide by the
        <a href='https://www.brc.ac.uk/irecord/lrc-tc'>
        LERC Terms and Conditions</a>.</b></p>"
      }-->

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

ElasticsearchReportHelper::recordsMover
---------------------------------------

Needs configuration on the warehouse data_utils.

Options
^^^^^^^

**caption**

Button caption, defaults to "Move records". Will be translated.

**datasetMappings**

JSON array containing a list of mappings from a source website ID/survey ID pair to a destination
website ID/survey ID pair. Several mappings can be defined so that different survey dataset records
get moved to different destination survey datasets. Each mapping object contains a `src` and `dest`
property, each of which contains a child object that contains a `website_id` and `survey_id`
property.

For example:
```json
[
  {
    "src": {"website_id": 2, "survey_id": 2},
    "dest": {"website_id": 3, "survey_id": 4}
  },
  {
    "src": {"website_id": 2, "survey_id": 3},
    "dest": {"website_id": 3, "survey_id": 5}
  }
]
```

In the above example, records from survey ID 2 in website ID 2 are moved to survey ID 4 in website
ID 3. Records from survey ID 3 in website ID 2 are moved to survey ID 5 in website ID 3.

**id**

Optional. Specify an ID for the `recordsMover` control allowing you to refer to it from
elsewhere, e.g. CSS. If not specified, then a unique ID is generated by the code which
cannot be relied on.

**linkToDataControl**

Give the ID of an output data control (normally a `dataGrid`) which is showing the records that can
be moved. Enables use of multi-select checkboxes to specify a list of records if the control has
`@includeMultiSelectTool` set to true.

The source is obtained from this control. If the source contains records that are not in one of the
datasets from `datasetMappings` then the attempt to move records will fail and an error message
will be shown.

**restrictToOwnData**

Optional, defaults to true. Set to false to allow records to be moved according to the linked
source's current filter without enforcing a filter on the current user's records. Otherwise the
recordsMover tool will only move records belonging to the logged-in user.

ElasticsearchReportHelper::runCustomVerificationRulesets
--------------------------------------------------------

Provides a button which allows the user to access a list of their custom verification rulesets and
select one to run. They can also access a link for their rulesets management page and a tool is
provided for clearing their existing rulesets.

**id**

**manageRulesetsPagePath**

Path to a page which allows a user to manage a list of their custom verification rulesests. This is
typically a report page with a grid linked to the report
`library/custom_verification_rulesets/custom_verification_rulesets_list.xml`, and associated pages
for editing rulesets (prebuilt form `custom_verification_rulesets_edit`) and uploading rules
(prebuilt form `custom_verification_rulesets_upload`).

**source**

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

ElasticsearchReportHelper::urlParams
------------------------------------

This control allows you to configure how the page uses parameters in the URL to filter the
output shown on the page. By default, the following filter parameters are supported:

  * taxa_in_scratchpad_list_id - takes the ID of a `scratchpad_list` as a parameter and
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

**label**

Label for the control which will be translated before use. Set to empty string to exclude
the label. Default is 'Filter', or 'Context' if `@definesPermissions` is true.

ElasticsearchReportHelper::statusFilters
----------------------------------------

Provides a drop down list of record status filters. Selecting a filter
applies that filter to the current page's outputs. The options mirror those available in
the ‘records to include’ drop-down in the quality part of the [permissionFilters] control.
applies that filter to the current page's outputs. Changing the filter selected with this
control changes the selected option in the [permissionFilters] control, if there is one
on the page, and visa versa.

ElasticsearchReportHelper::surveyFilter
----------------------------------------

Provides a drop down list of surveys (datasets). Selecting a survey applies
a filter to the current page's outputs, limiting records to those belonging to the
selected survey. It is anticipated that this control will be used on pages that
provide dataset download facilities. When a survey is selected with this control,
the returned records will  include all custom sample and occurrence attributes
associated with that survey.

ElasticsearchReportHelper::filterSummary
----------------------------------------

Provides a textual summary of all the filters applied on the page using any of the
following controls: [standardParams], [permissionFilters], [userFilters], [statusFilters]
and [surveyFilter].
This can be used to make it less likely that a user has a filter applied
that they are not aware of, or two conflicting filters for example.

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

**includeUploadButton**

If set to true, a button is added to enable upload of a spreadsheet of verification decisions. This
allows a verification decisions spreadsheet with the following columns to be uploaded and
automatically applied to the records:

* ID - ID of the record
* '*Decision status*' - for records where the status is to be changed, specify one of the following
  values:
  * Accepted
  * Accepted as correct
  * Accepted as considered correct
  * Plausible
  * Not accepted as unable to verify
  * Not accepted as incorrect
  * Queried
* '*Decision comment*' - fill in with the comment to associate with the decision. A comment without
  a decision status will still be attached to the record but the status won't be changed.

The decision spreadsheet upload tool checks each record to ensure that it is one of the set of
records returned by the current verification context filter. Therefore it is impossible to update
records you are not a verifier for.

Note that the `warehouseName` option must be provided when `includeUploadButton` is true.

In order to set the decisions spreadsheet functionality up, a `[download]` control can be modified
to include the columns required for verification. It can also be configured to output the button
and resulting download file link under the records grid by adding the following options::

  [download]
  @linkToDataControl=records-grid
  @buttonContainerElement=#records-grid tfoot td
  @containerElement=#records-grid
  @addColumns=<!--[
    {"caption":"Status","field":"#verification_status:astext#"},
    {"caption":"Sub-status","field":"#verification_substatus:astext#"},
    {"caption":"*Decision status*","field":"#constant:#"},
    {"caption":"*Decision comment*","field":"#constant:#"}
  ]-->

The verification buttons can be configured to output the upload decisions spreadsheet button into
the report footer area as follows::

  [verificationButtons]
  @includeUploadButton=true
  @warehouseName=myexamplewarehouse.com
  @uploadButtonContainerElement=#records-grid tfoot td

**keyboardNavigation**

Enables the following shortcuts:
* 1 = Verify current record (accepted as correct, or accepted when showing just tier 1 buttons).
* 2 = Verify current record (accepted as considered correct).
* 3 = Set current record as plausible.
* 4 = Reject current record (unable to verify).
* 5 = Verify current record (rejected as incorrect).
* Q = Query current record.
* R = Re-determine current record.

**redeterminerNameAttributeHandling**

To change the behaviour for updating the determiner name associated with a record after a
redetermination, set to one of the following:

* overwriteOnRedet - The determiner name attribute of a record is changed to the name of
  the user performing a redetermination. This is the default.
* allowChoice - the user performing a redetermination is able to choose whether to overwrite the
  determiner name associated with a record or leave it as it is.

**showSelectedRow**

Specify the element ID of a `[dataGrid]` or `[cardGallery]` control which the buttons will source
the selected occurrence from.

**taxon_list_id**

Allows the master list to be specified that the redetermination functionality's search box can use.
If not set, then the master list set in the Indicia settings form will be used. One or other is
required.
The redetermination is always against the list used to make the record initially. If this is
different to the master list then a checkbox is added to allow selection of the master list. If
there is no master list then set this to 0.

**uploadButtonContainerElement**

If you want to add the upload button somewhere else on the page (e.g. to a table footer alongside a
download button, specify the element selector here.

**verificationTemplates**

Set to true to enable saving and loading templates for verification and redetermination comments.

**viewPath**

If a Drupal page path for a record details page is specified then a button is added to
allow record viewing.

**warehouseName**

Name of the warehouse stored against records in Elasticsearch (in the `metadata.warehouse` field).
Typically the domain name of the warehouse server. Must be set when the `includeUploadButton`
option is set as it is required to ensure that uploaded decisions do not affect records imported
into the Elasticsearch index from other warehouses.

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

