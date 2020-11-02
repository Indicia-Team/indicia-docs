Data Services - taxa_search service
===================================

The `taxa_search` service endpoint is a little different to the other services provided by
Data Services. It provides an optimised full text search service for species and other
taxon names and is read-only. Provided words in the search query are found anywhere in the
species name but priority in the search results is given to words near the start of the
name. It is suitable for linking to autocomplete or other similar species name search
controls.

Parameters
----------

The service accepts the following parameters:

  * taxon_list_id - required unless filtering by a specific list of taxa_Taxon_lists_ids.
    ID of the taxon list or an array of list IDs to search.
  * searchQuery - text to search for.
  * taxon_group_id - ID or array of IDs of taxon groups to limit the search to.
  * taxon_group - Taxon group name or array of taxon group names to limit the search to,
    an alternative to using taxon_group_id.
  * scratchpad_list_id - ID of an entry in the `scratchpad_lists` table where the `entity`
    is set to `taxa_taxon_list` and the entries are a list of taxa taxon_list recpords to
    limit the search to.
  * taxon_meaning_id - ID or array of IDs of taxon meanings to limit the search to.
  * taxa_taxon_list_id - ID or array of IDs of taxa taxon list records to limit the
    search to.
  * preferred_taxa_taxon_list_id - ID or array of IDs of taxa taxon list records to limit
    the search to, using the preferred name's ID to filter against, therefore including
    synonyms and common names in the search.
  * preferred_taxon - preferred taxon name or array of preferred names to limit the
    search to (e.g. limit to a list of species names). Exact matches required.
  * external_key - External key or array of external keys to limit the search to (e.g.
    limit to a list of TVKs).
  * parent_id - ID of a taxa_taxon_list record limit the search to children of, e.g. a
    species when searching the subspecies. May be set to null to force top level only.
    Pass null to search top level taxa only.
  * language - array of name languages to include in search results. Pass a 3 character
    iso code for the language, e.g. "lat" for Latin names or "eng" for English names.
  * preferred - set to true to limit to preferred names, false to limit to non-preferred
    names. E.g. filter language=lat&preferred=false to find all synonyms.
  * commonNames - set to true to limit to common names (non-latin names) or false to
    exclude non-latin names.
  * synonyms - set to true to limit to synonyms (latin names which are not the preferred
    name) or false to exclude synonyms.
  * abbreviations - boolean, default true. Set to false to disable searching 2+3
    character species name abbreviations.
  * marine_flag - set to true for only marine associated species, false to exclude
    marine-associated species.
  * freshwater_flag - set to true for only freshwater associated species, false to
    exclude marine-associated species.
  * terrestrial_flag - set to true for only terrestrial associated species, false to
    exclude terrestrial-associated species.
  * non_native_flag - set to true for only non-native species, false to exclude
    non-native species.
  * searchAuthors - boolean, default false. Set to true to include author strings in the
    searched text.
  * wholeWords - boolean, default false. Set to true to only search whole words in the
    full text index, otherwise searches the start of words.
  * min_taxon_rank_sort_order - integer. Minimum taxon rank to include in results. Can be
    used to exclude higher taxa from the search results (e.g. you might only want to
    records of genera or higher).
  * max_taxon_rank_sort_order - integer. Maximum taxon rank to include in results. Can be
    used to exclude lower taxa from the search results (e.g. you might want to exclude
    sub-species from the search results).
  * count - set to true to return a results count query.
  * limit - set to limit number of records returned.
  * offset - set to offset the query results from the start of the dataset for paging.

Response
--------

A list of taxon names matching the search parameters in priority order. Columns returned
are:

  * taxa_taxon_list_id - ID of the taxon list the taxon is on.
  * searchterm - the found search term.
  * highlighted - the found term is returned with HTML formatting used to highlight the
    parts of the search term which caused the hit.
  * taxon - the found taxon name.
  * authority - the found taxon's author string.
  * language_iso - the found taxon's language.
  * preferred_taxon - the preferred name of the found taxon.
  * preferred_authority - the found taxon's preferred name author string.
  * default_common_name - the default common name used for the found taxon.
  * taxon_group - the name of the taxon group of the found taxon.
  * preferred - 't' if the found taxon was a preferred name, otherwise 'f'.
  * preferred_taxa_taxon_list_id - ID of the taxa_taxon_lists record for the preferred
    name.
  * taxon_meaning_id - ID of the taxon meaning, identifies the unique taxonomic concept.
  * external_key - key for the found taxon as used in external system (e.g. NBN Key).
  * taxon_group_id - ID of the taxon group.
  * parent_id - ID of the taxon's parent where there is one.
  * identification_difficulty - value from 1 (easy) to 5 (difficult) where the Data
    Cleaner warehouse module defines the identification difficulty of the taxon.
  * id_diff_verification_rule_id - where there is an identification difficulty, provides
    the ID of the verification rule which can be used to obtain the ID difficulty message.
  * taxon_rank_sort_order - order value provided for the taxon rank of the found taxon.