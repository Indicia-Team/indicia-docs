**********************************
Example queries for report writers
**********************************

The following queries can all be run using a pgAdmin instance connected to your warehouse
database and assume that you have a full list of species populated in taxon list ID 15
(change this value if needed).

Find details of a species by name:

.. code-block:: sql

  select id, taxon_meaning_id, external_key, taxon, preferred_taxon, default_common_name
  from cache_taxa_taxon_lists
  where taxon ilike '7-spot ladybird'
  and taxon_list_id=15

Find details of a species by external key (preferred Taxon Version Key)

.. code-block:: sql

  select id, taxon_meaning_id, external_key, taxon, default_common_name
  from cache_taxa_taxon_lists
  where external_key='NBNSYS0000008324'
  and taxon_list_id=15

When filtering against the cache_occurrences_functional table (which is the preferred
approach to filtering species observations) you can use either the taxon_meaning_id,
preferred_taxa_taxon_list_id or external_key field to limit to a species.

Find records of 7-spot ladybirds within a polygon:

.. code-block:: sql

  select o.id,
    vague_date_to_string(o.date_start, o.date_end, o.date_type) as date,
    snf.public_entered_sref,
    cttl.preferred_taxon,
    cttl.default_common_name
  from cache_occurrences_functional o
  join cache_samples_nonfunctional snf on snf.id=o.sample_id
  join cache_taxa_taxon_lists cttl on cttl.id=o.taxa_taxon_list_id
  where o.taxa_taxon_list_external_key='NBNSYS0000008324'
  and st_intersects(
    o.public_geom,
    st_transform(
      st_geomfromtext(
        'POLYGON((450000 170000,460000 170000,460000 180000,450000 180000,450000 170000))',
        27700),
      900913
    )
  );

Find a list of all species in the same polygon:

.. code-block:: sql

  select distinct cttl.kingdom_taxon, cttl.order_taxon, cttl.family_taxon, cttl.preferred_taxon
  from cache_occurrences_functional o
  join cache_samples_nonfunctional snf on snf.id=o.sample_id
  join cache_taxa_taxon_lists cttl on cttl.id=o.taxa_taxon_list_id
  where st_intersects(
    o.public_geom,
    st_transform(
      st_geomfromtext('POLYGON((450000 170000,460000 170000,460000 180000,450000 180000,450000 170000))', 27700),
      900913
    )
  )
  order by cttl.kingdom_taxon, cttl.order_taxon, cttl.family_taxon, cttl.preferred_taxon;

Find all records in a vice county from the last month, assuming that a layer of vice
counties has been configured in the warehouse spatial index builder module:

.. code-block:: sql

  select o.id,
    vague_date_to_string(o.date_start, o.date_end, o.date_type) as date,
    snf.public_entered_sref,
    cttl.preferred_taxon,
    cttl.default_common_name
  from cache_occurrences_functional o
  join cache_samples_nonfunctional snf on snf.id=o.sample_id
  join cache_taxa_taxon_lists cttl on cttl.id=o.taxa_taxon_list_id
  join locations l on l.id=o.location_id_vice_county and l.deleted=false
  where l.name='Dorset'
  and now() - o.date_start < '1 month'::interval;

Find a list of 7-spot ladybird records entered by a particular user for the past year
(replace <user_id> with an ID from the `users` table):

.. code-block:: sql

  select o.id,
    vague_date_to_string(o.date_start, o.date_end, o.date_type) as date,
    snf.public_entered_sref,
    cttl.preferred_taxon,
    cttl.default_common_name
  from cache_occurrences_functional o
  join cache_samples_nonfunctional snf on snf.id=o.sample_id
  join cache_taxa_taxon_lists cttl on cttl.id=o.taxa_taxon_list_id
  where o.taxa_taxon_list_external_key='NBNSYS0000008324'
  and o.created_by_id=<user_id>
  and now() - o.date_start < '1 year'::interval;

Find a list of records that have had their determination changed during the past week,
with a summary of the prior determinations:

