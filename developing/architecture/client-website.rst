***************************
Client website architecture
***************************
A client website can be created using any website technology you like. The 
interface between the client and warehouse uses standard internet protocols and,
so long as you comply with the protocol, it should work.

If you choose to develop a client website with PHP then you can take advantage
of the `client_helpers <https://github.com/Indicia-Team/client_helpers>`_
library which provides many functions to simplify the creation of web pages to
enter and show data, managing all of the interaction with the warehouse for you.

Furthermore, if you choose to develop a website with the `Drupal
<http://drupal.org>`_ content management system then you can use our `IForm
module <https://github.com/Indicia-Team/drupal-8-module-iform>`_ for Drupal
which can reduce the creation of a client website to a configuration task which
can be performed by a non-programmer. The chapter on Building your site
:doc:`Building your site <../../../site-building/index>` provides some
information on how to do this.

When you find you have a requirement which exceeds what is available in the
existing code you will need to do some additional development. If the
requirement is very specific to your site then you should look at options for
:doc:`customisation
<../../../site-building/iform/customising-page-functionality>` or :doc:`creating
a new or extending an existing pre-built form
<../client-website/tutorial-writing-drupal-prebuilt-form/index>`.

If your requirement is more generally applicable then you may wish to submit
code improvements to the IForm module, client_helpers, or media libraries.