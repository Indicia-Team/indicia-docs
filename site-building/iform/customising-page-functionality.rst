Customising pages built using prebuilt forms in Drupal
======================================================

There are many things you can do to customise the behaviour and display of a
page built using the Indicia forms module's prebuilt form library, without
having to write your own form code or to hack the existing forms. You can modify
the form's appearance, language used for the labels, functionality including
validation rules and even change the template used for the entire page. All
these tasks are performed by creating files which are placed in the correct
location and which have a file name adhering to the correct pattern so that the
Indicia forms module can find and use them.

.. note::

  Previously, the recommendation was to place custom CSS and JS files in the path
  client_helpers/prebuilt_forms inside your IForm module folder. Although this still works
  in Drupal 7 (not Drupal 8) the result is your module folder containing custom changes
  which makes upgrading messy, so using the client_helpers/prebuilt_forms subfolders to
  hold custom code files is no longer recommended.

Add your own CSS stylesheets
----------------------------

To include your own CSS files, you need to create a .css file and place it in
the folder ``<public files path>/indicia/css``. The file should be called
node.\ *nid*\ .css where *nid* is the node id of the Drupal page your form is on.

In addition, developers of prebuilt forms can provide CSS that is added to the
page for all instances of a particular form by creating a file called
*form-name*\ .css,
replacing *form-name* with the name of the form. For example you will find a file
called verification_1.css in this location which is used for all instances of
the verification_1.php form.

Adding your own JavaScript
--------------------------

To include your own JavaScript files, you need to create a .js file and place
it in the folder ``<public files path>/indicia/js``. The file should be called
node.\ *nid*\ .js where *nid* is the node id of the Drupal page your form is on.

Your JavaScript code can use the `jQuery <http://jquery.com>`_ library version
1.3.2 which is linked in to all Indicia powered forms.

In addition, developers of prebuilt forms can provide JavaScript that is added
to the page for all instances of a particular form by creating a file called
*form-name*\ .js, replacing
*form-name* with the name of the form. For example you will find a file called
verification_1.js in this location which runs for all instances of the
verification_1.php form.

If you need to interact with the map on your web page, there are 2 hooks you can
use. The first, mapSettingsHooks lets you alter the settings object before it is
used to setup the map. For example:

