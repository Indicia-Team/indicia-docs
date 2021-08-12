.. _setup:

Setting Up
==========

This section deals with setting up the module. The following information applies
only to website administrators. If you are an app developer and this module is
being used to allow you to submit records through a website that you do not 
administer then you do not need to read this.

.. note:: This documentation covers only Drupal 7. The module is available for
 Drupal 6 but future development and support will target D7.

Prerequisites
-------------

The only requirement for setting up the Mobile Auth module is for the
**iForm module** to be installed and configured on your Drupal site.


Installation
------------

You can clone or download this module from `Github
<https://github.com/Indicia-Team/drupal-7-module-iform_mobile_auth>`_.

Depending on your Drupal installation the module should be placed in your
modules folder -``sites\all\modules``.

Setting permissions
-------------------

The module provides two permissions:

* View the administrative dashboard
* View personal dashboard

A user must be assigned one of these permissions in order to manage app accounts.

The difference is that a person with the administrator permission can
access and modify all application accounts on the site while a user who 
has the personal permission can only see and edit those of his own creation.

