Record Cleaner module
---------------------

The Record Cleaner module provides integration between an Indicia warehouse and the
`NBN Record Cleaner<http://www.nbn.org.uk/record-cleaner.aspx>`_ tool to automate checking of
incoming records. It runs as a scheduled task and sends records pending checking to the API, then
tags the resulting flags against the records.

The API currently supports period, phenology, 10 km distribution and species list checks. Records
are only checked against the API if the website configuration has the "Enable auto-verification
checks" option ticked.

For an internal version of the Record Cleaner, see the :doc:`record-cleaner` module.

Installation
============

First, set up a username and password on the Record Cleaner API.

Copy the file modules/record_cleaner/config/record_cleaner.php.example to create a file called
record_cleaner.php and edit it in a text editor. Enter the username and password as well as the
service URL.

Save the file, then edit application/config/config.php and ensure that record_cleaner is added to
the list of modules, then save the file:

.. code-block:: php

  $config['modules'] = [
    ...
    MODPATH.'record_cleaner',
    ...
  ];