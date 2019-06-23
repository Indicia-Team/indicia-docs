Verification 5
==============

The 5th version of Indicia's record verification tool, allowing experts to assign their
view of a record's quality.

.. todo::

  Complete documentation.

Managing permissions
--------------------

By default, a verifier can see all records. In this situation they can create their own
filters for any subsets of the records but are able to view anything. For most verifiers
though, you want to create a filter e.g. to limit the butterfly expert to butterfly
records. If you do this using a permissions filter, they will only be able to see
butterfly records so cannot verify any other data. They can still create their own
filters, but they won't be able to filter to see any records outside the group they are
restricted to. This is the typical setup you want for most verifiers I think. However, in
some cases you may have someone who is verifying more than one set of records, e.g. the
butterfly expert might also do bumblebees, in which case you can create several
permissions filters for the one person. In this situation, they get an extra "Context"
drop down, which allows them to select from the different permissions filters, so they
might spend one working session on butterflies and another on bumblebees

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