CREATE TABLE psprotcomp_location (
	psloc_id serial primary key,
	location text NOT NULL
) WITHOUT OIDS;

grant select on psprotcomp_location to PUBLIC;
comment on table psprotcomp_location is 'Softberry protcomp location lookup table';

insert into psprotcomp_location(psloc_id,location) values (0,'no prediction');
insert into psprotcomp_location(location) values ('Cytoplasmic');
insert into psprotcomp_location(location) values ('Endoplasmic reticulum');
insert into psprotcomp_location(location) values ('Extracellular (Secreted)');
insert into psprotcomp_location(location) values ('Golgi');
insert into psprotcomp_location(location) values ('Lysosomal');
insert into psprotcomp_location(location) values ('Mitochondrial');
insert into psprotcomp_location(location) values ('Nuclear');
insert into psprotcomp_location(location) values ('Peroxisomal');
insert into psprotcomp_location(location) values ('Plasma membrane');



-- psprotcomp
-- ----------
-- simloc, simscore, simdb, simtarget (pseq_id)
-- nnloc, nnscore
-- intloc, intscore
-- {nuc,pm,ext,cytop,mito,er,per,lys,golgi,avg?}int
-- 
-- other: tmstring, sig, gpi
-- patt conn with...
-- 
-- result
CREATE TABLE psprotcomp (
    pseq_id integer NOT NULL 
		CONSTRAINT psprotcomp_pseq_id_exists REFERENCES pseq(pseq_id)
		ON DELETE CASCADE ON UPDATE CASCADE, 

    params_id integer NOT NULL
		CONSTRAINT psprotcomp_params_id_exists REFERENCES params(params_id)
		ON DELETE CASCADE ON UPDATE CASCADE, 

	-- SIMILARILITY SUMMARY
	sim_psloc_id integer NOT NULL
		constraint psprotcomp_sim_psloc_id_exists 
		REFERENCES psprotcomp_location(psloc_id)
		ON DELETE NO ACTION ON UPDATE NO ACTION,
	sim_score real,
	sim_db text,
	sim_target_ac text,
	-- -- commented the following to obviate pseq_id lookup during loading
	-- sim_target_pseq_id integer
	-- 	CONSTRAINT psprotcomp_pseq_id_exists REFERENCES pseq(pseq_id)
	-- 	ON DELETE NO ACTION ON UPDATE CASCADE, 

	-- NN SUMMARY
	nn_psloc_id integer NOT NULL
		constraint psprotcomp_nn_psloc_id_exists 
		REFERENCES psprotcomp_location(psloc_id)
		ON DELETE NO ACTION ON UPDATE NO ACTION,
	nn_score real NOT NULL,

	-- INTEGRAL SUMMARY
	int_psloc_id integer NOT NULL
		constraint psprotcomp_int_psloc_id_exists 
		REFERENCES psprotcomp_location(psloc_id)
		ON DELETE NO ACTION ON UPDATE NO ACTION,
	int_score real NOT NULL,
	int_membrane boolean NOT NULL default FALSE,

	-- WEIGHTS
	int_nuc_score real NOT NULL,
	int_pm_score real NOT NULL,
	int_ext_score real NOT NULL,
	int_cyt_score real NOT NULL,
	int_mit_score real NOT NULL,
	int_er_score real NOT NULL,
	int_per_score real NOT NULL,
	int_lys_score real NOT NULL,
	int_gol_score real NOT NULL,

	features text,
	result_block text NOT NULL

) WITHOUT OIDS;


CREATE UNIQUE INDEX psprotcomp_pseq_id_params_id ON psprotcomp (pseq_id,params_id);
CREATE UNIQUE INDEX psprotcomp_search1 ON psprotcomp (params_id,sim_psloc_id,sim_score,pseq_id);
CREATE UNIQUE INDEX psprotcomp_search2 ON psprotcomp (params_id,nn_psloc_id,nn_score,pseq_id);
CREATE UNIQUE INDEX psprotcomp_search3 ON psprotcomp (params_id,int_psloc_id,int_score,pseq_id);
grant select on psprotcomp to PUBLIC;
grant insert on psprotcomp to loader;
comment on table psprotcomp is 'Softberry protcomp predictions';


create view v_psprotcomp as
select pseq_id,params_id,sim_psloc_id,sl.location as
sim_loc,sim_score,nn_psloc_id,nl.location as
nn_loc,nn_score,int_psloc_id,il.location as int_loc,int_score from
psprotcomp PC join psprotcomp_location sl on sl.psloc_id=PC.sim_psloc_id
join psprotcomp_location nl on nl.psloc_id=PC.nn_psloc_id join
psprotcomp_location il on il.psloc_id=PC.int_psloc_id;

grant select on v_psprotcomp to PUBLIC;
comment on view v_psprotcomp is 'protcomp summary view';


create view v_psprotcomp_reliable as
select pseq_id,params_id,sim_psloc_id as psloc_id,sim_loc as loc,
   'sequence similarity' as "method" from v_psprotcomp
WHERE sim_psloc_id!=0
UNION
SELECT pseq_id,params_id,nn_psloc_id as psloc_id,nn_loc as loc,
   'nn & integral agreement' as "method" from v_psprotcomp
WHERE sim_psloc_id=0 and int_psloc_id=nn_psloc_id;

grant select on v_psprotcomp_reliable to PUBLIC;
comment on view v_psprotcomp_reliable is 'reliable protcomp predictions';


-- pfprotcomp
-- ----------
-- tm,sig,gpi
-- COULD BE EXTRACTED FROM result_block, but aren't yet
