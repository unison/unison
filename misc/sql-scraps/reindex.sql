-- This SQL reindexes most tables in unison
-- This is worth doing peridically to recover unused index pages
-- WARNING: reindexing exclusively locks the specified table; write AND READS
-- will block until it finishes.
-- see also recluster.sql

reindex table pmsm_pmhmm;
reindex table palignment;
reindex table pmodelset;
reindex table pmodel;
reindex table pmhmm;
reindex table pmsm_pmpssm;
reindex table pmpssm;
reindex table plocus;
reindex table meta;
reindex table gseq;
reindex table pseqalias;
reindex table genome;
reindex table locus;
reindex table translation;
reindex table pfsigcleave;
reindex table pmprospect2;
reindex table origin;
reindex table pseqset;
reindex table pset;
reindex table pmsm;
reindex table pmsm_p2template;
reindex table pmpseq;
reindex table rprospect2;
reindex table pahmm;
reindex table pftmdetect;
reindex table pseq2go;
reindex table pmodel2go;
reindex table paprospect2;
reindex table pseqprop;
reindex table papseq;
reindex table pseq;
reindex table papssm;
reindex table pfantigenic;
reindex table pfeature;
reindex table pftype;
reindex table run;
reindex table last_run;
reindex table pfsignalpnn;
reindex table pfsignalphmm;
reindex table paliasorigin;
