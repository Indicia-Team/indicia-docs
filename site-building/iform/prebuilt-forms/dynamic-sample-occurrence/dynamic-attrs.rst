Dynamic taxon-linked custom attributes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Custom attributes can be dynamically loaded onto data entry forms according to the
selected taxon. For example, when entering a dragonfly record into a generic form you may
wish the life stage attribute use a lookup list that is specific to dragonflies. This
functionality requires the warehouse to be at version 2 or higher and the develop branch
of the client code.

  #. Create the attribute you want to use on the warehouse (**Custom attributes > Occurrence
     attributes**).
  #. Attach the attribute to the survey dataset you are recording into (either by ticking
     the dataset's checkbox on the attribute's edit page, or via **Observations data >
     Survey datasets > setup attributes**).
  #. Go to the attribute's survey specific settings page (via the button on either the
     attribute's edit page, or via **Observations data > Survey datasets > setup
     attributes**). In the Taxon restrictions grid at the bottom of the page enter the
     higher taxa you want to link the attribute to (e.g. Odonata) then save the page.
  #. Create a data entry form on your client site using the **Data entry forms > Enter
     single record or list of records (customisable)** form. Set it up as you would any
     other data entry form and link it to your survey dataset. Configure the species data
     entry for adding a single record at a time.
  #. In the form structure content, place the control [species dynamic attributes] where
     you want to output the dynamic attributes. Now, when any taxon within your selected
     higher taxon is selected for data entry, the correct attributes should load onto the
     form.

[species dynamic attributes] options
------------------------------------

The [species dynamic attributes] control can be configured with the following options:

  * @types - set to an array containing either or both of ["occurrence","sample"] to
    determine whether occurrence and/or sample custom attributes are to be included. Using
    this option it is possible to separate sample and occurrence attributes into separate
    areas on the form, for example.
  * Any options which are prefixed with the attribute ID (occAttr:n or smpAttr:n) followed
    by a pipe character will be passed through only to the custom attribute control which
    matches the ID. E.g. `@occAttr:4|caption=Altered caption`.
  * Any other parameters are passed through to all the output custom attribute controls.

.. tip::
  Behind the scenes, a call is made to the report
  `library/occurrence_attributes/occurrence_attributes_for_form.xml` or
  `library/sample_attributes/sample_attributes_for_form.xml` with the following parameters
  to retrieve details of the attributes that should be loaded onto the form:

    * survey_id
    * taxa_taxon_list_id
    * master_checklist_id (15 for the BRC warehouse1).
