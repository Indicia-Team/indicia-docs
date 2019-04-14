********************
Setting up GeoServer
********************

Indicia uses the PostGIS spatial database to store occurrence and site geospatial data.
This makes it relatively simple to use the data in mapping applications or to perform
spatial queries (e.g. tell me all the designated species occurrences within 100m of a
site). Whilst Indicia exposes the spatial data via its own data services making it
relatively easy for "Indicia Aware" applications to use the data, other spatial
applications do not understand the format. There are a number of standards for exchanging
and querying spatial data over the web, provided by the `Open Geospatial Consortium
<http://www.opengeospatial.org/>`_. 

GeoServer is a web-server application which connects
spatial data in a variety of formats to the web, by supporting the OGC standards.
Fortunately GeoServer has built in support for PostGIS data. This makes it easy to link
Indicia data to GIS applications, Google Earth or other similar maps.

Installation
============

There's a guide to installing GeoServer `here
<https://docs.geoserver.org/stable/en/user/installation/>`_, and links to more detailed
information if you have specific requirements as to how you wish to install it, e.g.
for different operating systems.

Note that before you can install GeoServer, you
will need to make sure that you have the Javascript Runtime Environment (JRE) installed
on the computer. 

The rest
of this document assumes you have access to a working GeoServer installation and are able
to login to the GeoServer administrative interface (e.g. at http:localhost:8080/geoserver).

This documentation applies to GeoServer 2.

Configuration for Indicia
=========================

The task is to set up a data source in Geoserver which can then be displayed in an online
mapping interface (or desktop GIS) via WMS or WFS web services. When your data is set up 
Geoserver gives you the opportunity to preview it directly in OpenLayers or export it to a
variety of formats (including KML for display in Google Earth), Shapefile and common image
formats (JPEG, PNG).

Data in Geoserver is organised hierachically. At the top level is a **Workspace**. This
"contains" one or more **Sources**, which in turn contain a **Layer** or layers. The
layers can be displayed using custom **Styles**. For our purpose here, the Source will
correspond to our Indicia database, and the Layer to the **cache_ocurrences** table in the
database which provides a general purpose output of the Indicia occurrences data.

The basic steps are:

#. Log in to Geoserver

#. Go to **Data > Workspaces** and click on the **Add New Workspace** link

#. Enter an appropriate name for the Workspace (which must not contain spaces) and also enter a
   URI (Uniform Resource Identifier). A URI is nothing more than a string of characters
   that uniquely identify a resource on the Internet (see `this Wikipedia article
   <http://en.wikipedia.org/wiki/Uniform_Resource_Identifier>`_ for more details).
   Typically it could be the Web address of a domain that you control, followed by a
   string unique to that domain. This should guarantee that the URI is completely unique
   on the Internet. An example might be http://www.example.com/mystuff. (Note that a
   folder called "mystuff" does not actually have to exist on the domain www.example.com).
   The Workspace name translates to a Namespace for XML-based files produced by Geoserver.
   
#. Go to Data>Stores and click on the Add New Store link. You will be offered a range of 
   data source types to choose from, both vector and raster - choose "PostGIS - PostGIS 
   database".
   
   Add the following information to the form that then appears:
  
   Firstly "Basic Store Info":
  
   **Workspace**: Select from the drop-down list the workspace you created in step 3 above.
  
   **Data Source Name**: Enter a suitable name.
  
   **Description**: Enter a description of your data source.
  
   Then "Connection Parameters":
  
   **dbtype**: postgis (not present in some versions)
  
   **host**: the host address for your Geoserver installation (often it will be 
   "localhost")
   
   **port**: the port of the host on which Geoserver is running - usually 5432
  
   **database**: enter the name of your Indicia database
   
   **schema**: enter the schema name for your Indicia database
  
   **user**: enter the name of your dedicated indicia user (or postgres)
  
   **passwd**: the password of your Indicia user (or postgres)

   You can leave other entries at their default (though you might want to check the 
   "validate connections" box).

#. Click Save to save your new data Store - this will take you directly to the **New Layer 
   Chooser**. You are presented here with a list of available tables and views (which are
   predefined queries stored in the database which can be accessed just like views) from
   your Indicia database. Choose the "detail_occurrences" view (click the 'publish' link).
   
