# U:W:Table -- spit an HTML Table from an array ref of
package Unison::WWW::Table;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;
use base 'CBT::Hash';
use Unison::WWW::utilities qw(coalesce);

# title
# caption
# cols = @<cols>
# row_fmt (_fx?) [ <tr> %s </tr> ]
# row_alt_color [rgb1,rgb2]
# class
# col_url
#
# col:=
# heading
# url
# tooltip
# cell_format => &(data), %s
# justification
# width
# cell_preprocess

#http://www.cssplay.co.uk/menu/tablescroll.html

sub render {
    return render_compat(@_) unless ( ref $_[0] eq __PACKAGE__ );

    die("code barricade -- code path shouldn't be here");

    # BELOW THIS POINT IS EXPERIMENTAL
    my $self = shift;
    my $fr   = shift;
    my $rv   = '';
    $rv .= '<div style="overflow: auto;"><table class=\"uwtable\">';
    $rv .=
        "<thead><tr>"
      . join( '', map { '<th align="left">' . $_ . '</th>' } @$fr )
      . "</tr></thead>\n";
    foreach ( my $i ; $i <= $#_ ; $i++ ) {
    }
    $rv .= "</table></div>\n";
    return ($rv);
}

sub render_headings {
    my $self = shift;
    return
      join( '', '<tr>', map { __render_th($_) } @{ $self->{columns} },
        '</tr>' );
}

sub render_th {
    return '<th>';
}

sub render_compat {

    # this code is among the worst I've written. I'm sorry.

    my $fr   = shift;
    my $ar   = shift;
    my $opts = shift;

    my $tbl_start = '<table class="uwtable">';
    my $tbl_end   = '</table>';

    my $rv = $tbl_start;

    if ( $#$ar == -1 ) {
        $rv .=
          sprintf( "<tr><td colspan=\"%d\">query returned no data</td></tr>\n",
            $#$fr + 1 );
        $rv .= $tbl_end;
        return $rv;
    }

    if ( not defined $opts->{highlight_column} ) {
        $rv =
"<DIV STYLE=\"height: 100px;\">"
          . $tbl_start
          if ( $opts->{scroll} );
        $rv .= "\n<thead>\n  <tr>\n"
          . join( '',
            map { '    <th>' . $_ . '</th>' . "\n" } @$fr )
          . "  </tr>\n</thead>\n";
        $rv .= '<tbody>' . "\n";
        $rv .= "  <tr>\n" . join(
            '',
            map {
                '    <td align="'
                  . guess_alignment($_) . '">'
                  . coalesce( $_, '' ) . '</td>' . "\n"
              } @$_
          )
          . "  </tr>\n"
          for @$ar;
        $rv .= "</tbody>\n";
        $rv .= $tbl_end;
        $rv .= "</div>" if ( $opts->{scroll} );
        return $rv;
    }

    # remainder is for the special case of column highlighting
    $rv .= '<tr>' . join(
        '',
        map {
            '<th'
              . (
                $_ == $opts->{highlight_column} ? ' class="highlighted"' : '' )
              . '>'
              . $fr->[$_] . '</th>'
          } 0 .. $#$fr
    ) . "</tr>\n";
    for ( my $r = 0 ; $r <= $#$ar ; $r++ ) {
        $rv .= "<tr>";
        my @row = @{ $ar->[$r] };
        for ( my $c = 0 ; $c <= $#row ; $c++ ) {
            my $cl =
              $c == $opts->{highlight_column} ? 'class="highlighted"' : '';
            my $al = 'align="' . guess_alignment( $row[$c] ) . '"';
            $rv .= "<td $cl $al>" . coalesce( $row[$c], '' ) . "</td>";
        }
        $rv .= "</tr>\n";
    }

    $rv .= $tbl_end;
    return $rv;
}

sub guess_alignment {
    my $s = shift;
    return ( defined $s and $s =~ m/^[-.e\d]+$/ ) ? 'right' : 'left';
}

1;
