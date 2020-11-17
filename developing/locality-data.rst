*************
Locality data
*************

Spatial references and geometry data
====================================

Indicia's data model has flexible support for spatial data so it's worth taking a look at
how it works. At the very minimum, a record is input into a website or app with a map
reference of some form, e.g. a GPS coordinate or a grid reference. In order to understand
this, Indicia needs to also know what format and projection the map reference is being
provided in. The map reference is stored in the `samples.entered_sref` field as input by
the recorder and the `samples.entered_sref_system` describes the format and projection
used. The system can be one of the following:

  * A numeric EPSG code. The European Petroleum Survey Group publish a registry of
    coordinate reference systems and are a widely accepted standard. For example, code
    4326 is the code for WGS84 (i.e. GPS latitude and longitude).
  * A map format code recognised by the Indicia warehouse, e.g. OSGB is used to denote
    Ordnance Survey British National Grid notation. This determines how the notation will
    be parsed to locate the record on a map and in itself the notation implies the
    underlying map projection.

Indicia understands that latitude and longitude values are entered in a different way to
other, typical "x, y" coordinate systems.

Indicia also parses the input map references and creates a spatial object to store in the
database `samples.geom` field. The geometry can either be a point or a polygon and is
transformed to EPSG:3857 (sometimes referred to as EPSG:900913 or Web Mercator) because
in this form objects can be drawn over most web mapping services such as Google Map layers
without further transformation. Once stored as a proper spatial object, it becomes possible
to use the PostGIS extensions for PostgreSQL to use spatial functions in our SQL statements
which we'll cover below. When storing the map data for a location rather than for a record,
the `locations` table has a centroid_sref and centroid_sref_system to store the map
reference text data, plus centroid_geom and boundary_geom to store the geometry data for
the site centr and boundary respectively.

In addition to the fields described above in the "core" data model, the following fields
are provided in the reporting cache tables for convenience when building reporting queries:

cache_occurrences_functional.public_geom
----------------------------------------

This field is the reporting cache version of `samples.geom`. The only difference is it is
automatically blurred to allow for sensitivity or privacy of the record.


cache_samples_nonfunctional public_entered_sref & entered_sref_system
---------------------------------------------------------------------

The cache table version of these fields is identical to the version in the samples table
except that for sensitive records or records where site privacy is a concern, the
`public_entered_sref` is nulled so it is safe to show to public users.

cache_occurrences_functional output_sref
----------------------------------------

This field creates a standardised spatial reference string for reporting purposes. The
string is forced to output as British National Grid or Irish Grid format for references
in Great Britain or Ireland respectively. Currently all other locations are output as
latitude and longitude but support could be added for other grid systems as required. The
`output_sref` is also always blurred to take account of sensitivity or privacy blurs or
the accuracy of a record's grid reference or point reference.

map_squares table
-----------------

The primary purpose of this table is to facilitate reporting on grid square data.
The map squares table is populated with a list of all 1km, 2km and 10km grid squares in
use for all records in the samples table. This includes grid squares which encapsulate
point based records (e.g. GPS lat long) so they can be easily drawn on a 1km map for
example. The grid squares are generated using Indicia's best understanding of the local
preferred grid system, e.g. OSGB over Great Britain or OSIE over Ireland.

The square IDs are linked to the `map_sq_<size>km_id` fields in both
`cache_occurrences_functional` and `cache_samples_functional`, where <size> is 1, 2 or
10 for ease of use when reporting.

The `map_squares` table's fields includes the following information:

  * `geom` - the geometry of the square.
  * `x` - x coordinate of the centroid of the square in Web Mercator projection.
  * `y` - y coordinate of the centroid of the square in Web Mercator projection.
  * `size` - size of the square in metres.

Place names
===========

samples location_name
---------------------

For records where a free text site or other location name has been provided, the name as
entered is provided in the `sample.location_name` field.

cache_occurrences_functional location_name
------------------------------------------

For ease of reporting, this field provides either the free text site or other location
name given for a record, or the name of the predefined location linked to the record. It
is automatically obscured if the record is sensitive or private.

Spatial query support
---------------------

Indicia's database is spatially enabled, which means that it has an understanding of the
shape data it contains and can perform functions such as near, distance, intersections etc.
Geometry fields are stored in the database using an internal binary format. In order to
make the field format usable by humans you can use the built in PostGIS functions
st_geomfromtext and st_astext, e.g.

.. code-block:: sql

  -- read the boundary_geom of a location in Well Known Text format
  select st_astext(boundary_geom) from locations where id=123;

  -- Create a geometry using a Well Known Text format point string in EPSG:27700 (OSGB
  -- Easting and Northing 1936), then transform it to web_mercator (EPSG:900913) and assign
  -- it to a location boundary.
  update locations
  set boundary_geom=st_transform(
    st_geomfromtext('POINT(461680 189630)', 27700),
    900913
  )
  where id=123;

These functions both work with the Well Known Text format for describing geometry objects.

.. tip::

  You'll often see the st_transform function in Indicia spatial queries. The geometry
  objects are stored internally in web mercator (EPSG:900913) which is compatible with most
  common web mapping providers such as Google, thus avoiding transformations when drawing
  map layers in most situations. However users will often use local coordinate systems
  like OSGB 1936 easting and northings which will need to be transformed if you want to get
  the correct results.

As another example, you could also use the st_intersects function to find occurrences which
intersect a point or polygon:

.. code-block:: sql

  -- Find all occurrences within a 10km buffer of a known point.
  select o.id,
    vague_date_to_string(o.date_start, o.date_end, o.date_type) as date,
    snf.public_entered_sref,
    cttl.preferred_taxon,
    cttl.default_common_name
  from cache_occurrences_functional o
  join cache_samples_nonfunctional snf on snf.id=o.sample_id
  join cache_taxa_taxon_lists cttl on cttl.id=o.taxa_taxon_list_id
  where st_intersects(
    o.public_geom,
    st_transform(
      st_buffer(
        st_geomfromtext('POINT(461680 189630)', 27700),
        10000
      ),
      900913
    )
  )
  and o.website_id=<website_id>;
