CREATE OR REPLACE FUNCTION unison.publicize() RETURNS void
    AS $$
DECLARE
	v_row record;
BEGIN
	if current_database() != 'csb-public' then
		RAISE EXCEPTION 'publicize(): database must be named "csb-public"';
	end if;
	RAISE WARNING '%: BEGINNING MASSIVE DELETE OF PROPRIETARY DATA.', timeofday();

	FOR v_row IN SELECT origin,origin_id FROM origin WHERE is_public=FALSE ORDER BY origin_id LOOP
		RAISE NOTICE '%: deleting results for ''%'' (origin_id=%)', timeofday(), v_row.origin, v_row.origin_id;
		DELETE FROM paliasorigin WHERE origin_id=v_row.origin_id;
		DELETE FROM origin WHERE origin_id=v_row.origin_id;
	END LOOP;

	FOR v_row IN SELECT name,params_id FROM params WHERE is_public=FALSE ORDER BY params_id LOOP   
		RAISE NOTICE '%: deleting results for ''%'' (params_id=%)', timeofday(), v_row.name, v_row.params_id;
		DELETE FROM pahmm WHERE params_id=v_row.params_id;
		DELETE FROM paprospect WHERE params_id=v_row.params_id;
		DELETE FROM params WHERE params_id=v_row.params_id;
	END LOOP;

	RAISE NOTICE 'deleting sequences NOT in pset_id=150';
	DELETE FROM pseq WHERE pseq_id NOT IN (SELECT pseq_id FROM pseqset WHERE pset_id=150);

	select meta_update_kv('publicized at',now());
	RAISE NOTICE '%: Done. You should VACUUM ANALYZE VERBOSE.', timeofday();
	RETURN;
END;$$
    LANGUAGE plpgsql;
ALTER FUNCTION unison.publicize() OWNER TO unison;
COMMENT ON FUNCTION publicize() IS 'DANGER: This function deletes all proprietary data. It may only be run in a database named csb-public.';
