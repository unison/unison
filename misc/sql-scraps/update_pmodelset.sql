create or replace function update_pmodelset (integer)
returns integer
language plpgsql
as '
DECLARE
	v_pmodelset_id alias for $1;

	v_row record;
	v_pg_row record;
	v_cmd text;
	v_tmptblname text;

	v_nrows_del integer := 0;
	v_nrows_ins integer := 0;
	v_nrows_tot integer := 0;
BEGIN
	-- ********************************* checklist *****************************************
	-- check if the requested pmodelset_id exists
	SELECT INTO v_row pmodelset_id,name,descr,def,locked,pmsm_table FROM pmodelset WHERE pmodelset_id=v_pmodelset_id;
	IF NOT FOUND THEN
		RAISE EXCEPTION ''pmodelset_id=% does not exist'', v_pmodelset_id;
		RETURN NULL;
	END IF;

	-- check if pmodelset is immutable (locked)
	IF v_row.locked IS TRUE THEN
		RAISE EXCEPTION ''% set (pmodelset_id=%) is locked for updates.'', v_row.name,v_pmodelset_id;
		RETURN NULL;
	END IF;

	-- check if an sql definition exists
	IF v_row.def IS NULL THEN
		RAISE EXCEPTION ''The definition for pmodelset_id=% is null.'', v_pmodelset_id;
		RETURN NULL;
	END IF;

	-- check if the pmsm_pm* table is set
	IF v_row.pmsm_table IS NULL THEN
		RAISE EXCEPTION ''The pmsm_pm* table name for this set (pmodelset_id=%) is null.'', v_pmodelset_id;
		RETURN NULL;
	END IF;

	-- check if the pmsm_pm* table exists
	SELECT INTO v_pg_row tablename FROM pg_tables where tablename=v_row.pmsm_table;
	IF NOT FOUND THEN
		RAISE EXCEPTION ''table=% does not exist'', v_row.pmsm_table;
		RETURN NULL;
	END IF;
	-- **************************************************************************************

	-- warn with name and id
	RAISE DEBUG ''* % (pmodelset_id=%)'', v_row.name, v_row.pmodelset_id;

	v_tmptblname := ''update_pmodelset_'' || v_pmodelset_id || ''_'' || md5(now()||random());

	-- materialize a temp table of the current set contents
	v_cmd := ''CREATE TEMP TABLE ''||v_tmptblname||'' AS SELECT DISTINCT pmodel_id FROM (''||v_row.def||'') X'';
	RAISE DEBUG ''%'', v_cmd;
	EXECUTE v_cmd;
	GET DIAGNOSTICS v_nrows_tot = ROW_COUNT;
	RAISE DEBUG ''% rows in temp table'', v_nrows_tot;

	-- delete obsolete models using an intermediate, indexed table
	v_cmd := ''CREATE TEMP TABLE ''||v_tmptblname||''_del AS SELECT pmodel_id from ''||v_row.pmsm_table||'' where pmodelset_id=''||v_pmodelset_id||'' EXCEPT select pmodel_id from ''||v_tmptblname;
	RAISE DEBUG ''%'', v_cmd;
	EXECUTE v_cmd;

	v_cmd := ''CREATE INDEX ''||v_tmptblname||''_del_m_idx on ''||v_tmptblname||''_del(pmodel_id)'';
	RAISE DEBUG ''%'', v_cmd;
	EXECUTE v_cmd;

	v_cmd := ''ANALYZE ''||v_tmptblname||''_del'';
	RAISE DEBUG ''%'', v_cmd;
	EXECUTE v_cmd;

	v_cmd:=''DELETE FROM ''||v_row.pmsm_table||'' USING ''||v_tmptblname||''_del D WHERE pmodelset_id=''||v_pmodelset_id||'' AND ''||v_row.pmsm_table||''.pmodel_id=D.pmodel_id'';
	RAISE DEBUG ''%'', v_cmd;
	EXECUTE v_cmd;
	GET DIAGNOSTICS v_nrows_del = ROW_COUNT;

	v_cmd:=''DROP TABLE '' || v_tmptblname||''_del'';
	RAISE DEBUG ''%'', v_cmd;
	EXECUTE v_cmd;

	-- add new models
	v_cmd:=''INSERT INTO ''||v_row.pmsm_table||'' (pmodelset_id,pmodel_id) SELECT ''||v_pmodelset_id||'',pmodel_id FROM (SELECT pmodel_id FROM ''||v_tmptblname||'' EXCEPT SELECT pmodel_id FROM ''||v_row.pmsm_table||'' WHERE pmodelset_id=''||v_pmodelset_id||'') X'';
	RAISE DEBUG ''%'', v_cmd;
	EXECUTE v_cmd;
	GET DIAGNOSTICS v_nrows_ins = ROW_COUNT;

	-- drop the temp table
	v_cmd:=''DROP TABLE '' || v_tmptblname;
	RAISE DEBUG ''%'', v_cmd;
	EXECUTE v_cmd;

	v_cmd := ''SELECT pmodel_id FROM ''||v_row.pmsm_table||'' WHERE pmodelset_id = ''||v_pmodelset_id;
	RAISE DEBUG ''%'', v_cmd;
	EXECUTE v_cmd;
	GET DIAGNOSTICS v_nrows_tot = ROW_COUNT;

	RAISE NOTICE ''  % (pmodelset_id=%): % model deleted, % models added, % total'',
	v_row.name, v_row.pmodelset_id, v_nrows_del, v_nrows_ins, v_nrows_tot;
	RETURN v_nrows_tot;

END
';
