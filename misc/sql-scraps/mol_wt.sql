#$Id$
create or replace function mol_wt(text)
returns real strict immutable language plperl as '

# http://www.expasy.org/tools/pi_tool-doc.html
# Protein Mw can be calculated by 
# the addition of average isotopic masses of amino acids (zwitter ion) in the protein 
# and the average isotopic mass of one water molecule.

#from EMBOSS/share/EMBOSS/data/Eamino.dat
my %weights = (
A => 71.0786,
B => 114.5960,
# They are for proteins with full reduced cysteine residues.  If all
# cysteines are oxidized to cystine, use
# a value of 60 for C
C => 103.1386,
D => 115.0884,
E => 129.1152,
F => 147.1762,
G => 57.0518,
H => 137.1408,
I => 113.1590,
K => 128.1736,
L => 113.1590,
# If met gets oxidised to the sulphoxide replace by 147.1926
M => 131.1926,
N => 114.1036,
P => 97.1164,
Q => 128.1304,
R => 156.1870,
S => 87.0780,
T => 101.1048,
U => 150.038, #not in EMBOSS
V => 99.1322,
W => 186.2128,
X => 144.0000,
Y => 163.1756,
Z => 128.6228
);

$_ = shift;
elog(ERROR, "sequence length <= 0") if(length($_) <= 0);

my $mol_wt =18.015; #mass of one water molecule

foreach my $aa(split //, $_) {
	elog(ERROR, "Unexpedted amino acid ".$aa) if(not defined $weights{uc($aa)});
	$mol_wt += $weights{uc($aa)};
}	
return $mol_wt;
';
comment on function mol_wt(text) is
	'returns the molecular weight of the protein in daltons';
grant execute on function mol_wt(text) to public;

