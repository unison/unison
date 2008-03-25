create or replace view pdb.pdb_ligand_descriptors_v
as 
select PL.pdbid,PL.ligand_id,LD.descriptor_origin_id,"DO".type,"DO".origin,"DO".version,LD.descriptor
from pdb.pdb_ligand PL
join pdb.ligand L on PL.ligand_id=L.ligand_id
join pdb.ligand_descriptors LD on L.ligand_id=LD.ligand_id
join pdb.descriptor_origin "DO" on LD.descriptor_origin_id="DO".descriptor_origin_id;

grant select on pdb.pdb_ligand_descriptors_v to PUBLIC;
