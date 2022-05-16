REST API Module
===============

The REST API module provides a RESTful web service to the following:

* Key data operations for wildlife records data (occurrences, samples, locations).
* Metadata operations for survey data set structure including creating and modifying
  surveys and custom attributes.
* Access to data via reports.
* Access to data in Elasticsearch if configured for this warehouse.
* Access to a taxon-observations and annotations end-point, a prototype for data exchange
  between wildlife recording systems that is deprecated and likely to be replaced.

Support for data operations on other data types may be added in future.

Once this module is enabled, you need to create a configuration file to define authentication
methods, resource endpoints and integration with Elasticsearch. The easiest way to do this is to
copy the file ``/modules/rest_api/config/rest.jwt-only.php`` to ``/modules/rest_api/config/rest.php``.
Now open the file in a text editor and perform the following amendments:

* If not using Elasticsearch, then remove the whole line for the ``elasticsearch`` key under the
  jwtUser resource_options section. Also remove the entire entry for ``$config['elasticsearch']``.
* If using Elasticsearch, replace ``http://my.elastic.url:9200`` with the URL of your Elasticsearch
  instance and ``my-index`` with the name of the index containing occurrence data.

Once configured, visit /index.php/services/rest for dynamically generated information about
the available API end-points.

For a more complete set of configuration options refer to the examples in the ``rest.example.php``
config file. The following configuration settings can be specified:

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

.. todo::
  Complete documentation including autofeed (tracking and tracking dates) and max_time
  information.

.. tip::
  Some default configurations of Apache do not pass the Authorization header through to PHP for
  security reasons. This will prevent authorisation using JWT (the 'jwtUser' method). To fix this,
  add the following lines to your .htaccess file::

    RewriteEngine On
    RewriteCond %{HTTP:Authorization} ^(.*)
    RewriteRule .* - [e=HTTP_AUTHORIZATION:%1]

  See `this post <https://stackoverflow.com/questions/26475885/authorization-header-missing-in-php-post-request>`_
  for more info.

Examples
--------

Basic POST to create
^^^^^^^^^^^^^^^^^^^^

.. code-block:: JSON

  POST /index.php/services/rest/samples
  {
    "values": {
      "survey_id": 1,
      "entered_sref": "SU1234",
      "entered_sref_system": "OSGB",
      "date": "01\/08\/2020",
      "comment": "A sample comment test"
    }
  }

  Response: 201 Created
  Location: http://localhostwarehouse-testindex.php/services/rest/samples/3
  {
    "values": {
      "id": "3",
      "created_on": "2020-08-03 19:01:41",
      "updated_on": "2020-08-03 19:01:41",
    },
    "href": "http:\/\/localhost\/warehouse-test\/index.php\/services\/rest\/samples\/3"
  }

GET the created record
^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: JSON

  GET /index.php/services/rest/samples/3

  Response: 200 OK
  {
    "values": {
      "id": "3",
      "survey_id": "1",
      "location_id": null,
      "date_start": "2020-08-01",
      "date_end": "2020-08-01",
      "date_type": "D",
      "entered_sref": "SU1234",
      "entered_sref_system": "OSGB",
      "location_name": null,
      "created_on": "2020-08-03 19:01:41",
      "created_by_id": "1",
      "updated_on": "2020-08-03 19:01:41",
      "updated_by_id": "1",
      "comment": "A sample comment test",
      "external_key": null,
      "sample_method_id": null,
      "deleted": "f",
      "geom": "010300002031BF0D000100000005000000CD62CC3B04DE08C1E66E5DD74B545941823D35E5E6DD08C18DCB406EDA555941F178F09934AC08C10AE5F578D9555941C0D2756854AC08C1CAC832E24A545941CD62CC3B04DE08C1E66E5DD74B545941",
      "recorder_names": null,
      "parent_id": null,
      "input_form": null,
      "group_id": null,
      "privacy_precision": null,
      "record_status": "C",
      "verified_by_id": null,
      "verified_on": null,
      "licence_id": null
    }
  }

Update the created record
^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: JSON

  PUT /index.php/services/rest/samples/3
  {
    "values": {
      "entered_sref": "SU121341"
    }
  }

  Response: 200 OK
  {
    "values": {
      "id": "3",
      "created_on": "2020-08-03 19:01:41",
      "updated_on": "2020-08-03 19:01:43",
    },
    "href": "http:\/\/localhost\/warehouse-test\/index.php\/services\/rest\/samples\/3"
  }

GET a missing sample
^^^^^^^^^^^^^^^^^^^^

.. code-block:: JSON

  GET /index.php/services/rest/samples/99999

  Reponse: 404 Not Found
  {
    "code": 404,
    "status": "Not found"
  }

POST an invalid sample
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: JSON

  POST /index.php/services/rest/samples
  {
    "values": {
      "entered_sref": "SU1234",
      "entered_sref_system": "OSGB",
      "date": "01\/08\/2020"
    }
  }

  Response: 400 Bad Request
  {
    "code": 400,
    "status": "Bad Request",
    "message": {
      "sample:survey_id": "The survey must be supplied."
    }
  }
