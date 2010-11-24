
=head1 NAME

PDBML

S<$Id$>

=head1 SYNOPSIS

 use PDBML;
 my $pdbml = new PDBML($xml_file)

=head1 DESCRIPTION

B<PDML> is a module for parsing pdb files in XML format
with subroutines for specific data output in tab 
delimited format that can be loaded into database tables

=cut

package PDBML;

use strict;
use warnings;
use XML::Twig;

my %aa_codes = (
    ALA   => 'A',
    VAL   => 'V',
    PHE   => 'F',
    PRO   => 'P',
    MET   => 'M',
    ILE   => 'I',
    LEU   => 'L',
    ASP   => 'D',
    GLU   => 'E',
    LYS   => 'K',
    ARG   => 'R',
    SER   => 'S',
    THR   => 'T',
    TYR   => 'Y',
    HIS   => 'H',
    CYS   => 'C',
    ASN   => 'N',
    GLN   => 'Q',
    TRP   => 'W',
    GLY   => 'G',
    '2AS' => 'D',
    '3AH' => 'H',
    '5HP' => 'E',
    ACL   => 'R',
    AIB   => 'A',
    ALM   => 'A',
    ALO   => 'T',
    ALY   => 'K',
    ARM   => 'R',
    ASA   => 'D',
    ASB   => 'D',
    ASK   => 'D',
    ASL   => 'D',
    ASQ   => 'D',
    AYA   => 'A',
    BCS   => 'C',
    BHD   => 'D',
    BMT   => 'T',
    BNN   => 'A',
    BUC   => 'C',
    BUG   => 'L',
    C5C   => 'C',
    C6C   => 'C',
    CCS   => 'C',
    CEA   => 'C',
    CHG   => 'A',
    CLE   => 'L',
    CME   => 'C',
    CSD   => 'A',
    CSO   => 'C',
    CSP   => 'C',
    CSS   => 'C',
    CSW   => 'C',
    CXM   => 'M',
    CY1   => 'C',
    CY3   => 'C',
    CYG   => 'C',
    CYM   => 'C',
    CYQ   => 'C',
    DAH   => 'F',
    DAL   => 'A',
    DAR   => 'R',
    DAS   => 'D',
    DCY   => 'C',
    DGL   => 'E',
    DGN   => 'Q',
    DHA   => 'A',
    DHI   => 'H',
    DIL   => 'I',
    DIV   => 'V',
    DLE   => 'L',
    DLY   => 'K',
    DNP   => 'A',
    DPN   => 'F',
    DPR   => 'P',
    DSN   => 'S',
    DSP   => 'D',
    DTH   => 'T',
    DTR   => 'W',
    DTY   => 'Y',
    DVA   => 'V',
    EFC   => 'C',
    FLA   => 'A',
    FME   => 'M',
    GGL   => 'E',
    GLZ   => 'G',
    GMA   => 'E',
    GSC   => 'G',
    HAC   => 'A',
    HAR   => 'R',
    HIC   => 'H',
    HIP   => 'H',
    HMR   => 'R',
    HPQ   => 'F',
    HTR   => 'W',
    HYP   => 'P',
    IIL   => 'I',
    IYR   => 'Y',
    KCX   => 'K',
    LLP   => 'K',
    LLY   => 'K',
    LTR   => 'W',
    LYM   => 'K',
    LYZ   => 'K',
    MAA   => 'A',
    MEN   => 'N',
    MHS   => 'H',
    MIS   => 'S',
    MLE   => 'L',
    MPQ   => 'G',
    MSA   => 'G',
    MSE   => 'M',
    MVA   => 'V',
    NEM   => 'H',
    NEP   => 'H',
    NLE   => 'L',
    NLN   => 'L',
    NLP   => 'L',
    NMC   => 'G',
    OAS   => 'S',
    OCS   => 'C',
    OMT   => 'M',
    PAQ   => 'Y',
    PCA   => 'E',
    PEC   => 'C',
    PHI   => 'F',
    PHL   => 'F',
    PR3   => 'C',
    PRR   => 'A',
    PTR   => 'Y',
    SAC   => 'S',
    SAR   => 'G',
    SCH   => 'C',
    SCS   => 'C',
    SCY   => 'C',
    SEL   => 'S',
    SEP   => 'S',
    SET   => 'S',
    SHC   => 'C',
    SHR   => 'K',
    SOC   => 'C',
    STY   => 'Y',
    SVA   => 'S',
    TIH   => 'A',
    TPL   => 'W',
    TPO   => 'T',
    TPQ   => 'A',
    TRG   => 'K',
    TRO   => 'W',
    TYB   => 'Y',
    TYQ   => 'Y',
    TYS   => 'Y',
    TYY   => 'Y',
    AGM   => 'R',
    GL3   => 'G',
    SMC   => 'C',
    ASX   => 'B',
    CGU   => 'E',
    CSX   => 'C',
    GLX   => 'Z'
);

