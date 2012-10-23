Warehouse Plugins
=================

Warehouse plugins are special modules which hook into and extend the core 
functionality of the warehouse in an Indicia specific way. We'll go through the
steps required to write a simple plugin in :doc:`tutorial-plugins`, but first,
here are some details of how plugins can interact with the rest of the 
warehouse.

Creating the plugin module folders and enabling it
--------------------------------------------------

To create a plugin module, you need to create a folder for your module in the 
modules folder. Don't forget to enable your module by editing the 
``$config['modules']`` array in the **application/config/config.php** file or 
the module content will be ignored. Within this folder, you can create views, 
controllers and models folders for the MVC code your plugin requires. This 
should give you a new URL displaying some output where the URL path is defined 
by the controller class name and the methods it exposes.

Declaring changes to the database
---------------------------------

You can also create a **db** folder, containing a folder with the scripts for 
each version of your module. You need to follow the naming conventions given 
here for this to work:

#. A script folder for a given version of the module must be called 
   version_x_x_x and placed in the db folder in your module folder. The 
   versioning must increment logically (e.g. you could have folders 
   version_0_1_0 then version_0_2_0 or version_0_1_1 but not version_0_1_3).
#. Inside the versioned scripts folder, create scripts using the date and time 
   as the first part of the file name, using the format 
   yyyymmddhhmm_filename.sql. This ensures the scripts are run in the correct 
   order. When you create scripts from pgAdmin, it is important to ensure that 
   you remove all schema prefixes from the queries. For example if your schema 
   is called indicia, then a query might read select * from indicia.taxa but you
   will need to remove the indicia. since another installation may use a 
   different schema name. You should also remove any statements which change the
   ownership of the objects you create, because the users created for Indicia to
   access the data can also vary between installations. When upgrading the 
   scripts will be run using the same user that the warehouse uses for other 
   database operations, so the owner will be correct by default anyway.

If any of this is unclear a good place to look for examples is the 
**taxon_designations** module which includes some database upgrade scripts.

Hooking into the rest of the warehouse
--------------------------------------

So far, our module code has allowed us to add new URL paths to the warehouse 
application as well as how to add the underlying database schema changes. The 
next step is to turn our module into a **plugin**, which means that we will be 
writing code to hook into existing pieces of functionality and extend them. For 
example, we could hook into the warehouse's menu generation code to extend the 
menu with new menu items, or even tweak or remove the existing ones.

To do this, you need to create a **plugins** folder within your module's folder,
alongside the models, views and controllers folders. This is the extension to 
the module architecture developed specifically for Indicia. Within this folder, 
create a PHP file with the same name as your module folder. Inside this you need 
to write hook methods which follow a certain naming convention, allowing Indicia 
to ask your module about how it wants to plug in to the Warehouse. So, for a 
module called *foo*, we need to create the following file:

**modules/foo/plugins/foo.php**

