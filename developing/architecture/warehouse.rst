**********************
Warehouse architecture
**********************
The following diagram illustrates the basic architecture of the warehouse.

.. image:: ../../images/diagrams/warehouse-architecture.png
  :alt: Overview of the warehouse architectural components
  :width: 100%
  
There are quite a few acronyms and other bits of jargon but don't worry, we'll 
work through each of these in turn.

PostgreSQL
==========

PostgreSQL is a relational database management system. In essence, a relational 
database is a collection of tables of data, each of which may relate to rows 
(records) in other tables in the database by the use of unique identifiers. 
PostgreSQL is just one of many pieces of software that are designed to manage 
relational databases, letting you store and extract the data in powerful and 
flexible ways. Each makes claim and counter-claim regarding which is the 
fastest, which can hold the most data and so forth. Our choice of PostgreSQL is 
based on:

* It has a free and open source community edition which we use for Indicia
* It is at least similar in performance, flexibility and power to the other, 
  proprietary commercial offerings
* When combined with PostGIS, it has better support for spatial data than most 
  alternatives, that is, data which have geographic information attached to 
  them. The most commonly used database for website development, MySQL, is 
  rather poor in its support for spatial querying in comparison. We'll find out 
  more information about PostGIS in a moment.
* It is actively being developed and continually improving.

PostGIS
=======

PostGIS adds support for geographical information to PostgreSQL. A database that
supports geographic data is often called "spatially enabled". Not only can 
PostgreSQL + PostGIS store map data directly in the database, but PostGIS adds
a whole plethora of functions for transforming between different 
cartographic projections, measuring, manipulating and otherwise interpreting
the geographic objects it stores. For example, PostGIS can:

* convert the boundary of a place from a latitude and longitude map projection
  to British National Grid projection,
* find all the records within 200m of a river,
* let you report on the data in a user-drawn polygon which can optionally be 
  buffered.

Warehouse MVC code
==================

.. warning::

  Jargon alert!

  The code for the warehouse is written in PHP and uses a framework called 
  `Kohana <http://kohanaframework.org/>`_. Kohana is one of a number of 
  frameworks that use the `Model View Controller <http://en.wikipedia.org/wiki/Model–view–controller>`_ 
  (MVC) design pattern available for PHP. By using a framework rather than 
  starting from scratch we get a collection of useful code for accessing the 
  database, building the user interface and business logic. As an MVC framework, 
  Kohana also provides a standard way to organise code classes into logically
  separate roles:

  * Models - classes which interact with the database. Each model class normally
    represents a single object in the database and provides methods to insert,
    delete and modify records as well as properties to inspect field values from
    the database.
  * Views - code which provides the user interface. In our case these are PHP
    files which output HTML. 
  * Controllers - classes which manage the business logic and interactions 
    between models and views.

Kohana's framework allows for additional modules which can extend existing
functionality and provide new functionality. 

Indicia's warehouse code adds lots of useful code to Kohana including
helper classes for handling different grid reference notations, managing vague
dates and a host of other online-recording tasks. In addition the extensibility
of Kohana is augmented to provide a simple way to add new data tables, screens,
and tabs to the existing warehouse user interface.

.. note: 

  This ability to extend the data model was used by the Wildfowl and Wetlands
  Trust to develop a module which provides support for recording individuals, 
  flocks, family relationships and identifying marks such as rings in birds.

Warehouse UI
============

The warehouse user interface code consists of a series of Kohana views. Each 
view is a simple PHP file which outputs the HTML required for the view. For the 
most part, the warehouse code uses the same client helper library API for the
user interface code as client websites. For example, the grids you can see in 
the warehouse when browsing data are the same ``report_helper::report_grid``
component used to add grids to client websites. However, because Indicia's 
warehouse was originally developed in parallel to the client helper library, 
some of the earlier views utilise the HTML helper provided by Kohana to generate
the HTML output. These are being converted to use the client helper library API
to keep the code consistent, but this is a lower priority than many other tasks.

Likewise, the import facilities available on the warehouse are use the exact
same ``import_helper`` class as the one provided in the client helper library
API to build import facilities for client websites.

Extension modules
=================

The Kohana framework provides useful support for extensibility via the concept
of modules, which allow the provision of additional models, views and 
controllers as well as the overriding of existing code from the main 
application. Indicia's warehouse extends this idea by allowing modules to hook
into various bits of core functionality. For example, Indicia allows a module
to provide additional items to add to the main menu or new tabs for an existing
page. Indicia's module framework can even be used to extend the data model with 
completely new entities and attributes and to support accessing these via the
web services. Therefore any extensions to the data model which are not likely
to be useful to the majority of online recording surveys should be implemented
via modules, helping to keep the core of Indicia lightweight and efficient.

Example modules which extend the data module include:

* **taxon_designations** for supporting designations information for species.
* **individuals_and_associations** for supporting records of individual 
  organisms and the associations with others, e.g. ringed birds or family 
  groups.

GeoServer
=========

`GeoServer <http://geoserver.org>`_ is an open source software server that 
allows users to share geospatial data. GeoServer publishes data using open 
standards and therefore provides an ideal platform for publishing Indicia's
PostGIS spatial database over the web. Data can be published directly as map
images or layers for overlay onto web mapping applications and GIS applications,
or a variety of text based spatial formats.

GeoServer is a separate optional installation which should sit alongside the 
warehouse on the same server. Although Indicia is capable of drawing maps 
without GeoServer, any attempt to map more than a few thousand points on a 
single map is likely to hit performance problems both in the browser's 
JavaScript engine (which is responsible for adding points to the map) and 
because of the size of the download file. One option that GeoServer provides
is a Web Mapping Service (WMS) which renders the map layer image on the server
and sends the image to the client. This results in drastically improved 
performance when rendering maps with large numbers of records.

