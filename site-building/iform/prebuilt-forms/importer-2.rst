Importer 2
----------

The Importer 2 page type provides a wizard similar to the original Importer page type but with a
few differences:

  * Importer 2 only supports importing occurrence data currently.
  * Importer 2 detects terms and species names in the import file that don't match any term or
    species in the database lookups, then allows the user to provide mappings to fix mismatches
    before the import is processed.
  * Importer 2 does a full validation check on all rows before importing anything.
  * Importer 1 required data from the same sample to be located in adjacent rows in order to be
    detected as such, Importer 2 does not have this requirement and can detect rows from the same
    sample across the entire import dataset.
  * Importer 2 does not create the `cache_*` table entries on the fly; instead they are queued
    making the initial import faster, but meaning that data may not be available for importing
    immediately after import.
  * Metadata about v2 imports are saved to the `imports` table.
  * The v2 importer supports importing zipped CSV or Excel files.
  * The v2 importer supports importing multiple files of the same structure in a single batch.

Architecturally, the big difference between the v1 and v2 importers is that v1 keeps the data
being imported in a spreadsheet and works through the data in order. V2 moves the data into a data
table in the database and can therefore perform additional manipulations and prechecking of the
data more easily.

Notes on the options for the Import 2 page type:

  * "Enable background imports" - when this option is enabled, large import files are queued in the
    warehouse's work queue and processed in the background. There is then no need to leave a page
    open for the import to continue processing as it happens independently of the user's browser;
    the user is notified by email on completion.
  * If using the background import option, the "Background import status path" option should be set
    to a page which has the type "Background import status". See
    :doc:`background-import-status`