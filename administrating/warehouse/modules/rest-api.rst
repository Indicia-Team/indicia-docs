REST API Module
---------------

The REST API module provides a RESTful web service to some aspects of Indicia's database,
namely reports and resources required for synchronisation of a warehouse with other online
recording databases. Support for other data types as well as data updates may be added in
future.

Once this module is enabled, visit /index.php/services/rest for dynamically generated
information about the available API end-points.

The REST API is configured by copying the file /modules/rest_api/config/rest.example.php to
/modules/rest_api/config/rest.php and editing it. The following configuration settings
can be specified:

  * **user_id** - when synchronising records with another system, each system must have a
    unique user ID specified here with which it will be identified on the other system.
  * **dataset_name_attr_id**
  * **authentication_methods**
  * **allow_auth_tokens_in_url** - defaults to FALSE. If set to TRUE then direct
    authentication methods (i.e. those which involve passing a user identifier and secret
    or password directly with each request) allow the authentication information to be
    passed in the request's URL query parameters. When FALSE, the authentication
    information must be passed in the HTTP header data. Setting to TRUE can be useful for
    development, testing or training purposes where it is easier to be able to create URLs
    manually rather than to write code which sets the HTTP header data with the request.
  * **clients**
