************************************************
Extending Indicia to support new spatial systems
************************************************

Indicia can support data entered as an x, y coordinate or in a local notation such as
British National Grid or MTB. If an x, y coordinate system is required which is not one
of the list supported in Indicia, then you will first need to know the EPSG code for your
projection. You should be able to find this online. You can enter a comma separated list
of EPSG codes into your Drupal IForm Settings page (under **List of spatial or grid
reference systems**) or, on a form by form basis on the form's edit tab under **Other Map
Setting > Allowed Spatial Ref Systems**. This enables an option to use this projection
when inputting coordinates (or clicking on the map) which is the bare minimum you'll need
to in order to submit records using your projection. Additional things you might like to
do include:

1. Edit the client_helpers/lang/default.php file to add a language string with the key
   `epsg:nnnn` where nnnn is your EPSG code. The language string provided will allow
   Indicia to show a sensible name for your projection rather than just a number.
2. Edit the IForm module's list of declared systems to add it to the IForm settings
   configuration page (`iform.admin.inc` in Drupal 7, `Settings/Form/Settings.php` in
   Drupal 8).
3. The reprojection code used by Indicia will obtain the details for projections which it
   does not recognise from a remote online repository. However to reduce network traffic
   and improve reliability it is better to create a local definition. This can be added to
   `media/js/proj4defs.js` and the definitions themselves can be obtained from
   `spatialreference.org <https://spatialreference.org/>`_.

Finally to support the projection properly on the warehouse, add the details required to
`application/config/sref_notations.php`.

If you need to add a new grid reference notation then there is an additional task to write
scripts which translate the notation to and from