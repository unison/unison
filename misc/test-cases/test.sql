insert into pseq (seq) VALUES ('SEQUENCE');
insert into porigin (origin) VALUES ('Reece''s brain');
insert into palias (pseq_id,porigin_id,alias) VALUES (1000000,1,'bogus');

select * from pseq,porigin,palias;
select currval('pseq_id'), currval('porigin_id'), currval('palias_id');

insert into pseq (sequence) VALUES ('r!@e #$e%^&c3*()e_-~');
insert into porigin (origin) VALUES ('Reece''s brain');
insert into palias (pseq_id,porigin_id,alias) VALUES (1000000,1,'bogus');

select * from pseq,porigin,palias;
select currval('pseq_id'), currval('porigin_id'), currval('palias_id');
