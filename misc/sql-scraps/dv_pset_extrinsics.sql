-- "extrinsics" means sets of things that I compute on (as opposed to
-- "intrinsic" data loaded with the sequences themselves)

CREATE OR REPLACE VIEW dv_pset_BLAST as
SELECT pseq_id FROM pseqset where pset_id=pset_id('uniA')
UNION SELECT A.pseq_id FROM v_current_annotations A WHERE A.origin_id in (origin_id('PDB'));

CREATE OR REPLACE VIEW dv_pset_uptodate_cheap as
SELECT 

CREATE OR REPLACE VIEW dv_pset_uptodate_moderate as
SELECT 

CREATE OR REPLACE VIEW dv_pset_uptodate_expensive as
SELECT 


grant select on dv_pset_BLAST to PUBLIC;
comment on view dv_pset_BLAST is 'defining view for pset BLAST';

grant select on dv_pset_BLAST to PUBLIC;
comment on view dv_pset_BLAST is 'defining view for pset BLAST';



