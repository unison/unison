
=head1 NAME

Unison::pseq_structure -- sequence-to-structure-related functions for Unison

$ID = q$Id: pseq_structure.pm,v 1.13 2005/12/07 23:21:02 rkh Exp $;

=head1 SYNOPSIS

 use Unison;
 use Unison::pseq_structure;
 my $ps = new Unison::pseq_structure(...);

=head1 DESCRIPTION

=cut

package Unison::Utilities::pseq_structure;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = ();

use Unison::Utilities::pfpsipred;

sub new {
    my ( $class, $pseq_id ) = @_;
    my $self = {};
    bless $self, $class;
    if ( !defined($pseq_id) ) {
        warn "pseq_structure needs a pseq_id to initialize\n";
        return undef;
    }
    else {
        $self->{'pseq_id'} = $pseq_id;
    }

    # store other characteristics of this structral template
    $self->{'num_structures'}   = 0;
    $self->{'num_templates'}    = 0;
    $self->{'loaded_structure'} = undef;
    $self->{'unison'}           = undef;
    $self->{'features'}         = {};
    $self->{'seq_str_map'}      = {};
    $self->{'length'}           = undef;

    return ($self);
}

sub unison {
    my ( $self, $u ) = @_;

    if ( defined $u ) {
        $self->{'unison'} = $u;
    }
    else {
        return $self->{'unison'} || undef;
    }
}

sub jmol {
    my ( $self, $j ) = @_;
    if ( defined $j ) {
        $self->{'jmol'} = $j;
    }
    else {
        return $self->{'jmol'} || undef;
    }
}

sub find_structures {
    my $self = shift;
    my $structures_sql =
"select a.pdbc, a.descr, p.len from alias_pdbcs_v a join pseq p on a.pseq_id=p.pseq_id where a.pseq_id=$self->{'pseq_id'}";
    my $structures_ar = $self->{'unison'}->selectall_arrayref($structures_sql);
    return undef unless defined($structures_ar);
    $self->initialize_structures($structures_ar);
    return $structures_ar;
}

sub find_templates {
    my $self   = shift;
    my $st_sql = <<EOSQL;
SELECT
	DISTINCT ON (pct_coverage,t_pseq_id,substr(template,1,4))
	q_pseq_id, template, q_start, q_stop, t_start, t_stop, gaps, eval, score, pct_ident, len, pct_coverage,method, descr
FROM pseq_template_v
WHERE q_pseq_id = $self->{'pseq_id'}
ORDER BY pct_coverage desc, t_pseq_id, substr(template,1,4)
LIMIT 20
EOSQL
    my $templates_ar = $self->{'unison'}->selectall_arrayref($st_sql);
    return undef unless defined $templates_ar;
    $self->initialize_templates($templates_ar);
    return $templates_ar;
}

sub initialize_structures {
    my ( $self, $ar ) = @_;
    foreach my $r (@$ar) {
        $self->_get_seq_str_map( $r->[0] );
        push @{ $self->{'structure_ids'} }, $r->[0];
        $self->{'num_structures'}++;
        $self->{'structures'}{ $r->[0] }{descr}  = $r->[1];
        $self->{'structures'}{ $r->[0] }{qstart} = 1;
        $self->{'structures'}{ $r->[0] }{qstop}  = $r->[2];
        $self->{'structures'}{ $r->[0] }{tstart} = undef;
    }
}

sub initialize_templates {
    my ( $self, $ar ) = @_;
    foreach my $r (@$ar) {
        $self->_get_seq_str_map( $r->[1] );
        push @{ $self->{'template_ids'} }, $r->[1];
        $self->{'num_templates'}++;
        $self->{'templates'}{ $r->[1] }{descr}  = $r->[13];
        $self->{'templates'}{ $r->[1] }{qstart} = $r->[2];
        $self->{'templates'}{ $r->[1] }{qstop}  = $r->[3];
        $self->{'templates'}{ $r->[1] }{tstart} = $r->[4];
    }
}

sub find_snps {
    my $self = shift;
    my $snp_sql =
"select s.original_aa,s.variant_aa,s.start_pos,s.descr,s.var_id from pseq_sp_var_v s where s.pseq_id="
      . $self->{'pseq_id'};
    my $snp_data = $self->{'unison'}->selectall_arrayref($snp_sql);
    $self->initialize_snps($snp_data);
}

