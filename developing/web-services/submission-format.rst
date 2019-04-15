Data Submission Format
======================

Before reading this section, don't forget that the Indicia client helpers API has
functions built in for automatically handling the submission format. This section might
be useful if you are planning on building your own Indicia client code.

Data is submitted to the warehouse using JSON strings. Each JSON object must contain an
**id** property containing the name of the model to post into, plus a **fields** property
containing a list of the field values to update or insert. The **fields** list contains
each field name with a sub-object containing a **value** entry for each value. The basic
form of this structure looks like the following:

.. code-block:: json

  {
    "id" : "{model}",
    "fields" : {
      "{field1}" : {"value" : "{value1}"},
      "{field2}" : {"value" : "{value2}"}
    }
  }

You might of course want to build this submission format by creating an array or object
then using the JSON encoding features of your chosen development language.

.. tip::

  If you provide the **id** field's value in the **fields** array, then this will prompt
  the warehouse to lookup and edit an existing record rather than insert a new one. When
  doing so, you only need to provide the values which have changed, you don't need to
  provide a complete record.

Value data types
----------------

When passing your values, ensure you consider the following depending on the data type for
each field you pass:

  * **dates** - to ensure there is no possibility of i18n issues with different server
    setups, it is recommended that dates are passed in yyyy-mm-dd format, e.g.
    '2013-06-15'.
  * **booleans** - pass the string 't' or 'f' for true and false respectively.

Sending custom attributes
-------------------------

To send a custom attribute value in a submission, specify field names of the format
``(smp|occ|psn|loc|srv)Attr:attrId``. So, for example you might have a custom sample
attribute ID 14 which holds the count for a record. To submit a value of 3, include the
following in your JSON fields list:

.. code-block:: json

  "smpAttr:14" : {"value" : 3}

If you need to re-submit an existing custom attribute value, then simply specify the
ID of the existing custom attribute record in the field name (with each token separated
by colons). For example:

.. code-block:: json

  "smpAttr:14:12345" : {"value" : 3}

If you are submitting a value for an attribute which has the allow ranges flag set so that
the value can store a lower and upper range value, then there are 2 methods of submitting
values. Submission can occur in a single text string with the 2 range values separated by
" - ":

.. code-block:: json

  "smpAttr:14" : {"value" : "3 - 5"}

Or, submit 2 separate values adding ":upper" to the key for the 2nd. This approach is
useful where your form has 2 inputs for the from ... and to ... values:

.. code-block:: json

  "smpAttr:14" : {"value" : 3}
  "smpAttr:14:upper" : {"value" : 5}

