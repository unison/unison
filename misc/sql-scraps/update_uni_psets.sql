CREATE OR REPLACE FUNCTION update_uni_psets ()
RETURNS VOID
LANGUAGE plpgsql
AS '
DECLARE
  v_pset_id integer;
BEGIN
  -- need to do this in the following order b/c each
  -- view is a subset of the previous one.  exit if
  -- we can not find a pset_id associated with the
  -- name.
 
  -- clean-out and repopulate uni pseqset
  select into v_pset_id name2pset_id('uni'::text);
  IF v_pset_id is null THEN
    RAISE EXCEPTION 'no pset_id in pset for name=uni';
  ELSE
    RAISE WARNING 'delete from pseqset where pset_id=%',v_pset_id;
    delete from pseqset where pset_id=v_pset_id;
    RAISE WARNING 'insert into pseqset select %,* from dv_set_uni',v_pset_id;
    insert into pseqset select v_pset_id,* from dv_set_uni;
  END IF;
 
  -- clean-out and repopulate uni_h pseqset
  select into v_pset_id name2pset_id('uni_h'::text);
  IF v_pset_id is null THEN
    RAISE EXCEPTION 'no pset_id in pset for name=uni_h';
  ELSE
    RAISE WARNING 'delete from pseqset where pset_id=%',v_pset_id;
    delete from pseqset where pset_id=v_pset_id;
    RAISE WARNING 'insert into pseqset select %,* from dv_set_uni_h',v_pset_id;
    insert into pseqset select v_pset_id,* from dv_set_uni_h;
  END IF;
 
  -- clean-out and repopulate uni_hmr pseqset
  select into v_pset_id name2pset_id('uni_hmr'::text);
  IF v_pset_id is null THEN
    RAISE EXCEPTION 'no pset_id in pset for name=uni_hmr';
  ELSE
    RAISE WARNING 'delete from pseqset where pset_id=%',v_pset_id;
    delete from pseqset where pset_id=v_pset_id;
    RAISE WARNING 'insert into pseqset select %,* from dv_set_uni_hmr',v_pset_id;
    insert into pseqset select v_pset_id,* from dv_set_uni_hmr;
  END IF;
 
  -- clean-out and repopulate uni_hmr_m pseqset
  select into v_pset_id name2pset_id('uni_hmr_m'::text);
  IF v_pset_id is null THEN
    RAISE EXCEPTION 'no pset_id in pset for name=uni_hmr_m';
  ELSE
    RAISE WARNING 'delete from pseqset where pset_id=%',v_pset_id;
    delete from pseqset where pset_id=v_pset_id;
    RAISE WARNING 'insert into pseqset select %,* from dv_set_uni_hmr_m',v_pset_id;
    insert into pseqset select v_pset_id,* from dv_set_uni_hmr_m;
  END IF;
 
  -- clean-out and repopulate uni_hmr_m_sec pseqset
  select into v_pset_id name2pset_id('uni_hmr_m_sec'::text);
  IF v_pset_id is null THEN
    RAISE EXCEPTION 'no pset_id in pset for name=uni_hmr_m_sec';
  ELSE
    RAISE WARNING 'delete from pseqset where pset_id=%',v_pset_id;
    delete from pseqset where pset_id=v_pset_id;
    RAISE WARNING 'insert into pseqset select %,* from dv_set_uni_hmr_m_sec',v_pset_id;
    insert into pseqset select v_pset_id,* from dv_set_uni_hmr_m_sec;
  END IF;
 
  -- clean-out and repopulate uni_hmr_m_sec_lt2000aa pseqset
  select into v_pset_id name2pset_id('uni_hmr_m_sec_lt2000aa'::text);
  IF v_pset_id is null THEN
    RAISE EXCEPTION 'no pset_id in pset for name=uni_hmr_m_sec_lt2000aa';
  ELSE
    RAISE WARNING 'delete from pseqset where pset_id=%',v_pset_id;
    delete from pseqset where pset_id=v_pset_id;
    RAISE WARNING 'insert into pseqset select %,* from dv_set_uni_hmr_m_sec_lt2000aa',v_pset_id;
    insert into pseqset select v_pset_id,* from dv_set_uni_hmr_m_sec_lt2000aa;
  END IF;
 
  return;
END;
';

