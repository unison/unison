create or replace function porigin_id_lookup (text)
returns integer
language plpgsql as '
BEGIN
	raise warning ''porigin_id_lookup(text) deprecated; use porigin_id(text) instead'';
	return porigin_id($1);
END;';

