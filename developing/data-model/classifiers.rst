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
`classifier_suggestions` table. Logs the name and probability given to the suggestion.

