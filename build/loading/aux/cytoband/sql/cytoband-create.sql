drop table "unison_aux".cytoband_hg18;
CREATE TABLE "unison_aux".cytoband_hg18 (
chr text not null,
gstart integer not null,
gstop integer not null,
band text not null,
stain text not null,
PRIMARY KEY (chr, gstart)
);
grant select on "unison_aux".cytoband_hg18 to PUBLIC;

CREATE UNIQUE INDEX cytoband_hg18_chr_gstop_unique_idx on "unison_aux".cytoband_hg18 using btree(chr,gstop);

comment on table "unison_aux".cytoband_hg18 is 'Cytobands on human chromosomes from ucsc genome assembly hg18';
comment on column "unison_aux".cytoband_hg18.chr is 'chromosome (e.g. 1..22,M,U,X,Y)';
comment on column "unison_aux".cytoband_hg18.gstart is 'start of band on genome (1-based, +1 frame, gstop > gstart)';
comment on column "unison_aux".cytoband_hg18.gstop is 'stop of band on genome (1-based, +1 frame, gstop > gstart)';
comment on column "unison_aux".cytoband_hg18.band is 'name of the cytoband';
comment on column "unison_aux".cytoband_hg18.stain is 'gie stain';
