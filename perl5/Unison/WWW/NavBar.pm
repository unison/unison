
=head1 NAME

Unison::WWW::NavBar -- render Unison's navigation menu

S<$Id$>

=head1 SYNOPSIS

 use Unison::template;
 #do something, you fool!

=head1 DESCRIPTION

B<Unison::template> is template for building new perl modules.

=cut

package Unison::WWW::NavBar;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use Unison::WWW::PageInfo;


=pod

=head1 ROUTINES AND METHODS

=over

=cut


######################################################################
## render

=pod

=item B<< $p->render( C<linkrefs>, C<index> ) >>

renders a NavBar, which is provided as an array reference to array
references, i.e., [ [name1,url1], [name2,url2], ... ].  C<index> is the
integer index of the link which should be highlighted.

=cut

#sub render_navbar2 {
#    ###
#    my @lr      = shift;                            # link ref [[name,url],...]
#    my $hilight = shift;                            # which to highlight
#    my $rv      = "<table class=\"navbar\"><tr>";
#    for ( my $i = 0 ; $i <= $#$lr ; $i++ ) {
#        my $c = $rv .= sprintf(
#            '<td%s><a href="%s">%s</a></td>',
#            ( $i == $hilight - 1 ) ? ' class="hi"' : '',
#            @{ $lr->[$i] }[ 1, 0 ]
#        );
#    }
#    $rv .= '</tr></table>';
#    return $rv;
#}


######################################################################
## NAVBAR CODE
## This navbar code is among the ugliest, most fragile, and least
## maintainable bits of flotsam I've ever created.  It should be
## jettisoned, except that there's so little glamor in rewriting something
## that works.  Long live inertia!

sub _nav_dump {
    eval 'use Data::Dumper;  $Data::Dumper::Indent = 0;';
    my $n = shift;
    my $d = Dumper( \@_ );
    $d =~ s/\],/],\n/g;
    print( STDERR "$n: ", $#_ + 1, " items:\n", $d, "\n" );
}

