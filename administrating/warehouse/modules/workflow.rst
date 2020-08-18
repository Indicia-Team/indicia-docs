Workflow
--------

The Workflow warehouse module intercepts records at the point at which they are about to be saved
and, if they meet a certain criteria, change properties of the record according to defined event
rules. Example usages include:

  * Intercept records of a sensitive species and change the `sensitivity_precision` field value to
    10000, blurring the record to a 10km square.
  * Intercept new records of a species and set the release status flag to 'U' so they are hidden
    from public view.
  * Intercept verification of the same species and set release status to 'R' when it is accepted,
    so the record appears in public views again.

Configuration
^^^^^^^^^^^^^

Before installing the module, copy the file `/modules/workflow/config/workflow_groups.php.example`
to `/modules/workflow/config/workflow_groups.php` and edit it in a text editor. This configuration
file allows you to group sets of workflow rules into named groups and decide which websites will
participate in each group. That allows you to have different behaviour depending on the website
that the record was entered into, e.g. a sensitivity rule might only apply in a regional dataset.

In the copied file, replace "NNSIP" with the code you'd like to give your group of rules which will
allow you to identify it in the user interface. Set `owner_website_id` to the website ID which
administers this group; users who are admins of this website will be able to administer the rules.
Set `member_website_ids` to an array of all the websites which will participate in the set of rules
attached to this group.

Now, save your file, then enable the module in `application/config/config.php` and visit
`/index.php/home/upgrade` on your warehouse in order to install the required tables.

Creating a workflow event
^^^^^^^^^^^^^^^^^^^^^^^^^

In the warehouse user interface, the **Admin** menu now as a **Worfklow Events** menu item. This
leads to a page listing the events that have been setup. Click **New Workflow event** to create
one. On the edit form you can set the following:

  * **Group** - the code of the workflow group that you would like to associate this event with.
  * **Linked taxon** - the taxon that will trigger the event.
  * **Alternative species checklist** - allows you to search other lists for the taxon to associate
    the event to.
  * **Event type** - what type of action will trigger the event on records of the selected species?
    Options are:

      * **Initially set as workflow record** - a newly added record of the species.
      * **Verification** - an existing record where the record_status is changed to 'V' (the
        record is accepted).
      * **Rejection** - an existing record where the record_status is changed to 'R' (the record is
        rejected).
      * **Unreleased** - an existing record where the release_status is changed to 'R' (released).
      * **Pending review** - an existing record where the release_status is changed to 'P' (pending
        review).
      * **Fully released** - an existing record where the release_status is changed to 'R'
        (released).

  * **Rewind record state first** - this applies when there are several events which affect a
    single species. If a 2nd or subsequent event fires when this checkbox is ticked for the event,
    any changes to the record previously caused by the Workflow module will be reverted before the
    new event is applied. If the checkbox is unticked, then the 2nd event will apply ontop of the
    changes made by the first event. E.g. if a record is flagged as sensitive and unreleased when
    initially entered, then set as released when verified, ticking this box would cause the
    sensitive data stored for the record to be reset to default when the record is verified.

  * **Columns to set** - define the values which will be changed on database inserts or updates
    that trigger this event. The fields you can change include:

      * **confidential** - set to 'f' (false) to ensure the record is not flagged as confidential,
        or 't' (true) to ensure the record is flagged as confidential. Confidential records are
        normally completely blocked from public reports.
      * **sensitivity_precision** can be set to blur a sensitive record to a set number of metres.
        Sensitive records are visible to the public but only at a lower precision.
      * **release_status** can be set to 'P' (pending review) or 'U' (unreleased) to block them
        from public reports, or 'R' (released) to make them available.