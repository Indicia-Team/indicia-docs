RESTful web service resources
=============================

For up to date documentation on the available resources, ensure that the rest_api warehouse
module is installed then visit `index.php/services/rest`. Currently the resources available
are limited to those required to support accessing reports as well as those required to
support the [http://indicia-online-recording-rest-api.readthedocs.io/en/latest/
online recording REST API] for exchanging records between online recording systems.

The `taxon-observations` and `annotations` resources are both covered in the
[http://indicia-online-recording-rest-api.readthedocs.io/en/latest/
online recording REST API] documentation.

index.php/services/rest
-----------------------

By visiting the root of the REST API you can access dynamically generated documentation of
the other resources available via the API. This endpoint does not need authentication.

index.php/services/reports
--------------------------

The reports resource provides access to Indicia's reporting system, allowing a variety of
queries to be run against the database with parameters of your choice. The resource can:

  * return the folders and reports within a single level of the reports hierarchy, e.g. by
    calling /reports or /reports/library.
  * return the output of a report, with parameters provided in the URL query string, e.g.
    by calling
    /reports/library/occurrences/filterable_explore_list.xml?verified_date_from=2017-05-22.
  * return the list of columns in a report, e.g. by calling
    /reports/library/occurrences/filterable_explore_list.xml/columns.
  * return the list of parameters for a report, e.g. by calling
    /reports/library/occurrences/filterable_explore_list.xml/params.

index.php/services/samples
--------------------------

Allows samples to be POSTed which are then created in the database. A JSON object should be
included in the POST body with a values entry containing a list of field values for the sample
entity. Additionally, child samples, occurrences and media can be specified using keys with the
same name. For example::

  POST /index.php/services/rest/samples
  {
    "values": {
      "survey_id": 1,
      "entered_sref": "SU1234",
      "entered_sref_system": "OSGB",
      "date": "01\/08\/2020"
    },
    "occurrences": [{
      "values": {
        "taxa_taxon_list_id": 2,
        "occAttr:8": "4 adults",
      },
      "media": [{
        "values": {
          "queued": "5f36a6d2b51472.42086512.jpg",
          "caption": "Occurrence image"
        }
      }]
    }]
  }

  Response:
  {
    "values": {
      "id": "3",
      "created_on": "2020-08-14T17:57:32+02:00",
      "updated_on": "2020-08-14T17:57:32+02:00"
    },
    "href": "http:\/\/localhost\/warehouse-test\/index.php\/services\/rest\/samples\/3",
    "occurrences": [{
      "values": {
        "id": "3",
        "created_on": "2020-08-14T17:57:32+02:00",
        "updated_on": "2020-08-14T17:57:32+02:00"
      },
      "href": "http:\/\/localhost\/warehouse-test\/index.php\/services\/rest\/occurrences\/3",
      "media": [{
        "values": {
          "id": "15",
          "created_on": "2020-08-14T17:57:32+02:00",
          "updated_on": "2020-08-14T17:57:32+02:00"
        },
        "href": "http:\/\/localhost\/warehouse-test\/index.php\/services\/rest\/occurrence_media\/15"
      }]
    }]
  }

index.php/services/samples/{id}
-------------------------------

Issue a GET request to retrieve a sample matching the provided ID. Currently restricted to samples
created by the logged in user.

Issue a PUT request to update a sample matching the provided ID. Currently restricted to samples
created by the logged in user. The submission format is the same as that for POST, but you only
need to provide field values that are actually changing.

Issue a DELETE request to delete a sample matching the provided ID. Currently restricted to samples
created by the logged in user.

index.php/services/occurrences
------------------------------

Allows occurrences to be POSTed which are then created in the database. A JSON object should be
included in the POST body with a values entry containing a list of field values for the occurrences
entity. Additionally, child media can be specified using a key with the same name. For example::

  POST /index.php/services/rest/occurrences
  {
    "values": {
      "taxa_taxon_list_id": 2,
      "occAttr:8": "4 adults",
    },
    "media": [{
      "values": {
        "sample_id": 123,
        "queued": "5f36a6d2b51472.42086512.jpg",
        "caption": "Occurrence image"
      }
    }]
  }

  Response:
  {
    "values": {
      "id": "3",
      "created_on": "2020-08-14T17:57:32+02:00",
      "updated_on": "2020-08-14T17:57:32+02:00"
    },
    "href": "http:\/\/localhost\/warehouse-test\/index.php\/services\/rest\/occurrences\/3",
    "media": [{
      "values": {
        "id": "15",
        "created_on": "2020-08-14T17:57:32+02:00",
        "updated_on": "2020-08-14T17:57:32+02:00"
      },
      "href": "http:\/\/localhost\/warehouse-test\/index.php\/services\/rest\/occurrence_media\/15"
    }]
  }

index.php/services/occurrences/{id}
-----------------------------------

Issue a GET request to retrieve an occurrence matching the provided ID. Currently restricted to
occurrences created by the logged in user.

Issue a PUT request to update a occurrence matching the provided ID. Currently restricted to
occurrences created by the logged in user. The submission format is the same as that for POST, but
you only  need to provide field values that are actually changing.

Issue a DELETE request to delete a occurrence matching the provided ID. Currently restricted to
occurrences created by the logged in user.

index.php/services/locations
----------------------------

Allows locations to be POSTed which are then created in the database. A JSON object should be
included in the POST body with a values entry containing a list of field values for the locations
entity. Additionally, child media can be specified using a key with the same name.

index.php/services/locations/{id}
---------------------------------

Issue a GET request to retrieve an location matching the provided ID. Currently restricted to
locations created by the logged in user.

Issue a PUT request to update a location matching the provided ID. Currently restricted to
locations created by the logged in user. The submission format is the same as that for POST, but
you only  need to provide field values that are actually changing.

Issue a DELETE request to delete a location matching the provided ID. Currently restricted to
locations created by the logged in user.

index.php/services/media-queue
------------------------------

index.php/services/taxon-observations
-------------------------------------

Provides access to occurrences stored on the warehouse. Described fully in the
[http://indicia-online-recording-rest-api.readthedocs.io/en/latest/ online recording REST
API] documentation.

index.php/services/annotations
------------------------------

Provides access to occurrence comments stored on the warehouse including verification
decisions. Described fully in the [http://indicia-online-recording-rest-api.readthedocs.io/en/latest/
online recording REST API] documentation.
