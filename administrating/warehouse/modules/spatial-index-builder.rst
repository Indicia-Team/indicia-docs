Spatial Index Builder Module
----------------------------

When running spatial queries, although PostGIS can support indexes on spatial data and
is highly optimised, sometimes the query can be just too complex for live use. An example
might be a query which returns a list of UK vice county sites plus a count of the records
that fall within them - this query requires each record in the database to be tested
against each vice county boundary. As these boundaries are very complex, testing a single
record might be very fast but when scaled up to the entire dataset this query is just
too complex to run on a live server.

The Spatial Index Builder module introduces a new table to the data model that keeps a
"hard link" between samples and locations. This link is created using the scheduled_tasks
process in the background, so although it is not created immediately a new record is input
it has little effect on performance and is ideal for this sort of summary reporting. Also
note that the link only needs to be created once per sample so you are not asking the
web server to repeatedly re-perform the same intensive spatial querying tasks. The module
creates links to the samples rather than the occurrences table since this results
in a smaller index table and it is a simple one step join from samples to occurrences
anyway.

The module can be restricted to only indexing certain location types by the use of a
configuration setting, described below.

Report Support
^^^^^^^^^^^^^^

The Spatial Index Builder module is required if you plan to use any of the following
reports:

* ``library/occurrences/explore_list_using_spatial_index_builder.xml`` - used to filter
  the explore output to the user's locality set in their preferences.
* ``library/occurrence_images/explore_list_using_spatial_index_builder.xml`` - used to
  filter the explore output to the user's locality set in their preferences.
* ``library/occurrences/nbn_exchange.xml`` - used to attach a Vice County to the NBN
  Exchange Format download, therefore the location type **Vice County** must be one of the
  indexed location types.
* ``library/locations/occurrence_counts_mappable_summary.xml`` - used to increase
  performance of report output when grouped by locations.
* ``library/locations/species_counts_mappable_summary.xml`` - used to increase
  performance of report output when grouped by locations.

Database notes
^^^^^^^^^^^^^^

This module adds the following to the database:

* A table called **index_locations_samples** which joins between samples and locations.

Installation notes
^^^^^^^^^^^^^^^^^^

#. Once the module is enabled, log into the warehouse and visit ``index.php/home/upgrade``
   in order to install the new database tables.
#. You must ensure that the :doc:`../scheduled-tasks` are configured for the warehouse.
#. If you want to limit the location types that are indexed, then you must duplicate the
   file ``modules/spatial-index-builder/config/spatial_index_builder.php.example`` and
   call the duplicated file ``spatial_index_builder.php``. Now edit the file using a text
   editor and ensure the configuration array contains the list of location type terms
   you want to include, noting that it is case sensitive. For example you might index
   national parks and national nature reserves with the following settings:

   .. code-block:: php

     <?php
     $config['location_types']=array(
       'National Parks',
       'National Nature Reserves'
     );
     ?>

#. You can further restrict the indexing for a given location type to records captured from
   a particular survey dataset or list of survey dataset. To do this, you need to add a
   second configuration item to the config file called ``survey_restrictions``. This must
   use the location type term as the key and the value of the array should be an array of
   survey IDs. You can omit this configuration item if not required, or only list the location
   types which are restricted by survey. For example, if the indexing of the National Parks
   location boundaries is only relevant to survey datasets with IDs 14 and 15, then you can
   add this configuration:

   .. code-block:: php

     <?php
     $config['survey_restrictions']=array(
       'National Parks' => array(14,15)
     );

     ?>
