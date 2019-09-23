Report File Format
==================

.. seealso::

  :doc:`tutorial-writing-a-report/index`

.. only:: developer

  We've included the full specification of the report file format here for your
  reference, but don't worry, you are not expected to work through and learn all
  of this during the developer training course!

Reports in Indicia are defined by placing XML files in the **reports** folder on
the warehouse which define the SQL query to run against the database, the
input parameters and the output columns. Report files must be valid XML
documents with the following element structure.

Element <report>
----------------

This is the top level element of the XML document.

Attributes
^^^^^^^^^^

* **title** - the display title of the report.
* **description** - the description of the report.
* **featured** - optional. Set to true for reports that meet the criteria to be
  included in lists of featured or recommended reports. Featured reports must:

  * support the standard report parameters, or at the very least support
    a parameter called created_by_id to filter by the user who created the
    records unless it is intentional that all the records exposed by the report
    are accessible to all users.
  * be well maintained and described.
  * be included in the list of report tests configured to run in the automated testing.
    See the $featuredReports variable defined in `the report test class
    <https://github.com/Indicia-Team/warehouse/blob/master/modules/indicia_svc_data/tests/controllers/services/reportTest.php>`_.

* **summary** - optional. Set to true for reports that only output summary data and
  therefore can be accessed without concern for whether raw data is being made available.
  The REST API uses this flag to limit reports available to users who shouldn't have raw
  data access.
* **restricted** - optional. Set to true for any reports that should not be exposed for
  public access. These reports will only be available for access via the RESTful API
  if authorised explicitly for a client project.

Child elements
^^^^^^^^^^^^^^

* :ref:`query <query-label>`
* :ref:`order-bys <order-bys-label>`
* :ref:`field-sql <field-sql-label>`
* :ref:`params <params-label>`
* :ref:`columns <columns-label>`
* :ref:`vagueDate <vaguedate-label>`

Example
^^^^^^^

.. code-block:: xml

  <report title="My report" description="A list of records">
    ...
  </report>

.. _query-label:

Element <query>
---------------

There is a single element called query in the XML document, which should be a
direct child of the report element. This contains the SQL statement to run,
which may contain modifications and replacement tokens to allow it to integrate
with the reporting system, as described elsewhere.

Attributes
^^^^^^^^^^

There are several attributes available for the ``<query>`` element, which serve
to override the default field used when the warehouse adds certain filters to
the query. For example, the **sharing** options for a report allow the report to
be filtered to a website or list of websites, or to the current user. The
warehouse therefore will need to know the field name to use when inserting each
filter into the query.

* *website_filter_field* - field name, including the table alias, used for
  identifying and filtering websites within the query. Defaults to "w.id" which
  is based on the assumption that the websites table is joined into the query
  with a table alias "w".
* *created_by_field* identifies the field in the SQL query which is used to
  filter for the current user when using the option **sharing=me**. Defaults
  to o.created_by_id which is based on the assumption that the occurrences table
  is joined into the query with a table alias "o".
* *samples_id_field* - identifies the field in the SQL query which is used to
  join to the sample_attribute_values table in order to include sample custom
  attributes in the report output. Use in conjunction with the **smpattrs**
  datatype for a report parameter. Defaults to "s.id" which is based on the
  assumption that the samples table is joined into the query with a table alias
  "s". See :ref:`attrs-label` for more info.
* *occurrences_id_field* - identifies the field in the SQL query which is used to
  join to the occurrence_attribute_values table in order to include occurrence
  custom attributes in the report output. Use in conjunction with the
  **occattrs** datatype for a report parameter. Defaults to "o.id" which is
  based on the assumption that the samples table is joined into the query with a
  table alias "o". See :ref:`attrs-label` for more info.
* *locations_id_field* - identifies the field in the SQL query which is used to
  join to the location_attribute_values table in order to include location
  custom attributes in the report output. Use in conjunction with the
  **locattrs** datatype for a report parameter. Defaults to "l.id" which is
  based on the assumption that the locations table is joined into the query with
  a table alias "l". See :ref:`attrs-label` for more info.
