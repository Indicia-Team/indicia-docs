Verification 5
==============

The 5th version of Indicia's record verification tool, allowing experts to assign their
view of a record's quality.

.. todo::

  Complete documentation.

Occurrence metadata
-------------------

Sometimes when processing records, it is useful to be able to assign flags regarding a
record's status which are really just information regarding the processing of the record,
not part of the record's data. Therefore it would not be appropriate to store this
information in standard custom attributes which are shown in many reports shown to the end
users. Storing such metadata flags can be achieved using the **Custom occurrence
metadata** configuration in the **Other Iform Parameters** section of the page's Edit tab.
Click the **Add field to fields list** link to add a field, then give it a title. If you
save the page now you will have added a free text input box and Save button to the details
pane shown for each record. You can optionally set a list of values to pick from by
specifying key=value pairs in the **Values** box, e.g.::

  P=Pending
  I=In progress
  C=Complete

Now, a drop down select input control will be added to the detais pane instead.