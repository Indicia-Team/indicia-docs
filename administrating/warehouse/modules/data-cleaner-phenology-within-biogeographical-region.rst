Data Cleaner - Phenology Within Biogeographical Region Module
-------------------------------------------------------------

This module provides a means for checking whether the date for a record falls within
an expected date range within the year for the biogeographical region within which the
record was made. For example the expected phenology of a single butterfly species can
vary widely across Europe, depending on the biogeographical region under consideration.
For any given species and biogeographical region, the expected phenology can consist
of one or more descrete date ranges - the latter case typically for bivoltine species.

A typical rule definition is shown below: ::

  [Metadata]
  TestType=phenBiogeoreg
  Group=Phenology within Biogeographical region
  ShortName=Phenology with biogeography: Pararge aegeria in Pannonian (eBMS)
  Description=Check known eBMS phenology for Pararge aegeria in the Pannonian biogeographical region
  tvk=eBMS498
  bgr=Pannonian
  ErrorMsg=Date for Pararge aegeria is outside known eBMS phenology in the Pannonian biogeographical area
  LastChanged=20230406
  [EndMetadata]

  [Data]
  startDate=0401
  endDate=0831
    
  startDate=0916
  endDate=0930

Dates are expressed in the format MMDD. If you need to specify an end date of the end of February,
you should epxress it as 0229 rather than 0228.