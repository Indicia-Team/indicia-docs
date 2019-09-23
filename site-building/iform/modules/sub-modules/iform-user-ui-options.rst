IForm User UI Options Module
----------------------------

This module allows configuration files to define choices which users can make about the
user interface provided by other Indicia forms. For example, a configuration file might
define alternatives so that the user can choose between Bing and Google map layers. These
choices are then presented on the user's user account and stored in their profile.

The module can be installed as normal within Drupal. Once installed, create a folder
called iform_user_ui_options in the Drupal ``sites/default/files`` directory and create
text files in this directory to define the configuration options. The text files contain
JSON text of the following format (`_comment` entries are for documenation only).

.. code-block:: json

  {
    "<option set name>": {
      "title" : "<option set title>",
      "description" : "<option set description>",
      "_comment": "clearCookies defines an array of the options to clear when this is selected",
      "clearCookies" : ["maplat","maplon","mapzoom"],
      "choices" : {
        "<choice name>" : {
          "title" : "<choice title>",
          "description" : "<choice description>",
          "_comment": "params is a JSON object defining the params to override",
          "params" : {}
        }
      }
    }
  }

You can have multiple option set names inside 1 file and each option set's choices
element can contain as many choices as you want. Each option set name corresponds to a
radio group which will appear on the user account's Preferences page. Each choice then
corresponds to a radio button within this set of choices. A default radio button is
always present in the radio group, allowing the user to revert to the original settings
specified for each form. If you define a choice where <choice name> is set to "default"
then this choice will override the default radio button and will provide settings that
are applied to all pages even if the user has never chosen an option in their profile.

The params JSON object defines a list of properties which you are defining a replacement
value for. Properties can be:

  * The name of a parameter for a prebuilt form, as returned by the form's
    ``get_parameters`` function.
  * A control name and property name from the form structure configuration of a dynamic
    prebuilt form's form structure configuration. The control name must be provided in
    square brackets (as it is on the form structure configuration) and separated from the
    property name by a ``|`` character. For example to define a setting which enables
    vague date input for date controls, this could be:

    .. code-block:: json

      {
        "params":{
          "[date]|allowVagueDates": true
        }
      }

