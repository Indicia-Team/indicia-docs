IForm Licences module
---------------------

The IForm licences module can be enabled on a Drupal Indicia site to allow users to
choose their own licence settings for records or media files.

  #. Before using it, you need to make sure that the licences you wish to use are
     available on the warehouse (see :doc:`../../../../site-building/warehouse/licences`).
  #. Enable the Drupal module as normal.
  #. Go to **Configuration > IForm > Settings** on your Drupal site. Near the bottom of
     the settings page you should find a configuration for the following choice of
     behaviour which you should select from then save the configuration page:

       * User can select licence for records only
       * User can select licence for media (photos etc) only
       * User can select licence for records and media separately.

  #. User profile edit pages will now have a control for choosing their licence, for their
     records and/or media files, depending on the above setting.

     .. image:: ../../../../images/screenshots/drupal/iform-licences-user-profile-control.png
       :width: 700px
       :alt: User profile licence options.