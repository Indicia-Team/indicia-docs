
Cache tables
============

The Indicia data model is normalised, which means that data are organised in such a way as
to reduce redundancy and improve integrity. The data required for a biological  record are
split across multiple tables with relationships between the records, as opposed to a more
flat "spreadsheet" approach where there a large number of columns in a single table. This
is generally  desirable in that each item of information needs to only be stored once
rather than repeated in several places, therefore ensuring consistency. However it can make
queries more complex with multiple joins required to bring in all the tables required for
the output of a query and in some cases the additional joins required can reduce the
performance of queries. For  example, to provide the basic "what, where, when and who" of a
set of biological records from the last week's input you need  something akin to the
following SQL:

.. code-block:: sql

  select
    t.taxon, tg.title as taxon_group,
    s.entered_sref, l.name as location_name,
    s.date_start, s.date_end, s.date_type,
    who.text_value as recorder
  from occurrences o
  join samples s on s.id=o.sample_id and s.deleted=false
  left join locations l on l.id = s.location_id and l.deleted=false
  join taxa_taxon_lists ttl on ttl.id=o.taxa_taxon_list_id
    and ttl.deleted=false
  join taxa t on t.id=ttl.taxon_id and t.deleted=false
  join taxon_groups tg on tg.id=t.taxon_group_id and tg.deleted=false
  left join (sample_attribute_values who
  join sample_attributes whoa on whoa.id=who.sample_attribute_id
    and whoa.deleted=false and whoa.system_function='full name'
  ) on who.sample_id=s.id and who.deleted=false
  where o.created_on>now() - '1 week'::interval
  and t.taxon_group_id=<taxon_group_id>

In order to make queries easier to write and also performant, Indicia includes a
set of tables which "flatten" the multiple tables of key parts of the data model into
a few tables which are easy to query and, more importantly, perform well when used to
generate report outputs. Here's an alternative version of the above query:

.. code-block:: sql

  select
    cttl.taxon, cttl.taxon_group,
    snf.public_entered_sref, o.location_name,
    o.date_start, o.date_end, o.date_type,
    snf.recorders
  from cache_occurrences_functional o
  join cache_samples_nonfunctional snf on snf.id=o.sample_id
  join cache_taxa_taxon_lists cttl on cttl.id=o.taxa_taxon_list_id
  where o.created_on>now() - '1 week'::interval
  and o.taxon_group_id=<taxon_group_id>

Not only are there less joins, but an important point is that the vast majority of fields
you might want to filter on are in the `cache_occurrences_functional` table. Filtering
in a single table then joining extra tables for addition of the information required for
output fields is much faster than filtering in different tables in PostgreSQL.

The cache_* tables available in the database are described below.

cache_occurrences_functional
----------------------------

This table contains all the fields which have a common functional use in building reports
that output occurrence data. This means it includes fields that are used for filtering,
sorting and grouping the report output rather than the labels which are typically output
in the report columns displayed to the user.

Hierarchical taxonomic queries are supported by the ``taxon_path`` field which contains an array
of ``taxon_meaning_ids`` for the taxon and all its taxonomic parents. E.g. to query for all mammal
data, find the ``taxon_meaning_id`` for Mammalia on your warehouse's master list, then use an SQL
where clause as follows:

.. code-block:: sql

  WHERE taxon_path && ARRAY[*taxon_meaning_id*]


.. note::

  By keeping all the commonly filtered, sorted and grouped columns in a single table, the
  PostgreSQL query optimiser is able to effectively perform all the processing on a single
  table then join in other columns to obtain output values for display as a last step. This
  is much more efficient than filtering 2 separate tables then joining to obtain the
  intersection. For example, a query that shows all taxa in the 'insects - beetles' group
  for the Dorset vice county should first obtain the IDs matching the 'insects - beetles'
  taxon group and the Dorset location, then select data from cache_occurrences_functional
  filtering on taxon_group_id and location_id_vice_county within the same table. This is
  MUCH more efficient than joining to the taxon_groups and locations tables to filter
  within those tables.

Ref. :ref:`table_cache_occurrences_functional`

cache_occurrences_nonfunctional
-------------------------------

Contains additional values for each record which are frequently useful to construct the
display output of a record but rarely used in filtering, grouping or sorting of the report
output.

Custom occurrence attribute values can be obtained from the `attrs_json` field which is an object
keyed by attribute ID. This saves joins to ``occurrence_attribute_values`` and
``cache_termlists_terms`` in order to get attribute values in query results.

Ref. :ref:`table_cache_occurrences_nonfunctional`

cache_samples_functional
------------------------

Similar to the cache_occurrences_functional, contains the commonly filtered, sorted and
grouped values for a sample. Note that when querying occurrences this table is unnecessary
since all the values are duplicated in cache_occurrences_functional (for the performance
reasons described above). It is only necessary to use this table when querying a list
of samples.

Ref. :ref:`table_cache_samples_functional`

cache_samples_nonfunctional
---------------------------

Contains additional values for each sample which are frequently useful to construct the
display output of a sample or the sample elements of a record but rarely used in filtering,
grouping or sorting of the report output.

Custom sample attribute values can be obtained from the ``attrs_json`` field which is an object
keyed by attribute ID. This saves joins to ``sample_attribute_values`` and
``cache_termlists_terms`` in order to get attribute values in query results.

Ref. :ref:`table_cache_samples_nonfunctional`

cache_taxa_taxon_lists
----------------------

Contains values pertaining to a single taxon name, for example you can find the used name,
the preferred name for the taxon as well as the default common name, kingdom, order and
family.

Ref. :ref:`table_cache_taxa_taxon_lists`

cache_taxon_searchterms
-----------------------

A table containing all variants and codes that can be used to lookup a taxon in a single
indexed list.

The following example shows how the cache_* tables can be joined to include all the cached
data relevant to a record. Note that in most cases you won't need to include all the
tables here, just the cache_occurrences_functional table plus any others required in the
output:

.. code-block:: sql

  select
  o.id,
  onf.licence_code,
  snf.public_entered_sref,
  vague_date_to_string(o.date_start, o.date_end, o.date_type),
  cttl.taxon,
  cttl.preferred_taxon as accepted_name,
  cttl.default_common_name as common_name,
  cttl.family_taxon,
  cttl.order_taxon
  from cache_occurrences_functional o
  join cache_occurrences_nonfunctional onf on onf.id=o.id
  join cache_samples_nonfunctional snf on snf.id=o.sample_id
  join cache_taxa_taxon_lists cttl on cttl.id=o.taxa_taxon_list_id
  where o.taxon_group_id=1
  and o.website_id=2
  and o.survey_id=3

.. tip::

  Because of the way the indexing works on cache_occurrences_functional, if you want to
  filter on a survey_id to restrict the output to a single dataset, also include a filter
  on the website_id as shown in the query above. This allows a compound index to work so
  is much more efficient.

Ref. :ref:`table_cache_taxon_searchterms`
