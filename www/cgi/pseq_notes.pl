#!/usr/bin/env perl

use strict;
use warnings;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::Exceptions;
use Error qw(:try);

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
my $sql;

$p->ensure_required_params(qw(pseq_id));

my $notify='';
if ( defined $v->{action} && $v->{action} eq 'submit' ) {
  $sql = "insert into pnote (pseq_id,note) values ($v->{pseq_id},'$v->{note}')";
  my $sth=$u->prepare($sql);
  $sth->execute();
  if ( defined $u->errstr ) {
    $notify = "<FONT COLOR='red'>Unable to insert pnote: " . $u->errstr . "</FONT><P/>";
  } else {
    $notify = 'Inserted new note!';
  }
}


$v->{sort} = 'added' if ! defined $v->{sort};
my @cols = ( 
  ['User',  'who'    ],
  ['Added', 'added'    ],
  ['Note',  ],
);
my $ob = { who => 'who', added => 'added desc', }->{$v->{sort}};
my @f = map { $_->[0] } @cols;
my %colnum = map {$cols[$_]->[1] => $_} grep {defined $cols[$_]->[1]} 0..$#cols;
$sql = qq/select who,added,note from pnote where pseq_id=$v->{pseq_id} order by $ob/;
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
          $p->make_url({sort=>$cols[$fi]->[1]},qw(pseq_id params_id)),
          $f[$fi]);
}

print $p->render("Notes for Unison:$v->{pseq_id}",
         $p->best_annotation($v->{pseq_id}),
         '<p>',
         $notify,
         $p->group("Notes",
               Unison::WWW::Table::render(\@f,$ar)),
         $p->sql($sql),
         $p->group("Enter New Note",
             "<FORM ACTION=",$p->make_url()," METHOD='POST'>" .
             "<TEXTAREA NAME='note' ROWS='5' COLS='80'></TEXTAREA>" .
             "<INPUT TYPE=HIDDEN NAME='pseq_id' VALUE='$v->{pseq_id}'>" .
             "<INPUT TYPE=SUBMIT NAME='action' VALUE='submit'>" .
             "</FORM>"),
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