sub render_navbar {
    my $p 	    = shift;
    my $v       = $p->Vars() || {};
    my $pseq_id = exists $v->{pseq_id} ? "pseq_id=$v->{pseq_id}" : '';
    my @navs =
      ## format: @navs = ( menu, menu, ... );
      ## where each menu is
      ## [
      ##   [ prd, pub, major_name, tooltip ],
      ##   [ prd, pub, minor_name, tooltip, script, args ],
      ##   [ prd, pub, minor_name, tooltip, script, args ],
      ##   ...
      ## ]
      ## prd = production? 1=yes, 0=no (i.e., show ONLY in production)
      ## pub = public? 1=yes, 0=no (i.e., show ONLY in public version)
      (
	   ## Search menu
	   [
		[
		 1, 1, 'Search', 'Text- and Feature-based mining',
		 'search_top.pl'
		],
		[
		 1, 1, 'By Alias',
		 'search for sequences by alias/name/accession',
		 'search_alias.pl'
		],
		[
		 1, 1,
		 'By Properties',
		 'mine for sequences based on properties',
		 'search_properties.pl'
		],
	   ],


	   ## Browse menu
	   [
		[
		 1, 1, 'Browse',
		 'browse curated queries and precomputed sequences sets',
		 'browse_top.pl'
		],
		[
		 1, 1, 'Views', 'browse dynamic queries of protein sequences',
		 'browse_views.pl'
		],
		[
		 1, 1, 'Sets', 'browse precomputed sets of proteins',
		 'browse_sets.pl'
		],
	   ],


	   ## Analyze menu
	   [
		[
		 1, 1, 'Analyze',
		 'display precomputed analyses for a single protein sequence',
		 'pseq_top.pl'
		],
		[
		 1, 1, 'Summary', 'summary of sequence information',
		 'pseq_summary.pl', $pseq_id
		],
		[
		 1, 1, 'Aliases', 'all aliases of this sequence',
		 'pseq_paliases.pl', $pseq_id
		],
		[
		 1, 0, 'Patents', 'patents on this sequence',
		 'pseq_patents.pl', $pseq_id
		],
		[
		 1, 1, 'Homologs', 'orthologs and paralogs of this sequence',
		 'pseq_homologs.pl', $pseq_id
		],
		[
		 1, 1, 'Functions', 'Protein Functions and References ',
		 'pseq_functions.pl', $pseq_id
		],
		[
		 1, 1, 'Features', 'sequences features',
		 'pseq_features.pl', $pseq_id
		],
		[
		 1, 1, 'Structure', 'structural features',
		 'pseq_structure.pl', $pseq_id
		],
		[
		 0, 1, 'BLAST', 'BLAST-related sequences',
		 'pseq_blast.pl', $pseq_id
		],
		[
		 0, 0, 'Prospect', 'Prospect threadings',
		 'pseq_paprospect.pl', $pseq_id
		],
		[
		 1, 1, 'HMM', 'Hidden Markov Model alignments',
		 'pseq_pahmm.pl', $pseq_id
		],
		[ 0, 1, 'PSSM', 'PSSM alignments', 'pseq_papssm.pl', $pseq_id ],
		[
		 0, 1, 'Interactions', 'Protein-Protein Interactions',
		 'pseq_intx.pl', $pseq_id
		],
		[ 1, 1, 'Loci', 'genomic localization', 'pseq_loci.pl', $pseq_id ],
		[
		 0, 0, 'Notes', 'user notes on this sequence',
		 'pseq_notes.pl', $pseq_id
		],
		[ 1, 1, 'History', 'run history', 'pseq_history.pl', $pseq_id ],
	   ],


	   ## Tools menu
	   [									#
		[
		 1, 1, 'Tools', 'Miscellaneous services', 'tools_top.pl'
		],
		[
		 1, 1, 'AliAn', 'Annotation of aliases',
		 'alias_annotation.pl'
		],
		[
		 1, 0, 'OnTarget',
		 'compare a set of sequences to a set of models ',
		 'on_target.pl'
		],
		[
		 1, 0, 'Framework',
		 'search for sequences matching a set of sequence regions',
		 'search_framework.pl'
		],
		[ 0, 0, 'Scores', 'compare scoring systems',
		  'compare_scores.pl' ],
		[
		 0, 0, 'Methods', 'compare threading methods',
		 'compare_methods.pl'
		]	   ],


	   # empty list forces right-justification of subsequent menus
	   [ [''] ],

	   [									# About menu
		[
		 # consider '<img width="10px" height="10px" src="../av/favicon.gif" alt="u">'
		 1, 1, 'About', ('Click for more information about Unison.'
						 . sprintf("<br>host=%s; db=%s; user=%s",
								   $v->{host}, $v->{dbname}, $v->{username})),
		 'about_unison.pl'
		],
		[ 1, 1, 'About Unison', 'Unison overview', 'about_unison.pl' ],
		[
		 1, 1, 'Statistics', 'Unison summary statistics',
		 'about_statistics.pl'
		],
		[ 1, 1, 'Origins', 'Unison data sources', 'about_origins.pl' ],
		[
		 1, 1, 'Params', 'Unison precomputed data types',
		 'about_params.pl'
		],
		[ 0, 1, 'Env',   'environment info', 'about_env.pl' ],
		[ 0, 1, 'Prefs', 'user prefs',       'about_prefs.pl' ],
	   ],
      );

    @navs = __format_tab_labels(@navs);
    @navs =
      __filter_navs( $p->is_prd_instance(), $p->is_public_instance(), @navs );
    my ( $navi, $subnavi ) = _find_nav_ids($p,@navs);
    $navi = -1 unless defined $navi;

    my @nav = @{ $navs[$navi] };
    shift @nav;    # menu header is first item; subnav items remain

    return(
		"<div class=\"nav\">\n"
      . "  <table class=\"navp\">\n"
      . _make_navrow( $navi, map { $_->[0] } @navs )
	  . "  </table>\n"
	  . "  <table class=\"navc\">\n" 
	  . _make_navrow( $subnavi, @nav )
	  . "  </table>\n"
	  . "</div>\n"
	)
}

