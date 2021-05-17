#! /bin/bash

# This script will create the csv files in this folder if it can
# connnect to an Indicia postgres database.

# The list of tables to describe
TABLES=(
    cache_occurrences_functional
    cache_occurrences_nonfunctional
    cache_samples_functional
    cache_samples_nonfunctional
    cache_taxa_taxon_lists
    cache_taxon_searchterms
    determinations
    filters
    group_pages
    groups
    groups_users
    languages
    location_attributes
    location_attributes_websites
    location_attribute_values
    locations
    occurrence_attributes
    occurrence_attributes_websites
    occurrence_attribute_values
    occurrence_comments
    occurrences
    people
    person_attributes
    person_attributes_websites
    person_attribute_values
    sample_attributes
    sample_attributes_websites
    sample_attribute_values
    samples
    survey_attributes
    survey_attributes_websites
    survey_attribute_values
    surveys
    taxa
    taxa_taxon_list_attributes
    taxa_taxon_list_attribute_values
    taxa_taxon_lists
    taxon_groups
    taxon_lists
    taxon_lists_taxa_taxon_list_attributes
    termlists_term_attributes
    termlists_term_attribute_values
    termlists_termlists_term_attributes
    users
    users_websites
    websites
)

# The connection information your postgres server
HOST=localhost
DATABASE=indicia
SCHEMA=indicia
USER=postgres

PSQL_FILE=temp.psql

# Add initial commands to psql file.
cat <<EOF >> $PSQL_FILE

\pset format csv

EOF

# Loop through all the tables and append
# all the psql commands we want to run to the file.
# (So that we only have to authenticate once.)
for TABLE in ${TABLES[@]}; do
    cat <<EOF >> $PSQL_FILE

\o $TABLE.csv

SELECT 
	column_name AS "Column", 
	CONCAT(
        CASE WHEN data_type = 'timestamp without time zone'
            THEN 'timestamp (no tz)'
        WHEN data_type = 'character varying'
            THEN 'char varying'
        ELSE
            data_type
        END,
        CASE WHEN character_maximum_length IS NULL
            THEN NULL
        ELSE 
            ' (' || character_maximum_length::text || ')'
        END
    ) AS "Type", 
    CASE WHEN column_default IS NULL
            THEN ''
        WHEN SUBSTRING(column_default FOR 7) = 'nextval'
            THEN 'nextval(...)'
        ELSE 
            column_default
	END AS "Default", 
	CASE WHEN is_nullable = 'YES'
        THEN 'Yes'
        ELSE 'No' 
    END AS "Nullable",
	pgd.description AS "Description"
FROM information_schema.columns c 
LEFT JOIN pg_catalog.pg_statio_all_tables AS st
	ON c.table_schema=st.schemaname and c.table_name=st.relname
LEFT JOIN pg_catalog.pg_description pgd 
	ON pgd.objoid=st.relid AND pgd.objsubid=c.ordinal_position
WHERE c.table_schema = '$SCHEMA' and c.table_name = '$TABLE';

\o

EOF

done

# Run the queries to create the files.
psql --host=$HOST --dbname=$DATABASE --username=$USER --file=$PSQL_FILE 

rm $PSQL_FILE
