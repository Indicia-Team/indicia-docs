*******************************
Importing a Darwin Core Archive
*******************************

This tutorial guides you through the process of importing from an example Darwin Core
Archive file. As the steps involve the manual preparation of the survey dataset to import
into as well as the data file for upload, the principles can be applied to data from a
variety of sources.

Before proceeding, ensure you have created a new Survey dataset on the warehouse ready
to configure. You should also have a taxon list created ready.

The DwC file contains a meta.xml document which for our example lists the
following columns for 2 different classes. Each DwC file may contain different columns so
you'll need to use the steps below as a guide rather than to exactly copy it:

Class: http://rs.tdwg.org/dwc/terms/Event
-----------------------------------------

In Indicia, DwC events map to the samples entity. Here's an example text file containing
a single record from our example DwC archive::

id	eventID	samplingProtocol	eventDate	countryCode	decimalLatitude	decimalLongitude	geodeticDatum
2010-3-27:858	2010-3-27:858	Point/Punkt	2010-03-27 11:00:00+00	SE	59.0329	17.31623	WGS84

Columns
^^^^^^^

  * **id** - as this is duplicated by eventID we can ignore this column and remove it from
    the import file so there is no confusion when the data are merged with the occurrence
    data.
  * **http://rs.tdwg.org/dwc/terms/eventID** - a unique, externally generated identifier
    for the event which we can map to samples.external_key.
  * **http://rs.tdwg.org/dwc/terms/samplingProtocol** - the method or protocol used. We
    can either create a custom attribute with the system function set to "Sample method",
    or use the `samples.sample_method_id` field which points to a predefined termlist
    called "Sample Methods". Using the `sample_method_id` rather than a custom attribute
    allows us to do things like dynamically configure recording forms according to the
    chosen protocol, but has the disadvantage that there is a single global list of
    sample method terms. If a specialist local list of terms is required for the
    protocols in a survey dataset then a custom sample attribute with its own termlist is
    a better approach. For our example import, we add the distinct terms in this column
    to the "Sample Methods" termlist. To do this:

      * Go to **Lookup lists > Termlists** in the menu.
      * Set the filter to "Filter for **Sample methods** in **Title**" and apply the
        filter.
      * Edit the termlist.
      * On the **Terms** tab, click **New term**, fill in the **Term** field then save it
        and repeat for each term.

    Note you could also import terms from CSV if you had lots to add.
  * **http://rs.tdwg.org/dwc/terms/eventDate** - the date of the sampling event which can
    be mapped to the built in sample date fields. Either remove the time from the values
    in the import file, or split it into a 2nd column called Time and import this into
    a new sample custom attribute.
  * **http://rs.tdwg.org/dwc/terms/countryCode** - we're going to create a sample custom
    attribute to capture this value, using the list of ISO 3166-1-alpha-2 country codes as
    terms for a lookup. Use the option to create a new termlist when creating the
    attribute and paste in the list of codes. Also set the **Term name** to
    "countryCode" and the **Term identifier** to "http://rs.tdwg.org/dwc/terms/countryCode"
    to maintain the association between the Indicia custom attribute and the DwC field.
    Also note that the custom attribute must be linked to the survey dataset you plan to
    import into (using the checkboxes at the bottom of the form).
  * **http://rs.tdwg.org/dwc/terms/decimalLatitude** and **http://rs.tdwg.org/dwc/terms/decimalLongitude**
    can be mapped to `samples.entered_sref`. We need to combine the 2 values into a single
    field using a simple spreadsheet formula so that decimalLatitude 59.17822 and
    decimalLongitude 17.41426 would be formatted as a single value "59.17822N 17.41426E".
  * **http://rs.tdwg.org/dwc/terms/geodeticDatum** - our file contains the value WGS84 for
    all fields. For latitude and longitude data, Indicia requires the SRID of the
    projection which is imported into `samples.entered_sref_system`, in this case the
    value should be 4326. So a new column is added to the spreadsheet for this value which
    is replicated for all columns.

Class: http://rs.tdwg.org/dwc/terms/Occurrence
----------------------------------------------

Here's an example text file containing a single record from our example DwC archive::

  id	basisOfRecord	individualCount	eventID	eventDate	scientificNameID	scientificName	kingdom	taxonRank
  2010-3-27:858	HumanObservation	1	2010-3-27:858	2010-03-27 11:00:00+00	201058	Colias hyale	Animalia	species

Columns
^^^^^^^

  * **id** - in order to be able to cross reference back to the source, we store this
    value in `occurrences.external_key` since Indicia always generates its own unique
    record IDs.
  * **http://rs.tdwg.org/dwc/terms/basisOfRecord** - we can create an occurrence custom
    attribute called "Basis of record" with the data type set to "Lookup", using the
    option to create a new termlist when the attribute is saved. The terms in the termlist
    can be populated from the suggested Darwin Core class names, i.e.:

      * LivingSpecimen
      * PreservedSpecimen
      * FossilSpecimen
      * HumanObservation
      * MachineObservation

    The **Term name** field can be set to "basisOfRecord" and the **Term identifier**
    field can be set to "http://rs.tdwg.org/dwc/terms/basisOfRecord" in order to preserve
    the association between the custom attribute and the associated field in DwC. Also
    note that the custom attribute must be linked to the survey dataset you plan to import
    into (using the checkboxes at the bottom of the form).
  * **http://rs.tdwg.org/dwc/terms/individualCount** - we can create an occurrence custom
    attribute to capture the individualCount values. Assuming all the values are integers
    then the data type should be set to "Integer" but in some cases it may be necessary to
    use the "text" data type to capture more messy data. Set the **Term name** to
    "individualCount", the **Term identifier** value to
    "http://rs.tdwg.org/dwc/terms/individualCount" and the **System function** to "Count
    or abundance of a sex or life stage" to link it to the DwC field and identify it as
    holding abundance values. Also note that the custom attribute must be linked to the
    survey dataset you plan to import into (using the checkboxes at the bottom of the
    form). Finally, you can add a validation rule so that the minimum value allowed is
    0, to prevent negative counts being imported.
  * **http://rs.tdwg.org/dwc/terms/eventID** - does not need to be imported into the
    occurrences data as it will be identified by a link to the sample. This can be removed
    from the import file *after merging the occurrences and event data as described
    below*.
  * **http://rs.tdwg.org/dwc/terms/eventDate** - as **eventID**.
  * **http://rs.tdwg.org/dwc/terms/scientificName** - will be mapped to the record's
    identification during the import.
  * **http://rs.tdwg.org/dwc/terms/kingdom**, **http://rs.tdwg.org/dwc/terms/taxonRank**
    and **http://rs.tdwg.org/dwc/terms/scientificNameID** should be stored within the
    species list data in Indicia so are not required as import columns. They can be left
    in the file or deleted to keep things a bit simpler.

We now need to merge our events.txt file and occurrences.txt file into a single CSV file,
using the eventID to join the 2 files. Here's an explnation of one possible approach:
https://www.ablebits.com/office-addins-blog/2018/11/14/excel-join-tables-power-query/.

Combined with the above suggested column mappings, the resulting file should look like the
following::

  eventID	samplingProtocol	eventDate	countryCode	decimalLatitude	decimalLongitude	lat/lon	geodeticDatum	id	basisOfRecord	individualCount	scientificName
  2010-3-27:858	Point/Punkt	2010-03-27	SE	59.0329	17.31623	59.0329N 17.31623E	WGS84	2010-3-27:858	HumanObservation	1	Nymphalis antiopa

This can be saved as a CSV file then imported into the **Observations data > Occurrences**
page on the warehouse.