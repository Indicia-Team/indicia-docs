************
Web services
************

The web services are key to the interactions between the client website and the
warehouse. Web services use the same protocols that we use everyday for browsing
the internet but instead of providing a user interface (website), web services
provide a programmatic interface. In a typical web transaction, a *user* sends a
request to a specified *web address*. The *server* responds with the *web page*.
A typical web service transaction is instigated by some code on the client
website. The *code* sends a request to a specified *web address*. The *server*
responds with some *data*. The *code* then processes that data before rendering
the web page as appropriate.

The web services in Indicia are comprehensive in comparison with some systems
where the web services were added as an afterthought, because the Indicia
architecture means that every single interaction with the data on the warehouse
must go through the web services. Every record, every report and every map you 
see on websites like `iRecord <https://irecord.org.uk/>`_ is obtained
via the web services. Indicia's web services provide the following facilities:

* Data services

  * Read individual database records
  * Read lists of database records according to provided sort and filter criteria.
    This supports pagination in grids by allowing **limit** and **offset** 
    parameters
  * Write to records for edits and deletes

* Reporting Services

  * Read the output of reports, also with support for pagination in grids by 
    allowing **limit** and **offset** parameters

* Other web services

  * Authenticate a client website
  * Spatial reference operations including transformations from map coordinates to
    and from any spatial reference notation.
  * Bulk import records
  * Apply verification rules to proposed records

The data access via Indicia's web services requires secure authentication and 
applies authorisation so that each client website cannot see data that belongs
to other websites by default.

