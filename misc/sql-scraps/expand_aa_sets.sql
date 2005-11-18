create or replace function _expand_aa_sets(text)
returns text strict immutable language plperl as '
# http://www.dur.ac.uk/biological.sciences/Bioinformatics/aminoacids.htm
# http://www.ncbi.nlm.nih.gov/Class/MLACourse/Modules/MolBioReview/iupac_aa_abbreviations.html
# http://www.ncbi.nlm.nih.gov/projects/collab/FT/index.html#7.5.3
# Expasy References:
# 1) Thomas E. Creighton (1993) "Proteins." W.H. Freeman and Company, New York. 2nd Edition.
# 2) Richards, F.M. (1974) J. Mol.Biol. 82:1-14. [Van-der-Waals radii of amino acids]

$_ = shift;

# IUPAC ambiguities
## Ambiguity codes are included in their own expansions so that
## they match themselves in sequences which contain ambiguities.
s/B/[BDN]/g;
s/Z/[ZEQ]/g;
s/X/[ACDEFGHIKLMNPQRSTVWYUBZX]/g;

# amino acid sets
s/<(?:basic|\\+)>/[HKR]/g;
s/<(?:acidic|-)>/[DE]/g;
s/<(?:neutral|0)>/[ACFGILMNPQSTUVWY]/g;
s/<(?:polar|p)>/[NQST]/g;
s/<(?:hphobic|o)>/[AIFLMVWY]/g;
s/<(?:aromatic|r)>/[FWY]/g;
s/<(?:small|s)>/[AGS]/g;
s/<(?:medium|m)>/[CDEHILMNPQTUV]/g;	 # U~C
s/<(?:large|l)>/[FKRWY]/g;

s/<(.*)>/!!$1!!/g;				# unrecognized sets

return $_;
';
comment on function _expand_aa_sets(text) is
	'INTERNAL; see expand_aa_sets(text)';
grant execute on function _expand_aa_sets(text) to public;



create or replace function expand_aa_sets(text) returns text
strict immutable language sql as 
'select _clean_regexp(_expand_aa_sets($1))';
comment on function expand_aa_sets(text) is
	'expand sets of amino acids represented in the given string';
grant execute on function expand_aa_sets(text) to public;

