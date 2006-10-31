--#$Id: pI.sql,v 1.1 2006/08/16 16:19:24 mukhyala Exp $
-- Adaptation of Mark Southern's pICalculator.pm in Bioperl
-- see Bio/Tools/pICalculator.pm
-- http://fields.scripps.edu/DTASelect/20010710-pI-Algorithm.pdf
-- http://www.hgmp.mrc.ac.uk/Software/EMBOSS/Apps/iep.html
-- http://us.expasy.org/tools/pi_tool.html

create or replace function pI(text,text)
returns real strict immutable language plperl as '
# pK values from the DTASelect program from Scripps
# http://fields.scripps.edu/DTASelect
my %pK_params;
$pK_params{dtaselect} = {  
		      N_term   =>  8.0,
                      K        => 10.0, # Lys
                      R        => 12.0, # Arg
                      H        =>  6.5, # His
                      D        =>  4.4, # Asp
                      E        =>  4.4, # Glu
                      C        =>  8.5, # Cys
                      Y        => 10.0, # Tyr
                      C_term   =>  3.1
                    };

# pK values from the iep program from EMBOSS
# http://www.hgmp.mrc.ac.uk/Software/EMBOSS/
$pK_params{emboss}  = { 
		   N_term   =>  8.6,
                   K        => 10.8, # Lys
                   R        => 12.5, # Arg
                   H        =>  6.5, # His
                   D        =>  3.9, # Asp
                   E        =>  4.1, # Glu
                   C        =>  8.5, # Cys
                   Y        => 10.1, # Tyr
                   C_term   =>  3.6
                 };
my $seq = shift;
elog(ERROR, "sequence length <= 0") if(length($seq) <= 0);

my $params = shift;
elog(ERROR, "pK params $params does not exist options are ''emboss'' and ''dtaselect''\n") if(not defined $pK_params{$params});
my $pKset = $pK_params{$params};

my $places = 2; #decimal places
my $count = _count_charged_residues( $seq );

return _calculate_iep($pKset,$places,$seq,$count);	

sub _calculate_iep {
    my( $pK, $places, $seq, $count ) = @_;
    my $pH = 7.0;
    my $step = 3.5;
    my $last_charge = 0.0;
    my $format = "%.${places}f";
    my $count = _count_charged_residues($seq);

    while(1){
       my $charge = _calculate_charge_at_pH( $pH, $pK, $count );
       last if sprintf($format,$charge) == 
	 sprintf($format,$last_charge);
       $charge > 0 ? ( $pH += $step ) : ( $pH -= $step );
       $step /= 2.0;
       $last_charge = $charge;
    }
    return sprintf( $format, $pH );
}

sub _count_charged_residues {
   my $seq = shift;
   my $count;
   for ( qw( K R H D E C Y ) ){ # charged AAs
      $count->{$_}++ while $seq =~ /$_/ig;
   }
   return $count;
}

# its the sum of all the partial charges for the
# termini and all of the charged aa s!
sub _calculate_charge_at_pH {

   my( $pH, $pK, $count ) = @_;
   my $charge =    _partial_charge( $pK->{N_term}, $pH )
   + $count->{K} * _partial_charge( $pK->{K},      $pH )
   + $count->{R} * _partial_charge( $pK->{R},      $pH )
   + $count->{H} * _partial_charge( $pK->{H},      $pH )
   - $count->{D} * _partial_charge( $pH,      $pK->{D} )
   - $count->{E} * _partial_charge( $pH,      $pK->{E} )
   - $count->{C} * _partial_charge( $pH,      $pK->{C} )
   - $count->{Y} * _partial_charge( $pH,      $pK->{Y} )
   -               _partial_charge( $pH, $pK->{C_term} );
   return $charge;
}

# Concentration Ratio is 10**(pK - pH) for positive groups
# and 10**(pH - pK) for negative groups
sub _partial_charge {
   my $cr = 10 ** ( $_[0] - $_[1] );
   return $cr / ( $cr + 1 );
}

';
comment on function pI(text,text) is
	'returns the theoretical isoelectric point of a protein, try pI(seq,''emboss'')';
grant execute on function pI(text,text) to public;

create or replace function pI(text) 
returns real language plpgsql as '
DECLARE 
	ans float;
BEGIN 
	select INTO ans pI($1,''emboss'');
	return ans;
END';
