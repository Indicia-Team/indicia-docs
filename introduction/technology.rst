*****************
Technical Choices
*****************

When selecting the technology used for each aspect of Indicia, we have given 
preference to

* Technology which is widely used and therefore familiar to a large pool of 
  developers
* Performance 
* Capabilities for supporting biological databases, in particular the mapping
  aspects
* Free and open source, so there are no costs for developers wishing to join the
  project

Database - PostgreSQL with PostGIS
==================================

`PostgreSQL <http://www.postgresql.org>`_ is a true open source database widely 
acknowledged as a serious rival to other well known commercial options, both in 
terms of speed and power. It is the ideal choice for Indicia because of the free
`PostGIS <http://postgis.refractions.net/>`_ extension which converts PostgreSQL
into a powerful spatially enabled database. This optimises the data for storing 
spatial data such as location boundaries and species records and also provides 
in-built support for questions such as "tell me which records are within the 
boundary of this location".

.. note::

  Indicia does not use MySQL to store its records despite that database being 
  more widely available than PostgreSQL, because MySQL's support for mapping 
  data is too limited for our needs.

Language - PHP
==============

The language used for the Core Module development is PHP, selected mainly for 
its ubiquitous nature and therefore ease of finding developers, getting support 
and hosting. PHP is also a fairly easy language to get started with and many
tools available for free.

Language - JavaScript
=====================

Indicia uses `JavaScript <http://en.wikipedia.org/wiki/JavaScript>`_ to provide
dynamic functionality within the web-browser such as maps, date pickers and 
type-ahead search controls. 


Frameworks
==========

Rather than build everything from scratch, Indicia uses existing frameworks to 
make the development of Indicia simpler, just like Indicia provides a way to 
make the development of online recording websites simpler. 

Kohana
^^^^^^

`Kohana <http://kohanaframework.org/>`_ is a framework which effectively 
provides a ready made layout for a PHP web application. It structures the 
application using a pattern known as Model View Controller and also provides 
lots of built in libraries and extensions to make day to day development tasks 
easier. `Documentation for Kohana 2 <https://kohana234.misty-stix.com/>`_
as used by Indicia, is no longer on the Kohana website.

jQuery
^^^^^^

`jQuery <http://jquery.com>`_ is a powerful JavaScript library that simplifies 
the task of writing the code which runs within the web browser, for example to 
provide image upload functionality and dynamic data input controls.

OpenLayers
^^^^^^^^^^

`OpenLayers <http://openlayers.org>`_ is an library of code for adding dynamic 
maps to web pages. These maps are used to allow input of a grid reference, to 
draw the boundary of a site, or to output a report data onto maps. OpenLayers 
has the advantage of being agnostic about the layers you choose to load onto the
map, so you can easily use Google or Bing base layers, or can even load your 
own.

Drupal
^^^^^^

Although Indicia can be integrated into any website capable of running its PHP
code on the server, for those who are starting from scratch 
`Drupal <http://drupal.org>`_ provides a powerful and flexible tool for building
websites in general and with tight integration with Indicia it is particularly 
suitable for building websites with an online biological recording component.


 
