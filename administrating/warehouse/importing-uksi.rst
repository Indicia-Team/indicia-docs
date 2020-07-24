Importing the UK Species Index into an Indicia list
===================================================

This page describes one technique for importing the UK Species Index data into an
Indicia species list ready for recording. You can of course use the CSV import facility
to do this, but by using the process described on this page you will be able to re-run
the update at a later date to just update the changes into your Indicia list.

There are 2 starting points for this process depending on whether you are going to
generate a fresh export of data from the UKSI Microsoft Access database or use the extract
provided for you the last time the sync tool was updated. The process is complex so it
would be wise to backup your warehouse database first and to plan to do the task when the
warehouse is not under high load or being used for anything important such as a
demonstration.

The GitHub repository for the synchronisation process (https://github.com/Indicia-Team/support_files/tree/master/UKSI)
contains the text files extracted from the UKSI Microsoft Access database the last time
the process was run. You can either use the copies in this repository, or read the notes
in the following section if you need to generate a fresh copy of the UKSI data.

Starting with the Microsoft Access database
-------------------------------------------

You should have been provided with the original UKSI Microsoft Access database, as
"curated" by London Natural History Museum.

To export the data into a text file format ready for the import, create the following
queries in your database. To add each query in Microsoft Access, first, create the query
in Design View by following these steps:

* Go to the Create tab on the ribbon, then click the Query Design button.
* Close the Show Table dialog.
* Use the Views toolbutton to change to SQL View.
* Then paste the query in and save the query with the appropriate title.
* Repeat until all 9 queries are created.

**Query 1 - title=all_designation_kinds**

This query gets the list of terms used to populate the categories of taxon designations.

.. code-block:: sql

  SELECT TAXON_DESIGNATION_TYPE_KIND.TAXON_DESIGNATION_TYPE_KIND_KEY,
  TAXON_DESIGNATION_TYPE_KIND.KIND
  FROM TAXON_DESIGNATION_TYPE_KIND;

**Query 2 - title=all_names**

This query gets all taxon names, excluding those which are explicitly marked as redundant
or deleted. Contains basic name data and a link to the preferred name.

.. code-block:: sql

  SELECT NAMESERVER.RECOMMENDED_TAXON_VERSION_KEY, NAMESERVER.INPUT_TAXON_VERSION_KEY,
  TAXON.ITEM_NAME, TAXON.AUTHORITY, NAMESERVER.TAXON_VERSION_FORM, NAMESERVER.TAXON_VERSION_STATUS,
  NAMESERVER.TAXON_TYPE, TAXON.LANGUAGE, TAXON_VERSION.OUTPUT_GROUP_KEY, TAXON_RANK.LONG_NAME,
  TAXON_VERSION.ATTRIBUTE, TAXON_RANK.SHORT_NAME
  FROM ((TAXON
  INNER JOIN (NAMESERVER
  INNER JOIN TAXON_VERSION ON NAMESERVER.INPUT_TAXON_VERSION_KEY = TAXON_VERSION.TAXON_VERSION_KEY)
  ON TAXON.TAXON_KEY = TAXON_VERSION.TAXON_KEY)
  INNER JOIN ORGANISM_MASTER ON NAMESERVER.RECOMMENDED_TAXON_VERSION_KEY = ORGANISM_MASTER.TAXON_VERSION_KEY)
  INNER JOIN TAXON_RANK ON TAXON_VERSION.TAXON_RANK_KEY = TAXON_RANK.TAXON_RANK_KEY
  WHERE NAMESERVER.DELETED_DATE Is Null
  AND ORGANISM_MASTER.DELETED_DATE Is Null
  AND ORGANISM_MASTER.REDUNDANT_FLAG Is Null
  AND TAXON_VERSION.DELETED_DATE Is Null;

**Query 3 - title=preferred_names**

This query gets a list of the preferred taxon names, excluding those which are explicitly
marked as redundant or deleted.

.. todo::

  Sort code (from taxon list item, recorder 3.3 list?)

.. code-block:: sql

  SELECT DISTINCT ORGANISM_MASTER.ORGANISM_KEY, ORGANISM_MASTER.TAXON_VERSION_KEY, TAXON.ITEM_NAME,
  TAXON.AUTHORITY, ORGANISM_MASTER.PARENT_TVK, ORGANISM_MASTER.PARENT_KEY, TAXON_VERSION.TAXON_RANK_KEY,
  TAXON_RANK.SEQUENCE, TAXON_RANK.LONG_NAME, TAXON_RANK.SHORT_NAME, ORGANISM_MASTER.MARINE_FLAG,
  ORGANISM_MASTER.TERRESTRIAL_FRESHWATER_FLAG AS TERRESTRIAL_FLAG,
  ORGANISM_MASTER.FRESHWATER AS FRESHWATER_FLAG, ORGANISM_MASTER.NON_NATIVE_FLAG, NULL AS SORT_CODE
  FROM (((TAXON_LIST_ITEM
  INNER JOIN (TAXON
  INNER JOIN (TAXON_VERSION
  INNER JOIN (ORGANISM_MASTER
  INNER JOIN NAMESERVER ON NAMESERVER.INPUT_TAXON_VERSION_KEY=ORGANISM_MASTER.TAXON_VERSION_KEY)
  ON TAXON_VERSION.TAXON_VERSION_KEY=ORGANISM_MASTER.TAXON_VERSION_KEY)
  ON TAXON.TAXON_KEY=TAXON_VERSION.TAXON_KEY)
  ON TAXON_LIST_ITEM.TAXON_VERSION_KEY=TAXON_VERSION.TAXON_VERSION_KEY)
  INNER JOIN TAXON_LIST_VERSION ON TAXON_LIST_ITEM.TAXON_LIST_VERSION_KEY=TAXON_LIST_VERSION.TAXON_LIST_VERSION_KEY)
  INNER JOIN TAXON_LIST ON TAXON_LIST_VERSION.TAXON_LIST_KEY=TAXON_LIST.TAXON_LIST_KEY)
  INNER JOIN TAXON_RANK ON TAXON_VERSION.TAXON_RANK_KEY=TAXON_RANK.TAXON_RANK_KEY
  WHERE NAMESERVER.DELETED_DATE Is Null
  And ORGANISM_MASTER.REDUNDANT_FLAG Is Null
  And ORGANISM_MASTER.DELETED_DATE Is Null
  And TAXON_VERSION.DELETED_DATE Is Null;

**Query 4 - title=taxa_taxon_designations**

Retrieves a list of the links between all taxon names and their designations.

.. code-block:: sql

  SELECT TAXON_DESIGNATION_TYPE.SHORT_NAME, TAXON_DESIGNATION.DATE_FROM, TAXON_DESIGNATION.DATE_TO,
  TAXON_DESIGNATION.STATUS_GEOGRAPHIC_AREA, TAXON_DESIGNATION.DETAIL, NAMESERVER.RECOMMENDED_TAXON_VERSION_KEY
  FROM (TAXON_LIST_ITEM
  INNER JOIN (TAXON_DESIGNATION
  INNER JOIN TAXON_DESIGNATION_TYPE ON TAXON_DESIGNATION.TAXON_DESIGNATION_TYPE_KEY =
      TAXON_DESIGNATION_TYPE.TAXON_DESIGNATION_TYPE_KEY)
  ON TAXON_LIST_ITEM.TAXON_LIST_ITEM_KEY = TAXON_DESIGNATION.TAXON_LIST_ITEM_KEY)
  INNER JOIN NAMESERVER ON TAXON_LIST_ITEM.TAXON_VERSION_KEY = NAMESERVER.INPUT_TAXON_VERSION_KEY;

**Query 5 - title=taxon_designations**

Retrieves a list of all the available taxon designations that can be linked to taxon
concepts.

.. code-block:: sql

  SELECT TAXON_DESIGNATION_TYPE.TAXON_DESIGNATION_TYPE_KEY, TAXON_DESIGNATION_TYPE.SHORT_NAME,
  TAXON_DESIGNATION_TYPE.LONG_NAME, TAXON_DESIGNATION_TYPE.DESCRIPTION, TAXON_DESIGNATION_TYPE.KIND,
  TAXON_DESIGNATION_TYPE.Status_Abbreviation
  FROM TAXON_DESIGNATION_TYPE;

**Query 6 - title=taxon_groups**

Retrieves a list of all the taxon groups (reporting categories).

.. code-block:: sql

  SELECT DISTINCT tg.taxon_group_key, tg.taxon_group_name,
  IIf(tg.input_level2_descriptor Is Null, tg.input_level1_descriptor, tg.input_level2_descriptor) AS description,
  tg.parent
  FROM (taxon_group_name AS tg LEFT JOIN taxon_group_name AS tg2 ON tg2.parent=tg.taxon_group_key)
  LEFT JOIN taxon_version AS tv ON tv.output_group_key=tg.taxon_group_key
  WHERE tg2.taxon_group_key IS NOT NULL OR tv.taxon_version_key IS NOT NULL;

**Query 7 - title=taxon_ranks**

Retrieves a list of all possible taxon ranks, e.g. Phylum, Family, Species.

.. code-block:: sql

  SELECT TAXON_RANK.SEQUENCE, TAXON_RANK.SHORT_NAME, TAXON_RANK.LONG_NAME, TAXON_RANK.LIST_FONT_ITALIC
  FROM TAXON_RANK;

**Query 8 - title=tcn_duplicates**

Where there are multiple common names and it is otherwise not possible to pick a single
default one to use in reports, this table provides a link from the organims to a taxon
record containing a common name to use.

.. code-block:: sql

  SELECT ORGANISM_MASTER.ORGANISM_KEY, TCN_DUPLICATE_FIX.TAXON_VERSION_KEY
  FROM ORGANISM_MASTER
  INNER JOIN (TAXON_LIST_ITEM
  INNER JOIN TCN_DUPLICATE_FIX ON TAXON_LIST_ITEM.TAXON_LIST_ITEM_KEY = TCN_DUPLICATE_FIX.TAXON_LIST_ITEM_KEY)
  ON ORGANISM_MASTER.TAXON_VERSION_KEY = TAXON_LIST_ITEM.TAXON_VERSION_KEY;

**Query 9 - title=all_taxon_version_keys**

Retrieves a list of all taxon version keys and the associated recommended key, including
deleted and redundant names. Can be used to work out the context of any names which have
now been removed from the online recording copy of UKSI.

.. code-block:: sql

  SELECT INPUT_TAXON_VERSION_KEY, RECOMMENDED_TAXON_VERSION_KEY
  FROM NAMESERVER;

The next step is to export the query results for each of the 9 queries as a text file.
Prepare a folder on your hard disk into which you will export the files (I used
``c:\tmp``). These instructions are for Microsoft Access 2007 but the steps should be
similar for other versions. For each query:

#. Select the **External Data** ribbon tab.
#. Under **Export**, choose the **Text File** option.
#. Set the file name to export to in the folder you prepared earlier. The file name should be the query title with a ``.txt``
   extension, e.g. ``all_names.txt``.
#. Click OK.
#. On the **Export Text Wizard** select the **Delimited** text option then click Next.
#. Set the delimiter to **Comma** and the **Text Qualifier** to a double quote character. Click Next.
#. Click Finish to export the file.

Now that you have exported the files, follow through the steps in the next section
"Starting with the exported text files" to complete the import. You will need to replace
the files obtained with the UKSI sync tool with the files you have generated.

Starting with the exported text files
-------------------------------------

#. If you don't already have a species list on the warehouse ready to import the taxa
   into, then create one now. You can use the normal Warehouse user interface to do this
   (Taxonomy > Species lists).
   Make a note of the ID of the list.
#. As the UKSI data is structurally complex you need to add a number of extension
   modules to add the necessary tables. To do this:

   #. Find the file ``application/config/config.php`` in your warehouse installation
      folder and open it in a text editor.
   #. Find the list of modules at the bottom of the page.
   #. Add an entry for several modules by adding the following lines into the
      list:

    .. code-block:: php

        MODPATH.'taxon_designations',
        MODPATH.'taxon_associations',
        MODPATH.'species_alerts',
        MODPATH.'data_cleaner_without_polygon',
        MODPATH.'data_cleaner_period_within_year'

   #. Log into your warehouse and visit the ``index.php/home/upgrade`` page to ensure that
      database upgrade scripts are run.

#. Grab a copy of the files from https://github.com/Indicia-Team/support_files/tree/master/UKSI
   and follow the instructions in readme file. If you generated your own copy of the files
   from the Access database make sure you replace the downloaded copies with your
   versions. You will have to supply a user ID when you run the scripts (as described in
   the readme file). Look in the users table of your indicia schema to get the id. If you
   use the id of your main admin account the number is likely to be 1.

