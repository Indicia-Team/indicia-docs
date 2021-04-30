**************************
Frequently asked questions
**************************

How much does Indicia cost?
---------------------------

Indicia is free and open source software and there are no costs for the software
itself or any of the software it is dependent on. However, before implementing a
project using Indicia please take into account the cost of web-hosting and
developing your Indicia powered site, although the latter should be considerably
cheaper using Indicia than if starting from scratch.

Does Indicia allow photos to be uploaded with records?
------------------------------------------------------

Yes, Indicia supports photo upload for records as well as for site data. The
uploader also supports resizing the image within the browser making uploads
much faster as well as showing a progress bar during the upload.

Does Indicia support expert verification of the records?
--------------------------------------------------------

Yes, Indicia can be used to build sites that support expert verification of
incoming records and includes ready made verification pages that can be
added to any Indicia site. Full details of records are available including
photos, maps with overlay of existing distributions of the species for
comparison and phenology charts built using existing records. The verification
facilities support bulk verification of records, e.g. verify all records of a
common and easy to identify species, or all records by a trusted recorder. Email
communication facilities and integration with NBN Record Cleaner rules combine
to make verification both simple and fast.

What support options are available?
-----------------------------------

Indicia currently has the following support and help options:

* A forum at http://forums.nbn.org.uk/viewforum.php?id=25
* A live chatroom at http://jabbr.net/#/rooms/indicia

If you would like something more concrete than free community support then there
are a number of developers available who can provide paid for support or complete
website development. The best approach would be to post a message requesting
assistance on the forum.

.. note::

  When choosing the technologies used for Indicia, we have consciously elected
  to stick with widely used, free and open source tools. Therefore finding
  developers with the right skillset (mainly PHP and JavaScript) is relatively
  easy and there are no up-front costs to get set up as a developer. You can
  :doc:`find out more about the technology <technology>` or
  :doc:`dive straight in to the developer documentation <../developing/index>`.

Will the Indicia project be maintained into the future?
------------------------------------------------------

These FAQ were first drafted in 2012 and I am just adding an update in 2021.
During that time Indicia has been in a state of continuous improvement. It now
underpins the work of the Biological Records Centre at the UK Centre for 
Ecology and Hydrology and has been adopted my numerous local record centres,
recording schemes and surveys, both in the UK and abroad. So long as an
interest remains in monitoring wildlife, tools will exist to facilitate that.
Indicia is one of the best solutions currently available. The future is a 
long time. If and when Indicia ceases to be worth maintaining it will most
likely be because there is a better solution that the community have chosen
to migrate to. 

Is there a mobile interface for Indicia?
----------------------------------------

Indicia provides an excellent platform for building mobile
applications against since it provides the services required to store records,
lookup species names and report on the data that a mobile application requires.
`Numerous apps <https://www.brc.ac.uk/apps>`_ have been created using it.

A `javascript library <https://github.com/Indicia-Team/indicia-js>`_ exists
which provides useful functions to an app using Indicia.

What do I need to do to setup my own online recording site?
-----------------------------------------------------------

There are two principal components to Indicia, the Warehouse and the website
which your recording forms are presented on. The Warehouse is the part which
stores all the data and provides an interface for administering the recording
surveys and the data they contain. Your website will communicate with the
Warehouse behind the scenes, sending and receiving data to and from it. You need
both of these components in order to use Indicia. However, the design of Indicia
is such that a single Warehouse can be shared between several websites, so you
may only need to host your own website and not the Warehouse.

What are the hosting options for the Indicia Warehouse?
-------------------------------------------------------

Most popular web-hosting packages support just MySQL as a database platform.
Unfortunately MySQL is excellent at what it does, but is currently very limited
in its capability to store and process spatial data - in particular it does not
properly handle reports which request the occurrences falling inside a polygon.
It also has weak support for "procedural" code embedded in the database itself.
PostgreSQL on the other hand has a very rich support for spatial data and is
free and open source, which in turn makes it well supported by other mapping
tools (it's pretty easy to draw PostgreSQL data onto a Google Map or a desktop
GIS for example).

