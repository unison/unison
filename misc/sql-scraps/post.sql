COMMENT ON database csb IS 'Computational Structural Biology / See Reece Hart for details';
COMMENT ON SCHEMA unison IS 'integrated proteomic annotation database';
COMMENT ON SCHEMA scop IS 'Structural Classification of Proteins v1.61 (http://scop.berkeley.edu/)';

SET search_path = unison;

-- CREATE INDEX len ON pseq USING btree (len);
-- CREATE INDEX palias ON pseq USING btree (palias_id);
-- CREATE UNIQUE INDEX seqhash ON pseq USING btree (seqhash(seq));
-- CREATE INDEX md5 ON pseq USING btree (md5);
-- ALTER TABLE ONLY pseq
--    ADD CONSTRAINT palias_id_exists FOREIGN KEY (palias_id) REFERENCES palias(palias_id) ON UPDATE NO ACTION ON DELETE NO ACTION;
-- alter table only pseq add constraint pseq_pkey primary key ("pseq_id");


-- CREATE INDEX ref_pseq_id ON palias USING btree (ref_pseq_id);
-- CREATE INDEX pseq_id ON palias USING btree (pseq_id);
-- CREATE INDEX porigin_id ON palias USING btree (porigin_id);
-- CREATE INDEX alias ON palias USING btree (alias);
-- ALTER TABLE ONLY palias
--    ADD CONSTRAINT ref_pseq_id_exists FOREIGN KEY (ref_pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE NO ACTION;
-- ALTER TABLE ONLY palias  ADD CONSTRAINT palias_pkey primary key (palias_id);
ALTER TABLE ONLY palias
    ADD CONSTRAINT unique_in_origin UNIQUE (porigin_id, alias);
ALTER TABLE ONLY palias
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY palias
    ADD CONSTRAINT porigin_id_exists FOREIGN KEY (porigin_id) REFERENCES porigin(porigin_id) ON UPDATE CASCADE ON DELETE CASCADE;


-- CREATE INDEX pftype_id ON pfeature USING btree (pftype_id);
-- CREATE INDEX pseq_id ON pfeature USING btree (pseq_id);
-- ALTER TABLE ONLY pfeature ADD CONSTRAINT pfeature_id_pkey primary key (pfeature_id);
-- ALTER TABLE ONLY pfeature
--    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY pfeature
    ADD CONSTRAINT pftype_id_exists FOREIGN KEY (pftype_id) REFERENCES pftype(pftype_id) ON UPDATE CASCADE ON DELETE CASCADE;


CREATE INDEX pseq_id ON pseqset USING btree (pseq_id);
CREATE INDEX pset_id ON pseqset USING btree (pset_id);
ALTER TABLE ONLY pseqset
    ADD CONSTRAINT seq_already_in_set UNIQUE (pset_id, pseq_id);
ALTER TABLE ONLY pseqset
    ADD CONSTRAINT pset_id_exists FOREIGN KEY (pset_id) REFERENCES pset(pset_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY pseqset
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


CREATE UNIQUE INDEX origin ON porigin USING btree (upper(origin));
ALTER TABLE ONLY porigin ADD CONSTRAINT porigin_id_pkey primary key (porigin_id);


CREATE UNIQUE INDEX name ON pset USING btree (upper(name));
ALTER TABLE ONLY pset ADD CONSTRAINT pset_id_pkey primary key (pset_id);


CREATE UNIQUE INDEX name ON p2params USING btree (name);
ALTER TABLE ONLY p2params  ADD CONSTRAINT p2params_id_pkey primary key (p2params_id);


CREATE UNIQUE INDEX name_uniqueness ON p2template USING btree (upper(name));
ALTER TABLE ONLY p2template ADD CONSTRAINT p2template_id_pkey primary key (p2template_id);
ALTER TABLE ONLY p2template
    ADD CONSTRAINT pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


CREATE INDEX p2params_id ON p2thread USING btree (p2params_id);
CREATE INDEX p2template_id ON p2thread USING btree (p2template_id);
CREATE UNIQUE INDEX unique_pseq_params_template ON p2thread USING btree (pseq_id, p2params_id, p2template_id);
CREATE INDEX pseq_id ON p2thread USING btree (pseq_id);
ALTER TABLE ONLY p2thread
    ADD CONSTRAINT p2params_id_exists FOREIGN KEY (p2params_id) REFERENCES p2params(p2params_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY p2thread
    ADD CONSTRAINT p2template_id_exists FOREIGN KEY (p2template_id) REFERENCES p2template(p2template_id) ON UPDATE CASCADE ON DELETE CASCADE;


CREATE INDEX sigpredict ON pseqprop USING btree (sigpredict);
ALTER TABLE ONLY pseqprop ADD CONSTRAINT pseq_id_pkey primary key ("pseq_id");
ALTER TABLE ONLY pseqprop
    ADD CONSTRAINT pseqprop_pseq_id_exists FOREIGN KEY (pseq_id) REFERENCES pseq(pseq_id) ON UPDATE CASCADE ON DELETE CASCADE;


CREATE UNIQUE INDEX name ON hmm USING btree (name);
ALTER TABLE ONLY hmm
    ADD CONSTRAINT hmm_pkey PRIMARY KEY (hmm_id);
ALTER TABLE ONLY hmm
    ADD CONSTRAINT hmm_porigin_id_exists FOREIGN KEY (porigin_id) REFERENCES porigin(porigin_id) ON UPDATE CASCADE ON DELETE CASCADE;


CREATE INDEX pseq_id ON pfhmm USING btree (pseq_id);
CREATE INDEX score ON pfhmm USING btree (score);
CREATE INDEX eval ON pfhmm USING btree (eval);
ALTER TABLE ONLY pfhmm
    ADD CONSTRAINT pfhmm_hmm_id_exists FOREIGN KEY (hmm_id) REFERENCES hmm(hmm_id) ON UPDATE CASCADE ON DELETE CASCADE;


CREATE UNIQUE INDEX model_already_in_set ON pmsm USING btree (pmodelset_id, p2template_id);
ALTER TABLE ONLY pftype ADD CONSTRAINT pftype_id_pkey primary key (pftype_id);


ALTER TABLE ONLY pmodelset
    ADD CONSTRAINT pmodelset_pkey PRIMARY KEY (pmodelset_id);

ALTER TABLE ONLY pmsm
    ADD CONSTRAINT pmodelset_id_exists FOREIGN KEY (pmodelset_id) REFERENCES pmodelset(pmodelset_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY pmsm
    ADD CONSTRAINT p2template_id_exists FOREIGN KEY (p2template_id) REFERENCES p2template(p2template_id) ON UPDATE CASCADE ON DELETE CASCADE;


ALTER TABLE ONLY meta ADD CONSTRAINT meta_pkey PRIMARY KEY ("key");


CREATE TRIGGER pseq_iu_trigger
    BEFORE INSERT OR UPDATE ON pseq
    FOR EACH ROW
    EXECUTE PROCEDURE pseq_iu_trigger ();
CREATE TRIGGER p2thread_i_trigger
    BEFORE INSERT ON p2thread
    FOR EACH ROW
    EXECUTE PROCEDURE p2thread_i_trigger ();



-- SET search_path = scop;
-- CREATE INDEX pdb ON cla USING btree (pdb);
-- CREATE INDEX sid ON cla USING btree (sid);
-- CREATE INDEX sccs ON cla USING btree (sccs);
-- CREATE INDEX sunid ON hie USING btree (sunid);
-- CREATE INDEX psunid ON hie USING btree (psunid);
-- ALTER TABLE ONLY des
--    ADD CONSTRAINT des_pkey PRIMARY KEY (sunid);
-- ALTER TABLE ONLY cla
--     ADD CONSTRAINT cla_pkey PRIMARY KEY (sunid);
