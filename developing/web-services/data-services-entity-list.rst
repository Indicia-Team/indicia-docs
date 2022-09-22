Data Services - list of available entities
==========================================

The following list describes the entities which can be accessed via a call to the data
services, either when :doc:`reading a single record <data-services-read-record>` or a
:doc:`set of records <data-services-read-dataset>`. Apart from for a small number of
special cases, each entity's records are read via a view called list_*, detail_* or gv_*
where * is the entity name and list, detail or gv are provided in the **view** web service
request parameter. Also, most views return a website_id for each record and this is used
to filter the records to those that are available to the calling website. Those which are
not filtered in this way are indicated in the **Website restrictions** column.

Warehouse core entities
-----------------------

================================ ================ =====================
Entity                           Available views  Website restrictions?
================================ ================ =====================
cache_taxa_taxon_lists           *none*           no
cache_taxon_searchterms          *none*           no
determination                    list
index_websites_website_agreement *none*
group                            list, detail
group_page                       list
groups_user                      detail
group_invitation                 list
group_relation                   list
language                         list, detail, gv
location                         list, detail, gv
location_attribute               list, gv
location_attribute_value         list
location_comment                 list, detail, gv
location_media                   list, gv
notification                     list             no
occurrence                       list, detail, gv
occurrence_attribute             list, gv
occurrence_attribute_value       list
occurrence_comment               list
occurrence_media                 list, gv
person                           list, detail, gv
person_attribute                 list, gv
person_attribute_value           list
sample                           list, detail
sample_attribute                 list, gv
sample_attribute_value           list
sample_comment                   list
sample_media                     list, gv
survey                           list, detail, gv
survey_comment                   list, detail, gv
survey_media                     list, gv
taxa_taxon_list                  list, detail, gv no
taxa_taxon_list_attribute        list, gv
taxa_taxon_list_attribute_value  list
taxon_code                       list, detail, gv
taxon_group                      list, detail, gv no
taxon_list                       list, detail, gv
taxon_media                      list, detail, gv
taxon_rank                       list, gv
taxon_relation                   list, gv         no
taxon_relation_type              list, detail, gv
taxon_search                                      no
term                             list, detail
termlist                         list, detail, gv
termlists_term                   list, detail, gv
title                            list, detail, gv
trigger                          gv
user                             list, gv
user_identifier                  gv
website                          list, detail, gv
website_agreement                list, detail, gv
websites_website_agreement       list, detail, gv
================================ ================ =====================

Note that warehouse modules may declare additional entities to extend this list.
