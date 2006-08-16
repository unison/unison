--#$Id$
-- E(Prot) = Numb(Tyr)*Ext(Tyr) + Numb(Trp)*Ext(Trp) + Numb(Cystine)*Ext(Cystine)
-- Pace et. al. Protein Science 1995

create or replace function A280(text,text,boolean)
returns real strict immutable language plperl as '

my %ec_params;
#EMBOSS/share/EMBOSS/data/Eamino.dat
$ec_params{emboss} = {
	eY => 1280,
	eW => 5690,
	eC => 60
	}; 
 
#Pace et al
$ec_params{pace} = {
	eY => 1490,
	eW => 5500,
	eC => 125
	};

my $seq = shift;
elog(ERROR, "sequence length <= 0") if(length($seq) <= 0);

my $params = shift;
elog(ERROR, "extinction coefficents set $params does not exist options are ''emboss'' (Gill and von Hippel (1989) _Anal_Biochem_ 182 319-326) and ''Pace'' (Pace et. al. Protein Science 1995)\n") if(not defined $ec_params{$params});

my $all_cystines = shift;
my $count = count_TyrTrp_residues($seq);

my $ans= (($count->{Y} * $ec_params{$params}{eY}) + ($count->{W} * $ec_params{$params}{eW}) );
$ans +=  int($count->{C}/2) * $ec_params{$params}{eC} if($all_cystines eq ''t'');

return $ans;

sub count_TyrTrp_residues {
   my $seq = shift;
   my $count;
   for ( qw( Y W C) ){ # Tyrosine and Trptophan AAs
      $count->{$_}++ while $seq =~ /$_/ig;
   }
   return $count;
}	

';
comment on function A280(text,text,boolean) is
	'returns the molar Extinction Coefficient of a protein in ';
grant execute on function A280(text,text,boolean) to public;

create or replace function A280(text) 
returns real language plpgsql as '
DECLARE 
	ans float;
BEGIN 
	select INTO ans A280($1,''emboss'',''f'');
	return ans;
END';

create or replace function A280(text,text) 
returns real language plpgsql as '
DECLARE 
	ans float;
BEGIN 
	select INTO ans A280($1,$2,''f'');
	return ans;
END';
