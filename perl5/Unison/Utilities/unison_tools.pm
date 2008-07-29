=head1 NAME

Unison::Utilities::unison_tools -- helper module for unison-tools

S<$Id$

=head1 SYNOPSIS

 use Unison::Utilities::unison_tools;

=head1 DESCRIPTION

 common module to handle user input for all unison- tools

=cut

package Unison::Utilities::unison_tools;

use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use Getopt::Long qw(:config gnu_getopt);

use File::Temp qw(tempfile);
use Pod::Usage;
use Bio::SeqIO;

use base 'Exporter';
our @EXPORT    = ();

sub new {
    my ( $class, $unison) = @_;
    my $self = {};
    bless $self, $class;

    #parse options
    if (not defined ($self->{opts} = parse_options())) {
	warn "unison_tools: problem in parsing options";
	return undef;
    }

    # args from command line or stdin, but not both
    my (@args) = @ARGV ? @ARGV : map { chomp; $_ } <>;
    $self->{'args'} = \@args;

    if ( !defined($unison) ) {
        warn "unison_tools requires a ref to unison\n";
        return undef;
    }
    else {
        $self->{'unison'} = $unison;
    }

    #we'll need pseq_ids
    my ( $pseq_ids, $user_anns ) = $self->map_args_to_pseq_ids();

    $self->{'pseq_ids'} = (defined $pseq_ids ? $pseq_ids : undef);
    $self->{'user_anns'}= (defined $user_anns ? $user_anns : undef);
    return ($self);
}

