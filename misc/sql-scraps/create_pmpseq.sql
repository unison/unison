--
-- Name: pmpseq; Type: TABLE; Schema: unison; Owner: admin
--
DROP TABLE unison.pmpseq CASCADE;
CREATE TABLE unison.pmpseq (
    pseq_id integer
)
INHERITS (pmodel) WITHOUT OIDS;

REVOKE ALL ON TABLE unison.pmpseq FROM PUBLIC;
GRANT SELECT ON TABLE unison.pmpseq TO PUBLIC;

--
-- Name: $1; Type: CONSTRAINT; Schema: unison; Owner: admin
--
ALTER TABLE unison.pmpseq
	ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;
CREATE INDEX pmpseq_pseq_id ON unison.pmpseq USING btree(pseq_id);
CREATE UNIQUE INDEX pmpseq_pmodel_id ON unison.pmpseq USING btree(pmodel_id);

--
-- Name: TABLE unison.pmpseq; Type: COMMENT; Schema: unison; Owner: admin
--
COMMENT ON TABLE unison.pmpseq IS 'models used for papseq alignments'; 


-- -----------------------------------------------------------------------------
--
-- pmpseq_iu_trigger():
--   purpose: insert name for sequence - use best_annotation()
--
CREATE OR REPLACE FUNCTION pmpseq_iu_trigger () RETURNS "trigger"
    AS '
  declare
		v_best_palias_id integer;
  begin

		-- get the best palias_id for this pseq_id
    select into v_best_palias_id best_palias_id(new.pseq_id,true);
    IF v_best_palias_id is null THEN
      RAISE EXCEPTION ''no best_palias_id for pseq_id=%'',new.pseq_id;
    END IF;

		select into new.porigin_id,new.name porigin_id,alias from palias where palias_id=v_best_palias_id;

    return new;
  end; '
    LANGUAGE plpgsql;
COMMENT ON FUNCTION pmpseq_iu_trigger() IS 'calculate derived values for inserting into pmpseq';

CREATE TRIGGER pmpseq_iu_trigger
  BEFORE INSERT OR UPDATE ON unison.pmpseq
    FOR EACH ROW
      EXECUTE PROCEDURE pmpseq_iu_trigger ();
-- -----------------------------------------------------------------------------
