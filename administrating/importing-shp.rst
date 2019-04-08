*****************************
Importing Location Boundaries
*****************************

The Indicia Warehouse allows you to upload a list of locations from an ESRI Shape File (.shp) which is a widely available GIS file 
format. This includes setting the boundaries of those locations and it can either create new locations or update existing ones.

Import Steps
============

1. First you need a suitable SHP file. The SHP file must contain a list of objects to be imported as locations in Indicia, as well as at least one attribute for the name of each location. You will therefore have a file called _myfile_.shp and also a file called _myfile_.dbf containing the attribute values.
2. Zip these 2 files into a single zip file with the same name, ready for upload.
3. Log into the Warehouse.
4. Select Lookup Lists > Locations from the menu.
5. Click the Browse button next to the input at the bottom called "Upload a Zipped up SHP fileset into this list" and select your _myfile_.zip file. Click the Upload Zip File button.
6. On the next page are various options for specifying how the upload is handled. You can choose the following things:

    a. Whether to import the polygon into the location's centroid or boundary geometry.
    b. Whether the locations have a parent location.
    c. Which spatial reference projection is used in the SHP file (SRID). 
    d. Which website the locations are being imported for.
    e. A prefix for the name field.
    f. Which field in the list of attributes is to be used to obtain the location's name, and which is used for the location's parent if the list of objects is hierarchical.

Note, if there are existing locations with the same name and website, then they are updated rather than new locations created.

When you are ready to import, click the Upload Data button.

Indexing Locations
==================

If you have the spatial index builder enabled then, when a location is
added which is of a type that is indexed,  samples will be checked to see
if they fall within the new location. You may be uploading a  location of
a new type in which case you need to create a term for that type in the
'location types' term list first and add the location type to the configuration
file for the spatial index builder 
(modules\\spatial_index_builder\\config\\spatial_index_builder.php).
If you do the config first, then upload the locations, they should 
get indexed next time the scheduled tasks run. There is a risk though 
that when you do this the index building code will choke if you 
add a lot of locations in one go. If you upload the locations, 
hen add the configuration, the index building code will only index any
new locations added, so you will need to run a one-off query to fill in
the missing index entries. This will be exactly the same query that the
index builder would have run, but  running it manually makes sense as you
can monitor it more easily, it won’t timeout and if it appears too slow you
could always break it up into chunks (e.g. locations beginning a..., then b... to z...). 

Therefore, additional step for indexing might be 

1. Create a term in the 'location types' term list.
2. Upload the locations using this location type (no indexing).
3. Run st_isvalid(boundary_geom) and st_isvalidreason(boundary_geom) on all the new locations to check there are no boundary anomalies. If so, run st_makevalid() to fix them and check that it works. If you find problems then they should be resolved before proceeding.
4. Run some test queries using some of the more complex locations (e.g. by copying queries from the log and changing the location ID). Check they work and perform OK.
5. If OK, then add the location type to the index builder’s config file and also run a one-off query to populate the spatial index table for the new locations.