So, our approach to this dilemma has been to split an Indicia based website into
2 parts as mentioned above. The "Warehouse" is where we put the PostgreSQL
database. This part provides an administration website plus a set of web
services providing access to the data and validation tools. The second part is
the bit you get to write - a website that allows your participants to enter
their observations, report and map them. It's completely up to you how you go
about this, but we are providing PHP classes to make the task extremely simple,
and also provide modules for the Drupal Content Management System so you can get
going without writing any code. Now the good thing is that all of this will run
easily on the vast majority of web-hosting packages.

So, whilst the actual online-recording websites will run pretty much anywhere,
the options for running the Warehouse are as follows:

#. Host your own web server. The good news here is that all the software
   required on the server is free and open source (Indicia is free as in free
   speech and free beer). Indicia's bandwidth requirements are also not likely
   to be very high by today's standards.
#. Use a web-hosting package. Whilst the packages that support PostgreSQL are
   limited, there are some, for example those in the following list:

   * http://www.nethosted.co.uk/uk-web-hosting.php
   * http://www.devisland.net
   * http://www.memset.com
   * http://www.a2hosting.com

   Please note that this list is not an endorsement in anyway, merely a
   suggestion of some hosts to investigate. For the ultimate in power and
   flexibility most hosts can provide a Virtual Private Server - effectively
   your own virtual machine which you have a lot more freedom over, though it is
   often quite a lot more expensive.
#. Share a server with a partner organisation that is willing and capable of
   hosting the Warehouse on your behalf. At this time the only organisation
   planning to do this on behalf of other organisations is the `Biological
   Records Centre <http://www.brc.ac.uk>`_, but that does not mean there won't be
   more.

Remember with options 1 and 2 there is an overhead of installation and
administration of the Warehouse - for example you will need to setup an
appropriate backup strategy and so forth.

One of the things you may want to think about when selecting a host is whether
you want to expose your data as "spatial web services". The way we are doing
this is to install a package called GeoServer. This runs alongside the
PostgreSQL database and allows GIS and web-mapping packages to request maps and
map data directly from the database using a standardised method. So, for
example, it is easy to dump data onto a web-map, Google Earth or your GIS. To do
this requires the ability to run Java on the server and it would be worth asking
a potential web host if they can support GeoServer before going down this route
(unless of course you don't need to expose the data spatially).

How do I access the data held in Indicia?
-----------------------------------------

Because Indicia is a web application as opposed to a desktop application, the
way you access the data is different. There are many options available but
typically you will use one of the following:

* Download the data in spreadsheet format
* Download the data in NBN Exchange format
* Directly access the data from a GIS or other mapping program such as Google
  Earth using web services.

.. note::

  It is possible to run powerful queries on the web-server itself so
  you don't even need to download the data to perform many basic analysis
  operations.

Which versions of Drupal does Indicia integrate with?
-----------------------------------------------------

At the time of writing (April 2021), the Indicia integration module is available for
Drupal 7 and 8 and a Drupal 9 version is being tested.

Can Indicia use a MySQL database?
---------------------------------

.. todo::

  Answer question about MySQL


How do I report a bug?
----------------------

First, you need to have a Google account. Once you have that set up, go to
`the Issues list <https://github.com/Indicia-Team/warehouse/issues>`_ and click the
**New Issue** link near the top. Please take care to fill in all the details you
can about how to reproduce the bug.

Does Indicia support the NBN Record Cleaner?
--------------------------------------------

The `NBN Record Cleaner <http://www.nbn.org.uk/record-cleaner.aspx>`_ is a tool
designed to help you spot common problems in your data, e.g. by identifying
records outside the expected time of year or geographic range for a species.
Indicia supports importing rule files created for the NBN Record Cleaner which
define individual verification rules. The rules are then automatically applied
to incoming data and this information is made available for verifiers during the
verification process. It all happens online and there is no need to download
data into the NBN Record Cleaner tool itself.

Indicia supports **Period**, **Period Within Year**, **Identification
Difficulty** and **Without Polygon** rules. See
http://www.nbn.org.uk/Tools-Resources/Recording-Resources/NBN-Record-Cleaner/Creating-verification-rules.aspx
for more information.

