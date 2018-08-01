User Identification
===================

One of the key advantages of online recording solutions over traditional means of
submitting records is that is allows recorders to keep direct control over their records.
They can view the "top copy" of their records, check the verification status and make
amendments all in real time. These functions all share the prerequisite that not only do
we store the name of the recorder with the record, but we maintain a link from the record
to the recorder's login, so that the records are not confused with other people having the
same name. In Indicia based online recording, the mechanism by which this link is
maintained is not set in stone, unlike most other recording systems, in fact it may not
exist at all. This is because the toolkit supports many different types of recording - in
some cases it may be appropriate to expect a user to login, but not in others for example.
The following sections describe each of the more common scenarios supported by Indicia.

Anonymous recording
-------------------

In this scenario, no personal details are associated with each record. Generally, a record
without the "who" part does not fulfil the minimum requirements of what most people define
as the essentials of a biological record: who, what, where and when. However, Indicia is
ideal for building surveys which are intended to encourage participation in biological
recording at all levels and in some cases not capturing recorder information may be
considered appropriate. An example might be a survey designed to inspire school children.
In this scenario, records cannot be linked back to the original recorder, which limits
their use outside the survey. It also means that feedback such as reports, charts or maps
of "my records" cannot be generated.

Recorder name attributes
------------------------

To complete the basic details of a biological record, custom attributes can be added to a
survey to capture the recorder's first name and surname (or just full name) as well as
other personal details such as email or address. This approach is useful when you want to
capture records without expecting the user to sign up for a website, but like the
anonymous approach above this also means that feedback such as reports, charts or maps
of "my records" cannot be generated, because a recorder name by itself does not uniquely
identify the recorder.

Link to content management system user ID
-----------------------------------------

If you are able to expect your recorders to log in to the website before contributing
records, then the recorder's user ID (as provided by the host website) can be stored with
each record, thus associating the record with the user. This has several benefits:

* Recorders do not need to input their name with each record, they can do this once on
  registration.
* Generation of reports of the user's own records becomes simple.
* Recorders can maintain a list of their own records and return to records to make
  corrections or add extra information to notable records.
* Information about the recorder's preferred recording habits (such as place and taxonomic
  groups) can be kept with their user account and used to optimise the system for them.
* Users can be associated with the sites they record at (e.g. for surveillance projects).

Additionally, requiring a logon provides additional possibilities relating to website
management and spam prevention. The disadvantage of this approach is the user account
details are stored in the Drupal website's database, which is *a different database to
Indicia's warehouse*. Therefore reporting on records with the recorder's name is not
trivial. To mitigate this, if you add Email, First Name and Last Name attributes to the
survey's custom attributes, then the attributes will be hidden and populated with the
appropriate details from the user's account by default, thus storing the recorder's
information with the record in the warehouse database.

.. tip::

  To ensure that the code knows you are using a custom attribute to store the recorder's
  content first name, surname and email address, you must set the **System Function**
  of each custom attribute correctly on the warehouse's attribute edit screen.

Easy Login
----------

Indicia provides an optional but highly recommented feature called Easy Login which links
any user accounts created on your Drupal website with a user account on the Indicia
warehouse. The user's email is used to uniquely identify users, which means that if
someone registers on several websites that share the same warehouse, there will only be
one user account created on the warehouse. Therefore each user is uniquely identifiable
across the warehouse. This approach has the following benefits over storing a content
management system user ID:

* It becomes possible to report on a user's records across multiple client websites.
* Less configuration required for each survey as no custom attributes are required to
  store the link to the user.
* User's preferences *could* be shared across multiple websites (though data protection
  issues must be considered).

So, consider the scenario where a user of iRecord (which allows recording of wildlife
across the UK) contributes records to the BWARS tree bee survey - Easy Login means that
the recorder can see their BWARS records in the My Records section of iRecord. They can
keep all their records in one place even if they have used multiple websites to contribute
the records.

.. only:: advanced

  In the following sections we'll take a look at the details of the Easy Login feature,
  then learn how to install it and configure it on our website.

.. only:: not advanced

  For more information on the Easy Login feature, see
  :doc:`modules/indicia-features/easy-login`.