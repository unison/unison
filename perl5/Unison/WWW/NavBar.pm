
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
use File::Basename qw(basename);

=pod

=head1 ROUTINES AND METHODS

=over

=cut


############################################################################
## This code is among the ugliest, most fragile, and least maintainable
## bits of flotsam I've ever created.  It should be jettisoned, except
## that there's so little glamor in rewriting something that works.  Long
## live inertia!
##
## Progress!  I've moved a lot of the code from Page.pm to NavBar.pm and
## PageInfo.pm.  PageInfo.pm is the sole source of page info.  The code
## below does contortions to translate PageInfo data into the array format 
## used previously.  The overhaul is still in progress.
############################################################################



sub render_navbar {
  my $p = shift;
  my $v = $p->Vars() || {};

  my @navs =  _build_navs($p);
  @navs = __format_tab_labels( @navs );
  @navs =
	__filter_navs( $p->is_prd_instance(), $p->is_public_instance(), @navs );
  my ( $navi, $subnavi ) = _find_nav_ids($p,@navs);
  $navi = -1 unless defined $navi;

  my @nav = @{ $navs[$navi] };
  shift @nav;			  # menu header is first item; subnav items remain

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



######################################################################
## INTERNAL FUNCTIONS

sub _nav_dump {
  eval 'use Data::Dumper;  $Data::Dumper::Indent = 0;';
  my $n = shift;
  my $d = Dumper( \@_ );
  $d =~ s/\],/],\n/g;
  print( STDERR "$n: ", $#_ + 1, " items:\n", $d, "\n" );
}

sub _build_navs {
  # convert PageInfo menu into the old-style array info
  # this function is transitional
  my $p = shift;
  my $v = $p->Vars();

  my @navm;
  foreach my $ps (@Unison::WWW::PageInfo::page_sets) {
	if (not ref $ps and $ps eq 'break') {
	  push(@navm, [['']]);					# special magic in old navbar code
	  next;
	}
	my @snavs;
	my $pub = 0;
	my $prd = 0;
	foreach my $t (@{$ps->[3]}) {
	  $pub++ if $t->{pub};
	  $prd++ if $t->{prd};
	  my $query_args;
	  if (defined $t->{args}) {
		$query_args = join(';', (
								 map { "$_=$v->{$_}" }
								 grep { defined $v->{$_} } 
								 @{$t->{args}} 
								)
						  );
	  }
	  push( @snavs, [
					 $t->{prd}||0,
					 $t->{pub}||0,
					 $t->{name},
					 $t->{brief},
					 $t->{script},
					 $query_args
					] );
	}
	push( @navm, [
				  [ $prd>0||0, $pub>0||0, $ps->[0], $ps->[1], $ps->[2] ],
				  @snavs
				 ]
		);
  }

  return @navm;
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
		   or ( $is_pub and not $navs[$i][0][1] ) ) {
	  splice( @navs, $i, 1 );				# entire major menu is tossed
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

  my $script = basename( $0 );

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
