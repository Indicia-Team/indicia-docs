Custom Verification Rules Upload
================================

A form allowing the import of a spreadsheet containing custom verification rules into an existing
custom verification ruleset. The page should be called with a URL containing a parameter
`custom_verification_ruleset_id` to indiciate which existing ruleset to upload the rules into.
Rulesets can be created using the Custom Verification Rulesets Edit form type.

Uploaded spreadsheets require a header row for column titles, containing the following:

* A column called "taxon" containing taxon names, or a column called "taxon id" containing taxon
  version keys, in order to identify the taxon to link each rule to.
* A column called "rule type" containing one of the following for each rule:

  * "abundance" - to define a rule that flags records with higher than a maximum abundance count.
    You should also provide the following columns:

    * "max individual count" - a number indicating the maximum allowed abundance count value.

  * "geography" - to define a geographic rule. You should also provide one of the following
    column combinations:

    * "grid refs" - a semi-colon separated list of allowed grid references and "grid ref system" -
      OSGB or OSNI for British or Irish grid references.
    * "min longitude" - the minimum allowed longitude (decimal format).
    * "max longitude" - the maximum allowed longitude (decimal format).
    * "min latitude" - the minimum allowed latitude (decimal format).
    * "min latitude" - the maximum allowed latitude (decimal format).
    * "location ids" - a semi-colon separated list of location IDs (from the warehouse locations
      table) which the record is allowed if it falls within the boundaries of.

  * "phenology" - define a time of year rule. You should also provide at least one of the following
    columns:

    * "min month" - the minimum allowed month number (1-12) and optionally "min day" to specify a
      day within that month (1-31), otherwise the start of the month is used.
    * "max month" - the maximum allowed month number (1-12) and optionally "max day" to specify a
      day within that month (1-31), otherwise the end of the month is used.

  * "period" - define a range of years that records are allowed for.

    * Provide columns for at least one of "min year" and "max year" to define the allowed range.

  * "species recorded" - if this rule type is specified, then all records of this species are
    flagged and no extra columns are required.

* An optional column called "reverse rule" - containing the value "yes" if the rule should be reversed and records that would have been flagged won't be and vice versa.