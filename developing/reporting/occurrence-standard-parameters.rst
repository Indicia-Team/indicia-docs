Occurrence report standard parameters
=====================================

When a report has been enabled for occurrence standard paramaters, it will support a common
set of parameters. The report will automatically support the following list of parameters:

  * ``idlist`` - a comma separated list of occurrence IDs to include.
  * ``searchArea`` - Well-Known Text (WKT) definition of a polygon to filter on. Use the
    web mercator projection (unless Indicia has been reconfigured to use a different
    projection).
  * ``occurrence_id`` - a single occurrence ID to filter against. Optionally supply a
    parameter called ``occurrence_id_op`` to specify =, >= or <= as the filter opration.
  * ``taxon_rank_sort_order`` can be used to filter to include taxa above or below a
    certain rank, defined by the sort_order field in the ``taxon_ranks`` table. Optionally
    supply a parameter called ``taxon_rank_sort_order_op`` to specify =, >= or <= as the
    filter opration.
  * ``location_name`` - the location name text field or linked location's name contains the
    supplied filter text.
  * ``location_list`` - a comma separated list of location IDs. Records are included if they
    overlap with or are contained in the location's boundary. Optionally
    supply a parameter called ``location_list_op`` to specify 'in' or 'not in' as the
    filter operation.
  * ``indexed_location_list`` - as location_list, but the locations must be indexed by the
    ``spatial_index_builder`` warehouse module. Much faster, especially for complex
    boundaries. Optionally supply a parameter called ``indexed_location_list_op`` to
    specify 'in' or 'not in' as the filter operation.
  * ``date_from`` - filter to records that were recorded on or after this date.
  * ``date_to`` - filter to records that were recorded on or before this date.
  * ``date_age`` - include records that were recorded after a date defined by an age.
    e.g. '3 weeks' or '1 year'.
  * ``input_date_from`` - filter to records that were input on or after this date.
  * ``input_date_to`` - filter to records that were input on or before this date.
  * ``input_date_age`` - include records that were input after a date defined by an age.
    e.g. '3 weeks' or '1 year'.
  * ``edited_date_from`` - filter to records that were edited on or after this date.
  * ``edited_date_to`` - filter to records that were edited on or before this date.
  * ``edited_date_age`` - include records that were edited after a date defined by an age.
    e.g. '3 weeks' or '1 year'.
  * ``verified_date_from`` - filter to records that were verified on or after this date.
  * ``verified_date_to`` - filter to records that were verified on or before this date.
  * ``verified_date_age`` - include records that were verified after a date defined by an age.
  * ``quality`` - defines the quality criteria to apply. The following options are available:

      * V - verified as correct by an expert only
      * C - recorder was certain and record not rejected by an expert
      * L - recorder's opinion was certain or likely and record not rejected by an expert
      * P - pending verification
      * !D - not rejected or dubiuos/queried
      * !R - not rejected
      * D - dubious/queried only
      * R - rejected only
      * DR - dubious or rejected only

  * ``exclude_sensitive`` - provide 't' to hide sensitive records completely. Note that the
    cache_occurrences table already blurs the information for sensitive records.
  * ``confidential`` - filter on the record's confidential status. This is different to
    sensitivity in that it is generally set by the dataset administrator in order to
    disable communications regarding a record, e.g. it prevents notifications being sent
    out to a recorder when the record is verified. Set the filter to 'f' to exclude
    confidential records, 't' to include only confidential records or 'all' to disable
    this filter. Default is 'f' so confidential records are excluded.
  * ``release_status`` - filter on the release status of records. The following options
    are available:

      * R - released records only (default)
      * U - unreleased records only
      * P - records pending a "peer review" check requested by the recorder
      * RM - release records and also all records input by the user (My records)

  * ``marine_flag`` - include or exclude species flagged as marine in the dictionary data.
    The following options are available:

      * Y - only marine
      * N - only non-marine

  * ``autochecks`` - filter based on automated verification rules applied to the records, with
    the following options:

      * P - only records which pass
      * F - only records which fail

  * ``has_photos`` - supply '1' to only include records with photos or '0' to exclude
    records with photos.
  * ``user_id`` - the current user's ID on the warehouse. Does not filter directly but may
    be used by other filter parameters.
  * ``my_records`` - supply 't' to only include records input by the current user.
  * ``created_by_id`` - filter to records created by the provided User ID. This is an
    alternative to setting ``user_id`` and ``my_records=1`` which may be more appropriate
    when filtering by another user's records.
  * ``group_id`` - ID of a recording group. Only include records explicitly posted to this group.
  * ``implicit_group_id`` - ID of a recording group. Only include records by the group
    members. Should be used in conjunction with a filter defined for the group's interests
    to retrieve the group records.
  * ``website_list`` - a comma separated list of website IDs to filter against (which must
    be ones that you have reporting access to). Specify ``website_list_op`` to either
    ``in`` (default) or ``not in`` to define how the filter is applied.
  * ``survey_list`` - a comma separated list of survey IDs to filter against. Specify
    ``survey_list_op`` to either ``in`` (default) or ``not in`` to define how the filter
    is applied.
  * ``input_form_list`` - a comma separated list of input form paths to filter against.
    Specify ``input_form_list_op`` to either ``in`` (default) or ``not in`` to define how
    the filter is applied.
  * ``taxon_group_list`` - a comma separated list of taxon group IDs to filter against.
  * ``taxa_taxon_list_list`` - a comma separated list of taxa_taxon_list record IDs to
    include, allowing filtering at the species or taxon level. Do not use this filter for
    taxa at family level or higher since the parameter below is optimised for wider
    queries. Provide the preferred taxa taxon list ID as this makes the query simpler and
    faster.
  * ``higher_taxa_taxon_list_list`` - a comma separated list of taxa_taxon_list record IDs
    to include, allowing filtering at the family or higher taxon level
  * ``taxon_meaning_list`` - a comma separated list of taxon meaning IDs to filter
    against.
  * ``identification_difficulty`` - specify a value from 1 to 5 to filter to this
    identification difficulty level if this feature is set up on your warehouse. Specify
    an optional ``identification_difficulty_op`` parameter to set the value '=', '<=' or
    '>=' to control how the filter is applied.
  * ``taxa_taxon_list_attribute_ids`` - to filter for species which are tagged with a
    particular term (e.g. a habitat or resource), provide a list of the
    taxa_taxon_list_attributes record IDs which will be searched in to determine which
    attributes to include in the query. Must be used in conjunction with
    ``taxa_taxon_list_attribute_termlist_term_ids``.
  * ``taxa_taxon_list_attribute_termlist_term_ids`` - to filter for species which are
    tagged with a particular term (e.g. a habitat or resource), provide a list of
    termlist_term IDs which will be searched for. Must be used in conjunction with
    ``taxa_taxon_list_attribute_ids``.