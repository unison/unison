-- update psets containing species
-- see also update_uni_pset

create or replace function update_species_psets()
returns void
language plpgsql as '
BEGIN
	delete from pseqset where pset_id=1;
	insert into pseqset select distinct 1,pseq_id from palias where tax_id=gs2tax_id(''HUMAN'');

	delete from pseqset where pset_id=2;
	insert into pseqset select distinct 2,pseq_id from palias where tax_id=gs2tax_id(''MOUSE'');

	delete from pseqset where pset_id=3;
	insert into pseqset select distinct 3,pseq_id from palias where tax_id=gs2tax_id(''RAT'');

	return;
END;';

comment on function update_species_psets() is 'update pset ids 1,2,3 (human,mouse,rat)';