my ( %pri_att, %att );
my ( $order,   $att_ctr );

=pod

=head1 ROUTINES AND METHODS

=over

=cut

######################################################################
## functionName

=pod

=item new()

 Name:      new()
 Purpose:   return pdml object
 Arguments: PDB XML format file
 Returns:   PDBML object


=cut

sub new {

    my ( $class, $fn ) = @_;
    my $self = {};
    bless $self, $class;
    if ( !defined($fn) ) {
        warn "PDBML needs an pdb file in XML format to initialize\n";
        return undef;
    }

    if ( !-e $fn ) {
        warn "file $fn does not exist\n";
        return undef;
    }

    $self->{twig} = $self->_xml_init();

    my $content = ( $fn =~ /\.gz$/ ? `gzip -cdq $fn` : `cat $fn` )
        || return undef;
    $self->{twig}->parse($content);    # build the twig

    my $entry_id = $self->{twig}->root->simplify();
    if ( !$entry_id->{datablockName} ) {
        warn "Couldn't infer pdbid : $entry_id\n";
        next;
    }
    $self->{pdbid} = $entry_id->{datablockName};
    $self->{md5} = (split(/\s+/,`md5sum $fn`))[0];
    my @f = (localtime ((stat($fn))[9]))[3..5,2,1,0];
    $self->{mtime} = sprintf "%d-%d-%d %d:%d:%d", $f[1] +1, $f[0], $f[2] + 1900,@f[3..5];
    return ($self) if ( defined( $self->{pdbid} ) and defined( $self->{md5}  ) );
    return undef;
}

######################################################################
## summary()

=pod

=item summary()

 Name:      summary()
 Purpose:   get data for the pdbsummary table
 Arguments: none
 Returns:   tab delimited summary info

=cut

sub summary {
    my $self  = shift;
    my $fh    = shift || \*STDOUT;
    my $pdbid = uc( $self->{pdbid} );
    my $md5 = $self->{md5};
    my $lastmdate = $self->{mtime};

    #summary
    my $method = $att{exptl}{method}{ $pdbid . ":" }
        || $self->_check("method");

    my $resolution = $att{refine}{ls_d_res_high}{ $pdbid . ":" } || '';
    my $r_factor = $att{refine}{ls_R_factor_R_work}{ $pdbid . ":" } || '';
    my $r_free = $att{refine}{ls_R_factor_R_free}{ $pdbid . ":" } || '';
    my $title = (
          $att{struct}{title}{ $pdbid . ":" }
        ? $att{struct}{title}{ $pdbid . ":" }
        : $att{struct}{pdbx_descriptor}{ $pdbid . ":" }
        )
        || $self->_check("title");
    my $header = $att{struct_keywords}{pdbx_keywords}{ $pdbid . ":" }
        || $self->_check("header");

# assuming that source is the same for all polymer entities and taking the first
    my $source = $att{entity_src_gen}{pdbx_gene_src_scientific_name}{'1:'} || '';

#print $fh lc($pdbid),"\t$method\t$resolution\t$title\t$header\t",uc($source),"\t$lastmdate\n";
    return

        lc($pdbid)
      . "\t$method\t$resolution\t$title\t$header\t"
      . uc($source)
      . "\t$lastmdate"
      . "\t$md5"
      . "\t$r_factor"
      . "\t$r_free\n";
}

######################################################################
## chain()

=pod

=item chain()

 Name:      chain()
 Purpose:   get data for the pdbchain table
 Arguments: none
 Returns:   tab delimited chain data

=cut

