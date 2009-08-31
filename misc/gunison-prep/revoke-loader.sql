select 'revoke all on "'||table_schema||'"."'||table_name||'" from loader,rkh,mukhyala;' 
from information_schema.tables
where table_schema in ('go','marray','ncbi','pdb','scop','sst','tax','unison','unison_aux');
