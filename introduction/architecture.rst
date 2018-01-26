************
Architecture
************

In order to understand how to setup your own online recording using Indicia you
first need to understand the key components that go together to build the
system.

The main “guts” of Indicia are provided in the **warehouse**. The
warehouse’s primary purpose is to store the records, including observations,
species data, sites, people and lists of terms used in the data. When a recorder
uses the online recording facilities on an Indicia site, they do not need to be
aware of the warehouse as the web interface they use is kept completely
separate. However, the warehouse does have its own administration interface
which we will look at later, designed for use by people whose role it is to set
up and configure the surveys that are being conducted.

Because the database used by Indicia is fully able to handle geographic objects
such as site boundaries as it is fully *spatially enabled*, you can link the
data in a warehouse easily to a GIS (Geographical Information System)
application, Google Earth or online map. However this does mean that the
technology used on the warehouse may not run on a typical low-cost hosted
website account. Don’t worry though as Indicia was designed with this in mind.
The warehouse can run on a different web server to your recording website so it
can be hosted completely separately to your online recording website. A single
warehouse installation can support multiple online recording websites making it
possible for organisations that do have the capacity to host a warehouse to
share this resource with other organisations which don’t. For example in the
following diagram the warehouse supports 3 online recording websites for various
schemes and societies (it could be many more).

.. image:: ../images/diagrams/warehouse-multiple-websites.png
  :width: 600px
  :alt: One website supports multiple client websites

The second component required of course is the online recording website itself.
This is the part you will definitely need to build but Indicia is designed to
make this as simple as possible. It is also designed to run on the vast majority
of web servers including very cheap hosted accounts on shared servers. Because
most of the hard work is done by the warehouse, Indicia does not place a huge
burden on the server hosting the online recording website and only uses
technologies that are more or less standard these days on nearly all web
servers.

There are several possible approaches to building your website using
Indicia, these include:

* :doc:`The Drupal IForm module <../site-building/iform/index>`
* :doc:`Using the Indicia programmers interface from your own PHP code
  <../developing/client-website/tutorial-writing-php-form/index>`

You can find out more about the site building choices in
`../site-building/building-your-website`.