sub initialize_snps {
    my ( $self, $ar ) = @_;
    foreach my $r (@$ar) {
        my $snp = (
            {
                'pseq_id' => $self->{'pseq_id'},
                'wt_aa'   => $r->[0],
                'var_aa'  => $r->[1],
                'start'   => $r->[2],
                'end'     => $r->[5],
                'name'    => $r->[3],
                'ref'     => $r->[4]
            }
        );
        push @{ $self->{'features'}{'snps'} }, $snp;
    }
}

sub load_first_structure {
    my $self = shift;
    $self->{'loaded_structure'} = ${ $self->{'structure_ids'} }[0]
      || ${ $self->{'template_ids'} }[0];
}

sub _get_seq_str_map {
    my ( $self, $pdbCode ) = @_;

    my $pdbc = lc( substr( $pdbCode, 0, 4 ) ) . uc( substr( $pdbCode, 4, 1 ) );

    my $map_sql =
"select seq_pos,res_id, seq_res,atom_res from pdb.residue where pdbc=\'$pdbc\'";

    my $map_ar = $self->{'unison'}->selectall_arrayref($map_sql);

    return undef unless defined($map_ar);
    foreach my $r (@$map_ar) {
        $self->{'seq_str_map'}{$pdbCode}{ $r->[0] }{'res_id'}   = $r->[1];
        $self->{'seq_str_map'}{$pdbCode}{ $r->[0] }{'seq_res'}  = $r->[3];
        $self->{'seq_str_map'}{$pdbCode}{ $r->[0] }{'atom_res'} = $r->[4];
    }
}

#this is used in parsing user features
sub get_hmm_range {
    my ( $self, $hmm ) = @_;
    my $sql =
"select a.start,a.stop from pahmm a join pmodel m on a.pmodel_id=m.pmodel_id where pseq_id=$self->{'pseq_id'} and m.descr ilike \'\%$hmm\%\'";
    my $ar = $self->{'unison'}->selectall_arrayref($sql);
    return $ar->[0];
}

####################################################################################
# related to jmol javascript
sub set_js_vars {
    my ($self) = @_;

    my $retval;
    my $stringio = IO::String->new($retval);

    $stringio->print(
"<form><script LANGUAGE=\"javascript\">var seq_str = new Object; var pdbid;"
    );

    foreach my $pdbid ( @{ $self->{'template_ids'} } ) {

        my $j = 0;
        $stringio->print("pdbid = \'$pdbid\';seq_str[pdbid] = new Object;");

        foreach
          my $i ( $self->{'templates'}{$pdbid}{'qstart'} .. $self->{'templates'}
            {$pdbid}{'qstop'} )
        {
            my $template_pos = $self->{'templates'}{$pdbid}{'tstart'} + $j++;
            next
              if ( !defined( $self->{'seq_str_map'}{$pdbid}{$template_pos} ) );
            my $pdb_res = $self->{'seq_str_map'}{$pdbid}{$template_pos};
            my $res     = $pdb_res->{'res_id'};

            $stringio->print("seq_str[pdbid][$i] = \'$res\';\n")
              if ( defined($res) );
        }

    }

    foreach my $pdbid ( @{ $self->{'structure_ids'} } ) {

        my $j = 0;
        $stringio->print("pdbid = \'$pdbid\';seq_str[pdbid] = new Object;");

        foreach my $i (
            $self->{'structures'}{$pdbid}{'qstart'} .. $self->{'structures'}
            {$pdbid}{'qstop'} )
        {
            my $structure_pos = $j++;
            next
              if ( !defined( $self->{'seq_str_map'}{$pdbid}{$structure_pos} ) );
            my $pdb_res = $self->{'seq_str_map'}{$pdbid}{$structure_pos};
            my $res     = $pdb_res->{'res_id'};

            $stringio->print("seq_str[pdbid][$i] = \'$res\';\n")
              if ( defined($res) );
        }

    }

    $stringio->print(
        "pdbid=\'" . $self->{loaded_structure} . "\';</script></form>" );
    return $retval;
}

sub region_script {
    my ( $self, $start, $end, $label, $color ) = @_;
    my $jmol = $self->{'jmol'};
    return "javascript:" . $jmol->selectRegion( $start, $end, $label, $color );
}

sub pos_script {
    my ( $self, $pos, $label, $color ) = @_;
    my $jmol = $self->{'jmol'};
    return "javascript:" . $jmol->selectPosition( $pos, $label, $color );
}

sub change_structure {
    my ( $self, $name ) = @_;
    my ( $pdb_id, $chain ) = ( substr( $name, 0, 4 ), substr( $name, 4, 1 ) );
    my $jmol = $self->{'jmol'};
    return "javascript:"
      . $jmol->changeStructureLoad( $jmol->load( "pdb$pdb_id.ent", $chain ),
        $name );
}

1;

