
=head1 NAME

Unison::WWW::Page -- Unison web page framework

S<$Id$

=head1 SYNOPSIS

 use Unison::WWW::EmbPage;
 my $p = new Unison::WWW::EmbPage;

=head1 DESCRIPTION

B<Unison::WWW::EmbPage> provides a class for consistent rendering of Unison
web pages without Unison's header tabs. It's simple and not powerful.

=cut

package Unison::WWW::EmbPage;

use base Unison::WWW::Page;

######################################################################
## render()

=pod

=item B<< $p->render( C<title>, C<body elems, ...> ) >>

Generates a Unison web page intended to be embedded in an iframe or object
block element.

=cut

sub render {
    my $self  = shift;
    my $title = shift;

    return (
        $self->header(),
        $self->start_html( -title => "Unison: $title" ),
        '<table width="100%">', "\n",
        '<tr>',                 "\n",
        "\n<!-- ========== begin page content ========== -->\n",
        '  <td class="body">', "\n",
        "  <b>$title</b><br>", "\n",
        '  ',      @_, "\n",
        '  </td>', "\n",
        "\n<!-- ========== end page content ========== -->\n",
        '</tr>',    "\n",
        '</table>', "\n",
        $self->end_html(),
        "\n"
    );
}

1;
