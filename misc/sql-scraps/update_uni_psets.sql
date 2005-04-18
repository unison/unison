CREATE OR REPLACE FUNCTION update_psets ()
RETURNS VOID
LANGUAGE plpgsql
AS '
DECLARE
    v_cmd text;
    v_nrows integer;
	v_row record;
BEGIN
	FOR v_row IN SELECT pset_id,name,def FROM pset WHERE def IS NOT NULL LOOP
		RAISE NOTICE ''* % (pset_id=%)'', v_row.name, v_row.pset_id;

        v_cmd:=''DELETE FROM pseqset WHERE pset_id=''||v_row.pset_id;
        RAISE NOTICE ''  %'', v_cmd;
        EXECUTE v_cmd;

        v_cmd:=''INSERT INTO pseqset (pset_id,pseq_id) SELECT ''||v_row.pset_id||'',pseq_id FROM (''||v_row.def||'') X'';
        RAISE NOTICE ''  %'', v_cmd;
        EXECUTE v_cmd;

		GET DIAGNOSTICS v_nrows = ROW_COUNT;
		RAISE NOTICE ''  % rows inserted for % (pset_id=%)'', 
			v_nrows, v_row.name, v_row.pset_id;
    END LOOP;
    return;
END;
';

