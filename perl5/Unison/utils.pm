package Unison::utils;
use base Exporter;
@EXPORT = ();
@EXPORT_OK = qw( range_to_enum );



# convert an array of ranges to enumerated values
# e.g., range_to_enum(qw(1 2 3..5)) returns (1,2,3,4,5)
sub range_to_enum(@) {
  my $rl = join(',',@_);
  eval "$rl";
}




;
