select 'alter table "'||table_schema||'"."'||table_name||'" owner to gunison;' 
from information_schema.tables
where table_schema in ('go','marray','ncbi','pdb','scop','sst','tax','unison','unison_aux');

select 'alter function '||P.oid::regprocedure||' owner to gunison;' 
from pg_proc P join pg_namespace N on P.pronamespace=N.oid
join pg_user U on P.proowner=U.usesysid
where N.nspname in ('go','marray','ncbi','pdb','scop','sst','tax','unison','unison_aux') and proisagg is false;

select 'alter aggregate '||P.oid::regprocedure||' owner to gunison;' 
from pg_proc P join pg_namespace N on P.pronamespace=N.oid
join pg_user U on P.proowner=U.usesysid
where N.nspname in ('go','marray','ncbi','pdb','scop','sst','tax','unison','unison_aux') and proisagg is true;

--select P.oid,N.nspname,U.usename,P.proname from pg_proc P join pg_namespace N on P.pronamespace=N.oid join pg_user U on P.proowner=U.usesysid where N.nspname in ('go','marray','ncbi','pdb','scop','sst','tax','unison','unison_aux');