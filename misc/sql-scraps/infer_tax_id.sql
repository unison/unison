-- infer_tax_id(origin,alias,descr)
-- returns inferred tax_id from origin, alias, and description
-- This function is intended to be used to update the paliasorigin table
-- using the SQL in assign_tax_ids.sql .



create or replace function _refseq_species(text) returns text
immutable strict language sql as 
'select compbio.plregex($1,''/^.+\\\\[(.+)\\\\]/$1/''::TEXT)';

create or replace function _nr_species(text) returns text
immutable strict language sql as 
'select compbio.plregex($1,''/^.+\\\\[(.+)\\\\].*/$1/''::TEXT)';

create or replace function _dblast_species(text) returns text
immutable strict language sql as 
'select compbio.plregex($1,''/^.* - (.+?)\\\\.?\\$/$1/''::TEXT)';



create or replace function infer_tax_id(text,text,text) returns integer 
immutable strict
language sql as '
SELECT CASE
    --------------------------------------------------------------
    -- FIRST, deal with single-species origins
    WHEN $1 IN (''MGC/Human'',
                ''Celera/Genscan'',
                ''NHGD30/Genscan'',
                ''Ensembl/Human'',
                ''hum'',
                ''Incyte'',
                ''TNF6F'',
                ''GGI'', ''GGI-subopt'', ''ProAnno v1'',
                ''Nick'')
    THEN
        gs2tax_id(''HUMAN'')


    WHEN $1 IN (''MGC/Mouse'',
                ''FANTOM'',
                ''mus'',
                ''rps'')
    THEN
        gs2tax_id(''MOUSE'')


    --------------------------------------------------------------
    -- SECOND, infer from the alias
    WHEN ($1 = ''Swiss-Prot'')
    THEN
        gs2tax_id( substr($2,strpos($2,''_'')+1) )


    --------------------------------------------------------------
    -- THIRD, infer from descr line matching for specific species
    WHEN ($1 = ''SPDI'')
    THEN
        (SELECT CASE
            WHEN ($3 ~ ''^Human'')                  THEN gs2tax_id(''HUMAN'')
            WHEN ($3 ~ ''^subunit [0-9] Human'')    THEN gs2tax_id(''HUMAN'')
            WHEN ($3 ~ ''^Mouse'')                  THEN gs2tax_id(''MOUSE'')
            WHEN ($3 ~ ''^subunit [0-9] Mouse'')    THEN gs2tax_id(''MOUSE'')
            WHEN ($3 ~ ''^Rhesus'')                 THEN gs2tax_id(''MACMU'')
            WHEN ($3 ~ ''^Rat'')                    THEN gs2tax_id(''RAT'')
            WHEN ($3 ~ ''^Zebrafish'')              THEN gs2tax_id(''BRARE'')
            WHEN ($3 ~ ''^Drosophila'')             THEN gs2tax_id(''DROME'')
        END)

    WHEN ($1 = ''Proteome'')
    THEN
        (SELECT CASE
            WHEN ($3 ~ ''^\\\\[Human\\\\]'')        THEN gs2tax_id(''HUMAN'')
            WHEN ($3 ~ ''^\\\\[Mouse\\\\]'')        THEN gs2tax_id(''MOUSE'')
            WHEN ($3 ~ ''^\\\\[Rat\\\\]'')          THEN gs2tax_id(''RAT'')
        END)

    WHEN ($1 = ''pred'')
    THEN
        (SELECT CASE
            WHEN ($3 ~ ''/species=hum'')        	THEN gs2tax_id(''HUMAN'')
            WHEN ($3 ~ ''/species=mus'')        	THEN gs2tax_id(''MOUSE'')
        END)

    WHEN ($1 = ''ncbi'')
    THEN
        (SELECT tax_id FROM tax.spspec WHERE UPPER(latin) = UPPER(_refseq_species($3)))

    WHEN ($1 = ''Refseq'')
    THEN
        (SELECT tax_id FROM tax.spspec WHERE UPPER(latin) = UPPER(_refseq_species($3)))

    WHEN ($1 = ''nr'')
    THEN
        (SELECT tax_id FROM tax.spspec WHERE UPPER(latin) = UPPER(_nr_species($3)))

    WHEN ($1 = ''dblast'')
    THEN
        (SELECT CASE
	        WHEN ($2 ~ ''_'' AND gs2tax_id(substr($2,strpos($2,''_'')+1)) IS NOT NULL)
							 					 	THEN gs2tax_id( substr($2,strpos($2,''_'')+1) )
            WHEN ($3 ~ '' - human'')   		     	THEN gs2tax_id(''HUMAN'')
            WHEN ($3 ~ '' - mouse'')   		     	THEN gs2tax_id(''MOUSE'')
            WHEN ($3 ~ '' - rat'')   		     	THEN gs2tax_id(''RAT'')
			ELSE (SELECT tax_id FROM tax.spspec WHERE UPPER(latin) = UPPER(_dblast_species($3)))
        END)

END;';

grant execute on function infer_tax_id(text,text,text) to PUBLIC;


comment on function infer_tax_id(text,text,text) is
    'infer tax_id from origin, alias, and description (text, not ids!)';
