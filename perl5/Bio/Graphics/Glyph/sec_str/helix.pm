###############################################
##This script downloaded from:
##http://www.pasteur.fr/recherche/unites/sis/formation/bioperl/ch02s03.html
##on 12/23/04. - mukhyala
###############################################
package Bio::Graphics::Glyph::sec_str::helix;

use strict;
use vars '@ISA';
use Bio::Graphics::Glyph::minmax;
use Bio::Graphics::Glyph::graded_segments;
use Bio::Graphics::Glyph::generic;
use GD;

@ISA = qw (
	   Bio::Graphics::Glyph::minmax
	   Bio::Graphics::Glyph::graded_segments
	   Bio::Graphics::Glyph::generic
	   );

sub draw {
    my $self = shift;
    my @parts = $self->parts;
    my ($min_score,$max_score) = $self->minmax(\@parts);

    return $self->draw_component(@_)
    unless defined($max_score) && defined($min_score)
    && $min_score < $max_score;

    my $span = $max_score - $min_score;

  # allocate colors
    my $fill   = $self->bgcolor;
    my ($red,$green,$blue) = $self->panel->rgb($fill);

    foreach my $part (@parts) {
	my $s = eval { $part->feature->score };
	unless (defined $s) {
	    $part->{partcolor} = $fill;
	    next;
	}
	my ($r,$g,$b) = $self->calculate_color($s,[$red,$green,$blue],$min_score,$span);
	my $idx      = $self->panel->translate_color($r,$g,$b);
	$part->{partcolor} = $idx;
	$self->{partcolor} = $idx;
    }
    $self->draw_component(@_);
}

sub draw_component {

    my $self = shift;
#   $self->SUPER::draw(@_);
    my $gd = shift;

    # and draw a cross through the box
    #my ($x1,$y1,$x2,$y2) = $self->calculate_boundaries(@_);
    my $fg = fgcolor($self);
    my $bg = bgcolor($self);

    my($x1,$y1,$x2,$y2) = $self->bounds(@_);
    
    my $dx = $x2 - $x1;
    my $dy = $y2 - $y1;
    
    my $t = $dy; #$dx / int($dx / $dy);
    
    if ($dx < 2 * $dy) {
	$self->SUPER::draw_component($gd, @_);
    }
    else {
	my $x;
	for ($x=$x1; $x <= $x2; $x += $t ) {
	    my $poly = new GD::Polygon;
	    $poly->addPt($x,$y1);
	    $poly->addPt($x+$t/2,$y1);
	    $poly->addPt($x+$t,$y2);
	    $poly->addPt($x+$t/2,$y2);
	    $gd->polygon($poly, $fg);
	    $gd->fill($x+$t/2, $y1+($y2 - $y1)/2, $bg) if defined $bg;
	    $gd->line($x+$t,$y1,$x+$t,$y2,$fg) if $x+$t <= $x2;
	}
#      my $poly = new GD::Polygon;
#      $poly->addPt($x,$y1);
#      my $xe = ($x2 < $x+$t/2) ? $x2 : $x+$t/2;
#      $poly->addPt($xe,$y1);
#      $poly->addPt($x2,$y1+$x2-$xe);
#      $poly->addPt($x2, $y2);
#      $poly->addPt($xe,$y2);
#      $gd->polygon($poly, $fg);
#      $gd->fill($x+$t/2, $y1+($y2 - $y1)/2, $bg) if defined $bg;
    }
}

# component draws a shaded box
sub bgcolor {
    my $self = shift;
    return defined $self->{partcolor} ? $self->{partcolor} : $self->SUPER::bgcolor;
}
sub fgcolor {
    my $self = shift;
    return $self->SUPER::fgcolor unless $self->option('vary_fg');
    return defined $self->{partcolor} ? $self->{partcolor} : $self->SUPER::fgcolor;
}


1;

__END__
