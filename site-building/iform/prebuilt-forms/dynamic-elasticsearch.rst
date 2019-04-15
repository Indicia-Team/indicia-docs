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

Controls availabe are as follows:

[source]
""""""""

The source control acts as a link from other controls on the page to a set of data from
Elasticsearch. A source can declare it's own query restrictions (in addition to those
specified on the page) and can also declare an Elasticsearch aggregation if needed. On its
own, a `[source]` control does nothing. Its only when another output control is linked to
it that data will be fetched and shown on the page.

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

**@shareFilterSource** [NOT IMPLEMENTED]

**@initialMapBounds**

Set to true to use this source's dataset to define the bounds of the map on initial
loading.

**@aggregation**

Use this property to declare an Elasticsearch aggregation in JSON format. See
`https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations.html`_.
You can use Kibana to build an aggregation then inspect the request to extract the
required JSON data.

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
selected row. In this case you should also set `@filterField` to define the field which
must match between the grid's selected row document and the documents returned by this
source.

For example you might have a 2 grids and a map where the map shows all the verified records
of the species selected in the grid. This requires 2 `[source]` controls, a `[dataGrid]`
and a `[map]`::

  [source]
  @id=gridData
  @size=30

  [source]
  @id=mapData
  @size=0
  @filterSourceGrid=records-grid
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

  [map]
  @id=map
  @source=<!--{
    "mapData": "Verified records of selected species"
  }-->

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

[dataGrid]
""""""""""

**@id**

**@source**

ID of the `[source]` control this dataGrid is populated from.

**@sourceTable**

Where the linked `[source]` control builds a table from it's aggregations (using
`@buildTableXY`, this can be set to the name of the table to use that table's output as
the source of data for this dataGrid.

**@simpleAggregation**

**@columns**
  * caption
  * multiselect
  * field
  * data-hide="tablet,mobile,default,all"
  * data-type="date|numeric"

**@autogenColumns**

**@actions**

**@includeColumnHeadings**

**@includeFilterRow**

**@includePager**

**@sortable**



*Filter controls*

*HTML inputs*

Attributes, diff query types
    $fieldQueryTypes = ['term', 'match', 'match_phrase', 'match_phrase_prefix'];
    $stringQueryTypes = ['query_string', 'simple_query_string'];

*[userFilters]*

* @sharingCode
* @definesPermissions

*[map]*

* @id
* @cookies

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

*[recordDetails]*

@id - [NOT IMPLEMENTED?]
* @showSelectedRow
* @explorePath

[urlParams]
"""""""""""

This control allows you to configure how the page uses parameters in the URL to filter the
output shown on the page. It currently only enables a parameter `taxon_scratchpad_list_id`
which takes the ID of a `scratcphad_list` as a parameter and creates a hidden filter
parameter which limits the returned records to those in the scratchpad list. For example,
a report page which lists scratchpad lists could have an action in the grid that links to
an Elasticsearch outputs page passing the list ID as a parameter.

Options available are:

* @taxon_scratchpad_list_id - set to false to disable this parameter.