sub chain {

    my $self  = shift;
    my $fh    = shift || \*STDOUT;
    my $pdbid = uc( $self->{pdbid} );
    my $ret   = '';

    #from pdbx_poly_seq_scheme (where you can map seqres to atoim res)
    foreach my $pri_col (
        sort { $order->{$a} <=> $order->{$b} }
        sort keys %{ $att{pdbx_poly_seq_scheme}{pdb_seq_num} }
        )
    {

        my ( $asym_id, $entity_id, $seq_res, $seq_num )
            = split( /\:/, $pri_col );

        my $chain = $att{pdbx_poly_seq_scheme}{pdb_strand_id}{$pri_col} || '';
        $self->{chains}{$chain}{count}++;
        $self->{chains}{$chain}{id} = $entity_id
            if ( !defined( $self->{chains}{$chain}{id} ) );
        $self->{chains}{$chain}{asym_id} = $asym_id
            if ( !defined( $self->{chains}{$chain}{asym_id} ) );
    }

    foreach my $pri_col ( sort keys %{ $att{pdbx_entity_name}{name} } ) {
        next unless defined( $att{pdbx_entity_name}{name}{$pri_col} );
        my ( $ent, $name, $name_type ) = split( /\:/, $pri_col );
        $self->{entities}{$ent}{name} = $name
            if (
            $name_type =~ /RCSB_NAME/
            or ( !defined( $self->{entities}{$ent}{name} )
                && $name_type =~ /NAME/ )
            );
    }
    foreach my $ent ( keys %{ $att{entity}{pdbx_description} } ) {
        $self->{entities}{$ent}{descr} = $att{entity}{pdbx_description}{$ent}
            if ( !defined( $self->{entities}{$ent}{descr} ) );
        $self->{entities}{$ent}{ec} = $att{entity}{pdbx_ec}{$ent}
            if ( !defined( $self->{entities}{$ent}{ec} )
            && $att{entity}{pdbx_ec}{$ent} =~ /\./ );
    }

    #chain
    foreach my $chain ( keys %{ $self->{chains} } ) {

        my $ent = $self->{chains}{$chain}{id};


        my $ec = $self->{entities}{ $ent . ":" }{ec} || '';
        $ec =~ s/E\.C\.\s//;
        my $name = (
            defined( $self->{entities}{$ent}{name} )
            ? $self->{entities}{$ent}{name}
            : $self->{entities}{ $ent . ":" }{descr}
            )
            || $self->_check("Chain Name");

# this is where we change the chainid to blank if pdbx_blank_PDB_chainid_flag is set to Y(true)
        #$chain =
        #  ( $att{struct_asym}{pdbx_blank_PDB_chainid_flag}
        #      { $self->{chains}{$chain}{asym_id} . ':' } eq 'Y' ? '' : $chain )
        #  if (
        #    defined(
        #        $att{struct_asym}{pdbx_blank_PDB_chainid_flag}
        #          { $self->{chains}{$chain}{asym_id} . ':' }
        #    )
        #  );

        $ret
            .= lc($pdbid)
            . "\t$chain\t"
            . lc($pdbid)
            . $chain . "\t"
            . $name . "\t"
            . $ec . "\n";
    }
    return $ret;
}

######################################################################
## residue()

=pod

=item residue()

 Name:      residue()
 Purpose:   get data for the residue table
 Arguments: none
 Returns:   tab delimited residue info

=cut

sub residue {

    my $self  = shift;
    my $fh    = shift || \*STDOUT;
    my $pdbid = uc( $self->{pdbid} );
    my $ret   = '';

    #sequence structure mapping
    foreach my $pri_col (
        sort { $order->{$a} <=> $order->{$b} }
        sort keys %{ $att{pdbx_poly_seq_scheme}{pdb_seq_num} }
        )
    {

        my ( $asym_id, $entity_id, $seq_res, $seq_num )
            = split( /\:/, $pri_col );
        next unless defined $aa_codes{$seq_res};
        my $chain = $att{pdbx_poly_seq_scheme}{pdb_strand_id}{$pri_col} || '';

# this is where we change the chainid to blank if pdbx_blank_PDB_chainid_flag is set to Y(true)
#        $chain =
#          ( $att{struct_asym}{pdbx_blank_PDB_chainid_flag}
#              { $self->{chains}{$chain}{asym_id} . ':' } eq 'Y' ? '' : $chain )
#          if (
#            defined(
#                $att{struct_asym}{pdbx_blank_PDB_chainid_flag}
#                  { $self->{chains}{$chain}{asym_id} . ':' }
#            )
#          );

        my $atom_res = (
            defined( $att{pdbx_poly_seq_scheme}{pdb_mon_id}{$pri_col} )
            ? $att{pdbx_poly_seq_scheme}{pdb_mon_id}{$pri_col}
            : ''
        );
        my $res_id = (
              $att{pdbx_poly_seq_scheme}{pdb_mon_id}{$pri_col}
            ? $att{pdbx_poly_seq_scheme}{pdb_seq_num}{$pri_col}
            : ''
        );

#print $fh lc($pdbid)."$chain\t",lc($pdbid),"\t$chain\t$seq_num\t",lc($aa_codes{$seq_res}),"\t",lc($aa_codes{$atom_res}),"\t$res_id\n";
        $ret
            .= lc($pdbid)
            . "$chain\t$seq_num\t"
            . lc( $aa_codes{$seq_res} ) . "\t"
            . lc( $aa_codes{$atom_res} )
            . "\t$res_id\n";
    }
    return $ret;
}


