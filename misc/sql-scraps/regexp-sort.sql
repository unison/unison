create or replace function sort_test_u() returns text
strict immutable language plperlu as '
my @x = qw(c b a);
return join("",sort @x);
';

select sort_test_u();


create or replace function sort_test() returns text
strict immutable language plperl as '
my @x = qw(c b a);
return join("",sort @x);
';

select sort_test_t();
