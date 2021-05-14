-- Query used to get table information in this folder

SELECT 
	column_name as "Column", 
	data_type as "Type", 
	coalesce(character_maximum_length::text, '') as "Max length", 
	coalesce(column_default, '') as "Default", 
	is_nullable as "Nullable",
	pgd.description as "Description"
FROM information_schema.columns c 
LEFT JOIN pg_catalog.pg_statio_all_tables as st
	ON c.table_schema=st.schemaname and c.table_name=st.relname
LEFT JOIN pg_catalog.pg_description pgd 
	ON pgd.objoid=st.relid AND pgd.objsubid=c.ordinal_position
WHERE c.table_schema = 'indicia' and c.table_name = 'samples';
