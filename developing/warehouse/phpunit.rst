Running phpUnit tests
=====================

The Indicia warehouse included phpUnit test classes for some key areas of functionality.
These provided automated tests ensuring that the code remains robust whilst changes are
implemented.

#. To run phpUnit tests, you must first `install phpUnit
   <http://phpunit.de/manual/current/en/index.html>`_. Currentlt phpUnit versions up to 5.x
   are supported.
#. The `pdo_pgsql` extension must be enabled for PHP.
#. You MUST run unit tests against a warehouse which has the following features:
     * The PostgreSQL database must be called 'indicia'.
     * The database connection user account must be called 'indicia_user' and the password set to
       'indicia_user_pass'.
     * Run 'ALTER USER indicia_user SET search_path=indicia, public, pg_catalog;' in pgAdmin.
     * The warehouse MUST only be used for unit testing, since each test run may clear existing
       data from the database.
#. Enable the following modules by adding them to the list in
   `application/config/config.php`:

     * rest_api
     * sref_mtb
     * data_cleaner_period_within_year
     * attribute_sets

#. Copy the file `modules/rest_api/config/rest.php.travis` to `rest.php`.
#. Enable the phpUnit warehouse module. You will need to disable it after running your
   tests, if you want to access the warehouse UI. Whilst the phpUnit module is enabled,
   your warehouse will not be fully functional so do not run tests on a live server.
   :doc:`Click here for more information on enabling modules
   <../../administrating/warehouse/modules/index>`.
#. Start a command prompt or terminal window and navigate to the root folder of your
   warehouse installation.
#. Enter the following command. The bootstrap option tells the phpUnit framework to load
   the Kohana framework::

     phpUnit --configuration=phpunit-tests.xml

The output will tell you how many tests ran, how many assertions ran and how many failed.
It also gives time and memory usage information.

The parameter in the command given above is a configuration file which defines the set of scripts
to run. You can also run tests for warehouse modules by pointing to the tests folder within that
module,
e.g.::

  phpUnit --bootstrap=index.php modules/indicia_svc_data/tests

Or you can run tests against a single class::

  phpUnit --bootstrap=index.php application/tests/helpers/vague_dateTest.php

More information on writing tests is available on `the phpUnit website
<http://phpunit.de/manual/current/en/writing-tests-for-phpunit.html>`_.

Using phpUnit phar
------------------

An easy way to setup phpUnit is to download the PHAR file. Unfortunately, Kohana is compatible with
phpUnit versions prior to 6, but these versions have function signature compatibility problems that
come to the fore in PHP 7.1 and higher. To get round this:

  * Download phpunit-5.7.5.phar from `the phpUnit PHAR downloads page <https://phar.phpunit.de/>`_.
  * From a command line, extract the contents to a local folder, for example::

    $ C:\xampp\php\php.exe C:\xampp\php\pharcommand.phar extract -f C:\xampp\htdocs\warehousetest\phpunit-5.7.5.phar c:\localsource\phar

  * Edit the phar folder.
  * Search for all instances of "function assertEquals". Edit all the comparator class descendents and ensure that assertEquals method
    has ", array &$processed = array()" as last parameter.
  * Temporarily set phar.readonly to off in the php.ini file.
  * Rebuild the *.phar file::

    $ C:\xampp\php\php.exe C:\xampp\php\pharcommand.phar pack -f C:\xampp\htdocs\warehousetest\phpunit-5.7.5.phar c:\localsource\phar

  * Reset php.ini file.
  * You can now run unit tests, e.g. from the root folder of the warehouse installation::

    $ c:\xampp\php\php.exe phpunit-5.7.5.phar --config=phpunit-tests.xml

Continuous Integration
----------------------

The Indicia warehouse is automatically rebuilt and tested each time a code change is
committed into GitHub. The output of these builds including test results can be viewed
`on Travis CI <https://travis-ci.org/Indicia-Team/warehouse>`_.
