create or replace view foreign_keys as 
select
  FN.nspname as "Fnamespace",FR.relname as "Frelation",FA.attname as "Fcolumn",
  PN.nspname as "Pnamespace",PR.relname as "Prelation",PA.attname as "Pcolumn",
  CN.nspname as "Cnamespace",C.conname as "Cname"
from pg_constraint C
join pg_namespace CN on CN.oid=C.connamespace
join pg_class FR on FR.oid=C.conrelid
join pg_namespace FN on FN.oid=FR.relnamespace
join pg_attribute FA on FA.attrelid=C.conrelid and FA.attnum = ANY (C.conkey)
join pg_class PR on PR.oid=C.confrelid
join pg_namespace PN on PN.oid=PR.relnamespace
join pg_attribute PA on PA.attrelid=C.confrelid and PA.attnum = ANY (C.confkey)
where C.contype='f';

create or replace view foreign_keys_pp as
select
  "Fnamespace"||'.'||"Frelation"||'('||"Fcolumn"||')' as "foreign key",
  "Cnamespace"||'.'||"Cname" as "constraint",
  "Pnamespace"||'.'||"Prelation"||'('||"Pcolumn"||')' as "primary key"
from foreign_keys;


grant select on foreign_keys,foreign_keys_pp to PUBLIC;

comment on view foreign_keys is 'foreign key relationships in the database';
comment on view foreign_keys_pp is 'pretty print of foreign_keys view';