######################################################################
## protein_atom()

=pod

=item protein_atom()

 Name:      protein_atom()
 Purpose:   get data for the protein_atom table
 Arguments: none
 Returns:   tab delimited protein_atom info

=cut

sub protein_atom {

    my $self  = shift;
    my $fh    = shift || \*STDOUT;
    my $pdbid = uc( $self->{pdbid} );
    my $ret   = '';
    my $method = $att{exptl}{method}{ $pdbid . ":" };
    foreach my $pri_col (sort {$order->{$a} <=> $order->{$b}} keys %{$att{atom_site}{label_seq_id}}) {

	my $seqres = $att{atom_site}{auth_comp_id}{$pri_col};
	next unless ($att{atom_site}{group_PDB}{$pri_col} eq 'ATOM') and defined $aa_codes{$seqres};

        my $chain = $att{atom_site}{auth_asym_id}{$pri_col} || '';
	my $x_coor = $att{atom_site}{Cartn_x}{$pri_col} || '';
	my $y_coor = $att{atom_site}{Cartn_y}{$pri_col} || '';
	my $z_coor = $att{atom_site}{Cartn_z}{$pri_col} || '';
	my $seq_num = $att{atom_site}{label_seq_id}{$pri_col} || '';
	my $res_id = $att{atom_site}{auth_seq_id}{$pri_col} || '';
	my $b_fac = $att{atom_site}{B_iso_or_equiv}{$pri_col} || '';
	my $atom_name = $att{atom_site}{auth_atom_id}{$pri_col} || '';
	#print "$pdbid$chain\t$atom_name\t$seq_num\t$res_id\t$x_coor\t$y_coor\t$z_coor\t$b_fac\n";
	$ret
            .= "$atom_name\t"
	    . "{$x_coor,"
	    . "$y_coor,"
	    . "$z_coor}\t"
	    . "$b_fac\t"
            . "$res_id\t"
	    . "$seq_num\t"
            . "$chain\t"
	    . lc($pdbid)."\n"

    }
    return $ret;
}

######################################################################
## ligand_atom()

=pod

=item ligand_atom()

 Name:      ligand_atom()
 Purpose:   get data for the ligand_atom table
 Arguments: none
 Returns:   tab delimited ligand_atom info

=cut

sub ligand_atom {

    my $self  = shift;
    my $fh    = shift || \*STDOUT;
    my $pdbid = uc( $self->{pdbid} );
    my $ret   = '';
   
    foreach my $pri_col (sort {$order->{$a} <=> $order->{$b}} keys %{$att{atom_site}{label_seq_id}}) {

	my $lig_id = $att{atom_site}{auth_comp_id}{$pri_col} || '';
	next unless ($att{atom_site}{group_PDB}{$pri_col} eq 'HETATM' and $lig_id ne 'HOH' and not defined $aa_codes{$lig_id});

	my $x_coor = $att{atom_site}{Cartn_x}{$pri_col} || '';
	my $y_coor = $att{atom_site}{Cartn_y}{$pri_col} || '';
	my $z_coor = $att{atom_site}{Cartn_z}{$pri_col} || '';
	my $b_fac = $att{atom_site}{B_iso_or_equiv}{$pri_col} || '';
	my $atom_name = $att{atom_site}{auth_atom_id}{$pri_col} || '';
	#print "$pdbid\t$atom_name\tt$lig_id\t$x_coor\t$y_coor\t$z_coor\t$b_fac\n";
	$ret
            .= "$atom_name\t"
	    . "{$x_coor,"
	    . "$y_coor,"
	    . "$z_coor}\t"
	    . "$b_fac\t"
            . "$lig_id\t"
	    . lc($pdbid)."\n"
    }
    return $ret;
}


