Installing the Indicia modules for Drupal
=========================================

The Indicia modules for Drupal provide a content type that allows pages which interact
with Indicia to be easily created. Page types include data input forms, reports, maps and
others.

To install the modules, create a folder called `custom` under your Drupal installation's
module folder. Then take one of the following approaches:

*Option 1 - Direct file download*

Download the latest iForm release from
https://github.com/Indicia-Team/drupal-8-module-iform/releases (iform.zip file) and unzip
it to `/modules/custom/` so you have a folder called `iform` inside the `custom` folder.

Download the latest Indicia features release from
https://github.com/Indicia-Team/drupal-8-modules-indicia_features/releases (Source code)
and extract it to `/modules/custom/` so you have a folder called `indicia_features`
inside the `custom folder`.

*Option 2 - Installation using Git*

If you are using Git to manage files, then you can do the following instead:

.. code-block:: bash

  git clone --recursive https://github.com/Indicia-Team/drupal-8-module-iform.git iform
  git clone https://github.com/Indicia-Team/drupal-8-modules-indicia_features.git indicia_features

Once you have the files in place using either method, visit **Extend** in your Drupal
website's admin toolbar (logged in as admin) and enable the following modules:

  * Indicia forms
  * Easy login
  * Indicia AJAX Proxy

Now, visit **Configuration > Indicia integration > Indicia settings** on the admin toolbar
and set the following options:

  * **Indicia warehouse** = Other
  * **Warehouse URL** = URL of your warehouse installation
  * **Indicia website ID** = ID of your website registration. See :doc:`Setting up a
    website registration <../warehouse/websites>` if you've not already done this.
  * **Password** and **Confirm password** for your website registration.
  * Further down the page, pan and zoom the map to cover the approximate area you will be
    recording in.
  * **List of spatial or grid reference systems** - tick GPS Latitude and Longitude (WGS84)
    and any others you feel are relevant.

Click **Submit** when done.
