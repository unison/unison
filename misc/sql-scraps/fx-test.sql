create or replace function test_nospec() returns void 
language plpgsql
AS '';

create or replace function test_volatile() returns void 
language plpgsql   VOLATILE
AS '';

create or replace function test_immutable() returns void 
language plpgsql   IMMUTABLE
AS '';

create or replace function test_stable() returns void 
language plpgsql   STABLE
AS '';

create or replace function test_strict() returns void 
language plpgsql   STRICT
AS '';
