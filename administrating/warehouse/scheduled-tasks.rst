Scheduled Tasks
===============

Because an Indicia server can support a large number of client websites, each of which
submits data and runs sometimes complex queries for reporting and mapping, it is
imperative that we consider performance at every step. One of the ways we can improve
performance is to move certain tasks offline, which is appropriate if the task does not
need to be run at the exact moment a record is submitted, or if we can pre-empt complex
report joins that are going to run repeatedly. Examples include running automated
verification checks against incoming records, indexing them against complex site
boundaries and triggers against incoming data generating notifications.

Instead of running these processes each time data is added, a task is scheduled to run
on a periodic basis (e.g. once per hour) which sweeps up all the records since the last
time it was ran. This is done by setting up an operating system task on the server which
simply accesses the URL ``/index.php/scheduled_tasks`` on your warehouse server. On a
Linux Apache server, the best way to do this is using `Cron
<http://en.wikipedia.org/wiki/Cron>`_ whereas on Windows you may like to consider using
the `Task Scheduler <http://en.wikipedia.org/wiki/Task_Scheduler>`_. You can also use
your web browser to access this url if required, though this is only really appropriate
for development and testing purposes as you would need to do this regularly throughout
the day.

When using cron to run the scheduled tasks link, it is common practice to call PHP
directly via the command line, rather than call it by visiting the URL. The command to
execute will be in the form:

  php path/to/file/index.php scheduled_tasks

You will need to insert your path to the Kohana index.php file, enclosing it in inverted
commas if it contains spaces. The specifics of setting up Cron will differ depending on
the operating system. The following illustration shows the required steps, taken from a
working Ubuntu installation:

First, Find the user that Apache is running as:

.. code-block:: console

  $ ps -ef | egrep '(httpd|apache2|apache)' | grep -v `whoami` | grep -v root | head -n1

The first column in the response is the user, in our case "daemon".Now, open the crontab
file for editing, using the same user as apache. Replace "daemon" if your username is
different.

.. code-block:: console

  $ sudo crontab -u daemon -e

Edit the file that appears, adding the following to the end, replacing the path to the
Warehouse index.php file as necessary::

  */15 * * * * php /opt/lampp/htdocs/warehouse/index.php scheduled_tasks

.. tip::

  You can also run the task directly by invoking Apache, solving the issues described with
  user accounts. To do this you can run the scheduled_tasks link with the
  following command:

    wget -0 - -q -t 1 http://my.warehouse.url/index.php/scheduled_tasks

Controlling which task is run
-----------------------------

The scheduled tasks process runs the notifications system plus any modules on the
warehouse that declare they should be scheduled to run. You can control exactly which
modules are run by appending a **tasks** URL parameter containing a comma separated list
of task names. The task names available are:

* **notifications** - fires the triggers and notifications system.
* **work_queue** - fires the work queue processor.
* **all_modules** - fires all the scheduled modules.
* **_module name_** - provide the folder name for a module to fire it specifically.

As an example the following URL triggers just the cache builder and data cleaner module to
fire::

  http://www.example.com/indicia/index.php/scheduled_tasks?tasks=cache_builder,data_cleaner

Using this approach it is possible to set up several different tasks which are repeated
at different frequencies, e.g. to run the notifications system once an hour, the data
cleaner once a night and the cache_builder every five minutes.

.. tip::

  The work_queue task is a recent addition to the Indicia warehouse for version 2. It
  examines the work_queue table to find tasks that have been queued and which need to be
  performed. The tasks are sorted by priority and the procesor is designed to be aware of
  your server's load and to avoid intensive tasks during periods of high load. Therefore
  it is safe to run the scheduled_tasks with a parameter `&tasks=work_queue` as frequently
  as you like. You can further control the work queue processor by setting the following
  parameters:

    * maxPriority - set to 1 (high priority) or 2 (medium priority) tasks only.
    * maxCost - set to a value from 1 to 100 to define the maximum cost of tasks. E.g.
      set to 80 to skip tasks that are very costly.

  Note that you should run the work_queue task without a maxPriority or maxCost parameter
  regularly at some point to ensure all tasks get processed, though you could limit these
  to certain times of the day for example.

Warehouse functionality dependent on scheduled tasks
----------------------------------------------------

The following functions require the scheduled tasks to be run at least periodically in
order to work:

* The warehouse :doc:`modules/cache-builder`. This module prepares simplified flat tables
  of the occurrences, taxa and term parts of the data model to significantly improve
  reporting performance.
* The warehouse :doc:`modules/data-cleaner`. This runs automated verification checks
  against the incoming records.
* The warehouse :doc:`modules/spatial-index-builder` module. This preempts the need to perform
  spatial joins to build lists of records in complex vice county and other similar
  boundaries.
* The warehouse :doc:`modules/notify-verifications-and-comments`. This sends notifications of
  automated verifications and record comments back to the original recorder of the record.
* The warehouse :doc:`modules/notify-pending-groups-users`. This sends notifications when
  a user requests membership of a group to the group's administrators.
* The warehouse :doc:`modules/notification-emails`. This module sends notifications as
  emails or digest emails according to the settings in the `user_email_notification_settings`
  table for each user.
* The warehouse functionality for :doc:`triggers-actions`.
