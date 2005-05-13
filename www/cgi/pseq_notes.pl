#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::Exceptions;
use Error qw(:try);

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
my $sql;

$p->ensure_required_params(qw(pseq_id));


if ( defined $v->{action} && $v->{action} eq 'submit' ) {
  $sql = "insert into pnote (pseq_id,note) values (?,?)";
  my $sth = $u->prepare($sql);
  $sth->execute($v->{pseq_id},$v->{note});
  if ( defined $u->errstr ) {
    $p->die('Unable to insert pnote: ',$u->errstr);
  }
}


$v->{sort} = 'added' if ! defined $v->{sort};
my @cols = ( 
  ['User',  'login'    ],
  ['Added', 'added'    ],
  ['Note',  ],
);
my $ob = { login => 'login', added => 'added desc' }->{$v->{sort}};
my @f = map { $_->[0] } @cols;
my %colnum = map {$cols[$_]->[1] => $_} grep {defined $cols[$_]->[1]} 0..$#cols;
$sql = qq/select login,date_trunc('second',added) as "added",note from pnote where pseq_id=$v->{pseq_id} order by $ob/;
my $ar;

try {
  $ar = $u->selectall_arrayref($sql);
} catch Unison::Exception with {
  $p->die('SQL Query Failed',
      $_[0],
      $p->sql($sql));
};


my $hc;
if (exists $colnum{$v->{sort}}) {
  $hc = $colnum{$v->{sort}};
}

for(my $fi=0; $fi<=$#f; $fi++) {
  next if $fi == $hc;
  next unless defined $cols[$fi]->[1];
  $f[$fi] = sprintf("<a href=\"%s\">%s</a>",
          $p->make_url({sort=>$cols[$fi]->[1]},qw(pseq_id)),
          $f[$fi]);
}

print $p->render("Notes for Unison:$v->{pseq_id}",
				 $p->best_annotation($v->{pseq_id}),
				 '<p>',
				 $p->group("Notes",
						   Unison::WWW::Table::render(\@f,$ar,{highlight_column=>$hc})),
				 '<p>',

				 ( $p->{readonly}
				   ? ''
				   : $p->group("Enter New Note",
							   "<FORM ACTION=",$p->make_url()," METHOD='POST'>" .
							   "<TEXTAREA NAME='note' ROWS='5' COLS='60'></TEXTAREA>" .
							   "<INPUT TYPE=HIDDEN NAME='pseq_id' VALUE='$v->{pseq_id}'>" .
							   "<br><INPUT TYPE=SUBMIT NAME='action' VALUE='submit'>" .
							   "</FORM>")
				 ),

				 $p->sql($sql),
				);



#-------------------------------------------------------------------------------
# NAME: heat
# PURPOSE: heat links found in the note
# ARGUMENTS: html string
# RETURN: html string
#-------------------------------------------------------------------------------
sub heat {
  my $html;
}