#. On the next screen you'll see two tabs - **Data** and **Publishing**. Data is selected 
   by default and you are presented with a set of fields to fill in.

   **Name**: this is the name that you will use to access the layer from other 
   applications and for clarity we'd advice that this matches the database table or view 
   which is being published, e.g. "detail_occurrences".

   **Title**: A "human-readable" description to briefly identify the layer to WMS/WFS
   clients. This can be more descriptive than the name - e.g. "Based on the
   detail_occurrence view from Indicia database"

   **Abstract** (optional): here you can add even more detail if you wish, particularly
   useful when clients request details of your web service to find our what it does.
  
   **Keywords**: (optional): individual keywords to help classify this data layer.
  
   **Metadata Links** (optional): allows linking to external documents that describe the
   data layer.

   The next section deals with the **coordinate system** - or Spatial Reference System
   (**SRS**) - of the data layer i.e. how your georeferenced spatial data relates to real
   locations on the Earth’s surface. So, a coordinate system might be Latitude/Longitude;
   British Ordnance Survey grid etc. A set of codes - the **EPSG** codes - have been
   devised to simplify dealing with the range of different coordinate systems that exist.
   The coordinate system used by Indicia (the Native SRS) is WGS84: Google Mercator -
   which corresponds to EPSG:900913. Geoserver also provides for re-projecting a data
   layer by defining a "Declared SRS".
  
   **Native SRS**: For our details_occurrences layer this will be entered automatically as
   EPSG:900913
  
   **Declared SRS**: This is also entered automatically as EPSG:900913
  
   **SRS handling**: This defaults to "force declared" - though presumably "keep native"
   would be fine in this case too, since declared and native SRSs are the same.
  
   The next section is **Bounding boxes** - The bounding box is determines the extent of a
   layer. The **Native Bounding Box** is the bounds of the data projected in the Native
   SRS. You can generate these bounds by clicking the **Compute from** data button. The
   **Lat/Long Bounding Box** computes the bounds based on the standard lat/long. These
   bounds can be generated by clicking the **Compute from native bounds** button.
   
#. Now move over to the **Publishing** tab and select a style from the drop-down list. 
   Select **point** for now.

#. You can define a **custom style** which you can use for your Indicia layer. The easiest
   way to do this is to edit an existing style (which is essentially an XML file ) and
   save it under a new name. To do this go to Styles under the Data menu. This will bring
   up the Style Editor. Enter a name for your new style and then from the drop-down list
   under "Copy from style" choose an existing style to act as your template. Edit this as
   required, click validate to check all is well and then submit. Next time you need a
   style for a layer your new style will appear in the drop-down list. The following style
   gives an example which draws both a point and, if the reference is a grid square, a
   square. This works well because when zoomed out so the grid square is tiny, it is drawn
   as a larger 6 pixel circle. When you zoom in the square's actual shape becomes visible.

.. code-block:: xml

  <?xml version="1.0" encoding="ISO-8859-1"?>
  <StyledLayerDescriptor version="1.0.0" xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
    <NamedLayer>
      <Name>Default Polygon</Name>
      <UserStyle>
        <Title>Default polygon style</Title>
        <Abstract>A sample style that just draws out a solid gray interior with a black 1px outline</Abstract>
        <FeatureTypeStyle>
          <Rule>
            <Title>Polygon</Title>
            <PointSymbolizer>
              <Graphic>
                <Mark>
                  <WellKnownName>circle</WellKnownName>
                  <Fill>
                    <CssParameter name="fill">#00FF00</CssParameter>
                  </Fill>
                </Mark>
                <Size>6</Size>
              </Graphic>
            </PointSymbolizer>
            <PolygonSymbolizer>
              <Fill>
                <CssParameter name="fill">#00FF00</CssParameter>
              </Fill>
              <Stroke>
                <CssParameter name="stroke">#000000</CssParameter>
                <CssParameter name="stroke-width">1</CssParameter>
              </Stroke>
            </PolygonSymbolizer>          
          </Rule>
        </FeatureTypeStyle>
      </UserStyle>
    </NamedLayer>
  </StyledLayerDescriptor>