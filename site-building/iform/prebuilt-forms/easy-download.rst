Easy Download
=============

The Easy Download form provides a simple way to download records in CSV or `NBN Exchange
<http://www.nbn.org.uk/Share-Data/Providing-Data/NBN-Data-Exchange-format.aspx>`_ format.
The records available are either those belonging to the logged in user or those which the
user is an expert for defined in their account profile. Note that this is designed to
integrate with the :doc:`../modules/indicia-features/easy-login` method rather than
other methods of identifying who the recorder for a record is.

The download form provides a start and end date to define the range of records downloaded
as well as a survey selection drop down, although it can also be configured to always
download records from a single survey.

.. image:: ../../../images/screenshots/prebuilt-forms/easy-download.png
  :width: 700px
  :alt: The Easy Download prebuilt form

Configuration options
---------------------

The following configuration options are useful when setting up an **Easy Download** page:

* **View access control** and **Permission name for view access control** - as described
  under :doc:`generic-settings`.
* **Permission required for downloading other people's data if you have expertise** - this
  defines a Drupal permission that, if the user has it, enables the option to download
  other people's data.
* **Allow my data download** - use this to enable downloading of the user's own records.
* **Allow expert's data download** - use this to enable downloading of records that an
  expert has expertise over.
* **Allow all data download** - use this to enable downloading of all records.
* **Survey for download** - select a specific survey to enable download for, or leave
  to allow the user to select.
* **CSV format download?** - enable this to allow downloading using CSV file format for
  spreadsheets.
* **NBN format download?** - enable this to allow downloading using NBN exchange file
  format for submission to the NBN Gateway.
* **Survey for download** - select the survey to be available for download, or leave blank
  to allow the choice.
* **CSV Download format report** - a report used to obtain the data for CSV download.
  Normally you should leave the default report selected. *If you select another report
  then you will need to ensure it has compatible input parameters*. Note that you can
  add custom attributes to the report using the **CSV Additional parameters** setting.
* **CSV Additional parameters** - default parameters for the download report. Note that
  the special parameters **smpattrs** and **occattrs** can be configured to contain one of
  the following:

  * a comma separated list of attribute IDs to download for sample or occurrence custom
    attributes.
  * a comma separated list of attribute system function names to automatically pick the
    attribute for each downloaded survey which fulfils a certain function in the survey.
    Each system function name must be prefixed with a # character.
    For sample data, choose from email, cms_user_id, cms_username, first_name, last_name,
    full_name, biotope, group_id. For occurrence data, choose from sex_stage, sex, stage,
    sex_stage_count, certainty, det_first_name, det_last_name, det_full_name.
  * Instead of or as well one of the above, specify #all_survey_attrs to specify that all
    survey attributes except email and cms_user_id will be included. This only takes
    effect when the user has chosen a single survey to download.

  The **quality** option allows you to set the minimum quality required for records to be
  included in the download. Choose from:

    * !R = anything not rejected
    * !D = anything not rejected or dubious
    * L = records not rejected or dubious and that are at least likely as set by the
      recorder (or certainty is not recorded)
    * C = records that not rejected or dubious and that are marked certain by the recorder
    * V = only verified records.

* **NBN Download format report** - as for the above, but defines the report used for NBN
  exchange format downloads. Should normally be left to its default setting.
* **NBN Additional parameters** - as described above but for NBN download format report
  parameters. Note that the default behaviour is to download only verified records in
  NBN format though this can of course be overridden.
* **Limit to number of records** - define a maximum number of records for download.
  Default is 20000.

Example scenario 1
------------------

To provide a download page for the coordinators of a specific survey, you might:

#. Set up an Easy Download page.
#. Set the **View access control** option and set the permission name to **<survey name>
   download** where survey name is the name of the specific survey.
#. Set the **Survey for download** option to the specific survey.
#. Uncheck the **Allow my data download** option.
#. Set the **smpattrs** and **occattrs** options in the additional parameters sent to each
   report to a comma separated list of the sample attribute IDs and occurrence attribute
   IDs respectively.
#. Add the page to an appropriate place in the menu system, noting that users who do not
   have access to the form will not see the menu item.
#. Set up a role called **<survey name> coordinator** and put the coordinators of the
   survey into this role.


Example scenario 2
------------------

To provide a download page for the someone who has a regional collation of records such
as a local record centre:

#. Use the SHP file upload facilities on the warehouse's Locations list to upload a list
   of the regional boundaries that are being collated for, eg. the boundaries of each LRC.
   Set the boundaries to a location type **LRC boundary**, creating the term if it does
   not already exist.
#. Enable the Easy Login module.
#. On the **Configuration > Indicia integration > Indicia settings** page in Drupal, scroll to the bottom.
   Set the **Location Type for profile collation options** to the term you created for
   location types, e.g. "LRC Boundary".
#. Add a new Easy Download page. Set the **View access control** option and set the
   permission name to "collate regional records".
#. Make sure **Allow my data download** and **Allow expert's data download** are unticked
   and **Allow all data download** is ticked.
#. Enable the options for **CSV format download?** and **NBN format download?** as you
   require.
#. Edit the setting for **CSV Additional parameters** by adding::

     ownLocality=1
     location_id={profile_location_collation}

   This forces the report to be filtered to the user's collation location boundary,
   because the default report used for download uses these 2 input parameters.
   Repeat this for the **NBN Additional parameters**.
#. Add the users you want to download to the **Regional Collator** role. After adding the
   role and saving, go to their **Preferences** page and edit their **Location of
   collation** to select the boundary this user is allowed to download. Save their
   profile.
#.