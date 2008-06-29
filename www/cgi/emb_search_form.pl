#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../../perl5", "$FindBin::RealBin/../../perl5-ext";

use CGI( -debug );
use CGI::Carp qw(fatalsToBrowser);

use Unison::WWW;
use Unison::WWW::EmbPage;
use Unison::WWW::Table;
use Unison::SQL;

my $p = new Unison::WWW::EmbPage;
my $u = $p->{unison};
my $v = $p->Vars();

my $js = <<EOJS;
<script type="text/javascript" language="javascript">
function get_value(field){
  if(field.type == "text" || field.type == "select-one")
    return field.value;
  else
    for(i=0;i<field.length;i++)
      if(field[i].checked)
        return field[i].value;
}
function check_psipred_q(value){
    if(value.length == 0 ) {
	alert('empty search query');
	return
    }
    var re = new RegExp("^([HEC\?])\>([0-9]+)\-([0-9]+)\$");
    var sse = value.split(",");
    var ctr=0;
    for (i=0;i<sse.length;i++) {
	var arr = re.exec(sse[i]);
	if( parseInt(arr[2]) > parseInt(arr[3])) {
	    alert('max should be greater then min ' + arr[2]+ ' >  ' + arr[3]);
	    return;
	}
	if(re.test(sse[i]))
	    ctr++;
    }
    if(ctr==sse.length)
	alert('syntax is valid');
    else 
	alert('invalid syntax');
}
</script>
EOJS

if ( not defined $v->{feature} ) {
    print $p->render();
    exit(0);
}
elsif ( $v->{feature} !~ /results/ and $v->{feature} !~ /sql/ ) {
    print $p->render( $js, _feature_form($p) );
    exit(0);
}

## build SQL statement
my $s_sql = Unison::SQL->new()->table('pseq P')->columns('distinct P.pseq_id');
my %feats;
map {
    my $t = 0;
    my @a = split( /\=/, $_ );
    $t = grep { /$a[0]/ } keys %feats;
    $a[0] .= $t++;
    $feats{ $a[0] } = $a[1]
} ( split( /\:/, $v->{global_q} ) );

