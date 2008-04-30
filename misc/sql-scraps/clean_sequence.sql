-- plperl can now handle s/// (it used to require plperlu)
-- let's move clean_sequence to plperl to facilitate installation


create or replace function clean_sequence(text)
returns text
strict immutable
language plperl
as $_$
  my $x = shift;
  $x =~ s/[^-\*ABCDEFGHIKLMNPQRSTUVWXYZ]//g;
  $x =~ s/\*+$//;
  return $x;
$_$;
