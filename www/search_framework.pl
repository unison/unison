#!/usr/bin/env perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use IO::Pipe;

my $cmd = '/gne/research/env/prd/opt/unison/bin/framework-search';

my $p = new Unison::WWW::Page();
my $v = $p->Vars();

if ( defined $v->{frameworks} ) {
    print $p->render( "Framework Search Results", results($p) );
}
else {
    print $p->render( "Framework Search", form($p) );
}

exit(0);

sub form {
    my $p = shift;
    return (
        $p->start_form(
            -method => 'GET',
            -action => $p->make_url()
        ),

        'Search title:',
        $p->textfield(
            -name => 'title',
            -size => 40,
        ),

        '<p>Framework regions (one per line, or fasta, or p1 file):',
        '<br>',
        $p->textarea(
            -name    => 'frameworks',
            -columns => 80,
            -rows    => 5,
        ),

        '<br>',
        $p->submit( -value => 'submit' ),
        $p->end_form(),
        "\n",
    );
}

sub results {
    my $p = shift;
    my $v = $p->Vars();
    my ( $fh, $fn, $urn ) = $p->tempfile( SUFFIX => '.html' );
    my @fr =
      map { s/\s+//; $_ } grep { m/^\w/ } split( /\n/m, $v->{frameworks} );

    if ( not @fr ) {
        $p->die("You didn't provide any framework regions");
    }

    my (@args);    # = qw(--testing);
    push( @args, "--title=$v->{title}" ) if defined $v->{title};
    push( @args, @fr );

    my $pipe = new IO::Pipe;
    if ( not $pipe->reader( $cmd, @args ) ) {
        $fh->print($!);
    }
    while ( my $line = <$pipe> ) {
        $fh->print($line);
    }
    $pipe->close();
    $fh->close();

    return
      sprintf(
        <<EOT, $urn, $urn, $p->warn('Your browser does not support iframes') );
<a href="%s">Click here for unframed results</a>
<br>
<iframe width="100%" height="300" src="%s" title="framework search results">%s</iframe>
EOT
}

