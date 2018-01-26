Introduction
------------

This tutorial takes you step by step through the process of converting the form
we wrote in :doc:`../tutorial-writing-php-form/index` into a prebuilt form
ready for use in Drupal. Before starting you should

#. have an installation of Drupal with the IForm module enabled.
#. have the completed code from the previous tutorial to hand.

Prebuilt forms are ready made pieces of Indicia functionality such as data input
forms, reporting and mapping pages. The idea is to allow development of reusable
pieces of PHP code, meaning that you don't need to write PHP to use much of the
power of Indicia. Note that the prebuilt forms can support their own
configuration forms meaning that they can be quite flexible, so you don't need
to write new forms for each survey input form or report. Prebuilt forms reside
in the **client_helpers/prebuilt_forms** directory within the IForm module and
take the form of classes which implement a predefined set of methods in order
to declare their parameters and to build the output HTML.

