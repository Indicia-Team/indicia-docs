Controlling the column output
-----------------------------

Columns are defined by creating an element in the XML document called
``<columns>`` at the same level as the ``<query>`` element. This contains
optional definitions of each column in the report in ``<column>`` sub-elements
with the attributes of each column definition defining which database field it
links to as well as the output behaviour. Therefore the structure might look
like:

.. code-block:: xml

  <?xml version="1.0" encoding="UTF-8"?>
  <report title="Tutorial"
      description="Display some records for the report writing tutorial">
    <query>
    ...
    </query>
    <columns>
      <column attr="value" />
      <column attr="value" />
      <column attr="value" />
    </columns>
  </report>

The first thing we are going to do with the columns is to add a new column for  the ID of
the record, but to then hide it from the default grid output leaving  the id available for
code to use but not for the user to see. For example we  might want to add a link to the
rows in the table which is to a page which  accept's the ID as a URL parameter and displays
some information about that  record. First, edit the SQL to include the column called
``o.id`` at the start of  the list of columns (using the o prefix to ensure that the id
column is accessed from the correct table). Then, create a ``<columns>`` section in your
report file after the closing ``</query>`` with a single ``<column>`` as follows:

.. code-block:: xml

  <columns>
    <column name="id" visible="false" />
  </columns>

Save your report file and reload the report in the warehouse. You shouldn't
notice any difference at this stage because the id field has been set to
``visible="false"`` but this field is available for use in the various
configuration and templating options available in the report grid.

Now, add 3 new columns to your report for the other 3 standard columns
(excluding date which already has a proper caption), using the **caption**
attribute of the column definition to set their captions to **Grid ref**,
**Species** and **Common name** respectively. Your report file should look like
this:

.. code-block:: xml

  <?xml version="1.0" encoding="UTF-8"?>
  <report title="Tutorial"
        description="Display some records for the report writing tutorial">
    <query>
      select o.id, snf.public_entered_sref, cttl.preferred_taxon, cttl.default_common_name,
            o.date_start, o.date_end, o.date_type
      from cache_occurrences_functional o
      join cache_samples_nonfunctional snf on snf.id=o.sample_Id
      join cache_taxa_taxon_lists cttl on cttl.id=o.taxa_taxon_list_id
      where o.created_on&gt;now()-'1 month'::interval
    </query>
    <columns>
      <column name="id" visible="false" />
      <column name="public_entered_sref" display="Grid ref" />
      <column name="preferred_taxon" display="Species" />
      <column name="default_common_name" display="Common name" />
    </columns>
  </report>

Reload the report to check that the column titles have been updated.
