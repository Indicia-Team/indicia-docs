Setting up a recording form for a local nature reserve
------------------------------------------------------

.. note::

  This page needs further work!

.. sidebar:: Prerequisites

  Before following this tutorial you need a website running Drupal 7 or 8 with the
  IForm module installed.

This tutorial guides you through the steps required to add a recording form for a local
nature reserve to a Drupal website. We are going to follow through the addition of a
recording form for the Wort's Meadow nature reserve to iRecord as a worked example. The
form will then be available as part of the library of forms on the site as well as having
it's own URL for registration of new users.

Setting up the initial form
^^^^^^^^^^^^^^^^^^^^^^^^^^^

* First, log into the warehouse. You will need site admin rights to the website
  that you are adding the survey to.
* Select **Lookup Lists > Surveys** from the menu. Click the **New Survey**
  button at the bottom of the page. Set the following values:

    * **Title** = Friends of Worts Meadow LNR
    * **Description** = A survey for recording at Worts Meadow on iRecord
    * **Website** = iRecord

* Setup any additional attributes required that don't already exist in the list
  of custom attributes. We need one called Worts Meadow Site, with an associated
  termlist containing the options Bourne Wood, The meadows, The moat, Field
  Pond, Other ponds/ditches. So, first create the termlist then the terms, then
  add an attribute, ticking the "Applies to Location" box. Use the Setup
  attributes page to configure the attributes.
* Log into the Drupal site with admin rights, or at least enough rights
  to setup new Indicia forms. In our case we log into iRecord.
* Find out the latitude and longitude of the centre of the site. Worts Meadow is
  at TL47426507 so I used the site at http://www.nearby.org.uk/coord.cgi#OSGB36%20Grid%20Reference
  to calculate the lat long, which is 52.264039, 0.158773.
* Select Content management > Create content > Indicia Pages from the admin menu.
* Set the following values on the form:

  * **Page title** - Worts Meadow Record List
  * **Select Form Category** - General Purpose Data Entry Forms
  * **Select Form** - Sample with occurrences form

* Then, click the **Load Settings Form** button. Set the following options on
  the form that appears:

    * **Other IForm Parameters**

      * **View access control** - ticked. This causes the form to use Drupal
        permissions to determine who can access it.
      * **Permission name for view access control** - "online recording". Anyone
        who has the online recording permission can access the form. This allows
        us to setup exactly who can do online recording.
      * **Survey** - "Friends of Worts Meadow LNR". Defines the survey that the
        records will be saved against.
      * **Display notification after save** - ticked. This causes the form to
        display a message thanking the user for the records after saving. An
        alternative would be to set the **Redirect to page after successful data
        entry** to a custom page which acknowledges the submission.

    * **Initial Map View**

      * **Centre of Map Latitude** - 52.264039
      * **Centre of Map Longitude** - 0.158773
      * **Map Zoom Level** - 10 (this is a guess, if wrong I can re-edit the
        form and tweak it).
      * **Map Height** - 550

    * **Base Map Layers**

      * **Google Hybrid** - ticked

    * **Other Map Settings**

      * **Controls to add to map** - layerSwitcher + panZoomBar (separate lines)
      * **Allowed Spatial Ref Systems** - OSGB

    * **User Interface**

      * **Interface Style Option** - Tabs
      * **Client Side Validation** - ticked
      * **Skip initial grid of data** - ticked

    * **Species**

      * **Extra Species List** - UK Master List
      * **User can filter the Extra Species List** - ticked
      * **Cache lookups** - ticked
      * **Include both naes in species controls and added rows** - ticked
      * **Include taxon group name in species autocomplete and added rows** -
        ticked
      * **Occurrrence Comment** - ticked
      * **Occurrence Images** - ticked
      * **Species Names Filter** - Allow common names or preferred latin names.

  * **Forms and surveys library settings**

    * **Include in library** - ticked
    * **Library title** - Friends of Worts Meadow LNR
    * **Library description** - A recording form for Worts Meadow in Cambridgeshire
    * **Locations** - Cambridgeshire
    * **Registration Path** - register-worts-meadow
    * **Registration intro** - Welcome to the online record submission facility
      for Worts Meadow. Before submitting your records, please register using
      the form below.

  * **Url Path Settings**

    * enter-worts-meadow-records

Now, save the form. There are a couple of things still to do, including getting
the form layout right and setting the map zoom.


Setting up the form structure
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* **Form Structure** - paste the following text in::

    =About you=
    [*]
    @smpAttr:36|helpText=Please provide your first name
    @smpAttr:36|class=control-width-5
    @smpAttr:58|helpText=Please provide your surname
    @smpAttr:58|class=control-width-5
    @smpAttr:8|helpText=Please provide your email. This will only be used to contact you if we require further information to verify the record.
    @smpAttr:8|class=control-width-5
    =Species=
    [date]
    @class=control-width-4
    @lockable=true
    [*]
    @smpAttr:127|class=control-width-5
    @smpAttr:127|default={profile_last_name}, {profile_first_name}
    @smpAttr:127|helpText=Enter the recorder's name, if different.
    @smpAttr:127|lockable=true
    ?Please enter all the species you saw at one site on a single day and any other information about them.  Then move to the <strong>When and where was it?</strong> tab before submitting your records.?
    [species]
    @resizeWidth=1500
    @resizeHeight=1500
    @occAttr:18|default={profile_last_name}, {profile_first_name}
    @helpText=Use * as a wildcard when searching for species names.
    [species attributes]
    =Place=
    [spatial reference]
    @lockable=true
    @class=control-width-4
    @label=Enter a spatial reference<br/><strong>Or</strong> simply click on your position on the map
    <div id="map-help" style="display: none" class="ui-state-highlight ui-corner-all page-notice"></div>
    <br/>
    [*]
    @smpAttr:56|lookUpListCtrl=hierarchical_select
    [sample comment]
    |
    [map]
    @helpToPickPrecisionMin=100
    @helpToPickPrecisionMax=10
    @helpToPickPrecisionSwitchAt=100
    @helpDiv=map-help
    =*=

Because the form structure contains a | splitter on the mapping page, we need to
add a dash of CSS to get the layout right.

Getting the map zoom right
^^^^^^^^^^^^^^^^^^^^^^^^^^

The map zoom level required is not easy to predict first time. Generally a
number between 10 and 16 can be used to give a zoomed in look at a region or a
site whereas numbers lower than this give a wider view. As we have only taken
a guess at this stage, here's a trick that will let you get it right without
trial and error. Go to your form's map (on the second tab, you will need to
input a dummy date to get past the validation on the first tab). Now you will
see the map is zoomed out too far. Click the + button to zoom the map until you
get the scale right and count the clicks. Now edit the form, find the **Map
Zoom Level** setting and add the number of clicks to the current value. If you
had to click - to zoom out then simply subtract instead of add. In this example
we come up with the magic number of 16, so edit the value to 16 and save your
form.

Theming
^^^^^^^
.. todo::

  Use page templating and css

.. code-block:: css

  .two .column label {
    display: block;
    width: auto;
  }

  .two .column textarea {
    width: 100%;
  }

  .two .column .helpText {
    margin-left: 0;
  }

  .two .column .hierarchy-select {
    font-size: 9px;
  }

  .two .column .page-notice {
    margin-top: 0.5em;
  }

  .two .column p.inline-error {
    margin: 0;
    display:-moz-inline-stack;
    display:inline-block;
    zoom:1;
    *display:inline;
  }

Survey Summary
^^^^^^^^^^^^^^