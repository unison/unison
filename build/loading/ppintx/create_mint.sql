CREATE TABLE unison.mint ( 
	sprot_a text, 
	organism_a text, 
	short_label_a text, 
	role_a text, 
	modifications_a text, 
	mutations_a text, 
	bd_name_a text, 
	bd_range_a text, 
	bd_identification_method_a text, 
	bd_xref_a text, 
	hotspot_range_a text, 
	hotspot_identification_method_a text, 
	var_splice_xref_a text, 
	var_splice_name_a text, 
	endogenous_a text, 
	tagged_a text, 
	sprot_b text, 
	organism_b text, 
	short_label_b text, 
	role_b text, 
	modifications_b text, 
	mutations_b text, 
	bd_name_b text, 
	bd_range_b text, 
	bd_identification_method_b text, 
	bd_xref_b text, 
	hotspot_range_b text, 
	hotspot_identification_method_b text, 
	var_splice_xref text,
	var_splice_name_b text, 
	endogenous_b text, 
	tagged_b text, 	
	interaction_type text, 
	negation text, kd text, 
	confidence_measure text, 
	confidence_value text, 
	target_modified_residues text, 
	comments text, 
	pmid text, 
	interaction_detection_method text, 
	participant_detection text, 
	vivo text, 
	other_ref text ) 
WITHOUT OIDS;

create index mint_sprot_a_idx on mint(sprot_a);
create index mint_sprot_b_idx on mint(sprot_b);

grant select on table mint to public;
comment on table mint is 'Protein-Protein interactions from the MINT database';




create or replace view v_mint_one_way as select A1.pseq_id as
"pseq_id_a",M.sprot_a,A2.pseq_id as
"pseq_id_b",M.sprot_b,M.interaction_detection_method,M.pmid from mint M
join palias A1 on M.sprot_a=A1.alias join palias A2 on M.sprot_b=A2.alias
where A1.origin_id=origin_id('Swiss-Prot') and
A2.origin_id=origin_id('Swiss-Prot');

grant select on table v_mint_one_way to public;
comment on view v_mint_one_way is 'abridged view of mint with pseq_ids';


create or replace view v_mint as
select * from v_mint_one_way union
select pseq_id_b as "pseq_id_a",sprot_b as "sprot_a",pseq_id_a as "pseq_id_b",sprot_a as
"sprot_b",interaction_detection_method,pmid from v_mint_one_way;
grant select on table v_mint to public;
comment on view v_mint is 'symmetric view of mint (v_mint_one_way) with pseq_ids';
