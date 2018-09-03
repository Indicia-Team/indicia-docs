Using the Indicia2Recorder addin for Recorder 6
===============================================

The Indicia2Recorder addin is an extension to Recorder 6 which allows download of the
records you have access to from an Indicia powered online recording website. The
addin depends on modules existing on the website which are currently only available for
Drupal, this means that the addin can only download Indicia records via a Drupal 7 or
Drupal 8 website such as iRecord at present (Drupal 6 is possible but no longer
supported).

If you already have the addin installed and configured, then jump straight to the section
on usage further down the page.

Installation
------------

Download the addin file from the `Indicia Downloads page
<http://www.indicia.org.uk/downloads>`_ and unzip it into a temporary folder,
then install it into Recorder 6 as normal. This adds a new **Indicia2Recorder** menu item
to the Recorder 6 Tools menu. Upgrades can be performed by simply copying the file to
replace the older version of the addin, though this must be done when Recorder 6 is not
running.

If you are the administrator of the Drupal/Indicia website and are setting it up for
Indicia2Recorder for the first time, then you will need to ensure that the following
modules installation and configuration has been performed depending on your version of
Drupal:

  * Drupal 7 requirements:

    * Install and enable the Indicia Mobile Auth module
    * Install and enable the Indicia Remote Download module
    * Visit the configuration page for Indicia Mobil Auth via the menu at **Site
      configuration > IForm > Mobile Auth Settings** in order to configure an shared
      secret (app secret) which you will need later.

  * Drupal 8 requirements:

    * Install and enable the Indicia Remote Download module
    * Visit the configuration page for this module and specify a shared app secret
      (Configuration > Indicia integration > Indicia remote download settings.


Configuration
-------------

Because the Indicia2Recorder addin uses a secure connection to the Indicia website where
the records are stored, it needs to be configured to know how to authenticate onto the
website. There are 2 possible ways of creating this configuration:

  * Use an existing connection configuration file.
  * If you are the administrator of the website then you can create your own connection
    configuration file.

Existing connection configuration files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You will need to obtain a file called **indiciaConnection.txt** for the website you are
connecting to. This may be available from the website administrator. For iRecord, there is
a connection file available from the `Indicia Google Code Downloads page
<http://code.google.com/p/indicia/downloads/list>`_.

Save this file to your Public Documents folder or personal My Documents folder in a
sub-folder called Indicia2Recorder.

Creating your own configuration connection file
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can create a configuration file only if you have access to the following information:

  * The URL of the website you are connecting to, e.g. http://www.brc.ac.uk/irecord
  * The Shared App Secret configured on this website using the Indicia Mobile Auth module
  * The Site ID that will be used by Recorder 6 to identify records belonging to the
    remote site.

The configuration file stores these encrypted connection settings. When the configuration
file cannot be found, then the addin will assist you in creating a new one as follows:

  #. Start Recorder 6 and access the addin via **Tools > Indicia2Recorder** on the menu.
  #. The addin will detect that the configuration file is not present and will ask you
     **There is no configuration file available to define connection settings for the
     remote site. If you are an administrator wanting to create a connection file then
     please answer the following questions.**

  #. Click OK and a popup will appear asking you to fill in the site URL. Fill in the full
     domain name of the site including ``http://`` but excluding any trailing slashes or
     specific page details. If the website is operating in a sub-folder, include that
     subfolder in the URL. For example, you might specify ``http://www.mysite.com`` or
     ``http://www.brc.ac.uk/irecord``.

  #. Click OK and a further popup will appear asking you to fill in the Shared App Secret
     of the application. This setting is defined on the Indicia Mobile Auth settings page
     (under Site configuration > IForm > Mobile Authentication). You need to click the
     link to add a mobile application and fill in the form fields and save it. One of the
     fields is called **Shared Secret**. Copy the shared secret into the popup in Recorder
     6 and click OK.

  #. A further popup will appear asking you to fill in the Site ID for records to be
     created in Recorder. You should obtain a new Site ID for your remote site in the same
     way that you can obtain Recorder 6 site IDs, from Recorder resellers. It should be
     an 8 character string consisting of uppercase characters and digits only.

  #. Click OK and a final popup appears asking for the name of the site. This will be
     used to create appropriate labels on the addin's dialog. Click OK when you are done
     and the configuration file will be created.

  #. Click OK and a final popup appears asking for the Drupal version - enter either 7 or
     8.

.. tip::

  If you want to change the settings in your connection configuration, just delete the
  existing file from the disk (Public Documents or My Documents, the file you want is
  ``Indicia2Recorder\indiciaConnection.txt``. Now restart the addin and it will guide you
  through creating the file again.

Configuring known people
^^^^^^^^^^^^^^^^^^^^^^^^

During the import process, where a record can be attributed to a definite person (i.e. there
is a link to a record in the people table), then the person's ID will be used to create a
unique local ID in your Recorder 6 database. However, in the circumstance that the person
already exists in the Recorder 6 database, the addin cannot associate the records with the
correct Recorder 6 NAME_KEY because a match on name alone is not guaranteed to be unique.
There is also the circumstance where a name has been filled in against a record in free text,
either in the Recorder or Determiner field.

So, to allow these names to be easily resolved to known people in your Recorder 6 database you
can create a file called ``knownPeople.txt`` in your configuration file folder. In this file
put details of a person on each line, in the format ``surname,firstname=NAME_KEY``. You can
enter several permutations of a name on separate lines if required, e.g. to match the first
name Dave and David to the same person. Note that where you are aware of 2 active recorders
with a possible name clash, you cannot use this technique so may be best post-processing the
data in Recorder 6 to resolve any issues.

Configuring the import of custom attributes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Indicia has the ability for each online recording survey to define attributes which extend
the data model and it is possible to configure the import of attribute values into
Recorder 6. These custom attributes can be associated with occurrences or samples and can
capture any single piece of information. Custom attributes have a single caption property
which describes them.

.. note::

  You will need to be able to run queries against the Recorder 6 database in order to
  perform this configuration task.

In Recorder 6, the approach to extensible data is via the measurements system, with
equivalent tables to capture measurements against both the sample and occurrence. The
main difference though is that Recorder 6 measurements are described by 3 properties:

  * The measurement type - what are you measuring?
  * The measurement unit - units of measurement
  * The measurement qualifier - what exactly is the measurement of?

**Example 1** - An Indicia attribute called Count. In Recorder 6 this would map to
type=Abundance, unit=Count, qualifier=Unknown (since we don't have any information as to
what was counted.

**Example 2** - An Indicia attribute called Count of Larvae. In Recorder 6 this would map
to type=Abundance, unit=Count, qualifier=Larvae.

**Example 3** - An Indicia sample attribute called Surroundings linked to a termlist. In
Recorder 6 this could map to type=Description, unit=Term, qualifier=Surroundings.

So, before you can configure the addin to import any custom attributes from Indicia, you
first need to decide which custom attributes you are going to import and you need to then
create the required measurement types, units and qualifiers in Recorder to capture the
data. You can do this via Recorder 6's **Tools > Termlists** screen. Once you have done
this, follow the steps below to configure the import.

  #. In your ``Public`` or ``My Documents\Indicia2Recorder`` folder, alongside the
     indiciaConnection.txt file, create a text file called config.txt and open it in a
     text editor.
  #. In this file, you can insert mappings from an Indicia custom attribute to a Recorder
     6 measurement. To do this. start by typing ``smpAttr:`` or ``occAttr:`` for a sample
     attribute or an occurrence attribute respectively. Follow this with the ID of the
     custom attribute (read from the warehouse user interface screen which lists the
     attributes), then an equals sign.
  #. The mapping does not need to know the measurement type, since if you tell it the
     measurement unit or qualifier these both have pointers in the database to the
     correct measurement type. So, you need to find the respective keys for the
     measurement units and qualifiers that you have set up using a database query tool
     such as SQL Server Management Studio. Here is an example of the querying steps you
     might follow:

     .. code-block:: sql

       SELECT MEASUREMENT_TYPE_KEY FROM MEASUREMENT_TYPE WHERE SHORT_NAME='Abundance'
       -- this returned MEASUREMENT_TYPE_KEY='NBNSYS0000000004' so we copy that into the next 2 queries

       SELECT MEASUREMENT_UNIT_KEY FROM MEASUREMENT_UNIT WHERE SHORT_NAME='Count' AND MEASUREMENT_TYPE_KEY='NBNSYS0000000004'
       -- this returned MEASUREMENT_UNIT_KEY='NBNSYS0000000009'

       SELECT MEASUREMENT_QUALIFIER_KEY FROM MEASUREMENT_QUALIFIER WHERE SHORT_NAME='Adult' AND MEASUREMENT_TYPE_KEY='NBNSYS0000000004'
       -- this returned MEASUREMENT_QUALIFIER_KEY='NBNSYS0000000025'

  #. Now all you need to do is to paste the MEASUREMENT_UNIT_KEY after the equals sign,
     then add a comma and finally paste in the MEASUREMENT_QUALIFIER_KEY.
  #. Repeat steps 2-4 on a new line for each additional custom attribute then save it.

Mapping custom attribute values
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Because Recorder 6 has a limit of 20 characters for data values, sometimes Indicia data
values can be too long to import into Recorder 6. If so then you can create a mapping file
to force Indicia2Recorder to map values to a shortened version when imported into Recorder
6. To do this:

  #. Find the Indicia name of the attribute you want to map values for. This will be one
     of the keys in your config.txt file, e.g. occAttr:314 for the occurrence attribute
     with ID 314.
  #. Create a file in the ``Public`` or ``My Documents\Indicia2Recorder`` folder,
     alongside the indiciaConnection.txt file, with the same name as your Indicia
     attribute but without the colon and with TermMappings.txt appended, e.g.
     `occAttr314TermMappings.txt`.
  #. Edit this file and add 1 mapping per line. Put the Indicia value first, followed by
     an equals sign, then the equivalent you want imported into Recorder 6. For example
     the file might contain::

       Winter bat roost in a tree=roost (wntr, tree)
       Summer bat roost in a building=roost (smr, blding)

  #. Save the file and Indicia2Recorder will map the values next time you import. Any
     values not in the mappings file will be imported in their original form.

Usage
-----

To use the addin, you will first need a login to iRecord. A standard login will allow you
to download your own records only, but if you are an LRC or verifier then you will be able
to download records within your area or iRecord expertise settings respectively. Currently
sensitive records are excluded from the download.

You will need to create a survey in Recorder 6 in which to store your records. To do this,
use the **Tools > Termlists** screen to create a survey type term called Indicia:

  #. Click on **Tools** then select the **Termlists** menu item.
  #. In the **Select List** box, choose Survey Type.
  #. Check if Indicia appears in the list of terms. If not, then continue with the
     following steps.
  #. Click the **Add** button.
  #. In the **Short Name** box, type Indicia.
  #. Click **Save**.

Once you have the survey type setup, you can create a survey and set the Survey Type to
Indicia, ready to import records into.

In Recorder 6, start the addin by selecting **Tools > Indicia2Recorder** from the menu.

.. image:: ../../images/screenshots/applications/indicia2recorder.png
  :width: 600px
  :alt: The addin dialog

The first step required is for you to fill in your email address that you registered on
the Indicia website with and your account password, then click **Login**. The addin will
then connect to the Indicia website and check your access rights. It can then populate the
various options for what you are able to download below.

Once logged in, you simply need to select whether to include your own, your verification
or your LRC records (if available), the survey on the Indicia website you want to import
records from, the date range, and the target survey then click **OK**. The addin will do
the rest.

Click the **Cancel** button to close the dialog when you are finished.

Importing batches of surveys
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As it can be laborious to import several surveys one at a time, if you know the Indicia
survey IDs and the Recorder survey keys for a list of surveys you want to import and their
destinations, you can preconfigure batches of surveys which will import in one go. Here
are the steps required to configure this:

  1. In your ``Public`` or ``My Documents\Indicia2Recorder`` folder, alongside the
     indiciaConnection.txt file, create a text file with a name that describes the batch
     of surveys and with a suffix `.batch` and open it in a text editor.
  2. Each pairing of an Indicia survey dataset to the Recorder 6 survey it will import
     into needs to go on its own line in the file. Start with the ID of the survey
     dataset in Indicia (available from **Lookup lists > Survey datasets** on the
     warehouse). Follow this with an equals sign, then the Recorder 6 survey key this will
     import into. For example::

       14=MYRECKEY01234567
       16=MYRECKEY76543210

  3. Now, the file name of the batch will appear in the list of surveys available to
     import - if you pick this survey and import it, the batch file will instruct
     Indicia2Recorder to import the full set of surveys you have configured.

Record Management
^^^^^^^^^^^^^^^^^

When you download records from an Indicia website using this addin, as long as other
Recorder 6 users doing the same use the same connection configuration file then their
downloaded records will get the same NBN Keys as the ones you download. Therefore these
will be understood by Recorder as the same record and if you exchange data with other
Recorder 6 users it will not create duplicate records. This also means that you can
download a set of records multiple times and Recorder 6 will not create duplicates -
subsequent downloads will overwrite the existing records. This means that if any record
changes are required, making them on the top copy in the Indicia dataset then downloading
into Recorder 6 ensures that changes are available to other Recorder 6 users.