foreach my $f ( sort keys %feats ) {

    if ( $f =~ /^alias_sel/ ) {
        $s_sql->join('palias A on P.pseq_id=A.pseq_id')
          ->where("A.alias=\'$feats{$f}\'");
    }
    elsif ( $f =~ /^protcomp_sel/ ) {
        $s_sql->join('psprotcomp_reliable_v CL on P.pseq_id=CL.pseq_id')
          ->where("CL.psloc_id=$feats{$f}");
    }
    elsif ( $f =~ /^pepcoil_prob/ ) {
        $s_sql->join('pfpepcoil CC on P.pseq_id=CC.pseq_id')
          ->where("CC.prob >= ($feats{$f}/100)");
    }
    elsif ( $f =~ /^bigpi/ ) {
        $s_sql->join('pfbigpi B on P.pseq_id=B.pseq_id')
          ->where("B.score > $feats{$f}");
    }
    elsif ( $f =~ /^seg/ ) {
        $s_sql->join('pfseg S on P.pseq_id=S.pseq_id')
          if ( $feats{$f} eq 'yes' );
    }
    elsif ( $f =~ /^pfam_sel/ ) {
        my $t = grep { /pahmm/ } @{ $s_sql->{tables} };
        my $w = "pfam_eval$t";
        $s_sql->join("pahmm P$t on P.pseq_id=P$t.pseq_id")
          ->where("P$t.pmodel_id=$feats{$f}")->where("P$t.eval<=$feats{$w}");
    }
    elsif ( $f =~ /^regexp_sel/ ) {
        my $t = grep { /pfregexp/ } @{ $s_sql->{tables} };
        $s_sql->join("pfregexp R$t on P.pseq_id=R$t.pseq_id")
          ->where("R$t.pmodel_id=$feats{$f}");
    }
    elsif ( $f =~ /^tax_sel/ ) {
        $s_sql->join("palias A on A.pseq_id=P.pseq_id")
          ->where("A.tax_id=$feats{$f}");
    }
    elsif ( $f =~ /^signalp/ ) {
        $s_sql->join('pfsignalpnn SP on P.pseq_id=SP.pseq_id')
          ->where('signal_peptide is true')
          if ( $feats{$f} eq 'yes' );
    }
    elsif ( $f =~ /^tmhmm/ ) {
        $s_sql->join('pftmhmm_tms_v tm on P.pseq_id=tm.pseq_id')
          if ( $feats{$f} eq 'yes' );
    }
    elsif ( $f =~ /^pdb/ ) {
        $s_sql->join('papseq_pdbcs_v bp on P.pseq_id=bp.q_pseq_id')
          if ( $feats{$f} eq 'yes' );
    }
    elsif ( $f =~ /^len_m/ ) {
        $s_sql->where("P.len >= $feats{$f}")
          if ( $f =~ /^len_min/ and defined $feats{$f} );
        $s_sql->where("P.len <= $feats{$f}")
          if ( $f =~ /^len_max/ and defined $feats{$f} );
    }
    elsif ( $f =~ /^wt_/ or $f =~ /^a280_/ or $f =~ /pI_/ ) {
        $s_sql->join("pseq_prop_v pp on P.pseq_id=pp.pseq_id")
          if defined $feats{$f}
              and not grep { /pseq_prop_v/ } @{ $s_sql->{tables} };
        $s_sql->where("pp.mol_wt >= $feats{$f}*1000")
          if ( $f =~ /^wt_min/ and defined $feats{$f} );
        $s_sql->where("pp.mol_wt <= $feats{$f}*1000")
          if ( $f =~ /^wt_max/ and defined $feats{$f} );
        $s_sql->where("pp.a280 >= $feats{$f}")
          if ( $f =~ /^a280_min/ and defined $feats{$f} );
        $s_sql->where("pp.a280 <= $feats{$f}")
          if ( $f =~ /^a280_max/ and defined $feats{$f} );
        $s_sql->where("pp.pi >= $feats{$f}")
          if ( $f =~ /^pI_min/ and defined $feats{$f} );
        $s_sql->where("pp.pi <= $feats{$f}")
          if ( $f =~ /^pI_max/ and defined $feats{$f} );
    }
    elsif ( $f =~ /^psipred/ ) {
        my $sse = 0;
        foreach ( split( /\,/, $feats{$f} ) ) {
            $sse++;
            if (/^([HEC\?])>(\d+)\-(\d+)$/) {
                $s_sql->join("pfpsipred psi$sse on P.pseq_id=psi$sse.pseq_id");
                if ( $2 == $3 ) {
                    $s_sql->where("psi$sse.stop-psi$sse.start = $2");
                }
                else {
                    $s_sql->where(
"psi$sse.stop-psi$sse.start >= $2 and psi$sse.stop-psi$sse.start <= $3"
                    );
                }
                $s_sql->where("psi$sse.type = '$1'") if ( $1 ne '?' );
                if ( $sse > 1 ) {
                    my $prev = $sse - 1;
                    $s_sql->where("psi$sse.start > psi$prev.stop");
                }
            }
        }
    }
    elsif ( $f =~ /^pmap/ ) {
        $s_sql->join(
"pmap_v pm on P.pseq_id=pm.pseq_id and pm.genasm_id=$feats{pmap_genasm_id0}"
          )
          if defined $feats{$f} and not grep { /pmap_v/ } @{ $s_sql->{tables} };
        $s_sql->where("pm.exons >= $feats{$f}")
          if ( $f =~ /^pmap_min_e/ and defined $feats{$f} );
        $s_sql->where("pm.exons <= $feats{$f}")
          if ( $f =~ /^pmap_max_e/ and defined $feats{$f} );
        $s_sql->where("pm.chr    = $feats{$f}")
          if (  $f =~ /^pmap_chr/
            and defined $feats{$f}
            and $feats{$f} !~ /select/ );
        $s_sql->where("pm.gstart>= $feats{$f}")
          if ( $f =~ /^pmap_gstart/ and defined $feats{$f} );
        $s_sql->where("pm.gstop <= $feats{$f}")
          if ( $f =~ /^pmap_gstop/ and defined $feats{$f} );
    }
    elsif ( $f =~ /^cytoband/
        and defined $feats{$f}
        and $feats{$f} !~ /select/ )
    {
        $s_sql->join("pseq_cytoband_v pc on P.pseq_id=pc.pseq_id")
          ->where("pm.chr||pm.stain = $feats{$f}");
    }
}

my $sql = "$s_sql";
$sql = "select X1.pseq_id,best_annotation(X1.pseq_id) from ($sql) X1";

my @results =
  ("<p>(SQL only requested -- go back and hit submit for results)\n");

