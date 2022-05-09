Image classifiers
=================

Where a client user interface allows image classifiers to be used to assist the identification of
photographed specimens, the results of the classification requests can be stored in the Indicia
data model.

The entity relationship diagram for this part of the data model is available `on GitHub
<https://github.com/Indicia-Team/warehouse/blob/master/docs/data-model/classifiers.vuerd.json>`_.

The data tables involved are described below:

classification_events
---------------------

Each time a request is made for image classification, a `classification_events` record is created.
The request may involve any number of images and, in theory, any number of classifiers may be
invoked though in practice it is likely to only be one classifier per event.

When a `classification_events` record is involved in the identification associated with an
occurrence, the `occurrences.classification_event_id` foreign key points to the event. If the
occurrence is subsequently re-determined (either manually or with the assistance of a classifier)
then the `determination.classification_event_id` foreign key ensures that the event remains
associated with the identification which it was involved in.

classification_results
----------------------

Entries in the `classification_results` table group the suggested identifications from a single
classifier's response to a classification event. For example, if a user has photographed an insect
and requests image classification, a single `classification_event` record is created. The software
may then internally decide to utilise 2 image classification services, in which case 2 records
are inserted in `classification_results` which are joined to the `classification_events` record by
a foreign key.

The classification result data include metadata about the classification service utlised, the
information actually included in the request and the raw results from the service.

classification_results_occurrence_media
---------------------------------------

Logs the media files that were included in the request sent to a classifier which resulted in a set
of results. A simple join table.

classifier_suggestions
----------------------

Each suggested identification provided by a classifier results in a record in the
`classifier_suggestions` table. Logs the name and `probability_given` to the suggestion as well as
the `taxa_taxon_list_id` if linked to a specific taxon in the database.

There are 2 flags in the suggestions table, `classifier_chosen` which implies that the classifier
was deemed as having selected this taxon (i.e. it uniquely had a high probability among the list
returned) and `human_chosen` which implies that the recorder picked this suggestion via the user
interface. To illustrate this, consider submitting an image for classification which comes back
with 3 suggestions. The first has a 95% probability so could be considered “chosen” by the
classifier so the `classifier_chosen` flag gets set. The human then rejects this and chooses the
second suggestion, so the `human_chosen` flag is set on that suggestion. Records where these flags
conflict then become a point of interest as either the classifier or human was wrong. Assuming that
the classifier API doesn’t have a “I chose this” flag, the level of probability required to trigger
setting the flag will need to be decided.

These flags are present to make the analysis of the results clearer. Although it may be
possible to infer the value of these flags from other information, they do make the data clearer
to read and therefore simpler to analyse. For example the `classifier_chosen` flag may not always
be the one with the highest probability - the classifier may be considered as only making a choice
when there is a clear leader and that suggestion has a fairly high probability. So, if the
classifier receives a blurry image and comes back with a single suggestion at 1% probability, it is
a little unrepresentative to treat that suggestion as classifier chosen. Likewise if there are 3
suggestions, with 34, 33 and 33% probability, there is no clear choice.

Likewise, `human_chosen` might be inferred from the other data, as it will be the one with the
matching taxa_taxon_list_id in most cases. There are 2 possible hypothetical scenarios where this
might not be so simple. First, the scenario where a user inputs a photo record and requests
classification. The default classifier returns some suggestions and provides library photos for the
user to compare. The user is unsure at this point, so requests the photo is sent to a secondary
classifier. This also returns suggestions but has a better library photo that allows the user to
see that their photo record matches, so they choose the suggestion. So the first classifier was
able to return the correct  suggestion, but was unable to provide enough information for the human
to choose it and therefore human_chosen is false. Another hypothetical scenario is a citizen
science mass participation project (e.g. school children), where the classifier's determination
takes precedence over the human choice, so the human chosen suggestion does not end up matching the
record's taxa_taxon_list_id.

occurrences and determinations
------------------------------

When a classification event is involved in the identification associated with an occurrence, the
`classification_event` table's id is stores in the `classification_event_id` foreign key field in the
`occurrences` table. When the occurrence is later redetermined and the initial identification details
are logged in the `determinations` table, the `classification_event_id` is also copied over to the
`determinations` table so all the information is kept together.

Along with the `classification_event_id` field, the `occurrences` and `determinations` tables both
contain a `machine_involvement` field that allows the involvement of the machine vs the human
recorder in coming to the identification to be tracked. Possible values are:

* Null: unknown;
* 0: no involvement;
* 1: human determined, machine suggestions were ignored;
* 2: human chose a machine suggestion given a very low probability;
* 3: human chose a machine suggestion that was less-preferred (a medium probability);
* 4: human chose a machine suggestion that was the preferred choice (a high probability);
* 5: machine determined with no human involvement.


