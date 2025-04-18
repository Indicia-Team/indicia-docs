Occurrence report standard parameters
=====================================

When a report has been enabled for occurrence standard paramaters, it will support a common
set of parameters. The report will automatically support the following list of parameters:

  * ``idlist`` - a comma separated list of occurrence IDs to include.
  * ``searchArea`` - Well-Known Text (WKT) definition of a polygon to filter on. Use the
    web mercator projection (unless Indicia has been reconfigured to use a different
    projection).
  * ``occ_id`` - a single occurrence ID to filter against. Optionally supply a
    parameter called ``occ_id_op`` to specify =, >= or <= as the filter operation.
  * ``occurrence_external_key`` - Limit to a single record matching this occurrence external key.
  * ``smp_id`` - a single sample ID to filter against. Optionally supply a
    parameter called ``smp_id_op`` to specify =, >= or <= as the filter operation.
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
  * ``output_sref_systems`` - supply a comma separated list of spatial reference system
    codes, e.g. OSGB,OSIE. Limits the records to those where the record's geographic
    location is such that the preferred output spatial reference system matches one in the
    supplied list.
  * ``date_from`` - filter to records that were recorded on or after this date.
  * ``date_to`` - filter to records that were recorded on or before this date.
  * ``date_age`` - include records that were recorded after a date defined by an age.
    e.g. '3 weeks' or '1 year'.
  * ``date_year_op`` - if using ``date_year``, then the operation to use against the 
    provided year, one of =, >= or <=.
  * ``date_year`` - filter the recorded date to this year, using the operation given in 
    ``date_year_op``.
  * ``input_date_from`` - filter to records that were input on or after this date.
  * ``input_date_to`` - filter to records that were input on or before this date.
  * ``input_date_age`` - include records that were input after a date defined by an age.
    e.g. '3 weeks' or '1 year'.
  * ``input_date_year_op`` - if using ``date_year``, then the operation to use against the 
    provided year, one of =, >= or <=.
  * ``input_date_year`` - filter the recorded date to this year, using the operation given  
    in ``input_date_year_op``.
  * ``edited_date_from`` - filter to records that were edited on or after this date.
  * ``edited_date_to`` - filter to records that were edited on or before this date.
  * ``edited_date_age`` - include records that were edited after a date defined by an age.
    e.g. '3 weeks' or '1 year'.
  * ``edited_date_year_op`` - if using ``date_year``, then the operation to use against the 
    provided year, one of =, >= or <=.
  * ``edited_date_year`` - filter the recorded date to this year, using the operation given 
    in ``date_year_op``.
  * ``verified_date_from`` - filter to records that were verified on or after this date.
  * ``verified_date_to`` - filter to records that were verified on or before this date.
  * ``verified_date_age`` - include records that were verified after a date defined by an age.
  * ``verified_date_year_op`` - if using ``date_year``, then the operation to use against the 
    provided year, one of =, >= or <=.
  * ``verified_date_year`` - filter the recorded date to this year, using the operation given
    in ``verified_date_year_op``.
  * ``tracking_from`` - filter to only include records after a given update tracking ID.
    Can be used to retrieve a feed of changes.
  * ``tracking_to`` - filter to only include records before a given update tracking ID.
    Can be used to retrieve a feed of changes.
  * ``quality`` - defines the quality criteria to apply. The following options are available:

      * A - record with an answered query
      * C3 - plausible only
      * D - dubious/queried only
      * OV - verified by other verifiers (only available when filtering against Elasticsearch data,
        not for PostgreSQL reports).
      * P - pending verification
      * R - not accepted records (all)
      * R4 - not accepted as unable to verify
      * R5 - not accepted as incorrect
      * V - accepted records (all)
      * V1 - accepted as correct records
      * V2 - accepted as considered correct records

    The following additional legacy options are available to support old filters.
      * -3 - Reviewer agreed at least plausible
      * !D - not rejected or dubiuos/queried
      * !R - not rejected
      * C - recorder was certain and record not rejected by an expert
      * DR - dubious or rejected only
      * L - recorder's opinion was certain or likely and record not rejected by an expert
      * T - trusted recorders (PostgreSQL queries only).

    Multiple options for quality can be provided as a comma separated list, e.g. for pending
    verification or queried records set `quality` to 'P,D'. The operation can be inverted by
    setting a parameter called `quality_op` to 'not in'.
  * ``certainty`` - defines a filter on the record's certainty that the record identification given
    by the recorder was correct. Options are:

      * C - certain
      * L - likely
      * U - uncertain
      * NS - the recorder did not give an indication of certainty.
    Multiple options for certainty can be provided as a comma separated list, e.g. for certain
    or likely records set `certainty` to 'C,L'
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
      * RU - released plus unreleased records only
      * P - records pending a "peer review" check requested by the recorder
      * RP - released plus records pending a "peer review" check requested by the recorder
      * RM - release records and also all records input by the user (My records)
      * A - all records irrespective of release status.

  * ``marine_flag`` - include or exclude species flagged as marine in the dictionary data.
    The following options are available:

      * Y - only marine
      * N - only non-marine

  * ``freshwater_flag`` - include or exclude species flagged as freshwater in the dictionary
    data. The following options are available:

      * Y - only freshwater
      * N - only non-freshwater

  * ``terrestrial_flag`` - include or exclude species flagged as terrestrial in the
    dictionary data. The following options are available:

      * Y - only terrestrial
      * N - only non-terrestrial

  * ``non_native_flag`` - include or exclude species flagged as non-native in the dictionary
    data. The following options are available:

      * Y - only terrestrial
      * N - only non-terrestrial

  * ``autochecks`` - filter based on automated verification rules applied to the records, with
    the following options:

      * P - only records which pass
      * F - only records which fail
      * any autocheck rule type name (e.g. identification_difficulty or
        period_within_year). Records are returned if they fail the given rule name.
  * ``classifier_agreement`` - specify Y to only show records if an image classifier was used and
    the classifier's top suggestion matches the record's current determination. specify N to only
    show records if an image classifier was used and the classifier's top suggestion does not match
    the record's current determination.
  * ``identification_difficulty`` - specify a value from 1 to 5 to filter to this
    identification difficulty level if this feature is set up on your warehouse. Specify
    an optional ``identification_difficulty_op`` parameter to set the value '=', '<=' or
    '>=' to control how the filter is applied.
  * ``has_photos`` - supply '1' to only include records with photos or '0' to exclude
    records with photos.
  * ``zero_abundance``` - supply '1' to only include zero abundance/negative presence
    records with photos or '0' to exclude zero abundance/negative presence records.
  * ``user_id`` - the current user's ID on the warehouse. Does not filter directly but may
    be used by other filter parameters.
  * ``my_records`` - supply '1' to only include records input by the current user or '0'
    to exclude records input by the current user.
  * ``recorder_name`` - supply a name to search for in the recorder names field. If multiple
    words are specified then searches for any of them. Contains search.
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
  * ``import_guid_list`` - a comma separated list of import GUIDS to filter against. Each
    import of occurrence data generates a unique GUID that allows the records to be
    located at a later date.
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
  * ``taxa_taxon_list_external_key_list`` - a comma separated list of taxon external keys
    (e.g. taxon_version_keys for UKSI data) to filter to. A higher taxon can be selected and the
    taxonomic children will be included.
  * ``taxa_taxon_list_attribute_ids`` - to filter for species which are tagged with a
    particular term (e.g. a habitat or resource), provide a list of the
    taxa_taxon_list_attributes record IDs which will be searched in to determine which
    attributes to include in the query. Must be used in conjunction with
    ``taxa_taxon_list_attribute_termlist_term_ids``.
  * ``taxa_taxon_list_attribute_termlist_term_ids`` - to filter for species which are
    tagged with a particular term (e.g. a habitat or resource), provide a list of
    termlist_term IDs which will be searched for. Must be used in conjunction with
    ``taxa_taxon_list_attribute_ids``.
