CREATE or replace FUNCTION unison.pseq_iu_trigger () RETURNS "trigger" LANGUAGE plpgsql AS '
declare
    orig_md5 text;
begin
	-- compute the incoming sequence''s md5 so that we can warn about changes
	-- (note: length doesn''t work because we might just up-case it)
    orig_md5 := md5(new.seq);

	-- remove whitespace and bogus chars, and upcase sequence
    new.seq := clean_sequence(new.seq);

	-- modifying sequences is prohibited
	if tg_op = ''UPDATE'' and old.seq != new.seq then
		raise exception ''pseq sequences may not be altered'';
	end if;

	-- compute the md5 and length of the "cleaned" sequence
    new.md5 := md5(new.seq);
    new.len := length(new.seq);

	-- warn (and proceed) if the sequence was modified by clean_sequence
    if orig_md5 != new.md5 then
        raise notice ''pseq_id % modified during insert.'',new.pseq_id;
    end if;

    return new;
end;';


CREATE TRIGGER pseq_iu_trigger
    BEFORE INSERT OR UPDATE ON pseq
    FOR EACH ROW
    EXECUTE PROCEDURE pseq_iu_trigger ();
 
