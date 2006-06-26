insert into pseq (seq) VALUES ('SEQUENCE');
insert into origin (origin) VALUES ('Reece''s brain');
insert into palias (pseq_id,origin_id,alias) VALUES (1000000,1,'bogus');

select * from pseq,origin,palias;
select currval('pseq_id'), currval('origin_id'), currval('palias_id');

insert into pseq (sequence) VALUES ('r!@e #$e%^&c3*()e_-~');
insert into origin (origin) VALUES ('Reece''s brain');
insert into palias (pseq_id,origin_id,alias) VALUES (1000000,1,'bogus');

select * from pseq,origin,palias;
select currval('pseq_id'), currval('origin_id'), currval('palias_id');
