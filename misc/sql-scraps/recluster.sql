-- This sql defines the table clustering order
-- Clustering is purely for optimization.
-- At the moment, I just run this manually.
-- see also reindex.sql

-- This may help to generate the list below:
-- select tablename, 'cluster ' || indexname || ' on ' || tablename  from pg_indexes  where schemaname = 'unison' order by tablename;

\set ECHO all

cluster last_run_nonredundant on last_run;
cluster pahmm_redundant_feature on pahmm;
cluster paprospect2_redundant_feature on paprospect2;
cluster papseq_redundant_feature on papseq;
cluster papssm_redundant_feature on papssm;
cluster pfantigenic_redundant_feature on pfantigenic;
cluster pfsigcleave_redundant_feature on pfsigcleave;
cluster pfsignalphmm_redundant_feature on pfsignalphmm;
cluster pfsignalpnn_redundant_feature on pfsignalpnn;
cluster pftmdetect_redundant_feature on pftmdetect;
cluster pmhmm_pkey on pmhmm;
cluster p2template_pkey on pmprospect2;
cluster pmpseq_pmodel_id on pmpseq;
cluster pmregexp_pmodel_id on pmregexp;
cluster pmsm_pmhmm_model_already_in_set on pmsm_pmhmm;
cluster pmsm_pmpssm_model_already_in_set on pmsm_pmpssm;
cluster pmsm_p2template_model_already_in_set on pmsm_prospect2;
cluster pseq_pkey on pseq;
cluster pseqalias_duplicate_alias_and_version on pseqalias;
cluster pseqprop_pseq_id_idx on pseqprop;
cluster seq_already_in_set on pseqset;
cluster seqov_ori1_ori2 on seqov;

\set ECHO none