Finally, if you are submitting multiple values for a single custom attribute such as from
a list of checkboxes, then the 4th part of the fieldname can be a unique index for each
value (or anything you like to make the fieldname unique:

.. code-block:: json

  "smpAttr:14::0" : {"value" : 3}
  "smpAttr:14::1" : {"value" : 8}
  "smpAttr:14::2" : {"value" : 13}

Alternatively, on initial submission of a multi-valued custom attribute you can simply
pass an array of the values, so the above could be written as:

.. code-block:: json

  "smpAttr:14" : {"value" : [3, 8, 13]}

This shorthand approach doesn't work when re-submitting existing custom value attributes
after loading a record to edit, because you need to pass through the existing record IDs
(in this case, the relevant attribute_values table record IDs) as the 3rd part of the
fieldname. The fieldnames are now unique so there is no need to provide a unique index in
the 4th element; if you do it will simply be ignored. Therefore a resubmission of the
above data might look like:

.. code-block:: json

  "smpAttr:14:98" : {"value" : 3}
  "smpAttr:14:99" : {"value" : 8}
  "smpAttr:14:100" : {"value" : 13}

If you need to delete custom attribute values you have to resubmit only the values you want to
keep, eg. if you want to delete the attribute with the value "13" from the above example you
have to have a submission like this:

.. code-block:: json

  "smpAttr:14:98" : {"value" : 3}
  "smpAttr:14:99" : {"value" : 8}

Note, that if you wan to delete all values you need a submission like:

.. code-block:: json

  "smpAttr:14" : {"value" : ""}

else the values keep untouched.

Automatic foreign key lookup
----------------------------

You will often need to submit field values which are IDs that relate to records in other
tables, for example:

  * when submitting a sample location the location_id needs to point to a record in the
    ``locations`` table.
  * when submitting a custom attribute of type lookup, the custom attribute value must
    point to a value in the ``termlists_terms`` table.

In all cases, if possible you should keep a lookup table of the IDs you will need to
submit in these fields in your client website, so that submitting records is as fast as
possible. However, if for some reason this is not practical Indicia provides an automatic
lookup facility to fill in the foreign key values for you.

If you need to automatically lookup a value to fill in a foreign key in the record being
saved, then specify a field called **fk_fieldname** which contains the lookup value. We'll
take the example of submitting a location with a parish location type to explain this, but
this technique applied to any other field holding a foreign key to another table,
including custom attribute lookup values. If we knew the location_type_id which refers to
parish, then we might specify a submission such as the following:

.. code-block:: json

  {
    "id" : "location",
    "fields" : {
      "name" : {"value" : "{value1}"},
      "location_type_id" : {"value" : 15}
    }
  }

However, if we don't know the location type ID for parish, then we can specify a foreign
key lookup as follows:

.. code-block:: json

  {
    "id" : "location",
    "fields" : {
      "name" : {"value" : "{value1}"},
      "fk_location_type_id" : {"value" : "parish"}
    }
  }

An issue here is that this will be a lookup against the content of the ``termlists_terms``
table (in fact, it uses one of the views to ensure that the term is available to lookup
against). ``Termlists_term`` here could be an entry for parish in a different termlist
so to ensure that the correct entry is found, we need to filter the lookup as follows:

.. code-block:: json

  {
    "id" : "location",
    "fields" : {
      "name" : {"value" : "{value1}"},
      "fk_location_type_id" : {"value" : "parish"},
      "fkFilter:termlists_term:termlist_id:" : {"value": 5}
    }
  }

In this example we are filtering for termlists_id=5 (which could be the location types
list).

Super and sub-models
--------------------

In Indicia, a very common type of submission is a biological record which will normally
require the insertion of both a sample and occurrence record in the database. Although
it is perfectly feasible to submit the sample first then the occurrence linking the
occurrence to the returned sample ID, in practice this incurs an additional network
request and therefore is not ideal for performance. Things get even worse when you
send submissions for a whole grid of records.

The solution is to embed *submodels* into your submission, making a single submission
which describes a hierarchy of records. This can be achieved as in the following example:

.. code-block:: json

  {
    "id" : "sample",
    "fields" : {
      "date" : {"value" : "2013-06-05"},
      "entered_sref" : {"value" : "SU998877"},
      "entered_sref_system" : {"value" : "OSGB"}
    }
    "subModels" : [{
      "fkId" : "sample_id",
      "model" : {
        "id" : "occurrence",
        "fields" : {
          "taxa_taxon_list_id" : {"value": 12345},
          "occAttr:14" : {"value": 3}
        }
      }
    }, {
      "fkId" : "sample_id",
      "model" : {
        "id" : "occurrence",
        "fields" : {
          "taxa_taxon_list_id" : {"value": 54321},
          "occAttr:14" : {"value": 1}
        }
      }
    }]
  }

Each submodel entry declares the field in the subModel table which holds the foreign key
linking the created row to the parent table in the `fkId` field. It will normally be set
to the parent table's `id` field but can be set to a different field's value by providing
the field name in an entry called `fkField`.

Note that the entry within the "model" property is a submission structure just like the
submission at the top level. This can be hierarchical, so you could for example submit
a transect with a parent sample containing a sub sample for each recorded point along the
transect, each containing a list of records.

Given the hierarchical nature of the data, the ability to submit whilst traversing up the
data model using a "supermodel" might seem illogical. In fact it is a special case
required to support the generation of a ``taxon_meaning_id`` or ``meaning_id`` when
submitting species or term entries. The structure is identical but uses the key
``superModels`` rather than ``subModels``. This results in a foreign key being populated
in the record you are submitting with the ID of a new record generated in the parent
table.

A real example
--------------

The following submission structure gives a real example of this all in action. Note that
the geom field is filled in with the WKT text for the polygon; this can be ommitted and
it will be calculated on the server if preferred.

.. code-block:: json

  {
    "id":"sample",
    "fields":{
      "website_id":{"value":"1"},
      "survey_id":{"value":"1"},
      "entered_sref":{"value":"SP41"},
      "geom":{"value":"POLYGON((-158240.806825904 6761745.97504841,-158112.504644672
          6777941.30688427,-141943.016288715 6777796.17577468,-142103.477852791
          6761601.59748373,-158240.806825904 6761745.97504841))"},
      "entered_sref_system":{"value":"OSGB"},
      "date":{"value":"2013-06-13"},
      "comment":{"value":"This is an example record"},
      "smpAttr:3":{"value":"158"},
      "smpAttr:41":{"value":""},
      "input_form":{"value":"node\/69"}
    },
    "subModels":[
      {
        "fkId":"sample_id",
        "model":{
          "id":"occurrence",
          "fields":{
            "zero_abundance":{"value":"f"},
            "taxa_taxon_list_id":{"value":"30"},
            "website_id":{"value":"1"},
            "record_status":{"value":"C"}
          }
        }
      },
      {
        "fkId":"sample_id",
        "model":{
          "id":"occurrence",
          "fields":{
            "zero_abundance":{"value":"f"},
            "taxa_taxon_list_id":{"value":"34"},
            "website_id":{"value":"1"},
            "record_status":{"value":"C"}
          }
        }
      }
    ]
  }

