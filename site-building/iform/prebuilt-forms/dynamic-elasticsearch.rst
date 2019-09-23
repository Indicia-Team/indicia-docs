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
on the warehouse, then follow the instructions at :doc:`../../../developing/rest-web-services/elasticsearch`.

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

Not yet implemented. Currently, you can control page filtering by adding hidden inputs to
the Form Structure.

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

The controls available for addition to the page are as follows:

[source]
""""""""

The `source` control acts as a link from other controls on the page to a set of data from
Elasticsearch. See :ref:`elasticsearch-report-helper-source`.

[indiciaSource]
"""""""""""""""

.. todo::

  Implement an indiciaSource control to make this code data source independent.

[dataGrid]

Generates a table containing Elasticsearch data. See
:ref:`elasticsearch-report-helper-dataGrid`.

[download]

A button with associated progress display for generating downloadable zip files of CSV
data from an associated [source] control. See
:ref:`elasticsearch-report-helper-download`.

[leafletMap]

A map panel which uses the leaflet library that can display occurrence data from
Elasticsearch in a variety of ways. See
:ref:`elasticsearch-report-helper-leafletMap`.

[templatedOutput]
"""""""""""""""""

A flexible output of ES data which uses templates to build the HTML. See
:ref:`elasticsearch-report-helper-templatedOutput`.





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

[higherGeographySelect]
"""""""""""""""""""""""

A select box for choosing an indexed location. When the user chooses a location, the map
will show the boundary, pan and zoom to the boundary and filter the results.

Locations must be from an indexed location layer. See :doc:`../../../administrating/warehouse/modules/spatial-index-builder`
for more info.

Options available are:

**@readAuth**
* **@label** - Attaches the given label to the control.
* **@blankText** - Text shown for the option which corresponds to no location filter.
* **@locationTypeId** - The ID of the locations layer to pick locations from.

[recordDetails]
"""""""""""""""

A tabbed panel showing key details of the record. Includes a tab for record field values,
one for comments logged against the record and one to show the recorder's level of
experience for this and similar taxa.

Options available are:

**@readAuth**

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