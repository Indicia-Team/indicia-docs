Data Services - reading a dataset
=================================

As well as the :doc:`support for reading individual records from the database
<data-services-read-record>`, the Data Services provide support for querying multiple
records in one request. Reading a set of records from the Data Services follows the
:doc:`general principles for reading data <data-services-reading>`. If your request URL
contains the singular form of the table name, plus authentication tokens and no other
parameters then you will receive a JSON document containing all the records from that
entity which your website is allowed to see. There are a number of GET or POST parameters
which can filter, format and sort the results as described below.

Filtering
---------

The following options control the records which are returned:

* Provide a URL parameter with the same name as a field in the dataset you are loading
  from set to the value you want to filter to. Use an asterisk as a wildcard in string
  filters or NULL to filter for null values. The fields available in the dataset which
  you can filter against are those available in the view which you are loading from,
  for example if you are accessing the sample model with a `view=list` parameter, then
  the fields available will be those in the list_samples view. See the notes below for
  more information on accessing the available fields.
* Set a URL parameter called **limit** to a positive whole number in order to limit the
  number of records returned.
* Set a URL parameter called **offset** to a positive whole number in order to skip a
  certain number of records from the beginning of the dataset.
* Set a parameter called **query** to specify an advanced query filter as described below.

.. tip::

  If you have access to the warehouse database via pgAdmin or a similar tool, then finding
  out which columns are available in which views for the data services requests is easy.
  However, if you are coding without direct access to the warehouse, you can download `a
  list of the view columns <http://www.indicia.org.uk/sites/default/files/downloads/view-columns.csv>`_
  for reference, currently correct to revision 6151. This list can be regenerated at any
  time using the following query, changing the schema and catalog name if required:

  .. code-block:: sql

    select table_name, column_name, data_type
    from INFORMATION_SCHEMA.columns
    where table_schema='indicia' and table_catalog='indicia'
    and (table_name like 'list_%' or table_name like 'detail_%' or table_name like 'gv_%'
        or table_name like 'cache_%')
    order by table_name, ordinal_position

Where a simple field filter is not sufficient, you can use the query parameter to build
more advanced queries against the data. This is achieved by passing a JSON object in the
query parameter. The top level of the object is an associative array of the filter type
name, each containing a set of the parameters required for the filter type. So, for a
simple example of a WHERE clause definition, you might pass the following using PHP which
generates the SQL given:

.. code-block:: php

  <?php
  ...
  'query' => urlencode(json_encode(array('where'=>array('survey_id', 5))))
  ...
  ?>

This generates:

.. code-block:: sql

  WHERE survey_id=5

In the case where you need 2 where clauses, you can do

.. code-block:: php

  <?php
  ...
  'query' => urlencode(json_encode(array(
    'where'=>array(array('survey_id'=>5, 'entered_sref_system'=>'OSGB'))
  )))
  ...
  ?>

This generates:

.. code-block:: sql

  WHERE survey_id=5 AND entered_sref_system='OSGB'

The supported filter type names are as follows:

* **where** -	Takes either 2 parameters, the fieldname and the value, or a single string
  parameter which is the join SQL, or an associative array of fieldnames and values.
  Multiple conditions are joined using an AND. If you need to support complex where syntax
  (e.g. wrapping parenthesis around 2 OR'ed statements) then this can be achieved by
  supplying an array containing a single string element, itself containing the full SQL
  required for the WHERE clause.
* **orwhere** - Identical to the where filter type, but conditions are joined using an OR.
* **in** - Takes 2 parameters, a fieldname and an array of values to generate an IN (...)
  SQL clause. If you need to provide multiple fields to filter with an IN (...) clause then
  you can provide an associative array where the keys are the fieldnames and the values are
  the arrays to filter against.
* **notin**	- Identical to in but generates a NOT IN clause.
* **like** -	Takes 2 parameters, a fieldname and a value to generate a LIKE SQL
  statement.
* **orlike** - Identical to the like filter type, but conditions are joined using an OR.

More may be added in future.

Sorting
-------

The following parameters can be used to control the sort order of the response.

* **orderby** -	Allows the field that the results are to be sorted by to be specified. This
  can be a comma separated list of field names to sort.
* **sortdir** - Specifies the sort direction. Options are ASC or DESC. This can be a comma
  separated list of **ASC** or **DESC** entries with the same number of entries as in
  orderby to define the order of each field. If there are less entries then the sort order
  for unspecified fields will be ASC.

Examples
--------

The following examples illustrate some Data Services requests that return multiple
records:

Example 1 - retrieve all taxon groups
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This request uses the limit parameter to restrict the response to the first 4 records.

Request::

  http://localhost/indicia/index.php/services/data/taxon_group
  ?mode=json&nonce=<nonce>&auth_token=<auth_token>&limit=4

Example response:

.. code-block:: json

  [
    {"id":"1","title":"Butterflies","website_id":null},
    {"id":"2","title":"Bugs","website_id":null},
    {"id":"3","title":"Moths","website_id":null},
    {"id":"4","title":"Beetles","website_id":null}
  ]
