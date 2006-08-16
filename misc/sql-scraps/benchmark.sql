CREATE OR REPLACE FUNCTION _get_benchmark(text,integer)
RETURNS numeric AS '
DECLARE
    code ALIAS for $1;
    n ALIAS for $2;
    s TIMESTAMP;
    e TIMESTAMP;
    d numeric := 0;
    r record;
BEGIN
	FOR a in 1..n LOOP
	        s := timeofday();
		EXECUTE code;
	        e := timeofday();
	        d := d + (extract(epoch from e) - extract(epoch from s));
	END LOOP;
 	return (d/n)*1000;
END; ' LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION _get_benchmark(text)
RETURNS numeric AS '
DECLARE
    code ALIAS for $1;
BEGIN
 	return _get_benchmark(code,1);
END; ' LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _get_benchmark(text[],integer)
RETURNS SETOF numeric AS '
DECLARE
    codes ALIAS for $1;
    n ALIAS for $2;
BEGIN
	FOR i IN array_lower(codes,1) .. array_upper(codes, 1) LOOP
		return next _get_benchmark(codes[i],n);
	END LOOP;
	RETURN;
END; ' LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _get_benchmark(text[])
RETURNS SETOF numeric AS '
DECLARE
    codes ALIAS for $1;
BEGIN
	FOR i IN array_lower(codes,1) .. array_upper(codes, 1) LOOP
		return next _get_benchmark(codes[i],1);
	END LOOP;
	RETURN;
END; ' LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION _get_benchmark()
RETURNS SETOF numeric AS '
DECLARE
    q RECORD;
BEGIN
	FOR q IN SELECT query from benchmark LOOP
		return next _get_benchmark(q.query,1);
	END LOOP;
	RETURN;
END; ' LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _get_benchmark(integer)
RETURNS numeric AS '
DECLARE
    i ALIAS for $1;
    q RECORD;
BEGIN
	SELECT INTO q query from benchmark where benchmark_id=i;
	return _get_benchmark(q.query,1);
END; ' LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION benchmark()
RETURNS SETOF benchmark AS '
DECLARE
    q RECORD;
    t numeric;
BEGIN	
	RAISE INFO ''*************first run*************'';
	FOR q IN SELECT * from benchmark LOOP
		t=_get_benchmark(q.query,1);
		RAISE INFO ''% : %ms (% %%) '',q.query,to_char(t,''99999.99''),to_char((t/q.runtime)*100,''999.99'');
		q.runtime=t;
		return next q;
	END LOOP;
	RAISE INFO '''';
	RAISE INFO ''*************cached run (average of 5 runs)*************'';
	FOR q IN SELECT * from benchmark LOOP
		t=_get_benchmark(q.query,5);
		RAISE INFO ''% : %ms (% %%) '',q.query,to_char(t,''99999.99''),to_char((t/q.runtime)*100,''999.99'');
		q.runtime=t;
		return next q;
	END LOOP;
	RETURN;

END; ' LANGUAGE plpgsql;



GRANT EXECUTE ON function _get_benchmark(text) to rkh;
GRANT EXECUTE ON function _get_benchmark(text,integer) to rkh;
GRANT EXECUTE ON function _get_benchmark(text[]) to rkh;
GRANT EXECUTE ON function _get_benchmark(text[],integer) to rkh;
GRANT EXECUTE ON function _get_benchmark(integer) to rkh;
GRANT EXECUTE ON function _get_benchmark() to rkh;
GRANT EXECUTE ON function benchmark() to rkh;
