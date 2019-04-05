Request Logging module
----------------------

Overview
^^^^^^^^

The Request Logging module captures web service requests and saves summary details to a
new table, `request_log_entries`. Details include the duration of the request so this
table can bee analysed to identify performance bottlenecks. Because the table will rapidly
fill up you might like to only enable the module whilst collecting statistics and disable
it again afterwards.

Installation
^^^^^^^^^^^^

Before enabling the module, copy the file `/modules/request_logging/config/request_logging.example.php`
to a new file in the same folder called `request_logging.php`. The various types of events
that can be logged are documented in the `$config['logged_requests']` variable inside this
file so edit the file and change these if necessary. For example if you know you are
looking into the performance of reports you can comment out the values except `o.report`.

Once the file is edited you can enable the module by adding to the list in
`application/config/config.php` then visit `/index.php/home/upgrade` to install the
required tables.

After a while, check the contents of `request_log_entries` to confirm that events are
being logged. You can truncate this table at any point to restart logging from that
point.

.. code-block:: sql

  TRUNCATE TABLE request_log_entries;