.. code-block:: sql

  select o.id,
    vague_date_to_string(o.date_start, o.date_end, o.date_type) as date,
    snf.public_entered_sref,
    t.taxon as current_taxon,
    t.search_code as current_tvk,
    p.surname || coalesce(', ' || p.first_name, '') as current_det_by,
    string_agg(
      td.taxon || coalesce(' (' || td.search_code || ')', '') || ', determined by ' || d.person_name ||
      ' on ' || to_char(d.created_on, 'DD/MM/YYYY HH:MM'),
      '; ' order by d.id) as old_dets
  from cache_occurrences_functional o
  join occurrences occ on occ.id=o.id and occ.deleted=false
  join users u on u.id=occ.updated_by_id and u.deleted=false
  join people p on p.id=u.person_id and p.deleted=false
  join cache_samples_nonfunctional snf on snf.id=o.sample_id
  join taxa_taxon_lists ttl on ttl.id=o.taxa_taxon_list_id and ttl.deleted=false
  join taxa t on t.id=ttl.taxon_id and t.deleted=false
  join determinations d on d.occurrence_id=o.id
  join taxa_taxon_lists ttld on ttld.id=d.taxa_taxon_list_id and ttld.deleted=false
  join taxa td on td.id=ttld.taxon_id and td.deleted=false
  where o.website_id=<website_id>
  and o.updated_on>now - '1 week'::interval
  group by o.id,
    vague_date_to_string(o.date_start, o.date_end, o.date_type),
    snf.public_entered_sref,
    t.taxon,
    t.search_code,
    p.surname || coalesce(', ' || p.first_name, '')

Find list of records with some checking data based on the number of verified/rejected/total
records of the same species in the same map square, limiting to those entered in the last 2
days. Note you could join to the check table using the location_id_* columns to check
against one of the indexed location boundaries instead of a map square:

.. code-block:: sql

  select o.id,
    vague_date_to_string(
      o.date_start, o.date_end, o.date_type) as date,
    snf.public_entered_sref,
    cttl.preferred_taxon,
    cttl.default_common_name,
    count(case when ocheck.record_status='V' then ocheck.id else null end) as verified_in_square,
    count(case when ocheck.record_status='R' then ocheck.id else null end) as rejected_in_square,
    count(ocheck.id) as total_in_square
  from cache_occurrences_functional o
  join cache_samples_nonfunctional snf on snf.id=o.sample_id
  join cache_taxa_taxon_lists cttl on cttl.id=o.taxa_taxon_list_id
  join cache_occurrences_functional ocheck
    on ocheck.map_sq_10km_id=o.map_sq_10km_id
    and ocheck.taxon_meaning_id=o.taxon_meaning_id
  and o.created_on > now() - '2 days'::interval
  group by o.id,
    vague_date_to_string(o.date_start, o.date_end, o.date_type),
    snf.public_entered_sref,
    cttl.preferred_taxon,
    cttl.default_common_name

History of a record. Note that this extracts the available information without relying on
the optional audit module which may not be available:

.. code-block:: sql

  select o.id, o.created_on as event_date, p.surname || coalesce(', ' || p.first_name) as by, 'Input' as event, null as detail
  from occurrences o
  join cache_taxa_taxon_lists cttl on cttl.id=o.taxa_taxon_list_id
  join users u on u.id=o.created_by_id and u.deleted=false
  join people p on p.id=u.person_id and p.deleted=false
  where o.id=4861423
  union
  select oc.occurrence_id, oc.created_on as event_date, p.surname || coalesce(', ' || p.first_name) as by,
  case oc.auto_generated when 't' then 'Record cleaner' else case when oc.record_status is null then 'Comment' else 'Verification check' end end as event, oc.comment as detail
  from occurrence_comments oc
  join users u on u.id=oc.created_by_id and u.deleted=false
  join people p on p.id=u.person_id and p.deleted=false
  where oc.occurrence_id=4861423
  union
  select d.occurrence_id, d.created_on as event_date, p.surname || coalesce(', ' || p.first_name) as by, 'Determined' as event, cttl.taxon as detail
  from determinations d
  join cache_taxa_taxon_lists cttl on cttl.id=d.taxa_taxon_list_id
  join users u on u.id=d.created_by_id and u.deleted=false
  join people p on p.id=u.person_id and p.deleted=false
  where d.occurrence_id=4861423
  and d.deleted=false
  order by id, event_date
