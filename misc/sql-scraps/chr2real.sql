-- convert strings like `chr5[343201:...' to a real number like 5.343201.
-- this permits easy chromosomal position selection and sorting

create or replace function chr2real (text) returns real
language plperl as '
$_[0] =~ s/chrX/chr90/; $_[0] =~ s/chrY/chr91/; $_[0] =~ s/chrM/chr92/;
return "$1.$2" if ($_[0] =~ m/^chr(\\d+)\\[(\\d+)/);
return "$1"    if ($_[0] =~ m/^chr(\\d+)_random/);
return undef;
';


