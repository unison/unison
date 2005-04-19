create or replace function update_pset (integer)
returns integer
language plpgsql
as '
DECLARE
	v_pset_id alias for $1;
	v_row record;
    v_cmd text;
    v_nrows integer;
BEGIN
	select into v_row pset_id,name,def FROM pset WHERE pset_id=v_pset_id;

	IF NOT FOUND THEN
		RAISE EXCEPTION ''pset_id=% does not exist'', v_pset_id;
		RETURN NULL;
	END IF;

	IF v_row.def IS NULL THEN
		RAISE EXCEPTION ''The set definition for pset_id=% is null.'', v_pset_id;
		RETURN NULL;
	END IF;

	RAISE NOTICE ''* % (pset_id=%)'', v_row.name, v_row.pset_id;

    v_cmd:=''DELETE FROM pseqset WHERE pset_id=''||v_row.pset_id;
    RAISE NOTICE ''  %'', v_cmd;
    EXECUTE v_cmd;

    v_cmd:=''INSERT INTO pseqset (pset_id,pseq_id) SELECT DISTINCT ''||v_row.pset_id||'',pseq_id FROM (''||v_row.def||'') X'';
    RAISE NOTICE ''  %'', v_cmd;
    EXECUTE v_cmd;

	GET DIAGNOSTICS v_nrows = ROW_COUNT;
	--RAISE NOTICE ''  % rows inserted for % (pset_id=%)'', 
	--	v_nrows, v_row.name, v_row.pset_id;

	return v_nrows;	
END
';

comment on function update_pset(integer) is 'update pseqset for a specified pset_id using the definition in pset.def';




CREATE OR REPLACE FUNCTION update_psets_intrinsic ()
RETURNS VOID
LANGUAGE plpgsql
AS '
DECLARE
	v_row record;
	v_nseqs integer;
BEGIN
	FOR v_row IN SELECT pset_id,name FROM pset WHERE pset_id between 1 and 99 order by pset_id LOOP
		select into v_nseqs update_pset( v_row.pset_id );
		RAISE NOTICE ''% (pset_id=%): % sequences'', v_row.name, v_row.pset_id, v_nseqs;
    END LOOP;
    return;
END;
';

comment on function update_psets_intrinsic () is 'update pseqset for set definitions based on origin, alias, description, and tax_id';




CREATE OR REPLACE FUNCTION update_psets_extrinsic ()
RETURNS VOID
LANGUAGE plpgsql
AS '
DECLARE
	v_row record;
	v_nseqs integer;
BEGIN
	FOR v_row IN SELECT pset_id,name FROM pset WHERE pset_id between 100 and 199 order by pset_id LOOP
		select into v_nseqs update_pset( v_row.pset_id );
		RAISE NOTICE ''% (pset_id=%): % sequences'', v_row.name, v_row.pset_id, v_nseqs;
    END LOOP;
    return;
END;
';

comment on function update_psets_extrinsic () is 'update pseqset for set definitions based on computed features';