.. code-block:: php

  <?php
  mapSettingsHooks.push(function(opts) {
    // disable zooming on scroll wheel usage
    opts.scroll_wheel_zoom = false;
  }

Don't forget that there are normally other ways to provide these configurations,
for example on the dynamic form you could edit the form structure and provide
some property overrides after the [map] element. The second hook is
mapInitialisationHooks which is called once the map is setup, letting you make
any post-setup changes or attach event handlers and so forth. For example:

.. code-block:: php

  <?php
  mapInitialisationHooks.push(function(div) {
    div.map.events.register('zoomend', this, function (event) {
      var currentZoom = map.getZoom();
      if (currentZoom > 5) {
        alert('You are zoomed in');
      }
    });
  }

Overridding the HTML templates used to output the input controls
----------------------------------------------------------------

The data_entry_helper declares a global array of templates called $indicia_templates. To
change any of the template values for an instance of a form, you need to create a PHP file
in the correct place with the correct naming convention that simply changes the entries in
``$indicia_templates`` that you need to change. The following example shows template
changes to remove the header above uploaded images as well as add some instructions to the
upload button:


.. code-block:: php

  <?php
  global $indicia_templates;
  $indicia_templates['file_box_initial_file_info'] =
      '<div id="{id}" class="ui-widget-content ui-corner-all photo">'.
      '<div class="progress"><div class="progress-bar" style="width: {imagewidth}px"></div>'.
      '<div class="progress-percent"></div></div><span class="photo-wrapper"></span></div>';
  $indicia_templates['file_box'] =
    '<fieldset class="ui-corner-all">\n<legend>{caption}</legend>\n{uploadSelectBtn}&nbsp;'.
      '<span class="tip">'.
      'You may upload up to four images of each species (max size per image of 4mb)</span>'.
      '<div class="filelist"></div>{uploadStartBtn}</fieldset>';

Overriding a single form
^^^^^^^^^^^^^^^^^^^^^^^^

Create a folder called templates in
``<public files path>/indicia/`` if one does not already exist. In this folder, create
your template file and call it node.\ *nid*\ .php where *nid* is the node id of the form
page.

Overriding all instances of a prebuilt form
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Developers of prebuilt forms can also create a file in the same templates folder
called *form-name*\ .php where *form-name* is the name of the form without the .php
extension. This provides a template override file which runs for all instances
of a particular form.

Global overrides
^^^^^^^^^^^^^^^^

You can provide a template override file in the same templates folder called ``global.php``
to provide custom template definitions for every single Indicia page on the site.
Alternatively, if you are developing a theme for Drupal, you can name your file
``indicia.templates.php`` and place it in the root of your theme's folder. This allows
you to keep your template definitions together with your theme code when appropriate.

Providing your own language files
---------------------------------

Language files for each prebuilt form are placed in the folder
``<public files path>/indicia/lang`` and are called
*form-name.lang*\ .php where *form-name* is the name of the form and  *lang*
is the 2 character ISO language code matching the declared code in Drupal.

In addition, a single form instance can either replace or change the language
file for a form by declaring a file called node.\ *nid.lang*\ .php where *nid* is the
form page's node id and *lang* is the 2 characher ISO language code. Place the file in the
Drupal files folder, in a sub-folder called ``indicia/lang``. You can also specify a file
in the ``files/indicia/lang`` folder called default.nn.php (where nn is the language code)
to provide custom terms that will apply to every form on the site.


When adding a page specific translation file or a file for translations for the whole
site, you should provide a complete set of custom terms by using the global
$custom_terms array, e.g.:

.. code-block:: php

  <?php
  global $custom_terms;

  $custom_terms = array(
          'Species' => 'Art',
          'Latin Name' => 'Latäineschen Numm',
          'Date' => 'Datum',
          'Spatial Ref' => 'Koordinaten'
  );

or override one or more terms leaving the rest intact by using the
$custom_term_overrides array:

.. code-block:: php

  <?php
  global $custom_term_overrides;
  $custom_term_overrides[] = array(
    'LANG_Tab_place' => 'When and Where?',
  );

If you need to override language strings in a Drupal multisite setup then you
can place this in the site specific version of the same folder. The site
specific versions of language files take precedence over the all sites versions
and the node specific versions take precedence over those defined for a prebuilt
form.

Why don't we use Drupal i18n? A good question - Drupal has mechanisms for
internationalisation which are mature and robust. We don't use them in Indicia
though, for 2 good reasons. Firstly, Indicia is not a Drupal specific project so
needs its own mechanisms for localisation. Secondly and more importantly, Drupal
allows you to localise into different languages but does not provide a mechanism
for overriding a string in the default language (other than hacking around with
theme functions or template files etc). So, in the example above we change the
English place tab title, even though the form developer had already provided a
suitable string. Drupal does not do this.

... tip::

  If you add a URL parameter called ``notranslate`` to your page's address (it
  doesn't matter what value you give it), then the page will output the untranslated
  text for each translateable item, in square brackets. That makes it easy to work
  out the keys you need to translate the page.

Providing custom validation code
--------------------------------

When the form submission has been built, ready to send to the warehouse, it is
possible to run custom PHP to validation the form POST data and return an array
of errors. To do this, create a folder within your iform module
iform\client_helpers\prebuilt_forms\validation. Inside this folder, create a
file called validate.\ *nid*\ .php where the *nid* is replaced by your page's Drupal
node ID. This file will be automatically loaded by the iform module at the
appropriate point. Inside the PHP file, create a single function called
iform_custom_validation which recieves a $post parameter containing form post
array and returns an an associative array of control names with error messages.
It can of course return an empty array if there are no problems found. Here's an
example:

.. code-block:: php

  <?php
  function iform_custom_validation($post) {
    $errors = array();
    if (substr($post['sample:entered_sref'], 0, 2)!=='SU')
      $errors['sample:entered_sref']=lang::get('This survey only accepts data in the SU grid square.');
    return $errors;
  }
