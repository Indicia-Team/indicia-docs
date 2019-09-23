Web services - errors
=====================

When an error occurs as a result of a call to the web services, the response will
be a JSON or XML formatted documented (depending on the format of your call) containing
the error message and an error code:

.. code-block:: xml

  <?xml  version="1.0" encoding="UTF-8"?>
  <error>
    <message>...</message>
    <code>...</code>
  </error>

or alternatively as JSON:

.. code-block:: json

  {
    "error": "...",
    "code": "..."
  }

For the JSON response format, an unexpected error will also contain the file the error
occurred in, line number and a trace of the error stack:

.. code-block:: json

  {
    "error": "...",
    "code": "...",
    "file": "...",
    "line": "...",
    "trace": []
  }

When a validation error occurs, the JSON contains a single summary error message as well
as individual messages with keys indicating the fields that the errors occurred against:

.. code-block:: json

  {
    "error": "Validation error",
    "code": "2003",
    "errors" {
      "sample:date":"The date is required",
      "sample:entered_sref":"The spatial reference is required"
    }
  }

Note that if the ``application/config/indicia.php`` file contains a setting
``http_status_responses=true;`` then HTTP status codes will be set on the response. This
is not enforced for backwards compatibility reasons.

Error codes
-----------
The following table lists the error codes that can be returned:

==== ======================================================================================
Code Description
==== ======================================================================================
0    Unspecified error
1    Authentication failure - tokens expired or incorrect
1001 Read failure - record not found or website ID of requested data does not match request
1002 Read failure - requested a custom view which does not exist for this entity
1003 Read failure - requested a standard view which does not exist for this entity
1004 Read failure - requested an entity not restricted to a website but without full access
2001 Write authorisation failure - website ID of written data does not match request
2002 Write failure - entity not writeable
2003 Validation failure on a submission
2004 Validation failure on an import
3001 Internal error in secure message system - should not occur
4001 Incorrect spatial reference format in spatial services request
==== ======================================================================================
