-- -----------------------------------------------------------------------------
--
-- NAME: create_unison.papseq.sql
-- PURPOSE: sql statements and PL/pgSQL commands for creating a
--          blast feature table and associated procedures
--
-- $Id: create_papseq.sql,v 1.4 2003/06/11 20:25:07 cavs Exp $
--
-- -----------------------------------------------------------------------------

\timing

--
-- papseq; Type: TABLE; Schema: unison; Owner: admin
--

DROP TABLE unison.papseq;
CREATE TABLE unison.papseq (
  pct_ident real,
  pct_hsp_coverage real,
  pct_coverage real
)
INHERITS (palignment) WITHOUT OIDS;

ALTER TABLE ONLY unison.papseq
	ADD CONSTRAINT pseq_id_fk FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE ONLY unison.papseq
	ADD CONSTRAINT pmodel_id_fk FOREIGN KEY (pmodel_id) REFERENCES pmpseq(pmodel_id) ON UPDATE CASCADE ON DELETE NO ACTION;


CREATE INDEX papseq_pkey ON unison.papseq USING btree (pfeature_id);
CREATE INDEX papseq_qss ON unison.papseq USING btree (pseq_id, "start", stop);
CREATE INDEX papseq_eval ON unison.papseq USING btree (eval);
CREATE INDEX papseq_pmodel_id ON unison.papseq USING btree (pmodel_id);
CREATE UNIQUE INDEX papseq_redundant ON unison.papseq USING btree (pseq_id, "start", stop, pmodel_id, mstart, mstop);
CREATE INDEX papseq_ident ON unison.papseq USING btree (ident);
CREATE INDEX papseq_sim ON unison.papseq USING btree (sim);
CREATE INDEX papseq_score ON unison.papseq USING btree (score);
CREATE INDEX papseq_gaps ON unison.papseq USING btree (gaps);
CREATE INDEX papseq_len ON unison.papseq USING btree (len);

CREATE INDEX papseq_pct_ident ON unison.papseq USING btree (pct_ident);
CREATE INDEX papseq_pct_hsp_coverage ON unison.papseq USING btree (pct_hsp_coverage);
CREATE INDEX papseq_pct_coverage ON unison.papseq USING btree (pct_coverage);

COMMENT ON COLUMN unison.papseq.pct_ident IS 'derived value: ident/len';
COMMENT ON COLUMN unison.papseq.pct_hsp_coverage IS 'derived value: len/length of query sequence';
COMMENT ON COLUMN unison.papseq.pct_coverage IS 'derived value: length of shorter sequence/length of longer sequence';

REVOKE ALL ON TABLE unison.papseq FROM PUBLIC;
GRANT SELECT ON TABLE unison.papseq TO PUBLIC;
GRANT INSERT,UPDATE ON TABLE unison.papseq TO loader;
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
--
-- papseq_iu_trigger():
--   purpose: calculate pct_hsp_coverage and pct_coverage for
--            inserts to the papseq table
--
CREATE OR REPLACE FUNCTION papseq_iu_trigger () RETURNS "trigger"
    AS '
  declare
    t_pseq_id integer;
    q_seq_len integer;
    t_seq_len integer;
    shorter_len integer;
    longer_len integer;
  begin

    -- get the t_pseq_id given the pmodel_id
    select into t_pseq_id pseq_id from pmpseq where pmodel_id=new.pmodel_id;
    IF t_pseq_id is null THEN
      RAISE EXCEPTION ''no pseq_id for pmodel_id=%'',new.pmodel_id;
    END IF;

    -- get the pftype_id
    NEW.pftype_id=pftype_id_lookup(''blast'');
    IF NEW.pftype_id is null THEN
      RAISE EXCEPTION ''no pftype_id for name="blast"'';
    END IF;

    -- get sequence lengths for derived values
    select into q_seq_len len from pseq where pseq_id=new.pseq_id;
    select into t_seq_len len from pseq where pseq_id=t_pseq_id;
    IF    q_seq_len is null or q_seq_len = 0 THEN
      RAISE EXCEPTION ''length for pseq_id=% is null or zero'',new.pseq_id;
    ELSIF t_seq_len is null or t_seq_len = 0 THEN
      RAISE EXCEPTION ''length for pseq_id=% is null or zero'',t_pseq_id;
    END IF;

    -- calculate derived values
    IF q_seq_len > t_seq_len THEN
      shorter_len := t_seq_len;
      longer_len := q_seq_len;
    ELSE
      shorter_len := q_seq_len;
      longer_len := t_seq_len;
    END IF;
    new.pct_hsp_coverage := ( new.len::real / shorter_len::real ) * 100.0;
    new.pct_coverage := ( shorter_len::real / longer_len::real )  * 100.0;

    return new;
  end; '
    LANGUAGE plpgsql;
COMMENT ON FUNCTION papseq_iu_trigger() IS 'calculate derived values for inserting into papseq';

CREATE TRIGGER papseq_iu_trigger
  BEFORE INSERT OR UPDATE ON unison.papseq
    FOR EACH ROW
      EXECUTE PROCEDURE papseq_iu_trigger ();
-- -----------------------------------------------------------------------------
