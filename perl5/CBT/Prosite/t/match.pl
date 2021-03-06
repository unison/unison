#!/usr/bin/env perl

BEGIN { unshift( @INC, $ENV{'HOME'} . '/cbc/opt/lib/perl5' ) }

use Prosite::DB;
use Prosite::Record;

$db = new Prosite::DB;
$fn = shift
  || die("missing database\n");
$db->open("$fn")
  || die("$fn: $!\n");
$db->scan();

$r = $db->read_parse_record('PS00314');

# sequence from ICEN_ERWUR, a TP of PS00314
$seq =
'MKEDKVLILRTCANNMADHGGIIWPLSGIVECKYWKPVKGFENGLTGLIWGKGSDSPLSLHADARWVVAEVDADECIAIETHGWIKFPRAEVLHVGTKTSAMQFILHHRADYVACTEMQAGPGAPDVTSEVKAGNRSLPVTDDIDATIESGSTQPTQTIEIATYGSTLSGTHQSQLIAGYGSTETAGDSSTLIAGYGSTGTAGSDSTLVAGYGSTQTAGEESSQMAGYGSTQTGMKGSDLTAGYGSTGTAGDDSSLIAGYGSTQTAGEDSSLTAGYGSTQTAQKGSDLTAGYGSTGTAGADSSLIAGYGSTQTAGEESTQTAGYGSTQTAQKGSDLTAGYGSTGTAGDDSSLIAGYGSTQTAGEDSSLTAGYGSTQTAQKGSDLTAGYGSTGTAGADSSLIAGYGSTQTAGEESTQTAGYGSTQTAQKGSDLTAGYGSTGTAGDDSSLIAGYGSTQTAGEDSSLTAGYGSTQTAQKGSDLTAGYGSTSTAGYESSLIAGYGSTQTAGYGSTLTAGYGSTQTAQNESDLITGYGSTSTAGANSSLIAGYGSTQTASYNSVLTAGYGSTQTAREGSDLTAGYGSTQTAQENSDLTTGYGSTSTAGYDSSLIAGYGSTQTAGYHSILTAGYGSTQTAQERSDLTTGYGSTSTAGADSSLIAGYGSTQTAGYNSILTAGYGSTQTAQENSDLTTGYGSTSTAGYESSLIAGYGSTQTASFKSTLMAGYGSSQTAREQSSLTAGYGSTSMAGYDSSLIAGYGSTQTAGYQSTLTAGYGSTQTAEHSSTLTAGYGSTATAGADSSLIAGYGSSLTSGIRSFLTAGYGSTLISGLRSVLTAGYGSSLISGRRSSLTAGYGSNQIASHRSSLIAGPESTQITGNRSMLIAGKGSSQTAGYRSTLISGADSVQMAGERGKLIAGADSTQTAGDRSKLLAGNNSYLTAGDRSKLTAGNDCILMAGDRSKLTAGINSILTAGCRSKLIGSNGSTLTAGENSVLIFRCWDGKRYTNVVAKTGKGGIEADMPYQMDEDNNIVNKPEE';
(@l) = $r->match($seq);
$l  = $r->match($seq);
$m  = $r->matches($seq);
$mr = $r->max_repeat;
printf( "match for %s against ICEN_ERWUR: max=%d, ar=%d sc=%d m=%d\n",
    $r->AC, $mr, $#l + 1, $l, $m );
$db->close();

