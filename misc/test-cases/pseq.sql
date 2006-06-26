\echo =================================================================
\echo adding sequences; expect 3 failures
insert into pseq (seq) VALUES ('SEQUENCE');
insert into pseq (seq) VALUES ('SEQUENCE');	-- fail
insert into pseq (seq) VALUES ('SEQ UENCE'); -- fail
insert into pseq (seq) VALUES ('SE!@#$%^+=()QUENCE'); --fail
\echo return to continue \!read z


\echo =================================================================
\echo adding origins; expect 1 failure
insert into origin (origin) VALUES ('Reece''s left brain');
insert into origin (origin) VALUES ('Reece''s right brain');
insert into origin (origin) VALUES ('Reece''s left brain');	--fail
\echo return to continue \!read z


\echo =================================================================
\echo adding sequences; expect 1 failure
insert into palias (pseq_id,origin_id,alias) VALUES (1,1,'ori1name');
insert into palias (pseq_id,origin_id,alias) VALUES (1,2,'ori2name');
insert into palias (pseq_id,origin_id,alias) VALUES (999,1,'ori1name'); --fail
\echo return to continue \!read z


\echo =================================================================
\echo removing origin 2; aliases with origin_id=2 should disappear...
\echo before:
select * from palias where origin_id=2;
delete from origin where origin_id=2;
\echo after:
select * from palias where origin_id=2;
\echo return to continue \!read z

