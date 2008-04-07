CREATE OR REPLACE FUNCTION aa_1_to_3(text) returns text
strict immutable
language sql  as
$_$
select case $1
	when 'A' then 'Ala'
	when 'B' then 'Bas'
	when 'C' then 'Cys'
	when 'D' then 'Asp'
	when 'E' then 'Glu'
	when 'F' then 'Phe'
	when 'G' then 'Gly'
	when 'H' then 'His'
	when 'I' then 'Iso'
	when 'K' then 'Lys'
	when 'L' then 'Leu'
	when 'M' then 'Met'
	when 'N' then 'Asn'
	when 'P' then 'Pro'
	when 'Q' then 'Gln'
	when 'R' then 'Arg'
	when 'S' then 'Ser'
	when 'T' then 'Thr'
	when 'V' then 'Val'
	when 'W' then 'Trp'
	when 'X' then 'Any'
	when 'Y' then 'Tyr'
	when 'Z' then 'Aci'
--	when '*' then 'Stp'
	else '???'
	end;
$_$;


CREATE OR REPLACE FUNCTION aa_3_to_1(text) returns text
strict immutable
language sql  as
$_$
select case $1
	when 'Ala' then 'A'
	when 'Bas' then 'B'
	when 'Cys' then 'C'
	when 'Asp' then 'D'
	when 'Glu' then 'E'
	when 'Phe' then 'F'
	when 'Gly' then 'G'
	when 'His' then 'H'
	when 'Iso' then 'I'
	when 'Lys' then 'K'
	when 'Leu' then 'L'
	when 'Met' then 'M'
	when 'Asn' then 'N'
	when 'Pro' then 'P'
	when 'Gln' then 'Q'
	when 'Arg' then 'R'
	when 'Ser' then 'S'
	when 'Thr' then 'T'
	when 'Val' then 'V'
	when 'Trp' then 'W'
	when 'Any' then 'X'
	when 'Tyr' then 'Y'
	when 'Aci' then 'Z'
	else '?'
	end;
$_$;



grant execute on function aa_1_to_3(text) to public;
grant execute on function aa_3_to_1(text) to public;
