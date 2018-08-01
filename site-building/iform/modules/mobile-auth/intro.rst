Introduction
============

The Mobile Authentication module was created to allow applications on mobile devices to communicate with the
web-site that hosts the module and so indirectly with the warehouse. Through multiple services it provides
the means to:

- register and login a user
- validate a user registration
- send records
- retrieve reports

All the services the Mobile Auth module provides are accessed through a few
dedicated URLs using POST requests.

To use the module, follow the procedure for :doc:`setting up the module<setup>`. Next
:doc:`create an account<management>` for your app. When you create an account for your
app, you choose a name and password which your app will have to send in order to use the
services provided by the module. Website administrators are advised to use https to
encrypt this communication. Finally, follow the protocol described for the
:doc:`services<services/index>` to communicate with the website. Turn on logging and
examine the Drupal log to diagnose any problems.

.. note::

  This  module could be used to augment any Indicia-powered Drupal website. It has been
  set up on `BRC's iRecord website <http://www.brc.ac.uk/irecord>`_ which is used in all
  the examples. App developers interested in sending records to iRecord should `contact
  the iRecord team <irecord@ceh.ac.uk>`_.


