UPDATE palias SET tax_id=gs2tax_id('HUMAN') 
	WHERE porigin_id=porigin_id_lookup('Swiss-Prot'::text) AND tax_id IS NULL AND alias ~ '_HUMAN$'::text;

UPDATE palias SET tax_id=gs2tax_id('MOUSE') 
	WHERE porigin_id=porigin_id_lookup('Swiss-Prot'::text) AND tax_id IS NULL AND alias ~ '_MOUSE$'::text;

UPDATE palias SET tax_id=gs2tax_id('RAT') 
	WHERE porigin_id=porigin_id_lookup('Swiss-Prot'::text) AND tax_id IS NULL AND alias ~ '_RAT$'::text;

UPDATE palias SET tax_id=gs2tax_id('HUMAN') 
	WHERE porigin_id=porigin_id_lookup('Refseq'::text) AND descr ~ '[[]Homo sapiens[]]$'::text AND tax_id IS NULL;

UPDATE palias SET tax_id=gs2tax_id('MOUSE') 
      WHERE porigin_id=porigin_id_lookup('Refseq'::text) AND descr ~ '[[]Mus musculus[]]$'::text AND tax_id IS NULL;

UPDATE palias SET tax_id=gs2tax_id('RAT') 
      WHERE porigin_id=porigin_id_lookup('Refseq'::text) AND descr ~ '[[]Rattus norvegicus[]]$'::text AND tax_id IS NULL;

UPDATE palias SET tax_id=gs2tax_id('HUMAN') 
	WHERE porigin_id=porigin_id_lookup('SPDI'::text) AND descr ~ '^Human'::text AND tax_id IS NULL;

UPDATE palias SET tax_id=gs2tax_id('MOUSE') 
      WHERE porigin_id=porigin_id_lookup('SPDI'::text) AND descr ~ '^Mouse'::text AND tax_id IS NULL;

UPDATE palias SET tax_id=gs2tax_id('RAT') 
      WHERE porigin_id=porigin_id_lookup('SPDI'::text) AND descr ~ '^Rat'::text AND tax_id IS NULL;

UPDATE palias SET tax_id=gs2tax_id('MOUSE') 
	WHERE porigin_id=porigin_id_lookup('mus'::text) AND tax_id IS NULL;

UPDATE palias SET tax_id=gs2tax_id('HUMAN') 
	WHERE porigin_id=porigin_id_lookup('MGC/Human'::text) AND tax_id IS NULL;

UPDATE palias SET tax_id=gs2tax_id('MOUSE') 
	WHERE porigin_id=porigin_id_lookup('MGC/Mouse'::text) AND tax_id IS NULL;