sub __format_tab_labels(@) {
    my @navs = @_;
    for ( my $i = 0 ; $i <= $#navs ; $i++ ) {
        for ( my $j = 0 ; $j <= $#{ $navs[$i] } ; $j++ ) {
            my @tooltip_tags = ();
            if ( not $navs[$i]->[$j]->[1] ) {
                $navs[$i]->[$j]->[2] = "<i>$navs[$i]->[$j]->[2]</i>"
                  if defined $navs[$i]->[$j]->[2];
                push( @tooltip_tags, 'public' );
            }
            if ( not $navs[$i]->[$j]->[0] ) {
                $navs[$i]->[$j]->[2] = "<u>$navs[$i]->[$j]->[2]</u>"
                  if defined $navs[$i]->[$j]->[2];
                push( @tooltip_tags, 'production' );
            }
            if (@tooltip_tags) {
                $navs[$i]->[$j]->[3] = '' unless $navs[$i]->[$j]->[3];
                $navs[$i]->[$j]->[3] .=
                  ( '<hr>NOTE: This tab contains data that will not appear in '
                      . join( ' or ', @tooltip_tags )
                      . ' versions of Unison.' );
            }
        }
    }
    return @navs;
}

sub __filter_navs($$@) {
    ## Purpose: remove development tabs from production environments, and remove
    ## proprietary tabs from public environments.  The result is a modified navbar
    ## array WITHOUT the prd and pub bits (array elems 0 and 1).

    my ( $is_prd, $is_pub, @navs ) = @_;
    for ( my $i = $#navs ; $i >= 0 ; $i-- ) {
        if ( $navs[$i][0][0] eq '' ) {

            # menu break
            next;
        }

        if (   ( $is_prd and not $navs[$i][0][0] )
            or ( $is_pub and not $navs[$i][0][1] ) )
        {
            splice( @navs, $i, 1 );    # entire major menu is tossed
            next;
        }

        # else...
        @{ $navs[$i] } =
          grep { ( ( not $is_prd or $_->[0] ) and ( not $is_pub or $_->[1] ) ) }
          @{ $navs[$i] };
        @{ $navs[$i] } = map { [ splice( @$_, 2 ) ] } @{ $navs[$i] };
    }

    #_nav_dump("is_prd=$is_prd; is_pub=$is_pub; returned=",@navs);
    return @navs;
}

sub _find_nav_ids {
  # identify indexes in  major and minor @nav entries for
  # the current page
  my $p   = shift;
  my @navs   = @_;

  my $script = $p->url( -relative => 1 );
  return unless defined $script;	   # e.g., when command line debugging
  $script =~ s/\?$//;

  for ( my $i = 0 ; $i <= $#navs ; $i++ ) {
	my @nav = @{ $navs[$i] };

	# search subnav first
	for ( my $j = 1 ; $j <= $#nav ; $j++ ) {
	  if ( defined $nav[$j]->[2] and $nav[$j]->[2] eq $script ) {
		return ( $i, $j-1 )					# $nav[0] is heading => -1
	  }
	}

	# if no subnav match, try nav heading
	if (defined $nav[0]->[2] and $nav[0]->[2] eq $script) {
	  return ( $i, undef );
	}
  }

  return;
}

sub _make_navrow {
    # A navrow is a tr, with 2 tds, each with 1 ul, each of which has >=0
    # li entities. 
    # $sel is which is selected, and may be undef
    # @tu = array ref of [tab_label,tooltip,url,params]
    my ( $sel, @tu ) = @_;
    my $nav = "    <tr>\n      <td><ul>\n";
	my $close_open = "      </ul></td>\n      <td class=\"right\"><ul>\n";

    for ( my $i = 0 ; $i <= $#tu ; $i++ ) {
        my ( $tab_label, $tooltip, $url, $params ) = @{ $tu[$i] };
		
        if ( $tab_label eq '' ) {
            $nav .= $close_open;
			$close_open = '';
            next;
        }

        $url .= "?$params" if defined $params;
        my $cl = '';
        if ( defined $sel and $sel == $i ) {
            $cl  = ' class="selected"';
            $url = undef;
        }

		my $tt = ( (defined $tooltip and $tooltip =~ m/\w/)
				   ? sprintf('tooltip="%s"',CGI::escapeHTML($tooltip))
				   : '' );
		$nav .= 
			"\t<li$cl>"
			. (defined $url 
			   ? "<a $tt href=\"$url\">$tab_label</a>" 
			   : "<span $tt>$tab_label</span>")
			. "</li>\n"
    }

    $nav .= $close_open;
    $nav .= "      </ul></td>\n    </tr>\n";

    return $nav;
}



=pod

=back

=head1 BUGS

Please report bugs to Reece Hart E<lt>hart.reece@gene.comE<gt>.

=head1 SEE ALSO

=over 4

=item * perldoc Unison

=back

=head1 AUTHOR

see C<perldoc Unison> for contact information

=cut

1;
