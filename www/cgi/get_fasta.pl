#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../../perl5";

use Unison;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::Exceptions;
use Unison::Utilities::misc qw(wrap);


my $p = new Unison::WWW::Page();
my $u = $p->{unison};
my $v = $p->Vars();
$p->ensure_required_params( qw( pseq_id ) );

my $seq;
my $alias;

try {
  $seq = $u->get_sequence_by_pseq_id($v->{pseq_id});
  $alias = $u->best_annotation($v->{pseq_id})
} catch Unison::Exception with {
  $p->die(@_);
};

print("Content-type: text/plain\n",
	  "Content-disposition: attachment; filename=Unison$v->{pseq_id}.fa\n",
	  "\n",
	  ">Unison:$v->{pseq_id} $alias\n",
	  wrap($seq)
	 );