* *standard_param* - set to "occurrences" to enable a standardised set of filter parameters
  for filtering occurrence records or "samples" for sample records. This includes a range
  of filter options such as date, species group, geography etc. They are designed to
  integrate with the filter panel provided in the reporting client helpers. See
  :doc:`standard-parameters` for more information.

Replacements Tokens
^^^^^^^^^^^^^^^^^^^

Within the SQL you include in the ``<query>`` element, you can insert the
following tokens which will be replaced when the warehouse builds the query to
run:

* #columns# - replaced by a list of fields generated from the **sql** attributes
  of each ``<column>`` element in the ``<columns>`` section. For example, the
  query could read ``select #columns# from taxa`` and there could be 2
  ``<column>`` definitions with the **sql** attribute set to "id" and "taxon"
  respectively, resulting in a query ``select id, taxon from taxa``.
* #field_sql# - replaced by the contents of the ``<field_sql>`` element and used
  to separate the list of fields from the rest of the SQL statement, which
  allows the warehouse to replace the field list with ``count(*)`` in order to
  count the query results. If using #columns# then it is not necessary. See
  :ref:`field-sql-label` for more information on using this replacement token.
* #agreements_join# - if you are using the **sharing** parameter for the
  reporting web service, then this replacement token specifies where in the
  query that the warehouse will insert a join to the
  **index_websites_website_agreements** table when needing to find the list of
  websites whose records can be included in the report output.
* #sharing_filter# - if you are using tbe **sharing** parameter for the
  reporting web service, then this replacement token specifies where in the
  query's ``WHERE`` clause to insert any filter required for the sharing, e.g.
  this could be a filter on the occurrence **created_by_id** field when the
  sharing mode is "me", or it could be a filter on the websites joined by the
  **index_websites_website_agreements** table for other sharing modes which
  allow records from other specific websites to be included in query output.
* #idlist# - when used in conjunction with the **idlist** datatype for a report
  parameter, this is replaced by a list of selected IDs to filter the report by
  as provided for the parameter. A typical use of the idlist is to allow a
  report to integrate with a map featuring polygon based querying. Once the
  polygon is drawn on the map and the contained points are found, the IDs of the
  points can be passed to the idlist parameter so that the grid filters to show
  just the points within the polygon. Therefore the idlist token should mark a
  position in the report ``WHERE`` clause which is suitable for the warehouse
  to insert SQL along the lines of ``AND o.id IN (1,2,3,4,5)``.
* #order_by# - When a report output is required in a particular sort order, e.g.
  after clicking on a column title in a grid to sort it, Indicia will append an
  SQL ``ORDER BY`` clause to the end of the query. This token is only required
  in the unusual circumstance that the clause needs to be inserted into the
  query somewhere other than the very end of the report SQL, e.g. if it needs
  to precede a ``LIMIT`` statement.
* #training# - If the report includes either the occurrences or cache_occurrences table
  with a website filter, then the training mode on the logged in user's account will be
  automatically applied to filter the report. In some cases however you may want to handle
  training mode filtering in a different way, in which case your report can use the
  #training# replacement, which will be set to **true** or **false** as appropriate.
* #group_bys# - if your query contains aggregate columns, then Indicia wil automatically
  generate a GROUP BY clause in the SQL. By default this is placed at the end of the
  query. Using this replacement token allows you to specify where in the query the
  GROUP BY will appear, useful when grouping in a subquery for example.

In addition any declared :ref:`parameters <params-label>` are available as
replacement tokens, so if there is a parameter called "survey_id" then the
replacement token ``#survey_id#`` can be used in the report and it will be
replaced by the selected survey ID when the report is run.

Example
^^^^^^^

