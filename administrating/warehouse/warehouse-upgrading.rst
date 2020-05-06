*******************************
Upgrading the Indicia warehouse
*******************************

Upgrades for Indicia, including the warehouse, are released periodically and announced on
`the forum <http://forums.nbn.org.uk/viewforum.php?id=25>`_. The files required for the
upgrade are the same as the files for the latest stable release. The link for this is
available on the `Github home page <https://github.com/Indicia-Team/warehouse>`_.

If you have an existing Indicia warehouse which needs to be upgraded, the following steps
are required.

#. Endeavour to notify users that you are upgrading the warehouse and that it will be
   temporarily unavailable.
#. Stop your web server to prevent changes being made to the database by users or, better
   still, keep it running but deny access to users.
#. Make a backup of your existing Indicia installation folder and database for safe
   keeping.
#. Download the new version from the downloads page.
#. Now, unzip the files and copy the contents directly over the contents of your existing
   installation folder.
#. Restart your web server if you stopped it.
#. Next, log into your Indicia Warehouse and visit the home page. You should see a
   notification that an upgrade needs to be run. Click the button to upgrade your
   warehouse.
#. Take careful note of any messages shown to ensure that the upgrade ran successfully. In
   particular, there may be scripts which you need to run against the warehouse database
   using the *postgres* user account if full database permissions are required - in this
   case we suggest you log in to pgAdmin and paste the supplied scripts into a query
   window to run them.
#. Re-enable access to the warehouse if you had denied it.

.. note::

  If upgrading from version 0.2.3 of the warehouse or earlier, you will first need to
  upgrade using 0.9.x of the warehouse before upgrading to versions after version 1.0.0.

That's it!

Developer Notes
===============

If you are maintaining an Indicia Warehouse which is being kept up to date from the
:doc:`Github repository <../../developing/github>` rather than downloaded releases,
you won't see the upgrade notification on the home page after an Git pull unless the
application version has changed. However, there are a couple of options for upgrading your
database on a more ad-hoc basis:

#. You can enable a facility to automatically run any new script files which appear in the
   latest scripts folder (modules/indicia_setup/db/version_x_x_x). This may have a small
   affect on performance though it should not be too significant. To do this, copy the
   file modules/indicia_setup/config/upgrade.php.example and name the new file
   upgrade.php.

#. Rather than automatically running any scripts that have been added to the setup when
   you performed SVN update, you can manually ask Indicia to bring the database fully up
   to date. To do this, just log in then visit the URL /index.php/home/upgrade. The
   advantage of this approach is that Indicia does not have to scan for upgrade scripts
   each time it is accessed, so the performance will be better.

The upgrade process places each set of scripts required for upgrade in a folder called
modules/indicia_setup/db/version_x_x_x, where x_x_x reflects the version number. If a
script needs to be run with superuser privileges, then insert the following comment on the
first line of the script so that the upgrader can provide instructions to the user to
manually run the scripts using the postgres user:

.. code-block:: sql

  -- #postgres user#

Similarly, tag any scripts that are likely to be slow (such as those which do data
manipulations) with the comment below so that the script can be given to the user to run
manually after the upgrade:

.. code-block:: sql

  -- #slow script#

In addition, any code that is required for an upgrade can be placed in a method called
``version_x_x_x`` placed in the Upgrade_Model class, in
modules/indicia_setup/models/upgrade.php.