Inside this PHP file you must create **hook methods** that adhere to certain 
naming conventions, allowing the warehouse to find them and use them to extend 
existing functionality. Each hook method must be called the same as the module 
(i.e. the module's folder), followed by an underscore, then the hook name.

extend_ui hook
^^^^^^^^^^^^^^

This hook allows your module to declare extensions to the user interface of 
existing views. It simply returns an array of the extensions it wants to perform
on the user interface, which currently means an additional tab but could be 
extended to include other types of user interface component in future. Each 
extension is a child array, containing a view (the path of the view it is 
extending), type (='tab'), controller (the path to the controller function which 
should be displayed on the tab), title (the title of the tab). For example:

.. code-block:: php

  function my_module_extend_ui() {
    return array(array(
      'view'=>'location/location_edit', 
      'type'=>'tab',
      'controller'=>'site_management_overview', 
      'title'=>'Site Management',
      'allowForNew' => false
    ));
  }

In this example, a new tab titled Site Management is attached to the view in 
location_edit.php, in the application/views/location folder. When clicked, the 
tab loads the content from the controllers/site_management_overview.php file 
within the plugin. This must declare a class Site_management_overview_Controller 
derived from Controller or one of its subclasses, with a public Index method 
since this is the default controller action. The optional value allowForNew can 
be set to false for tabs which must not be displayed when creating a new record 
but become available when editing a record.

alter_menu hook
^^^^^^^^^^^^^^^

This hook allows your module to modify the main menu. Write a method called 
module_alter_menu replacing module for your module's folder name. It should take 
a single **$menu** parameter which is an array describing the main menu 
structure. It simply makes the modifications it requires setting the entries to 
the relevant controller path to be called by the new menu items, then returns 
the menu. The following example is from the log_browser plugin, and it is in a 
file modules/log_browser/plugins/log_browser.php:

.. code-block:: php

  <php
  function log_browser_alter_menu($menu) {
    $menu['Admin']['Browse Server Logs']='browse_server_logs';
    return $menu;
  }
  ?>

In this example, there is a controller file browse_server_logs.php, containing 
the class Browse_server_logs_Controller which declares a public index method 
(since the path in the above menu item does not specify the action, so the 
default index is used).

extend_orm hook
^^^^^^^^^^^^^^^

The Kohana ORM implementation allows objects to understand how they relate to 
other objects in the data model. For example, if a *sample has_many occurrences*
then when a sample ORM object is instantiated, it is possible to access the 
occurrences via $sample->occurrences. These relationships are declared as part 
of the ORM class definitions and are documented in the 
`Kohana framework documentation <http://docs.kohanaphp.com/libraries/orm/starting>`_.

In order to add new tables and ORM entities to the data model properly, you will 
need to declare relationships from your new ORM model class (which you can do 
direct in the class definition) as well as in the existing ORM model class which 
you are relating to. However, you don't want to change the existing warehouse 
model code to do this. For example, if you wanted to add a plugin module which 
declares a new entity for site land parcels. You would declare a new model for 
*land_parcels* in your plugin module's models folder and this model would 
declare that it *belongs_to* location. However, the location model already 
exists in the main application/models folder and you don't want to touch that to
extend it otherwise the warehouse would depend on your module which is supposed 
to be optional. So, you can write a method in your plugins file such as:

.. code-block:: php

  function land_parcels_extend_orm() {
    return array('location'=>array(
      'has_many'=>array('land_parcels')
    ));
  }

You can use the following predicates to declare relationships: **has_one**, 
**has_many**, **belongs_to**, **has_and_belongs_to_many**. These are described 
in the `Kohana ORM documentation <http://docs.kohanaphp.com/libraries/orm/starting>`_.

extend_data_services hook
^^^^^^^^^^^^^^^^^^^^^^^^^

If a plugin adds entities to the data model, it is possible to extend the data 
services (**indicia_svc_data**) module to allow the new entities to be 
accessible externally via web service calls. Of course it is always possible to 
expose the data via report files, but if you want to allow record level access 
then it is necessary to extend the data services. In fact this is necessary even 
to browse the new entities in the warehouse, since the warehouse code generally 
uses the same components and web services as client websites built using 
Indicia. To enable access to a data entity via the data services:

#. you first need to create a view called list_myrecords where myrecords is the 
   plural version of your model name. Create an upgrade script for this in your 
   module as described above. This view should contain the minimum details 
   required to provide the basic information for the record as this view is 
   generally used for quick lookups against the data.
#. you also need to create a view called detail_myrecords where myrecords is 
   the plural version of your model name. Create an upgrade script for this in 
   your module as described above. This view should expose more comprehensive 
   information for each record, joining in other parts of the data model as 
   required.
#. Add a hook method to your plugins file called mymodule_extend_data_services. 
   The method returns an array of the table names you are exposing (plural) with 
   a sub-array of options. The only option currently available is readOnly which 
   can be set to true to prevent write access to an entity via data services. 
   For example:

.. code-block:: php

  function taxon_designations_extend_data_services() {
    return array('taxon_designations'=>array('readOnly'=>true));
  }

Caching
-------

One last point about writing plugin modules. Because the architecture requires 
the warehouse to scan through various PHP files looking for methods which match 
a set naming convention, there would be a performance impact for each plugin. To
avoid this problem, the warehouse caches the list of plugin hook methods it 
finds and uses the cache versions rather than scanning the files again and 
again. Although the cache copy is refreshed periodically, when writing your own 
plugin modules this can be frustrating.

To clear the cached versions of each module's hooks, delete the files starting 
with *indicia-*, *orm-* and *tabs-* in the application/cache folder in your 
Indicia warehouse installation.