.. code-block:: xml

  <query website_filter_field="o.website_id">
  SELECT #columns#
  FROM cache_occurrences o
  JOIN websites w on w.id=o.website_id
  #agreements_join#
  #joins#
  WHERE #sharing_filter#
  AND o.record_status not in ('I','T') AND (#ownData#=1 OR o.record_status not in ('D','R'))
  AND ('#searchArea#'='' OR st_intersects(o.public_geom, st_geomfromtext('#searchArea#',900913)))
  AND (#ownData#=0 OR CAST(o.created_by_id AS character varying)='#currentUser#')
  #idlist#
  </query>

.. _order-bys-label:

Element <order_bys>
-------------------

Contains elements defining the default sort order of the report. This can be
overriding by an ascending or descending sort on any column, e.g. when clicking
on a report grid title.

Child elements
^^^^^^^^^^^^^^

* :ref:`order_by <order-by-label>`

.. _order-by-label:

Element <order_by>
------------------

Contains the SQL for a single sort order field or comma separated group of
fields, e.g. ``s.date_start ASC``.


.. _field-sql-label:

Element <field_sql>
-------------------

When the #field_sql# replacement token is used in the query, provide the SQL for
the list of fields in this element which will be replaced into the token when
the query is run. The #field_sql# token should go immediately after the
``SELECT`` keyword and before the ``FROM`` keyword to form a valid SQL statement
when it is replaced. This approach provides a quick way of allowing Indicia to
perform a count of the records in a report without running the entire report
query. For a fully featured paginator to be shown for any report grids, Indicia
needs to know the total count of rows in the report result. Although this is
achievable by simply loading the entire results of a query and counting rows,
Indicia does not take this approach as it could lead to severe performance
impacts on the server for inefficient queries or large result sets. Using a
``count(*)``  query is much faster.

Example
^^^^^^^

.. code-block:: xml

  ...
  <query>SELECT #field_sql# FROM cache_occurrences</query>
  <field_sql>id, preferred_taxon_name, public_entered_sref</field_sql>
  ...

.. _params-label:

Element <params>
----------------

The ``<params>`` element provides an area within the report definition to list
parameters for the query and provide configuration for each.

Child elements
^^^^^^^^^^^^^^

* :ref:`param <param-label>`

.. _param-label:

Element <param>
---------------

Configuration for a single report parameter.

Attributes
^^^^^^^^^^

* **name** -
  The name of the attribute. Must consist of alphabetic characters,
  numbers and underscores only. The attribute is wrapped in hashes to create the
  replacement token which will be replaced in the query. For example, if

  * a parameter named "startdate" is passed a value 01/10/2012 when the report
    is run
  * the report include a clause ``WHERE date>'#startdate#'`` in the SQL

  then the clause would be replaced when the report is run to form the SQL
  ``WHERE date>'01/10/2012'``.
* **display** -
  The text used to label the parameter in the input parameters form displayed to
  the user before running the report.
* **description** -
  Gives a further description displayed alongside the parameter in the form.
* **datatype** -
  Used in determining the type of control to show when requesting the parameter.
  Currently, the core module report interface supports datatypes 'text', 'text[]',
  'integer', 'integer[]', 'lookup', 'date', 'geometry', 'polygon', 'line', 'point', 'idlist',
  'smpattrs', 'occattrs', 'locattrs'. All other values default to text. Date
  will show a datepicker control. Lookup will show a select box. Geometry,
  Polygon, Line and Point all require a map for the user to draw the input
  parameter shape onto. Finally, idlist, smpattrs, occattrs and locattrs are
  special datatypes that are described in the section :ref:`attrs-label`. When
  viewing the parameters form in the Warehouse interface, the contents of the
  lookup are populated using the query in the query attribute. When using the
  report_grid control in the data_entry_helper class, the contents of the lookup
  are populated using the population_call attribute. Alternatively a fixed set
  of values can be specified by using the lookup_values attribute.
  Note that the datatypes with [] appended indicate cases where a list of comma
  separated values is provided to use in an SQL IN clause, allowing the system
  to sanitise individual list elements.
* **query** -
  Used to provide an SQL query used to populate the select box for
  lookup parameters. The query should return 2 fields, the key and display
  value. This only works on the warehouse and does not work for reports run from
  client websites, since they cannot directly issue SQL queries, so it is
  recommended that you use the **population_call** attribute instead.
* **population_call** -
  Allows report parameter forms on client websites to populate the select boxes
  shown in the report's input parameters form. The format of the value specified
  for this attribute should be either of the following, replacing the values in
  <> as appropriate:

  * direct:<table name>:<value field>:<caption field>
  * report:<report name>:<value field>:<caption field>
  * autocomplete:species

  The first part of the value is set to direct or report to indicate loading data from a
  table or report respectively. This is followed by the table name or report name
  (including path), then the name of the field which provides the underlying parameter
  value to pass into the report, then finally the name of the field which provides the
  caption to display to the user for this value in the drop down. Examples include
  "direct:survey:id:title" or "report:my_reports/taxon_groups:id:title" where
  `my_reports/taxon_groups.xml` is a report which must return fields named id and title.
  You can optionally append an additional colon, then a list of report parameters, comma-
  separate in form `param=value`.

  Use the `autocomplete:species` value in population_call to invoke a species autocomplete
  control for the parameter.

* **lookup_values** -
  Allows specification of a fixed list of values for a parameter with the lookup
  datatype. This is an alternative to using population_call to populate the
  select box in the parameters input form from the database. Specify each entry
  as key:value with commas between them, for example "all:All,C:Complete,S:Sent
  for verification,V:Verified".
* **linked_to** -
  Available only for select parameters and allows another select to be specified
  as the parent. In this case, the values in this select are filtered using the
  value in the parent select. For example, a select for survey might be linked
  to a select for website, meaning that selecting a website repopulates the list
  of available surveys.
* **linked_filter_field** -
  Applies when using **linked_to**, and allows the filtered field in the entity
  accessed by the population_call to be specified. In the above example of a
  survey lookup linked to a website lookup, the survey lookup would specify this
  as website_id.
* **emptyvalue** -
  Allows a special value to be used when the parameter is left
  blank by the user. As an example, take an integer parameter, with SQL syntax
  WHERE id=#id#. If the user leaves this parameter blank, then invalid SQL is
  generated (WHERE id=). But, if emptyvalue='0' is specified in the parameter
  definition, then the SQL generated will be WHERE id=0, which is valid and in
  most cases will return no records. Consider replacing the SQL with ``WHERE
  (id=#id# OR #id#=0)`` to create a filter that will return all records when
  left blank.
* **default** -
  A parameter with a default value
* **fieldname** -
  Use in conjunction with the **idlist** datatype. For more information see
  :ref:`idlist-label`
* **alias** -
  Use in conjunction with the **idlist** datatype. For more information see
  :ref:`idlist-label`
* **preprocess** -
  Sometimes it is more efficient to pre-process a parameter value using an SQL statement
  than to try to perform the required processing within the single report query. An
  example is when filtering a report by taxon hierarchy if the passed in parameter is a
  higher taxon such as a family or order. The preprocess query can convert the input
  parameter to a list of keys or IDs corresponding to all the species within the input
  taxon and feed that list into the report. The original value can still be accessed
  within the main query by adding -unprocessed to the parameter name, for example for a
  parameter called "higher_taxon" the processed list of species would be replaced for a
  token called #higher_taxon# and the unprocessed original parameter would be available
  in #higher_taxon-unprocessed#. The preprocess value can contain one of the following:

  * A single SQL statement which has the parameter name as a token (surrounded by #
    characters) which will be replaced by the original parameter value, plus optionally
    #website_ids# and #master_list_id# tokens which will be replaced as appropriate. The
    query should return a string which will be replaced into the parameter's SQL,
    replacing the token with the same name as the parameter.
  * An array of several SQL statements, keyed by the name of the token which should be
    replaced in the parameter's SQL. For example, the taxa_taxon_list_list parameter
    uses 2 preprocess queries, one to convert the input taxa_taxon_list_ids into
    taxon_meaning_ids (which can be used to easily search the taxon hierarchy), plus a
    second which identifies the taxon_group_ids. Providing a list of taxon_meaning_ids
    as well as a list of taxon_group_ids gives the query planner a better chance to use
    indexes when optimising the query, since the taxon_group_ids is likely to be a much
    simpler case with a smaller list of IDs.

.. _idlist-label:

More information on the idlist datatype
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The **idlist** is a special datatype that will not add a control to the input
form. Instead it provides a hidden input in the form which other code on the
page can use to filter the report. An example of the use of this field is when
using the report_map control linked with a report_grid so that clicking on the
map passes a comma separated list of occurrence IDs into the hidden input, then
reloads the report grid. In order for this to work it is necessary to provide 2
additional attributes of the parameter alongside the datatype="idlist". These
are **fieldname** which defines the name of the field in the SQL (including
table alias if necessary) and **alias** which is the aliased fieldname that is
output by the query. The former is used when constructing the SQL report query,
the latter is used when retrieving the ids to filter against from the report
output. So, in a simplified report example which includes this SQL:

.. code-block:: sql

  SELECT o.id as occurrence_id FROM occurrences
  WHERE o.deleted=false
  #idlist#

you would expect a parameter defined like:

.. code-block:: xml

  <param name="idlist" display="List of IDs"
      description="Comma separated list of occurrence IDs to filter to."
      datatype="idlist" fieldname="o.id" alias="occurrence_id" />

Parameters which require additional filters in the WHERE section
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If a query should have a filter in the WHERE section only if one of the parameters is
specified or has a certain value, you can add a ``<where>`` element to the ``<param>``.
For example, a filter on taxon group could include the filter SQL only when a taxon
group has been specified.

.. code-block:: xml

  <param name='taxon_groups' display='Taxon Groups'
      description='Comma separated list of taxon group IDs to filter the report by, if
      any'>
    <where>
      o.taxon_group_id in (#taxon_groups#)
    </where>
  </param>

It is also possible to qualify the filter, by specifying attributes **operator**
and **value**. The operator must be set to equal or notequal and the value
should then be set to define a condition on when this filter is applied to the report
SQL. In this example, a taxon groups preferences parameter is only applied to the report
if the ownGroups param is checked.

.. code-block:: xml

  <param name="taxon_groups" display="Taxon Groups"
      description="Comma separated list of taxon group IDs to filter the report by, if
      any"/>
  <param name="ownGroups"
    <where operator="equal" value="true">
      o.taxon_group_id in (#taxon_groups#)
    </where>
  </param>

Parameters which require additional joins
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sometimes, a query join is required in a report only when a parameter has a
value, or has a certain value. Including the join in the report at all times
would normally reduce performance of the report even when the join was not
necessary. For example, a parameter filtering on the record's survey title might
require a join to the surveys table which would not otherwise be required. In
this case, specify a child element of the parameter called ``<join>`` which
contains the join SQL, and ensure that the query contains the ``#joins#`` tag so
that the pre-processor knows where to insert the join. The following example is
from a verification report which only includes a join to the locations table if
the expert's region of expertise is specified:

.. code-block:: xml

  <param name='expertise_location' display='Location of Expertise'
      description='Provide the location in which your expertise applies'
      datatype='lookup' population_call='direct:location:id:name'>
    <join>
      JOIN locations lexpert ON st_intersects(lexpert.boundary_geom, s.geom)
        AND lexpert.id=#expertise_location#
    </join>
  </param>

It is also possible to qualify the join, by specifying attributes **operator**
and **value**. The operator must be set to equal or notequal and the value
should then be set to define a filter on when this join is applied to the report
SQL.

.. _attrs-label:

Optional custom attributes
^^^^^^^^^^^^^^^^^^^^^^^^^^

The parameter datatypes *smpattrs*, *occattrs* and *locattrs* are special types
used to allow the input of a comma separated list of custom attributes to be
added to the report output. Attributes can be sample attributes, occurrence
attributes and location attributes respectively and can be provided either by
specifying the attribute caption or ID in the comma separated list. A third option is to
specify a hash followed by the key of a system function in which case the appropriate
attributes for that system function will be automatically pulled into the report. For
example you might include the sex, stage and identifier of a record by referring to the
system functions of the columns as ::

  smpattrs=#sex,#stage,#det_full_name

To use parameters of these types it is necessary to fulfill several requirements in the
way your report is specified:

#. The report must use the *field_sql* element to separate the field list from
   the SQL statement, so that additional fields can be added to the list as
   required.
#. The report query must contain a tag *#joins#* in the SQL in a position where
   additional joins can be inserted.
#. The query must include a table which contains the ID attribute that the
   attribute values are linked to, for example the sample ID, occurrence ID or
   location ID.
#. If the ID fields can be referred to in the SQL using *s.id*, *o.id* and
   *l.id* then no further changes are required. You can override these defaults,
   for example if you have a query listing occurrences which does not join in the
   samples table but need to be able to add sample attribute values. In this
   case, the query element needs an attribute *samples_id_field* which
   identifies the field reference that can be used in the SQL to join to the
   sample, in this case *o.sample_id*.

You can also use the output column as if it were a normally declared column in
your report. This lets you specify the column details in the report_grid options
to show or hide a column, set the caption etc, or to specify the column in the
extraParams in order to filter for a specific column value. To do this you need
to work out the name of the custom attribute's report column. This will be of
the pattern *attr_(location|sample|occurrence)_(ref)*, where ref is the
attribute's ID or caption depending on how you requested the attribute
originally, with the caption being converted to lowercase and all
non-alphanumeric characters converted to underscores. There is also a second
hidden column added called *attr_id_(location|sample|occurrence)_(ref)* which
contains the attribute value table's ID useful if you need to identify which
record to update to change the data underlying the report. For example, if a
sample attribute has ID 4 and caption "CMS User ID" then you can request this in
either of the following ways:

==============================  =======================  =====================================
Parameter request for smpattrs  Output column name       sample_attribute_value.id column name
==============================  =======================  =====================================
4	                              attr_location_4	         attr_id_location_4
CMS User ID                     attr_sample_cms_user_id  attr_id_location_cms_user_id
==============================  =======================  =====================================

For system function references, there is just a single column called attr followed by an
underscore then the key of the system function, e.g. attr_det_full_name.

.. _columns-label:

Element <columns>
-----------------

The ``<columns>`` element provides an area within the report definition to list
output columns and provide configuration for each column. A report which lists
the columns directly in the ``<query>`` element's SQL statement does not need
to specify the columns here to work, although the flexibility of the report is
greatly increased if columns are specified.

Child elements
^^^^^^^^^^^^^^

* :ref:`column <column-label>`

.. _column-label:

Element <column>
----------------

Provides the definition of a single output column for the report query.

Attributes
^^^^^^^^^^

* **name**
  Should match the name used in the query:

  * ``SELECT foo FROM websites`` should have name *foo*
  * ``SELECT bar AS baz FROM websites`` should have name *baz* (not *bar*)
  * ``SELECT w.foo FROM websites`` should have name foo, not w.foo, though where
    there is ambiguity renaming your columns with 'AS' is the recommended
    solution. Failing to match this correctly may leave phantom columns in the
    report.

* **display**
  Will be displayed as the column header.
* **style**
  Provides CSS which will be applied to the column of the output HTML table
  (though not the header).
* **class**
  Defines a css class that will be applied to the body cells in the column.
  For example, in a species column you can specify "sci binomial" to define that
  this is the name part of the row. This can then be detected as a `Species
  Microformat <http://microformats.org/wiki/species>`_.
* **visible** can be set to false to hide a column.
* **img** can be set to true for a field that contains the filename of an image
  uploaded to the Warehouse. This will then be replaced by a thumbnail of the
  image, with support for FancyBox image popups to show the full image size.
  Multiple images can be comma separated in the field output to output mutiple
  thumbnails.
* **mappable** can be set to true to declare a column which can then be output
  using the ``report_helper`` class' ``report_map`` method. The column must
  output a `WKT <http://en.wikipedia.org/wiki/Well-known_text>`_ definition of
  the geometry to be mapped, e.g. the column definition in the SQL might be
  ``st_astext(geom)``.
* **orderby** can be set to the name of another column in the report (including
  hidden columns) when a column that is logically selected for sorting
  physically uses another column to provide the sort order. For example terms in
  Indicia termlists support a sort_order field which gives an optional non-
  alphabetical sort order for the list of terms (good, better, best is an
  example of a non-alphabetical but logical sort order). By specifying
  ``orderby="sort_order"`` for the term column, this causes the logical rather
  than alphabetical sort to be used when clicking on this column's header.
* **datatype** can be used to declare the datatype of a column to enable column
  filtering in the grid. Set to one of text, species, date, integer or float. When set,
  a text box is shown at the top of the column into which the user can type
  filters. Note that the species datatype is a variant of text which removes subgenera and
  spaces from the search text to make it more tolerant.
* **aggregate**
  Described in the section :ref:`declaring-column-sql-label` below.
* **distincton**
  Described in the section :ref:`declaring-column-sql-label` below.
* **in_count**
  Described in the section :ref:`declaring-column-sql-label` below.
* **on_demand** can be set to true to mark a column which does not need to be included in
  the results set, but can be used in the report filter on demand. A good example of the
  use of this is when a report grid and a report map are on the same page and
  synchronised. The report grid allows column based filtering, but the report used to
  populate the map must be as efficient as possible and therefore should only return the
  geometry related data. The filterable grid columns can be included in the map report so
  that the map report can have the exact same filter applied when the grid is filtered
  without impacting on the performance of the map load.
* **internal_sql**
* **term** can be populated with the URL of a term defined in a known schema, for example
  set to http://rs.tdwg.org/dwc/terms/individualCount to link a column to the Darwin core
  individualCount attribute.
* **template** provides an HTML template to put the column information in. It is not limited
  to the column tag it is hosted in and so can use the information from all the columns in
  the report. Format is ``{column name}``. The simpliest form showing the column value looks

  .. code-block:: xml

    <column name="id" template="{id}" />

  from there it could be extened to include some text, in this case the percentage sign

  .. code-block:: xml

    <column name="percent" template="{percent}%" />

  or using an HTML temlpate, where < and > are replaced with &lt; and &gt; respectively,
  make the text bold

  .. code-block:: xml

    <column name="percent" template="&lt;b&gt; {id} &lt;/b&gt;" />

  it could even enhance the functionality by adding some JS code, like here

  .. code-block:: xml

    <column name="id" template="&lt;a href='#' onclick='alert({percent})' &gt; {id} &lt;/a&gt;"  />

* **feature_style** can be used when there is a mappable column on the report,
  to define a column which provides the value for one of the map styling
  parameters supported in OpenLayers. Supported options include **strokeColor**
  (a CSS colour specification, e.g. '#00FF00'), **strokeOpacity** (a number from
  0 to 1), **strokeWidth** (number of pixels wide to draw the perimeter line),
  **strokeDashStyle** (dot, dash, dashdot, longdash, longdashdot or solid),
  **fillColor** (as strokeColor), fillOpacity (as strokeOpacity) graphicZIndex (higher
  number draws on top of lower number). For example, a report could vary the opacity of
  output grid references on the map according to size by including this column in the SQL:

  .. code-block:: sql

    length(s.entered_sref) / 24.0 as fillopacity,

  This column then has a definition:

  .. code-block:: xml

    <column name='fillopacity' visible='false' feature_style="fillOpacity"  />

.. _declaring-column-sql-label:

Declaring SQL for each column
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

There are certain limitations to what the Indicia reporting engine can do with
the columns SQL all defined in a single block, either in the query or using the
``<field_sql>`` element. For example, any query with aggregate functions in it
cannot return an accurate record count for the grid paginator. Consider the
following query:

.. code-block:: sql

  select l.id, l.name, count(s.id) as sample_count
  from locations l
  join samples s on s.location_id=l.id
  group by l.id, l.name

This returns a list of locations with their sample counts. If we use the
``<field_sql>`` approach, then Indicia will run a select count(*) query to get
the count of records for the paginator, since this will return the count of
sample records not the count of locations. To get round these restrictions, you
can define the SQL for each field in the ``<column>`` definition using an
attribute called ``sql`` then specify a replacement in the SQL statement
*#columns#*. You don’t need to define each field’s alias as the column name will
be used for that (since they must be the same). You can also define attributes
aggregate (set to true for columns that define an aggregate function so they can
be skipped in the count query), distincton (set to true for any columns that you
don’t want to duplicate ever) and in_count (set to true if the column should be
included in the count query, which defaults to true for distincton columns but
false otherwise). To illustrate these points, here is the SQL and column list
for the above query:

.. code-block:: xml

  <query>
  select #columns#
  from locations l
  join samples s on s.location_id=l.id
  group by l.id, l.name
  </query>
  <columns>
  <column name="id" sql="l.id" />
  <column name="name" sql="l.name " />
  <column name="sample_count" sql="count(s.id)" aggregate="true" />
  </columns>

By marking the aggregate column, then Indicia is able to correctly count the
distinct non-aggregate values enabling the pager for a report grid to know the
correct number of pages. To illustrate the use of distincton, consider writing a
query which returns a list of locations plus a sample date, where you don’t
actually care which sample date is returned (you just want to know that it has
been sampled). Here's the query to do this:

.. code-block:: sql

  select distinct on (l.id) l.id, l.name, s.date_start
  from locations l
  join samples s on s.location_id=l.id

Here's how you could represent that in report XML:

.. code-block:: xml

  <sql>
  select #columns#
  from locations l
  join samples s on s.location_id=l.id
  </sql>
  <columns>
  <column name="id" sql="l.id" distincton="true" />
  <column name="name" sql="l.name " />
  <column name="date" sql="s.date_start" />
  </columns>

Note that the **distincton** support was added for Indicia 0.8 and is not
available in earlier versions.

.. _vaguedate-label:

Element <vagueDate>
-------------------

By default, vague dates provided as a **date_start**, **date_end** and
**date_type** field in the report output columns are processed to result in a
single **date** column containing the vague date as a readable string. It is
possible to override this behaviour and leave the original columns in place, by
adding the following element to the ``<report>`` element in the xml:

.. code-block:: xml

  <vagueDate enableProcessing="false" />

When vague date processing is enabled, as an example your query might output the
following table:

=================  ===============  ================
sample_date_start  sample_date_end  sample_date_type
=================  ===============  ================
2011-12-14	       2011-12-14	      D
2010-01-01	       2011-12-31	      Y
=================  ===============  ================

This would be output as:

===================  =================  ==================  ===========
*sample_date_start*  *sample_date_end*  *sample_date_type*  sample_date
===================  =================  ==================  ===========
2011-12-14           2011-12-14         D                   14/12/2011
2010-01-01           2010-12-31         Y                   2010
===================  =================  ==================  ===========

Note that the columns with titles in italics are not visible in the output grid,
though the data is returned in the dataset so is accessible.

Standard Report Parameters
--------------------------

The standard parameters feature built into Indicia's reporting engine provides a flexible
common set of reporting parameters that can be applied to any report that runs against the
cache_occurrences_functional table or cache_samples_functional. More information is
provided in :doc:`the next section <standard-parameters>`.
