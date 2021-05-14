Custom attribute tables
=======================

Indicia is designed to allow flexible capture of wildlife records and to tolerate the fact
that wildlife surveys are often designed with specific attributes in the data, for example
it is possible to record everything from plant abundance on the DAFOR scale or to record
the chemical conditions of seawater in an oceanic sample. Clearly the database model cannot
be designed to cater for all the possible attributes in a traditional way. Instead, the
surveys, samples, occurrences, locations, taxa_taxon_lists, people and termlists_terms tables
allow allow extension with custom attributes. In the following example, you can replace
<table> with the singular name of the table you are adding a custom attribute to, e.g.
sample_attributes.

<table>_attributes
------------------

For each custom attribute, a record is created in the <table>_attributes table which
describes the global properties of the attribute, including its caption, data type and
validation rules.

Ref. :ref:`developing/data-model/tables:location_attributes`, 
:ref:`developing/data-model/tables:occurrence_attributes`,
:ref:`developing/data-model/tables:person_attributes`, 
:ref:`developing/data-model/tables:sample_attributes`, 
:ref:`developing/data-model/tables:survey_attributes`, 
:ref:`developing/data-model/tables:taxa_taxon_list_attributes`,
:ref:`developing/data-model/tables:termlists_term_attributes`

<table>_attributes_websites
---------------------------

Each custom attribute is then linked to the website/survey dataset combinations it is being
used for by a record in <table>_attributes_websites. Note that this record can specify
additional validation rules to apply to the attribute within the context of this survey
dataset, for example it is normally appropriate to set an attribute to required in some
survey datasets but not others.

Ref. :ref:`developing/data-model/tables:location_attributes_websites`, 
:ref:`developing/data-model/tables:occurrence_attributes_websites`,
:ref:`developing/data-model/tables:person_attributes_websites`, 
:ref:`developing/data-model/tables:sample_attributes_websites`, 
:ref:`developing/data-model/tables:survey_attributes_websites`, 
:ref:`developing/data-model/tables:taxon_lists_taxa_taxon_list_attributes`,
:ref:`developing/data-model/tables:termlists_termlists_term_attributes`

<table>_attribute_values
------------------------

Once a custom attribute has been created for a dataset, the captured values are stored in
the <table>_attribute_values table, which links the <table>_attributes attribute
definition to the actual record in <table>.

By means of illustration, the following query pulls out all the custom attribute values for
samples in a given survey dataset. Note the use of the coalesce() function to pull out the
first non-null value in the list of different fields used to store custom attribute values
of different data types. The int_value field is either used to store an integer number
value, or in the case of lookup attributes, points to the ID of the selected term in the
lookup:

.. code-block:: sql

  select
    s.id,
    string_agg(
      a.caption || ': ' ||
        coalesce(
          t.term,
          v.text_value,
          v.int_value::varchar,
          v.float_value::varchar,
          vague_date_to_string(v.date_start_value, v.date_end_value, v.date_type_value)
        ),
      '; ') as values
  from samples s
  join sample_attribute_values v on v.sample_id=s.id and v.deleted=false
  join sample_attributes a on a.id=v.sample_attribute_id and v.deleted=false
  left join cache_termlists_terms t on t.id=v.int_value and a.data_type='L'
  where s.survey_id=<survey_id>
  group by s.id

Some attributes will have the system_function field populated in the <table>_attributes
table. This attribute flags up attributes which have a standard meaning that the system
can recognise, for example there might be a variety of attributes which capture the
biotope associated with a sample and they can all be tagged as such. System function
attributes values for occurrences and samples are automatically added to the
cache_occurrences_nonfunctional and cache_samples_nonfunctional tables respectively with
fieldnames prefixed `attr_*`, for
example:

.. code-block:: sql

  select id, attr_biotope from cache_samples_nonfunctional

Ref. :ref:`developing/data-model/tables:location_attribute_values`, 
:ref:`developing/data-model/tables:occurrence_attribute_values`,
:ref:`developing/data-model/tables:person_attribute_values`, 
:ref:`developing/data-model/tables:sample_attribute_values`, 
:ref:`developing/data-model/tables:survey_attribute_values`, 
:ref:`developing/data-model/tables:taxa_taxon_list_attribute_values`,
:ref:`developing/data-model/tables:termlists_term_attribute_values`
  