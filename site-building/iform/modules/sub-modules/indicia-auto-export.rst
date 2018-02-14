Indicia Auto Export module
--------------------------

.. note::

  This module is currently available for Drupal 7 only.

The Indicia Auto Export module allows the automation of the creation of export files
from your Indicia records. An example use case is the export of records to the NBN Atlas
or other national portal aggregating records. To use this module you will need admin
rights and should follow the steps below:

* Enable the module as normal on the Modules page in your Drupal 7 install.
* In a standard Export page, create a filter which defines the records you want to export
  and save it, making sure you give the filter a recognisable name, e.g. the name of the
  exported dataset.
* Now, select Content > Add content > Indicia auto export from the menu and fill in the
  details of the export:

  * Title of your export configuration.
  * Description (optional).
  * Schedule - set to one of the available schedules for regeneration of the export file.
  * Format - choose an export format. If using the Darwin Core Archive format, then
    you must ensure the report used for the export is compatible with DwC and also
    consider populating the EML field described below.
  * EML - if exporting to Darwin Core Archive (DwC-A) format, then you can optionally
    provide the contents of an Ecological Metadata Markup file to include in the archive.
    This is further described in the Darwin Core Archive documentation.
  * Dataset ID - optional. Will be used to define the generated file's filename if
    specified, otherwise the title is used.
  * Report path - path to the report file to use on the warehouse. The default is
    suitable for export to the NBN Atlas in Dwc-A format.
  * Indicia filter - search for and select the filter you created earlier.

* Save the content when ready.
* The content will be triggered as appropriate for the schedule and will be saved to your
  Drupal file folder (private is used if configured), in the indicia/exports subfolder.
* To trigger a manual export, visit the path indicia_auto_export/process/nid, replacing
  nid with the ID of your Drupal export content node.

.. tip::

  Create a view of the Indicia Auto Export content with an edit link in a column to
  allow a quick overview of the exports. You can include a trigger link for manual
  exports.