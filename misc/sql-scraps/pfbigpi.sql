create table pfbigpi (
	site_no	smallint not null 
		CONSTRAINT big_pi_identifies_only_two_sites check (siten=1 or siten=2),
	quality	char 	not null
		CONSTRAINT quality_must_be_one_of_ABCDSNI check (strpos('ABCDSNI',quality)!=0),
	score 	real	not null
) INHERITS (pfeature) WITHOUT OIDS;

alter table pfbigpi alter column pftype_id set default pftype_id_lookup('BIG-PI');
alter table pfbigpi alter column stop set not null;
alter table pfbigpi alter column stop set default 0;
alter table pfbigpi alter column confidence set not null;
alter table pfbigpi alter column params_id set not null;
alter table pfbigpi alter column start set not null;

create index pfbigpi_pseq_id on pfbigpi(pseq_id);
create unique index pfbigpi_redundant_feature on pfbigpi(pseq_id,start,params_id);
create index pfbigpi_gpi_proteins on pfbigpi(pseq_id) where quality in ('A','B','C','D');

COMMENT ON TABLE pfbigpi IS 'BIG-PI GPI predictions; see also v_bigpi';
COMMENT ON column pfbigpi.start IS 'omega site';
COMMENT ON column pfbigpi.stop IS '0';
COMMENT ON column pfbigpi.quality IS 'A-D are good sites; S,N,I are rejected sites';
COMMENT ON column pfbigpi.confidence IS 'BIG-PI Pv value';

--------------------------------------------------------------------------------
-- Name: pfbigpi_site_trigger
-- Purpose: sets column stop = start
-- 
CREATE OR REPLACE FUNCTION pfbigpi_site_trigger() RETURNS "trigger"
    AS '
  begin
    new.stop := new.start;
    return new;
  end; '
    LANGUAGE plpgsql;
COMMENT ON FUNCTION pfbigpi_site_trigger() IS 'sets stop equal to start';

CREATE TRIGGER pfbigpi_site_trigger
	BEFORE INSERT 
	ON pfbigpi
	FOR EACH ROW
	EXECUTE PROCEDURE pfbigpi_site_trigger();
