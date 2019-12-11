.. _survey-register:

Registering your survey dataset
===============================

In Indicia’s terminology, a survey dataset is a collection of records which share the
same set of attributes. Survey datasets maybe created for a specific purpose, or to
capture records for a specific group of taxa, or for a specific methodology. The common
feature of all these reasons for creating a survey dataset is that records within the
dataset are structurally similar.

For example, butterfly transect records will capture different information about the
environment and wildlife records than a citizen science project dataset. Or, you might
run a survey of hedgehogs in your area as well as a survey of garden birds. The garden
bird survey could allow the user to tick a box for nesting birds as opposed to
non-breeding visitors to the garden. Obviously it would not make sense to provide this
checkbox on a form for inputting hedgehog records. Don’t worry about dividing your data
up into several surveys if you need to in order to get the right attributes for each
survey, or simply to categorise your records logically, as it is simple to join the data
back together again when producing reports and maps later.

A good analogy is a worksheet in a spreadsheet application - where the list of rows
requires different types of values, it's common practice to create a new spreadsheet.
It's OK for some records to miss out some of the values that are provided for other
records in the dataset, but if the records are significantly different in structure then
you will need a new dataset.

Whilst we are on the topic of terminology, we will be using the following:

* *record* or *occurrence* describes a unique observation of a species on a specified
  date, at a specified place, by a specified person(s).

* *sample* describes the observation event that leads to the taking of zero or more
  occurrences, e.g. the use of a trap on a particular date by a particular person(s) at a
  particular place.

* *location* describes any named place which you are keeping details of in the system. A
  location may be a site that you visit for recording purposes, but could also be
  something like a town or other place name.

Follow these steps to register a new survey for recording on the warehouse.

#. Login using the warehouse login you created in the previous step, who has admin rights
   to the website registration you have created for your website. If you have not already
   setup the website and user, please see the :doc:`Setting up a website registration <websites>`
   tutorial.
#. Select **Observation data > Surveys datasets** from the warehouse’s menu. You should
   now be on a page that shows a grid of surveys that already exist. Like the websites
   list, there is a demonstration item added to the list during installation to provide
   somewhere to add records which are for demo and testing purposes.
#. Click the **New survey dataset** button at the bottom of the grid. This takes you to
   the New Survey page.
#. Enter a title for your survey as well as an optional description. For the purposes of
   this tutorial we will set up a survey called “Damselflies”.
#. The survey dataset creation page allows you to enforce additional mandatory field
   validation rules when required. For example, you might like to enforce that a sample
   location name is specified with every record. You can leave these options unticked for
   this tutorial.
#. A further option available is to link a survey dataset to a parent dataset, for
   organisational purposes. The **Parent survey** field can be left blank for this
   tutorial.
#. Select the website you are using this survey for from the Website drop-down at the
   bottom.

   .. image:: ../../images/screenshots/warehouse/new_survey.png
     :width: 700px
     :alt: The create new survey page.

#. Click the **Save** button.