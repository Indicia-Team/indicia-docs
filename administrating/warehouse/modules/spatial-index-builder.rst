Spatial Index Builder Module
----------------------------

When running spatial queries, although PostGIS can support indexes on spatial data and
is highly optimised, sometimes the query can be just too complex for live use. An example
might be a query which returns a list of UK vice county sites plus a count of the records
that fall within them - this query requires each record in the database to be tested
against each vice county boundary. As these boundaries are very complex, testing a single
record might be very fast but when scaled up to the entire dataset this query is just
too complex to run on a live server.

The Spatial Index Builder module uses the Work Queue to create tasks for all inserted
and updated samples and locations. It then runs a spatial query to look for intersections
between sample and location polygons and then stores the results of the query in the
`cache_samples_functional.location_ids` and `cache_occurrences_functional.location_ids`
fields, both of which hold arrays of integers. Once this "hard link" is created, the
data linked to a location can be located using the @> or && PostgreSQL operators, e.g.

.. code-block: sql

  -- Find records for location where id=123.
  SELECT * FROM cache_occurrences_functional
  WHERE location_ids @> ARRAY[123];

This is much faster than repeating the spatial query each time a report query is run.

The module can be restricted to only indexing certain location types by the use of a
configuration setting, described below. It also allows indexing to automatically include
the parents of any found location, e.g. you can index against a layer of counties and
automatically include the links to the associated countries, which saves time during the
background task processing.

Installation notes
^^^^^^^^^^^^^^^^^^

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
       'National Nature Reserves',
     );
     ?>

#. If you have an indexed layer (e.g. National Parks) where the location records have the
   `parent_id` field set to point to a parent location such as a country, then you can
   specify the `hierarchical_location_types` configuration to include these parent
   locations in the indexed data. E.g.

   .. code-block:: php

     <?php
     $config['hierarchical_location_types']=array(
       'National Parks',
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
