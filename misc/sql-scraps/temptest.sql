create or replace function temptest() returns void
language plpgsql as '
DECLARE
	m integer;
	n integer;
BEGIN
	FOR m IN 1..10 LOOP
		create temp table less_than_m as 
			select distinct pseq_id from pseq where pseq_id<m;

		select into n count(*) from less_than_m;

		raise notice ''there are % less than %'',n,m;

		drop table less_than_m;
	END LOOP;
END;';


create or replace function temptest2() returns void
language plpgsql as '
DECLARE
	m integer;
	n integer;
BEGIN
	FOR m IN 1..10 LOOP
		select into n count1(m);
		raise notice ''there are % less than %'',n,m;
	END LOOP;
END;';




create or replace function count1(integer) returns integer
language plpgsql as '
DECLARE
	m alias for $1;
	n integer;
BEGIN
	create temp table less_than_m as 
		select distinct pseq_id from pseq where pseq_id<m;
	select into n count(*) from less_than_m;
	drop table less_than_m;
	return n;
END;';


