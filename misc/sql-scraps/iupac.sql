create or replace function has_iupac_ambiguity_aa(text)
returns boolean strict immutable language sql as 
'select $1 ~ ''[BXZ]''';
comment on function has_iupac_ambiguity_aa(text) is
	'sequence contains IUPAC ambiguity (B=[DE], Z=[NQ], X=any)'; 
grant execute on function has_iupac_ambiguity_aa(text) to public;

create or replace function has_iupac_gap_aa(text)
returns boolean strict immutable language sql as 
'select $1 ~ ''-''';
comment on function has_iupac_gap_aa(text) is
	'sequence contains an IUPAC gap';
grant execute on function has_iupac_gap_aa(text) to public;

create or replace function has_iupac_stop_aa(text)
returns boolean strict immutable language sql as 
'select $1 ~ ''\\\\*''';
comment on function has_iupac_stop_aa(text) is
	'sequence contains an IUPAC stop';
grant execute on function has_iupac_stop_aa(text) to public;



create or replace function has_non_iupac_aa(text)
returns boolean strict immutable language sql as
'select $1 ~ ''[^-*ACDEFGHIKLMNPQRSTVWYUBZX]''';
comment on function has_non_iupac_aa(text) is
	'sequence has non-IUPAC symbols (selenocysteine, gaps, stops, and ambiguities okay)';
grant execute on function has_non_iupac_aa(text) to public;



create or replace function has_only_iupac_aa_ungapped(text)
returns boolean strict immutable language sql as
'select $1 !~ ''[^ACDEFGHIKLMNPQRSTVWYUBZX]''';
comment on function has_only_iupac_aa_ungapped(text) is
	'ungapped sequence contains only IUPAC amino acids or ambiguities';
grant execute on function has_only_iupac_aa_ungapped(text) to public;

create or replace function has_only_iupac_std_aa_ungapped(text)
returns boolean strict immutable language sql as
'select $1 !~ ''[^ACDEFGHIKLMNPQRSTVWY]''';
comment on function has_only_iupac_std_aa_ungapped(text) is
	'ungapped sequence contains only the standard 20 IUPAC amino acids';
grant execute on function has_only_iupac_std_aa_ungapped(text) to public;