if ( $v->{feature} eq 'results' ) {
    my @fields = ( 'pseq_id', 'origin:alias (description)' );
    my $ar;
    $ar = $u->selectall_arrayref($sql);
    for ( my $i = 0 ; $i <= $#$ar ; $i++ ) {
        $ar->[$i][0] = sprintf( '<a href="pseq_summary.pl?pseq_id=%d">%d</a>',
            $ar->[$i][0], $ar->[$i][0] );
    }
    @results = $p->group(
        sprintf( "%d results", $#$ar + 1 ),
        Unison::WWW::Table::render( \@fields, $ar )
    );
}
print $p->render( "Feature Based Mining Results", @results, $p->sql($sql) );

exit(0);

############################################################################################################
sub _feature_form {
    my $p = shift;
    my $u = $p->{unison};
    my $v = $p->Vars();

    my $ret;

    if ( $v->{feature} eq 'alias' ) {
        $ret = 'Accession:';
        $ret .= join(
            '', '<p>',
            $p->start_form( -method => 'GET' ),
            $p->textfield(
                -name     => 'alias_sel',
                -size     => 40,
                -override => 1,
            ),
            _form_buttons( 'alias', ('alias_sel') ),
            $p->end_form(),
        );
    }
    elsif ( $v->{feature} eq 'protcomp' ) {

        my %protcomp = map { $_->[1] => "$_->[0]" } @{
            $u->selectall_arrayref(
                'select location,psloc_id from psprotcomp_location')
          };

        $ret = 'Choose from the following cellular locations:';
        $ret .= join(
            '', '<p>',
            $p->start_form( -method => 'GET' ),
            $p->popup_menu(
                -name => 'protcomp_sel',
                -values =>
                  [ sort { $protcomp{$a} cmp $protcomp{$b} } keys %protcomp ],
                -labels   => \%protcomp,
                -override => 1,
                -default  => 1
            ),
            _form_buttons( 'protcomp', ('protcomp_sel') ),
            $p->end_form(),
        );
    }
    elsif ( $v->{feature} eq 'hmm' ) {

        my %doms = map { $_->[1] => "$_->[0]" } @{
            $u->selectall_arrayref(
'select m.name,m.pmodel_id from pmhmm m join pmsm_pmhmm s on s.pmodel_id=m.pmodel_id join run r on r.pmodelset_id=s.pmodelset_id where r.run_id=preferred_run_id_by_pftype(\'HMM\')'
            )
          };

        $ret = 'Choose from the following Pfam domains:', $ret .= join(
            '', '<p>',
            $p->start_form( -method => 'GET' ),
            $p->popup_menu(
                -name     => 'pfam_sel',
                -values   => [ sort { $doms{$a} cmp $doms{$b} } keys %doms ],
                -labels   => \%doms,
                -override => 1,
                -default  => 1
            ),
            ' with eval <= ',
            $p->popup_menu(
                -name    => 'pfam_eval',
                -values  => [qw(1e-40 1e-30 1e-20 1e-10 1 5 10)],
                -default => '1e-10'
            ),
            _form_buttons( 'hmm', ( 'pfam_sel', 'pfam_eval' ) ),
            $p->end_form(),
        );
    }
    elsif ( $v->{feature} eq 'pmap' ) {

        my %pmap_asm =
          map { $_->[1] => "$_->[0]" }
          @{ $u->selectall_arrayref('select name,genasm_id from genasm') };
        my @pmap_chr =
          sort { $a <=> $b }
          @{ $u->selectcol_arrayref('select distinct(chr) from pmap_hsp') };
        my @cyto = @{
            $u->selectcol_arrayref(
                'select chr||\'.\'||band from unison_aux.cytoband_hg18')
          };
        unshift( @pmap_chr, 'select ...' );
        unshift( @cyto,     'select ...' );

        $ret = 'Choose from the following genomic properties:', $ret .= join(
            '', '<p>',
            $p->start_form( -method => 'GET' ),
            'Assembly:',
            $p->popup_menu(
                -name => 'pmap_genasm_id',
                -values =>
                  [ sort { $pmap_asm{$a} cmp $pmap_asm{$b} } keys %pmap_asm ],
                -labels   => \%pmap_asm,
                -override => 1,
                -default  => 3
            ),
            ' chr :',
            $p->popup_menu(
                -name   => 'pmap_chr',
                -values => [@pmap_chr]
            ),
            '<p>',
            'start >= ',
            $p->textfield(
                -name     => 'pmap_gstart',
                -size     => 30,
                -override => 1
            ),
            'stop  <= ',
            $p->textfield(
                -name     => 'pmap_gstop',
                -size     => 30,
                -override => 1
            ),
            '<p>',
            'min_exons >= ',
            $p->textfield(
                -name     => 'pmap_min_e',
                -size     => 30,
                -override => 1
            ),
            'max_exons  <= ',
            $p->textfield(
                -name     => 'pmap_max_e',
                -size     => 30,
                -override => 1
            ),
            '<p>',
            ' cytoband :',
            $p->popup_menu(
                -name   => 'cytoband',
                -values => [@cyto]
            ),
            _form_buttons(
                'pmap',
                (
                    'pmap_genasm_id', 'pmap_chr',
                    'pmap_min_e',     'pmap_max_e',
                    'pmap_gstart',    'pmap_gstop',
                    'cytoband'
                )
            ),
            $p->end_form(),
        );
    }
    elsif ( $v->{feature} eq 'pepcoil' ) {
        $ret = 'Choose the probabily of a coiled-coil region:', $ret .= join(
            '', '<p>',
            $p->start_form( -method => 'GET' ),
            $p->popup_menu(
                -name    => 'pepcoil_prob',
                -values  => [qw(50 60 70 80 90 100)],
                -default => '90'
            ),
            _form_buttons( 'pepcoil', ('pepcoil_prob') ),
            $p->end_form(),
        );
    }
    elsif ( $v->{feature} eq 'bigpi' ) {
        my %bigpi = map {
            $_->[1] =>
" '$_->[0]' (score range $_->[1] to $_->[2], pvalue range $_->[3] to $_->[4])"
          } @{
            $u->selectall_arrayref(
'select quality,max(score) as max_score,min(score) as min_score, min(pvalue) as min_pvalue,max(pvalue) as max_pvalue from pfbigpi_v group by quality'
            )
          };

        $ret = 'Choose the quality of GPI Modification Site:', $ret .= join(
            '', '<p>',
            $p->start_form( -method => 'GET' ),
            $p->popup_menu(
                -name     => 'bigpi',
                -values   => [ sort { $bigpi{$a} cmp $bigpi{$b} } keys %bigpi ],
                -labels   => \%bigpi,
                -override => 1,
                -default  => 'D'
            ),
            _form_buttons( 'bigpi', ('bigpi') ),
            $p->end_form(),
        );
    }
    elsif ( $v->{feature} eq 'seg' ) {
        $ret = 'Low Complexity Region:', $ret .= join(
            '', '<p>',
            $p->start_form( -method => 'GET' ),
            $p->radio_group(
                -name   => 'seg',
                -values => [qw(yes no)]
            ),
            _form_buttons( 'seg', ('seg') ),
            $p->end_form(),
        );
    }
    elsif ( $v->{feature} eq 'regexp' ) {

        my %regexp = map { $_->[1] => "$_->[0] ($_->[2])" } @{
            $u->selectall_arrayref(
'select name,pmodel_id,regexp from pmregexp where origin_id=origin_id(\'Prosite\')'
            )
          };

        $ret = 'Choose from the following Prosite patterns:', $ret .= join(
            '', '<p>',
            $p->start_form( -method => 'GET' ),
            $p->popup_menu(
                -name => 'regexp_sel',
                -values =>
                  [ sort { $regexp{$a} cmp $regexp{$b} } keys %regexp ],
                -labels   => \%regexp,
                -override => 1,
                -default  => 1
            ),
            _form_buttons( 'regexp', ('regexp_sel') ),
            $p->end_form(),
        );
    }
    elsif ( $v->{feature} eq 'tax' ) {
        my %tax =
          map { $_->[1] => "$_->[0]" }
          @{ $u->selectall_arrayref('select gs,tax_id from tax.spspec') };

        $ret = 'Choose from the following species:', $ret .= join(
            '', '<p>',
            $p->start_form( -method => 'GET' ),
            $p->popup_menu(
                -name     => 'tax_sel',
                -values   => [ sort keys %tax ],
                -labels   => \%tax,
                -override => 1,
                -default  => 9606
            ),
            _form_buttons( 'tax', ('tax_sel') ),
            $p->end_form(),
        );
    }
    elsif ( $v->{feature} eq 'signalp' ) {
        $ret = 'Signal Peptide', $ret .= join(
            '', '<p>',
            $p->start_form( -method => 'GET' ),
            $p->radio_group(
                -name   => 'signalp',
                -values => [qw(yes no)]
            ),
            _form_buttons( 'signalp', ('signalp') ),
            $p->end_form(),
        );
    }
    elsif ( $v->{feature} eq 'pdb' ) {
        $ret = 'PDB Structure', $ret .= join(
            '', '<p>',
            $p->start_form( -method => 'GET' ),
            $p->radio_group(
                -name   => 'pdb',
                -values => [qw(yes no)]
            ),
            _form_buttons( 'pdb', ('pdb') ),
            $p->end_form(),
        );
    }
    elsif ( $v->{feature} eq 'tmhmm' ) {
        $ret = 'Transmembrane Region', $ret .= join(
            '', '<p>',
            $p->start_form( -method => 'GET' ),
            $p->radio_group(
                -name   => 'tmhmm',
                -values => [qw(yes no)]
            ),
            _form_buttons( 'tmhmm', ('tmhmm') ),
            $p->end_form(),
        );
    }
    elsif ( $v->{feature} eq 'psipred' ) {
        $ret = 'Secondary Structure Prediction', $ret .= join(
            '', '<p>',
            $p->start_form( -method => 'GET' ),
            'Format : ss_type>min-max,[repeat...]',
            '<p>ss_type can be H,E or C<p>',
            $p->textfield(
                -name     => 'psipred',
                -size     => 50,
                -override => 1
            ),
            '&nbsp;',
            $p->button(
                -name    => 'check',
                -value   => 'check syntax',
                -onClick => "check_psipred_q(document.forms[0].psipred.value)"
            ),
            _form_buttons( 'psipred', ('psipred') ),
            $p->end_form(),
        );
    }
    elsif ( $v->{feature} eq 'physical' ) {

        $ret = 'Choose from the following Characteristics:', $ret .= join(
            '', '<p>',
            $p->start_form( -method => 'GET' ),
            'Length is between ',
            $p->textfield(
                -name     => 'len_min',
                -size     => 10,
                -override => 1,
            ),
            ' aa and ',
            $p->textfield(
                -name     => 'len_max',
                -size     => 10,
                -override => 1,
            ),
            ' aa <p>',
            'mol_wt is between ',
            $p->textfield(
                -name     => 'wt_min',
                -size     => 10,
                -override => 1,
            ),
            ' kDa and ',
            $p->textfield(
                -name     => 'wt_max',
                -size     => 10,
                -override => 1,
            ),
            ' kDa<p>',
            'Extinction Coefficient is between ',
            $p->textfield(
                -name     => 'a280_min',
                -size     => 10,
                -override => 1,
            ),
            ' M<sup>-1</sup>cm<sup>-1</sup> and ',
            $p->textfield(
                -name     => 'a280_max',
                -size     => 10,
                -override => 1,
            ),
            ' M<sup>-1</sup>cm<sup>-1</sup> <p>',
            'Isoelectric Point is between ',
            $p->textfield(
                -name     => 'pI_min',
                -size     => 10,
                -override => 1,
            ),
            ' and ',
            $p->textfield(
                -name     => 'pI_max',
                -size     => 10,
                -override => 1,
            ),
            _form_buttons(
                'physical',
                (
                    'len_min',  'len_max',  'wt_min', 'wt_max',
                    'a280_min', 'a280_max', 'pI_min', 'pI_max'
                )
            ),
            $p->end_form(),
        );
    }
    return $ret;
}

sub _form_buttons {
    my $f    = shift;
    my @keys = @_;
    my $params;
    foreach my $k (@keys) {
        if ( defined $params ) {
            $params .= "+':";
        }
        else {
            $params .= "'";
        }
        $params .= $k . "='+get_value(document.forms[0]." . $k . ")";
    }
    return join(
        '', '<p>',
        $p->button(
            -name    => 'results',
            -value   => 'submit',
            -onClick => "window.parent.update_emb_search_form('results')"
        ),
        '&nbsp;',
        $p->button(
            -name    => 'sql',
            -value   => 'sql only',
            -onClick => "window.parent.update_emb_search_form('sql')"
        ),
        '&nbsp;',
        $p->button(
            -name    => 'add',
            -value   => 'select',
            -onClick => "window.parent.update_emb_search_form('" 
              . $f . "',"
              . $params . ")"
        ),
        '&nbsp;',
        $p->button(
            -name    => 'reset',
            -value   => 'reset',
            -onClick => "window.parent.update_emb_search_form('" 
              . $f
              . "','reset')"
        )
    );
}