############################################################################
## argument processing
sub map_args_to_pseq_ids {
  my $self = shift;
  my $u = $self->{unison} || warn "unison not defined\n";
  my %opts = %{$self->{opts}};
  my @args = @{$self->{args}};

  my $or = $self->{opts};
    my (@pseq_ids);
    my %user_anns;
    my $sno = 0;
    if ( $or->{'select-by-unison-id'} ) {

        # expand ranges like 1..5 to (1,2,3,4,5)
        # This is in part to sanitize the expressions which will be
        # eval'd next
        if ( my @bad = grep { not /^\d+$|^\d+\.\.\d+$|\d+-\d+$/ } @args ) {
            die("'$bad[0]' doesn't specify a pseq_id or a range of pseq_ids\n"
            );
        }
        @pseq_ids = grep { $u->get_sequence_by_pseq_id($_) }
            map { s/-/../; eval "$_" } @args;
        if ( $#pseq_ids < 0 ) {            printf( STDERR "0 sequences specified by Unison id\n" );
            exit(-1);
        }
        else {
            printf( STDERR "# %d sequences specified by Unison id\n",
                $#pseq_ids + 1
            ) if $opts{verbose};
        }
    }
    elsif ( $or->{'select-by-seq'} ) {

        my $file = $args[0];
        my $in;
        if ( $file =~ /^\>/ ) {
            my ( $fh, $fn ) = tempfile();
            if ( defined $fh ) {
                print $fh join "\n", @args;
                $fh->close;
                $in = new Bio::SeqIO(
                    -file   => $fn,
                    -format => 'fasta'
                );
            }
        }
        else {
            $in = new Bio::SeqIO(
                -file   => $file,
                -format => 'fasta'
            );
        }
        while ( my $bs = $in->next_seq() ) {
            $sno++;
            my $pseq_id = $u->pseq_id_by_sequence( $bs->seq() );
            if ( not defined $pseq_id ) {
                warn(
                    "#! Sequence #$sno (",
                    $bs->display_id(),
                    ") not in Unison\n"
                );
                next;
            }
            printf( STDOUT "#* %s (Unison:%d; %s);\n",
                $bs->display_id(), $pseq_id,
                $u->best_alias($pseq_id) || '<no alias>' )
                if $opts{verbose};
            push @pseq_ids, $pseq_id;
            $user_anns{$pseq_id} = $bs->display_id() . ":" . $bs->desc();
        }
    }
    elsif ( $or->{'select-by-alias'} or $or->{'select-by-alias-fuzzy'} ) {
        foreach my $arg (@args) {
            my (@Q) = (
                  $or->{'select-by-alias'}
                ? $u->get_pseq_id_from_alias_exact($arg)
                : $u->get_pseq_id_from_alias($arg)
            );
            if ( not @Q ) {
                warn("#$0: no sequences found for alias '$arg'\n");
            }
            elsif ( $#Q > 0 ) {

                # no warning for fuzzy searches
                # this can only happen for aliases in multiple origins
                warn("#$0: multiple sequences found for alias '$arg'\n")
                    if ( $or->{'select-by-alias'} );
            }
            if ( $or->{'select-by-alias-fuzzy'} and $or->{'human'} ) {
                my @ids;
                foreach my $q (@Q) {
                    my ($e)
                        = $u->selectrow_array(
                        "select pseq_id from pseqset where pseq_id=$q and pset_id=1"
                        );
                    push @ids, $q if ($e);
                }
                @Q = @ids;
            }
            $user_anns{$_} = $arg foreach (@Q);
            push( @pseq_ids, @Q );
        }
        printf( STDOUT "# %d sequences selected by alias\n", $#pseq_ids + 1 )
            if $opts{verbose};
    }
    elsif ( $or->{'select-by-gi'} ) {

        # expand ranges like 1..5 to (1,2,3,4,5)
        # This is in part to sanitize the expressions which will be
        # eval'd next
        if ( my @bad = grep { not /^\d+$|^\d+\.\.\d+$|\d+-\d+$/ } @args ) {
            die("'$bad[0]' doesn't specify a gi or a range of gi\n");
        }
        my @gis = map { s/-/../; eval "$_" } @args;

        my @ids;
        foreach my $gi (@gis) {
            my @Q = @{
                $u->selectall_arrayref(
                    "select distinct(pseq_id) from pseq_gene_mv where gene_id=$gi"
                )
                };
            push @ids, @Q if ( $#Q >= 0 );
            if ( not @Q ) {
                warn("#$0: no sequences found for gi '$gi'\n");
            }
            elsif ( $#Q > 0 ) {
                warn("#$0: multiple sequences found for gi '$gi'\n");
            }
            $user_anns{$_} = $gi foreach (@Q);
        }
        push( @pseq_ids, map { $_->[0] } @ids );
        printf( STDOUT "# %d sequences specified by Unison id\n",
            $#pseq_ids + 1
        ) if $opts{verbose};
    }
    elsif ( $or->{'select-by-probe'} ) {
        my %ids;
        foreach my $pi (@args) {
            my @Q = @{
                $u->selectall_arrayref(
                    "select distinct (r.t_pseq_id) from pmap_locus_representative_mv r join pseq_probe_mv p on r.q_pseq_id=p.pseq_id where probe_id='$pi'"
                )
                };
            map { $ids{ $_->[0] }++ } @Q if ( $#Q >= 0 );
            if ( not @Q ) {
                warn("#$0: no sequences found for probe_id '$pi'\n");
            }
            elsif ( $#Q > 0 ) {
                warn("#$0: multiple sequences found for probe_id '$pi'\n");
            }
            map { $user_anns{ $_->[0] } = $pi } @Q;
        }
        push( @pseq_ids, keys %ids );
        printf( STDOUT "# %d sequences specified by Unison id\n",
            $#pseq_ids + 1
        ) if $opts{verbose};
    }
    return ( \@pseq_ids, \%user_anns );
}

############################################################################
# please restrict default constants to %opts
sub parse_options {

    my %opts = (

        # how to select sequences
        'select-by-seq'         => 0,
        'select-by-alias'       => 0,
        'select-by-alias-fuzzy' => 0,
        'select-by-unison-id'   => 0,
        'select-by-gi'          => 0,
        'select-by-probe'       => 0,

	#user selected/defined features
	'features' => undef,
	'highlight' => undef,

        #data type
        'pfam'     => 0,
        'signalp'  => 0,
        'tm'       => 0,
        'protcomp' => 0,
        'bipig'    => 0,
        'regexp'   => 0,
        'patents'  => 0,
        'alias'    => 0,

        #output options
        format => 'png',
	bg_color => 'white',
        snp_color => 'red',
        width  => undef,
        height => undef,
	outfile => 'u-s-g.png',
	init_width => 1200,
	init_height => 1200,

        #filtering options
        'human' => 0,

	'pdbid' => undef,

        # generic options
        'verbose'           => 0,
        'verbose_frequency' => 10,
        'help'              => 0,
        'version'           => 0
    );
    GetOptions(
        \%opts,
        'select-by-seq|S+',
        'select-by-alias|A+',
        'select-by-alias-fuzzy|F+',
        'select-by-unison-id|P+',
        'select-by-gi|G+',
        'select-by-probe|p+',

	'features=s',
	'highlight=s',

        'width|w=i',
        'height|l=i',
	'init_width=i',
        'init_height=i',

        'outfile|o=s',

        'bg_color|b=s',
	'snp_color=s',

        'pfam',
        'signalp',
        'tm',
        'protcomp',
        'bigpi',
        'regexp',
        'patents',
        'alias',

        'human',
	'pdbid|P=s',

        'format|f=s',
        'verbose|v+',
        'help|h+',
        'version|V',
    ) || die("$0: you got usage issues, homey\n");

    my $optot;
    my @opts;
    @opts = qw(select-by-seq select-by-alias select-by-alias-fuzzy
        select-by-unison-id select-by-gi select-by-probe);
    $optot = eval join( '+', map { $opts{$_} ? 1 : 0 } @opts );
    if ( $optot == 0 ) {
        $opts{'select-by-unison-id'}++;
    }
    elsif ( $optot > 1 ) {
        die( "$0: may only specify one of {", join( ',', @opts ), "}.\n" );
    }

    if ( $opts{version} ) {
        print( STDOUT
                '$Id$ ',
            "\n"
        );
        exit;
    }
    if ( $opts{help} ) {
        pod2usage( { -verbose => 2 } );
    }
    if ( $opts{format} eq 'summary') {
	$opts{summary}++;
    }
    return \%opts;
}

############################################################################
#parses user input options --features and --highlights
#its a separate funtion because not all unison-tools need to parse this
#expected format is --features=feature1@start-[end],features2... 
#                   --highlight=user:feature1:color,HMM:pfamdom:color...
sub get_user_specs {
    my $self = shift;

    if ( defined( $self->{opts}{features} ) ) {
        foreach ( split( /,/, $self->{opts}{features} ) ) {
            die(
                "wrong user features format expecting :: name@\coord[-coord]\n")
              unless (/(\w+)@(.*)/);
	    my $feat=$1;
            my ( $start, $end ) = (split( /-/, $2 ));
            $self->{opts}{feats}{$1}{type}  = 'user';
            $self->{opts}{feats}{$1}{start} = $start;
            $self->{opts}{feats}{$1}{end}   = $end;
        }
    }

    if ( defined( $self->{opts}{highlight} ) ) {
        foreach ( split( /,/, $self->{opts}{highlight} ) ) {
            die(
                "wrong highlight format expecting source:feature[:color]\n")
              unless (/(\S+)\:(\S+)/);
            my @hl = split(/\:/);
            die("Looks like you didn't define $hl[1]\n")
              if ( $hl[0] eq 'user'
                and !defined( $self->{opts}{feats}{ $hl[1] } ) );
            if ( $hl[0] =~ /hmm/i ) {
                my $ar = $self->get_hmm_range( $hl[1] );
                die("Couldn't find $hl[1] domain in PFAM hits")
                  if ( $#{$ar} < 1 );
                (
                    $self->{opts}{feats}{ $hl[1] }{type},
                    $self->{opts}{feats}{ $hl[1] }{start},
                    $self->{opts}{feats}{ $hl[1] }{end}
                ) = ( 'hmm', $ar->[0], $ar->[1] );
            }
            if ( $hl[2] =~ /^\*/ ) {
                die(
                    "$hl[2] 6 digits expected with RGB hexadecimal format\n")
                  if ( length( $hl[2] ) != 7 );
                $hl[2] =
                    hex( substr( $hl[2], 1, 2 ) ) . "-"
                  . hex( substr( $hl[2], 3, 2 ) ) . "-"
                  . hex( substr( $hl[2], 5, 2 ) )
                  || die(
"Something probably wrong with your RGB hexadecimal format\n"
                  );
            }
            $hl[2] =~ s/\[//;
            $hl[2] =~ s/\]//;
            $self->{opts}{feats}{ $hl[1] }{color} = $hl[2]
              if ( $hl[0] =~ /user/i or $hl[0] =~ /hmm/i );
            die(
"source for the feature to be highlighted must be either user or hmm: you entered $hl[0]"
            ) unless ( $hl[0] =~ /user/i or $hl[0] =~ /hmm/i );
        }
    }
}

#this is used in parsing user features
sub get_hmm_range {
    my ( $self, $hmm ) = @_;
    my $sql = "select a.start,a.stop from pahmm a join pmhmm m on a.pmodel_id=m.pmodel_id where pseq_id=$self->{'pseq_ids'}->[0] and m.name = \'$hmm\'";
    my $ar = $self->{'unison'}->selectall_arrayref($sql);
    return $ar->[0];
}
1;
