create or replace function unison._clean_regexp(text) returns text
strict immutable language plperlu as '
$_ = shift;

my $NOT_RT_BRACKET = qr([^\\]]);

# flatten nested [] e.g., [A[BC]D[EF]FG] -> ABCDEFFG
while (s/\\[($NOT_RT_BRACKET*)\\[($NOT_RT_BRACKET*)\\]/[\\1\\2/) {
  die("complement operator (''^'') is not allowed inside nested regexps\n") if $2 =~ m/\\^/;
};

# eliminate redundancies in [] sets e.g., A[BBC]D -> A[BC]D
# postgresql 7.x requires plperlu, 8.x may use plperl
# WARNING: - is intepreted literally, i.e., ranges aren''t supported
s&
  \\[($NOT_RT_BRACKET+)\\]
&
  my %aa = map {$_=>1} split(//,$1);
  my @aa = sort keys %aa;
  my $comp = 0;
  if ($aa[$#aa] eq ''^'') { $comp++; pop(@aa); }  # pop ''^''
  ''['' . ($comp?''^'':'''') . join("",@aa) . '']'';
&egx;

return $_;
';
comment on function _clean_regexp(text) is
	'reformat regular expression';
grant execute on function _clean_regexp(text) to public;

