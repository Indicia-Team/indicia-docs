*************************
Installation Requirements
*************************

For the client website, assuming that the website will use the client helpers
PHP API the requirements are as follows:

* PHP version 5.6, 7.0 or 7.1. Better performance is achieved using PHP 7.*.
* The cUrl PHP extension should be enabled.
* Any other requirements of the website (e.g. for running Drupal if using this
  option).
* Your webserver must not be blocked from accessing the Warehouse server by a
  firewall to allow communications between the 2 servers.

For the Warehouse, the requirements are as follows:

* PHP version 5.6, 7.0 or 7.1.
* The cUrl PHP extension should be enabled.
* PostgreSQL 9.5 or higher is required.
* The PostGIS extension for PostgreSQL must be installed.
* If you want to expose spatial layers using standard web services then an
  installation of GeoServer alongside the Warehouse. This requires a Java SDK.
