-- -----------------------------------------------------------------------------
-- NAME: assign_tax_id.sql
-- PURPOSE: assign tax_id in the paliasorigin table
--
-- $Id: assign_tax_id.sql,v 1.6 2004/03/23 23:15:11 cavs Exp $
-- -----------------------------------------------------------------------------






-- swissprot - key off the gs info in the accession
UPDATE paliasorigin SET tax_id=gs2tax_id('HUMAN') 
  WHERE porigin_id=porigin_id_lookup('Swiss-Prot'::text) AND alias ~ '_HUMAN$'::text AND tax_id IS NULL;

UPDATE paliasorigin SET tax_id=gs2tax_id('MOUSE') 
  WHERE porigin_id=porigin_id_lookup('Swiss-Prot'::text) AND alias ~ '_MOUSE$'::text AND tax_id IS NULL;

UPDATE paliasorigin SET tax_id=gs2tax_id('RAT') 
  WHERE porigin_id=porigin_id_lookup('Swiss-Prot'::text) AND alias ~ '_RAT$'::text AND tax_id IS NULL;


-- refseq - key off the gs in the descr
UPDATE paliasorigin SET tax_id=gs2tax_id('HUMAN') 
  WHERE porigin_id=porigin_id_lookup('Refseq'::text) AND descr ~ '[[]Homo sapiens[]]$'::text AND tax_id IS NULL;

UPDATE paliasorigin SET tax_id=gs2tax_id('MOUSE') 
  WHERE porigin_id=porigin_id_lookup('Refseq'::text) AND descr ~ '[[]Mus musculus[]]$'::text AND tax_id IS NULL;

UPDATE paliasorigin SET tax_id=gs2tax_id('RAT') 
  WHERE porigin_id=porigin_id_lookup('Refseq'::text) AND descr ~ '[[]Rattus norvegicus[]]$'::text AND tax_id IS NULL;


-- proteome - key off species identifier in descr
UPDATE paliasorigin SET tax_id=gs2tax_id('HUMAN') 
  WHERE porigin_id=porigin_id_lookup('Proteome'::text) AND descr ~ '^[[]Human[]]' AND tax_id IS NULL;
UPDATE paliasorigin SET tax_id=gs2tax_id('MOUSE') 
  WHERE porigin_id=porigin_id_lookup('Proteome'::text) AND descr ~ '^[[]Mouse[]]' AND tax_id IS NULL;
UPDATE paliasorigin SET tax_id=gs2tax_id('RAT') 
  WHERE porigin_id=porigin_id_lookup('Proteome'::text) AND descr ~ '^[[]Rat[]]' AND tax_id IS NULL;


-- dblast - key off the gs in the descr
UPDATE paliasorigin SET tax_id=gs2tax_id('HUMAN') 
  WHERE porigin_id=porigin_id_lookup('dblast'::text) AND descr ~ '- Homo sapiens$' AND tax_id IS NULL;

UPDATE paliasorigin SET tax_id=gs2tax_id('MOUSE') 
  WHERE porigin_id=porigin_id_lookup('dblast'::text) AND descr ~ '- Mus musculus$' AND tax_id IS NULL;

UPDATE paliasorigin SET tax_id=gs2tax_id('HUMAN') 
  WHERE porigin_id=porigin_id_lookup('dblast'::text) AND descr ~ '- Rattus norvegicus$' AND tax_id IS NULL;


-- SPDI - key off the initial species word in the descr
UPDATE paliasorigin SET tax_id=gs2tax_id('HUMAN') 
  WHERE porigin_id=porigin_id_lookup('SPDI'::text) AND descr ~ '^Human'::text AND tax_id IS NULL;

UPDATE paliasorigin SET tax_id=gs2tax_id('MOUSE') 
  WHERE porigin_id=porigin_id_lookup('SPDI'::text) AND descr ~ '^Mouse'::text AND tax_id IS NULL;

UPDATE paliasorigin SET tax_id=gs2tax_id('RAT') 
  WHERE porigin_id=porigin_id_lookup('SPDI'::text) AND descr ~ '^Rat'::text AND tax_id IS NULL;


-- species specific database stuff
UPDATE paliasorigin SET tax_id=gs2tax_id('MOUSE') 
  WHERE porigin_id=porigin_id_lookup('mus'::text) AND tax_id IS NULL;

UPDATE paliasorigin SET tax_id=gs2tax_id('HUMAN') 
  WHERE porigin_id=porigin_id_lookup('MGC/Human'::text) AND tax_id IS NULL;

UPDATE paliasorigin SET tax_id=gs2tax_id('MOUSE') 
  WHERE porigin_id=porigin_id_lookup('MGC/Mouse'::text) AND tax_id IS NULL;

