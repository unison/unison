-- -------------------------------------------------------------------------------
-- name: dv_set_uni.sql
-- purpose: sql code to build views functions for uni psets
-- -------------------------------------------------------------------------------

-- -------------------------------------------------------------------------------
-- name: dv_set_uni
-- purpose: define a set of sequences to keep up-to-date. load into pseqset using
-- pset.name='uni'
-- -------------------------------------------------------------------------------
DROP VIEW dv_set_uni;
CREATE VIEW dv_set_uni AS
  SELECT DISTINCT pseq_id FROM palias_wo_sort WHERE
    porigin_id = porigin_id_lookup('SPDI'::text) OR porigin_id = porigin_id_lookup('Swiss-Prot'::text) OR 
		porigin_id = porigin_id_lookup('Proteome'::text) OR porigin_id = porigin_id_lookup('Refseq'::text) 
		except select pseq_id from pseqset where pset_id=0;

-- ------------------------------------------------------------------------------
-- name: dv_set_uni_hmr
-- purpose: subset of the dv_set_uni view for only human/mouse/rat sequences
-- ------------------------------------------------------------------------------
DROP VIEW dv_set_uni_hmr;
CREATE VIEW dv_set_uni_hmr AS
 SELECT pseq_id FROM pseqset where pset_id=name2pset_id('uni'::text) intersect
	 SELECT pseq_id FROM palias_wo_sort WHERE 
	 	tax_id=gs2tax_id('HUMAN'::text) OR tax_id=gs2tax_id('MOUSE'::text) OR tax_id=gs2tax_id('RAT'::text);

-- ------------------------------------------------------------------------------
-- name: dv_set_uni_hmr_m
-- purpose: subset of the dv_set_uni_hmr view with seqs containing init met
-- ------------------------------------------------------------------------------
DROP VIEW dv_set_uni_hmr_m;
CREATE VIEW dv_set_uni_hmr_m AS
 SELECT pseq_id FROM pseqset where pset_id=name2pset_id('uni_hmr'::text) intersect
	 SELECT pseq_id FROM pseq WHERE seq ~ '^M';

-- ------------------------------------------------------------------------------
-- name: dv_set_uni_hmr_m_sec
-- purpose: subset of the dv_set_uni_hmr_m view with sigpredict >= 0.5
-- ------------------------------------------------------------------------------
DROP VIEW dv_set_uni_hmr_m_sec;
CREATE VIEW dv_set_uni_hmr_m_sec AS
 SELECT pseq_id FROM pseqset where pset_id=name2pset_id('uni_hmr_m'::text) intersect
   SELECT pseq_id FROM pseqprop WHERE sigpredict>=0.5;

-- ------------------------------------------------------------------------------
-- name: dv_set_uni_hmr_m_sec_lt2000aa
-- purpose: subset of the dv_set_uni_hmr_m_sec view with 100 <= len <= 2000
-- ------------------------------------------------------------------------------
DROP VIEW dv_set_uni_hmr_m_sec_lt2000aa;
CREATE VIEW dv_set_uni_hmr_m_sec_lt2000aa AS
 SELECT pseq_id FROM pseqset where pset_id=name2pset_id('uni_hmr_m_sec'::text) intersect
	 SELECT pseq_id FROM pseq WHERE len>=100 and len<=2000;

CREATE OR REPLACE FUNCTION update_uni_psets() RETURNS void
    AS '
DECLARE
	v_pset_id integer;
BEGIN

  -- need to do this in the following order b/c each
  -- view is a subset of the previous one.  exit if
  -- we can not find a pset_id associated with the
  -- name.

  -- clean-out and repopulate uni pseqset
	select into v_pset_id name2pset_id(''uni''::text);
  IF v_pset_id is null THEN
    RAISE EXCEPTION ''no pset_id in pset for name=uni'';
  ELSE
		RAISE WARNING ''delete from pseqset where pset_id=%'',v_pset_id;
		delete from pseqset where pset_id=v_pset_id;
		RAISE WARNING ''insert into pseqset select %,* from dv_set_uni'',v_pset_id;
		insert into pseqset select v_pset_id,* from dv_set_uni;
  END IF;

  -- clean-out and repopulate uni_hmr pseqset
	select into v_pset_id name2pset_id(''uni_hmr''::text);
  IF v_pset_id is null THEN
    RAISE EXCEPTION ''no pset_id in pset for name=uni_hmr'';
  ELSE
		RAISE WARNING ''delete from pseqset where pset_id=%'',v_pset_id;
		delete from pseqset where pset_id=v_pset_id;
		RAISE WARNING ''insert into pseqset select %,* from dv_set_uni_hmr'',v_pset_id;
		insert into pseqset select v_pset_id,* from dv_set_uni_hmr;
  END IF;

  -- clean-out and repopulate uni_hmr_m pseqset
	select into v_pset_id name2pset_id(''uni_hmr_m''::text);
  IF v_pset_id is null THEN
    RAISE EXCEPTION ''no pset_id in pset for name=uni_hmr_m'';
  ELSE
		RAISE WARNING ''delete from pseqset where pset_id=%'',v_pset_id;
		delete from pseqset where pset_id=v_pset_id;
		RAISE WARNING ''insert into pseqset select %,* from dv_set_uni_hmr_m'',v_pset_id;
		insert into pseqset select v_pset_id,* from dv_set_uni_hmr_m;
  END IF;

  -- clean-out and repopulate uni_hmr_m_sec pseqset
	select into v_pset_id name2pset_id(''uni_hmr_m_sec''::text);
  IF v_pset_id is null THEN
    RAISE EXCEPTION ''no pset_id in pset for name=uni_hmr_m_sec'';
  ELSE
		RAISE WARNING ''delete from pseqset where pset_id=%'',v_pset_id;
		delete from pseqset where pset_id=v_pset_id;
		RAISE WARNING ''insert into pseqset select %,* from dv_set_uni_hmr_m_sec'',v_pset_id;
		insert into pseqset select v_pset_id,* from dv_set_uni_hmr_m_sec;
  END IF;

  -- clean-out and repopulate uni_hmr_m_sec_lt2000aa pseqset
	select into v_pset_id name2pset_id(''uni_hmr_m_sec_lt2000aa''::text);
  IF v_pset_id is null THEN
    RAISE EXCEPTION ''no pset_id in pset for name=uni_hmr_m_sec_lt2000aa'';
  ELSE
		RAISE WARNING ''delete from pseqset where pset_id=%'',v_pset_id;
		delete from pseqset where pset_id=v_pset_id;
		RAISE WARNING ''insert into pseqset select %,* from dv_set_uni_hmr_m_sec_lt2000aa'',v_pset_id;
		insert into pseqset select v_pset_id,* from dv_set_uni_hmr_m_sec_lt2000aa;
  END IF;

  return;
END;
' LANGUAGE plpgsql;