######################################################################
## pdb_ligand()

=pod

=item pdb_ligand()

 Name:      pdb_ligand()
 Purpose:   get data for the pdbligand table
 Arguments: optional file handle
 Returns:   tab delimited pdb_ligand data

=cut

sub pdb_ligand {

    my $self  = shift;
    my $fh    = shift || \*STDOUT;
    my $pdbid = uc( $self->{pdbid} );
    my $ret   = '';

    #pdb_ligand
    foreach my $ligand ( keys %{ $att{chem_comp}{name} } ) {
        next
            unless ( $att{chem_comp}{type}{$ligand} ne 'polymer'
            and ( $ligand ne 'HOH:' )
            and $att{chem_comp}{type}{$ligand} !~ /peptide/ );
        my $lig = $ligand;
        $lig =~ s/://;

	#print $fh lc($pdbid),"\t$lig\n";
        $ret .= lc($pdbid)
          . "\t$lig\n";
    }
    return $ret;
}

#=========================================================================================
#INTERNAL FUNCTIONS
#

sub _get_data_tag {

    my ( $twig, $field ) = @_;

    my $table_name = $field->gi;

    $table_name =~ s/^PDBx://;
    $table_name =~ s/Category$//;
    my %options = ( forcearray => '1', keyattr => 'id' );

    foreach my $row ( $field->children() ) {
        my $pri_col = '';
        foreach my $pcol ( sort keys %{ $pri_att{$table_name} } ) {
            my $simplified = $row->simplify(%options)->{$pcol};
            $pri_col .= $simplified . ":" if $simplified;
        }
        foreach my $col ( sort keys %{ $att{$table_name} } ) {

            $att{$table_name}{$col}{$pri_col} = ''
                if ( !$row->first_child( 'PDBx:' . $col ) );

            next unless ( $row->first_child( 'PDBx:' . $col ) );

            $att{$table_name}{$col}{$pri_col} =
              $row->first_child( 'PDBx:' . $col )->text;

            $order->{$pri_col} = $att_ctr++;

	    #print "$table_name\t$col\t$pri_col\t$att{$table_name}{$col}{$pri_col}\n";
        }
    }
}

#=========================================================================================

