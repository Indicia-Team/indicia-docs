Adding a map control
--------------------

The essentials of a typical biological record are generally understood to be
**who**, **what**, **where** and **when**. These correspond to the following
things that we want to capture on our record form.

* recorder
* species
* grid ref or other spatial ref and optional site
* date

.. note::

  Indicia has a special take on its interpretation of the essentials of a
  biological record. We strongly believe that it is perfectly valid to build
  a recording system aimed solely at educating and inspiring future recorders.
  Therefore we consider the recorder field to be optional, so that you might,
  for example, build a form aimed at children which captures no recorder data.
  We also allow the recording of any taxon, not just species, including
  non-taxonomic colloquialisms such as "water bird" or "flying insect".
  The resultant information does not really constitute a biological record in
  the purest form but as long as we understand and use the records only as
  appropriate this does not matter.

To finish off the essentials of our record input form, we need to add at least
a method of inputting a grid reference. We are going to use the sref_and_system
and map_panel functions to create a grid reference input box and a supporting
map by inserting the following code into your PHP block:

.. code-block:: php

  <?php
  ...
  echo data_entry_helper::sref_and_system(array(
    'label' => 'Grid Ref',
    'fieldname' => 'sample:entered_sref',
    'systems' => array('osgb'=>'British National Grid')
  ));
  echo map_helper::map_panel(array(
    'presetLayers' => array('google_streets','google_satellite')
  ));
  ...
  ?>

Because you are now also using the `map_helper` class, you need to add the following to your code
near the top of the PHP (just under the line which includes the `data_entry_helper.php` file:

.. code-block:: php

  <?php
  require_once 'client_helpers/map_helper.php';
  ?>

Save your PHP file and reload the form in your browser. With any luck, a map
has appeared for the Google street map layer, centered over the UK. There
are pan and zoom controls, drag, double click to zoom and shift drag to zoom
features as well as a layer switcher in the top right of the map (click the +
button). There are of course lots of options to configure the mapping behaviour
but this tutorial is about the basic requirements of an online recording form
so we'll leave those for another time. Now, try inputting a British National
Grid reference into the Grid Ref box, then pressing the tab key to move out of
the control. You should find that the map highlights the input grid reference
and zooms in.

.. note:

  This sort of visual confirmation of user input is the reason why online
  recording can mean the end of incorrectly transcribed grid references and
  other similar mistakes. A real time saver for anyone who is tasked with
  cleaning up the data...

You can also try clicking on the map to set a grid reference - you no longer
need to know how grid references work to input them!

.. tip::

  At the moment, the layout of your controls on the form is a bit haphazard.
  Try adding a call to ``data_entry_helper::link_default_stylesheet();`` before
  the ``dump_javascript()`` call to request that Indicia includes its standard
  stylesheets which will give a good starting point for improving your form
  layout. This also does things like colour the mandatory control asterisks
  red and other generally useful styling.