create or replace function update_pset (integer)
returns integer
language plpgsql
as '
DECLARE
	v_pset_id alias for $1;
	v_row record;
    v_cmd text;
    v_nrows_del integer;
    v_nrows_ins integer;
    v_nrows_tot integer;
BEGIN
	SELECT INTO v_row pset_id,name,def FROM pset WHERE pset_id=v_pset_id;

	IF NOT FOUND THEN
		RAISE EXCEPTION ''pset_id=% does not exist'', v_pset_id;
		RETURN NULL;
	END IF;

	IF v_row.def IS NULL THEN
		RAISE EXCEPTION ''The set definition for pset_id=% is null.'', v_pset_id;
		RETURN NULL;
	END IF;

	RAISE DEBUG ''* % (pset_id=%)'', v_row.name, v_row.pset_id;

	v_cmd:=''delete from pseqset where pset_id=''||v_row.pset_id;
	RAISE DEBUG ''  %'', v_cmd;
	EXECUTE v_cmd;
	GET DIAGNOSTICS v_nrows_del = ROW_COUNT;

	v_cmd:=''INSERT INTO pseqset (pset_id,pseq_id) SELECT ''||v_row.pset_id||'',pseq_id FROM (''||v_row.def||'')X'';
	RAISE DEBUG ''  %'', v_cmd;
	EXECUTE v_cmd;
	GET DIAGNOSTICS v_nrows_ins = ROW_COUNT;

	RAISE NOTICE ''  % (pset_id=%): % sequences deleted, % sequences added'',
		v_row.name, v_row.pset_id, v_nrows_del, v_nrows_ins;

	RETURN v_nrows_ins;
END
';

comment on function update_pset(integer) is 'update pseqset for a specified pset_id using the definition in pset_def';

