drop table sst.v_trans;
create table sst.v_trans (
dnaid integer not null,
pseq_id integer not null
) without oids;

grant select on sst.v_trans to public;

create unique index v_trans_dna_pseq_idx on sst.v_trans using btree(dnaid,pseq_id);

drop table sst.v_unq2dna;
create table sst.v_unq2dna (
dnaid integer not null,
proid integer not null,
unqid integer not null,
unqname text,
shortname text not null
) without oids; 

grant select on sst.v_unq2dna to public;

create unique index v_unq2dna_dna_unq_idx on sst.v_unq2dna using btree(dnaid,proid,unqid);