sub _xml_init {

    my $self = shift;

    %pri_att = (
        'database_PDB_rev' => { 'num'      => undef },
        'struct_ref_seq'   => { 'align_id' => undef },
        'pdbx_entity_name' => {
            'entity_id' => undef,
            'name'      => undef,
            'name_type' => undef
        },
        'entity_src_gen'       => { 'entity_id' => undef },
        'pdbx_poly_seq_scheme' => {
            'entity_id' => undef,
            'seq_id'    => undef,
            'asym_id'   => undef,
            'mon_id'    => undef
        },
        'struct_asym'     => { 'id'       => undef },
        'chem_comp'       => { 'id'       => undef },
        'entity'          => { 'id'       => undef },
        'refine'          => { 'entry_id' => undef },
	'refine_hist'     => { 'cycle_id' => undef },
        'struct_keywords' => { 'entry_id' => undef },
        'struct'          => { 'entry_id' => undef },
        'exptl'           => { 'entry_id' => undef },
        'struct_conn'     => { 'id'       => undef },
	'atom_site'       => { 'id'       => undef }
    );
    %att = (
        'database_PDB_rev' => { 'date'           => undef },
        'struct_ref_seq'   => { 'pdbx_strand_id' => undef },
        'pdbx_entity_name' => { 'name'           => undef },
        'entity_src_gen'   => {
            'pdbx_gene_src_scientific_name' => undef,

            #			   'gene_src_common_name' => undef
            #			   'pdbx_gene_src_gene'   => undef
        },
        'pdbx_poly_seq_scheme' => {
            'pdb_seq_num'   => undef,
            'pdb_mon_id'    => undef,
            'pdb_strand_id' => undef
        },
        'struct_asym' => { 'pdbx_blank_PDB_chainid_flag' => undef },
        'chem_comp'   => {
            'type'          => undef,
            'name'          => undef
        },
        'entity' => {
            'pdbx_description' => undef,
            'pdbx_ec'          => undef
        },
        'refine'          => { 'ls_d_res_high' => undef,
			       'ls_R_factor_R_work' => undef,
			       'ls_R_factor_R_free' => undef
			     },
        'refine_hist'     => { 'pdbx_number_atoms_protein' => undef },
        'struct_keywords' => { 'pdbx_keywords' => undef },
        'struct'          => {
            'title'           => undef,
            'pdbx_descriptor' => undef
        },
        'exptl' => { 'method' => undef },
	'struct_conn' => { 
	    'ptnr1_auth_asym_id' => undef,
	    'ptnr1_auth_comp_id' => undef,
	    'ptnr1_auth_seq_id'  => undef,
	    'ptnr2_auth_asym_id' => undef,
	    'ptnr2_auth_comp_id' => undef,
	    'ptnr2_auth_seq_id'  => undef,
	},
	'atom_site' => {
	    'group_PDB' => undef,
	    'Cartn_x' => undef,
	    'Cartn_y' => undef,
	    'Cartn_z' => undef,
	    'label_seq_id' => undef,
	    'B_iso_or_equiv' => undef,
    	    'auth_seq_id' => undef,
	    'auth_atom_id' => undef,
	    'auth_asym_id' => undef,
	    'auth_comp_id' => undef,
	    'pdbx_PDB_model_num' => undef
	    },
    );

    $order            = undef;
    $att_ctr          = 0;
    $self->{entities} = undef;
    $self->{chains}   = undef;

    my $twig = new XML::Twig(
        TwigRoots => {
            'PDBx:database_PDB_revCategory'     => 1,
            'PDBx:struct_ref_seqCategory'       => 1,
            'PDBx:pdbx_entity_nameCategory'     => 1,
            'PDBx:entity_src_genCategory'       => 1,
            'PDBx:pdbx_poly_seq_schemeCategory' => 1,
            'PDBx:struct_asymCategory'          => 1,
            'PDBx:chem_compCategory'            => 1,
            'PDBx:entityCategory'               => 1,
            'PDBx:refineCategory'               => 1,
            'PDBx:refine_histCategory'          => 1,
            'PDBx:struct_keywordsCategory'      => 1,
            'PDBx:structCategory'               => 1,
            'PDBx:exptlCategory'                => 1,
            'PDBx:struct_connCategory'          => 1,
	    'PDBx:atom_siteCategory'            => 1
        },
        TwigHandlers => {
            'PDBx:database_PDB_revCategory'     => \&_get_data_tag,
            'PDBx:struct_ref_seqCategory'       => \&_get_data_tag,
            'PDBx:pdbx_entity_nameCategory'     => \&_get_data_tag,
            'PDBx:entity_src_genCategory'       => \&_get_data_tag,
            'PDBx:pdbx_poly_seq_schemeCategory' => \&_get_data_tag,
            'PDBx:struct_asymCategory'          => \&_get_data_tag,
            'PDBx:chem_compCategory'            => \&_get_data_tag,
            'PDBx:entityCategory'               => \&_get_data_tag,
            'PDBx:refineCategory'               => \&_get_data_tag,
            'PDBx:refine_histCategory'          => \&_get_data_tag,
            'PDBx:struct_keywordsCategory'      => \&_get_data_tag,
            'PDBx:structCategory'               => \&_get_data_tag,
            'PDBx:exptlCategory'                => \&_get_data_tag,
            'PDBx:struct_connCategory'          => \&_get_data_tag,
	    'PDBx:atom_siteCategory'            => \&_get_data_tag
        }
    );

    return $twig;
}

sub _check {

    my ( $self, $field ) = @_;
    print STDERR "$field\tCOULD NOT BE PARSED for $self->{pdbid}\n";
    return '';
}

=pod

=back

=head1 BUGS

Please report bugs to Kiran Mukhyala E<lt>mukhyala.kiran@gene.comE<gt>.

=head1 SEE ALSO

=over 4

=item * perldoc PDBML

=back

=head1 AUTHOR

Kiran Mukhyala E<lt>mukhyala.kiran@gene.comE<gt>.

=cut

1;
