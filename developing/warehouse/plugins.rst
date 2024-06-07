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

import_plugins hook
^^^^^^^^^^^^^^^^^^^

This hook allows you to extend the version 2 spreadsheet import process functionality. Currently
this supports the following:
* Addition of additional fields to the list available for importing into.
* Additional preprocessing steps which operate before the actual import takes place. Preprocessing
  steps can modify the import data, import metadata (e.g. alter or add column mappings) and apply
  validation checks to the import data.

An example of this type of hook is given in the `import_svc_data` module.

The hook method (`<my_module>_import_plugins()`) receives a parameter `$entity` and should return
an empty array if the plugin does not apply to the entity being imported, or return an associative
array keyed by plugin name (UpperCamelCase format) and with a description in the value. The
description will be used to provide information on the list of plugins to enable which appears on
the Edit page of the Importer 2 prebuilt form type. A plugin can have configuration parameters
added via the Edit tab of the import page (e.g. the database ID of attributes that the plugin
interacts with) so explain the parameters required in the description given.

Your module must now declare a helper class, `helpers/importPlugin<plugin name>.php` containing a
class with the same name as the file and containing public static methods that implement the
required alterations to the import process. All methods are optional - only implement those that
are needed. The following methods are recognised:

`public static function alterAvailableDbFields(array $params, $required, array &$fields)`
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Use this method to alter the $fields array which contains metadata about each of the fields
available for importing into. It is possible to add new, edit or remove fields. If you are adding
a field which is not required, then do not add it if the `$required` flag is TRUE. The $fields
array is keyed by the fieldname (normally a database field of the form <entity>.<column> and the
value is the display label of the field.

`public static function isApplicable(array $params,  array $config)`
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

If a plugin wants to disable itself after the columns are mapped by the user, check the mapped
columns in `$config['columns']` then return FALSE to turn off the plugin.

`public static function alterPreprocessSteps(array $params, array $config, array &$steps)`
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Implement this function and add any extra preprocessing steps to the `$steps` array. A step is
defined as an array containing the step function name, a description, plus the helper class name
which contains the function. Preprocessing steps can modify the data, perform lookups to fill in
data values, check for error conditions and specify extra validation functionality.

Write a public static function in the helper class matching the function name given in the hook which performs any preprocessing. This can:
* Access the import configuration, e.g. 'columns' contains the list of columns mapped for import
  and 'tableName' contains the name of the table in the `import` schema which contains the data
  ready to import.
* Scan or modify the data in the import table referred to by `$config['tableName']`.
* Add any errors to the errors JSON field in the table.
* Return an array conting a key 'error' with a message value if the preprocessor has detected a
  condition meaning the import cannot proceed. Add an extra key `errorCount` if the errors are
  specific to rows in the database table which have an error added to the `errors` JSON field;
  this will trigger the option for the user to be able to download and inspect the rows where the
  `errors` field is not empty.
* If successful, return an array containing a message key, with the value being an array where the
  first element is the message. This is translatable, so replacements starting `{1}` can be
  specified which will be replaced by the values in any further array entries.

scheduled_task hook
^^^^^^^^^^^^^^^^^^^

Implement this hook to provide a background process function that will run each time the
``scheduled_tasks`` URL is visited on your server. See ``../../administrating/warehouse/scheduled-tasks``
for more information.

orm_work_queue
^^^^^^^^^^^^^^

Implement this hook to add tasks to the work queue when data is updated, inserted or
deleted in particular tables via the warehouse's ORM database layer. Return an array of
configuration, keyed by entity name (singular). Each configuration is itself an
associative array with the following keys:

* ops - contains an array of operations (insert, update or delete) this configuration
  applies to.
* task - name of the task to add to the queue. Must correspond to a helper class which
  has the following requirements:

  * Same name as the task added to the queue.
  * Declares a `public const BATCH_SIZE` in the class, set to a number greater than zero
    which corresponds to the number of work queue entries the class is willing to process
    in one go. This will depend on the efficiency gains of processing multiple records
    together vs the risk of locking the work queue processing for long periods of time.
  * Implements `public static function process($db, $taskType, $procId)` to provide a
    function that performs the task. It should perform the task for ALL entries in the
    work queue which match this task name and where the claimed_by field matches the
    $procId parameter.

* cost_estimate - a value from 1 (very low cost) to 100 (very high cost), used to
  prevent overloading the server with high cost tasks when busy.
* priority - set to 1 for high priority tasks, 2 for normal priority tasks, 3 for low
  priority tasks.

For example, the following code is used in the cache_builder module to detect changes in
the samples and occurrences tables which need to be updated in the reporting cache
attrs_json fields.

.. code-block:: php

  function cache_builder_orm_work_queue() {
    return [
      'sample' => [
        'ops' => ['insert', 'update'],
        'task' => 'task_cache_builder_attrs_sample',
        'cost_estimate' => 30,
        'priority' => 2,
      ],
      'occurrence' => [
        'ops' => ['insert', 'update'],
        'task' => 'task_cache_builder_attrs_occurrence',
        'cost_estimate' => 30,
        'priority' => 2,
      ],
    ];
  }

metadata hook
^^^^^^^^^^^^^

This hook allows the plugin to return additional metadata and settings for the plugin. The
function should return an array keyed by setting name. The only setting currently
supported applies to plugins which implement the `scheduled_task` hook:

  * **requires_occurrences_delta** - set to TRUE to ensure that a temporary table called
    occdelta table is available when this task is run. This table will contain a copy of
    all the columns from `cache_occurrences` for all occurrence records which have changed
    since the last time the scheduled tasks were run. A maximum of 200 records will be
    provided and records will be queued automatically should there be more than 200, to
    ensure that scheduled tasks do not cause performance problems when processing large
    sets of new records. In addition to the columns in `cache_occurrences`, `occdelta`
    contains a column called `CUD` which contains C(reate) for newly created records,
    U(pdate) for updated records and D(elete) for deleted records. There is also a
    ``timestamp`` column containing the time of the change.

.. note::

  The occdelta table is provided to help efficiently inform plugins about which records
  have new information requiring reprocessing by the plugin. It is not an audit of all
  changes. Therefore, if a record is created then immediately edited before the next
  run of the `scheduled_tasks`, the occdelta table will only contain a single entry with
  CUD set to 'C', indicating that this is the first time the plugin has been informed
  about the record. The update operation will not be notified to the plugin unless it
  occurs after the next run of the tasks, in which case the plugin needs to be notified
  in case there is new information in the record that requires reprocessing.

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