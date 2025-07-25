Importing the UK Species Index into an Indicia list - incremental updates
=========================================================================

If you already have a copy of UKSI installed into your database, then it is possible to update it
using the entries in UKSI's UKSI_History table which can be more efficient and easier to debug than
a complete re-synchronisation. See :doc:`importing-uksi` for information on performing a full
synchronisation.

1. If this is the first time that the incremental updates have been run, or the last update was
   done by processing a full UKSI synchronisation, then find the highest Processed_Date from the
   UKSI_History table in the last UKSI Access database that has already been synchronised (not the
   new one you are updating to). If the last update was done using the incremental update system,
   then find the max Batch_Processed_On value from UKSI_operations table (Taxonomy > UKSI
   Operations menu item on the warehouse).
2. In Access, use an SQL query to select everything from the UKSI_History table, sorted by ID, and
   filtered so that only those records with Processed_Date > the date found in the last step are included.
   Export the data from the query to a CSV file using the Text file tool on the Export section of
   Access's External data ribbon tab. Ensure you set the delimited to ',' and the string quote
   character to '"'. Click the Advanced button and ensure that the Unicode (utf-8) code page is
   selected. Also ensure the option to include column names on the first row is ticked.
3. Import the CSV file into the UKSI_operations table on the warehouse using the import tool on the
   Taxonomy > UKSI Operations page. As long as you haven't changed the column names in the CSV file
   the default mappings suggested by the import tool should be correct.
4. Run the following query in pgAdmin on the warehouse and keep a copy of the results. This allows
   us to later "rewind" Logstash to ensure that all records are re-indexed using the latest UKSI
   operation results.

   ```sql
   select name, value from variables where name like 'rest-autofeed-BRC%' and name not like '%DEL'
   ```

5. Click the **Process all operations** button on the warehouse UKSI Operations page and wait till
   the operations have all processed.
6. Follow the steps required to recreate the taxa.yml and taxon-paths.yml files and place them on
   the Elasticsearch server (see
   https://github.com/Indicia-Team/support_files/blob/master/Elasticsearch/docs/occurrences.md#prepare-the-lookups-for-taxon-data).
   The files should be placed in the `D:\elastic\indicia_support_files\Elasticsearch\data` folder,
   replacing the existing files.
7. For each variable whose value was captured in point 4, update the variable to its original
   value by running an SQL statement similar to the following:

   ```sql
   UPDATE variables SET value='[{""mode"":""updates"",""last_tracking_id"":""517250851""}]'
   WHERE name='rest-autofeed-BRC5'
   ```

   Also search for and delete all files in application/cache where the filename contains
   "variable-rest-autofeed-BRC", to ensure the old values are not cached. This ensures that the
   Logstash process re-indexes all data changes tracked since the start of the process with the
   latest UKSI species data. Note that Logstash should automatically re-index all taxa with
   alterations, as when the operations are processed the warehouse ORM object layer triggers the
   relevant work queue entries.
8. Where preferred names may have changed, we may need to update the data now linked to the synonym
   so it points to the new preferred name. This includes data for taxon attribute values,
   associations, designations and verification rules. To update the links, run the following SQL
   statment::

     select f_fixup_uksi_links();

   Also run the following if the data_cleaner warehouse module is installed::

     select f_fixup_uksi_links_data_cleaner();

9. Regenerated the Pantheon species index table by running the following SQL statement::

     select pantheon.f_pantheon_rebuild_species_index();

10. Provide details on the changes to the NatureSpot team - see the comment at the top of the
    following script:
    https://github.com/Indicia-Team/support_files/blob/master/UKSI/scripts/Naturespot%20update.sql.

