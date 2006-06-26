drop table pfregexp;
drop table pmregexp;

create table pmregexp (
    regexp text
) inherits (pmodel) without oids; 

create unique index pmregexp_pmodel_id on pmregexp (pmodel_id );

create or replace function pmregexp_u_trigger ()
returns trigger
language plpgsql as '
BEGIN
	RAISE EXCEPTION ''pmodel_id % (%): regular expressions are immutable'',
           OLD.pmodel_id, OLD.acc;
	-- no return
    RETURN NEW;
END;';

create trigger pmregexp_u_trigger before update on pmregexp 
for each row execute procedure pmregexp_u_trigger();


--create rule pmregexp_regexps_are_immutable as on update to pmregexp where
--old.regexp != new.regexp do instead select warn(old.acc||': regexps are immutable');

create table pfregexp (
    pmodel_id integer not null 
        references pmregexp(pmodel_id)
        on delete cascade on update cascade
) inherits (pfeature) without oids;


comment on table pmregexp is 'regular expression models (e.g., PROSITE and other simple motifs)';
comment on table pfregexp is 'regular expression features based on pmregexp motifs';




insert into pmregexp (origin_id,acc,regexp,descr) values (origin_id_lookup('rkh'),
    'ITIM','[ILV].(Y)..[ILV]',
    'Immunotyrosine Inhibition Motif. See http://elm.eu.org/basicELM/cgimodel.py?fun=Show_Elm&elmId=20');
insert into pmregexp (origin_id,acc,regexp,descr) values (origin_id_lookup('rkh'),
    'ITAM','[DE]..(Y)..[LI].{6,12}(Y)..[LI]',
    'Immunotyrosine Activation Motif. See http://elm.eu.org/basicELM/cgimodel.py?fun=Show_Elm&elmId=17');
insert into pmregexp (origin_id,acc,regexp,descr) values (origin_id_lookup('rkh'),
    'ITSM','..T.(Y)..[IV]',
    'Immunotyrosine Switch Motif. See http://elm.eu.org/basicELM/cgimodel.py?fun=Show_Elm&elmId=142');

