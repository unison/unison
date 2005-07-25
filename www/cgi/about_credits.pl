#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use CGI( -debug );
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};

print $p->render("Credits", <<EOHTML );
<p>Unison was developed by Kiran Mukhyala, David Cavanaugh, and Reece
Hart.<br>Please <a href="mailto:hart.reece\@gene.com">contact Reece</a> with
suggestions, bugs, or comments.

<p>We gratefully acknowledge the following groups and projects for their
freely-distributable contributions to the community. Unison is released
under an Open Source license; please see <a href="about_legal.pl">Unison
legal information</a> for details.


<table border=1 align="center" style="border: #006699 thin solid;" width="80%">

<!-- TEMPLATE:
<tr>
	<td align="center"></td>
	<td align="left"><a href=""></a></td>
	<td></td>
</tr>
-->


<tr><th colspan=3 bgcolor="#006699"><font color="white">Data in Unison</font></th></tr>

<tr>
	<td align="center"><img height=30 src="../av/ncbi.gif" alt="NCBI"></td>
	<td align="left"><a href="http://www.ncbi.nlm.nih.gov/">NCBI</a> for BLAST, CDD, RefSeq, Taxonomy</td>
	<td>Public domain</td>
</tr>

<tr>
	<td align="center"><img height=30 src="../av/GOthumbnail.gif" alt="GO"></td>
	<td align="left"><a href="http://www.geneontology.org/">GeneOntology.org</a></td>
	<td>Freely available [<a href="http://www.geneontology.org/GO.cite.shtml">License</a>]
</tr>

<tr>
	<td align="center"><font face="sans-serif" size="6pt" color="#990000"><strong>Pfam</strong></font></td>
	<td align="left"><a href="http://pfam.wustl.edu/">Pfam</a></td>
	<td>Freely available [<a href="ftp://ftp.genetics.wustl.edu/pub/Pfam/COPYRIGHT">License (GPL)</a>]</td>
</tr>

<tr>
	<td align="center"></td>
	<td align="left"><a href="http://scop.berkeley.edu/">SCOP - Structural Classifcation of Proteins</a></td>
	<td>Freely available without license after July 1, 2004 [<a href="http://scop.mrc-lmb.cam.ac.uk/scoplic/licence.html">License</a>]</td>
</tr>

<tr>
	<td align="center"><img height=30 src="../av/UNIPROT.jpg"></td>
	<td align="left"><a href="http://www.uniprot.org/">UniProt</a></td>
	<td>Freely distributable after Jan 1, 2005 [<a href="http://www.pir.uniprot.org/start/faq.shtml#redistribution">License</a>]</td>
</tr>



<tr><th colspan=3 bgcolor="#006699"><font color="white">Software used by Unison</font></th></tr>
<tr>
	<td align="center"><img height=20 src="../av/feather.gif"></td>
	<td align="left"><a href="http://www.apache.org/">Apache web server</a></td>
	<td>Freely available [<a href="http://www.apache.org/licenses/LICENSE-2.0">License (Apache)</a>]</td>
</tr>

<tr>
	<td align="center"></td>
	<td align="left"><a href="http://www.bioperl.org/">BioPerl</a></td>
	<td>Freely available [<a href="http://www.bioperl.org/License.shtml">License (Artistic)</a>]</td>
</tr>

<tr>
	<td align="center"><img height=30 src="../av/emboss.png"></td>
	<td align="left"><a href="http://emboss.sourceforge.net/">EMBOSS</a></td>
	<td>Freely available [<a href="http://emboss.sourceforge.net/licence/">License (GPL and LGPL)</a>]</td>
</tr>

<tr>
	<td align="center"><img height=30 src="../av/gnu-head-sm.png" alt="GNU/FSF"></td>
	<td align="left"><a href="http://www.gnu.org">GNU/Free Software Foundation</a> tools</td>
	<td>Um, that'd be free [<a href="ftp://ftp.genetics.wustl.edu/pub/Pfam/COPYRIGHT">License (GPL)</a>]</td>
</tr>

<tr>
	<td align="center"><img height=30 src="../av/hammer_sm.gif" alt="HMMER"></td>
	<td align="left"><a href="http://hmmer.wustl.edu/">HMMER</a></td>
	<td>Freely available [<a href="ftp://ftp.genetics.wustl.edu/pub/eddy/hmmer/CURRENT/COPYRIGHT">License (GPL)</a>]</td>
</tr>

<tr>
	<td align="center"><img height=30 src="../av/jmol.gif"></td>
	<td align="left"><a href="http://jmol.sourceforge.net/">JMol</a></td>
	<td>Freely available [<a href="http://www.kernel.org/pub/linux/kernel/COPYING">License (GPL)</a>]</td>
</tr>

<tr>
	<td align="center"><img height=30 src="../av/linux-penguin-sm.gif" alt="Linux"></td>
	<td align="left"><a href="http://www.linux.org/">Linux</a> (Linus Torvalds and linux-gnu contributors)</td>
	<td>Freely available [<a href="http://www.kernel.org/pub/linux/kernel/COPYING">License (GPL)</a>]</td>
</tr>

<tr>
	<td align="center"><img height=30 src="../av/camel.png"></td>
	<td align="left"><a href="http://www.perl.com/">Perl</a> (Larry Wall and perl contributors)</td>
	<td>Freely available [<a href="http://www.perl.com/pub/a/language/misc/Artistic.html">License (Artistic)</a>]</td>
</tr>

<tr>
	<td align="center"></td>
	<td align="left"><a href="http://pfaat.sourceforge.net/">Pfaat</a></td>
	<td>Freely available [<a href="http://www.perl.com/pub/a/language/misc/Artistic.html">License (Artistic)</a>]</td>
</tr>

<tr>
	<td align="center"></td>
	<td align="left"><a href="http://insulin.brunel.ac.uk/psiform.html">PSIPred</a></td>
	<td>Freely available (Para 8: "...may be made available...if
	access is granted free of charge...")</td>
</tr>

<tr>
	<td align="center"><img src="../av/poweredby_postgresql.gif"></td>
	<td align="left"><a href="http://www.postgresql.org">PostgreSQL</a>, a full-features OpenSource RDBMDS</td>
	<td>Freely available [<a href="http://www.postgresql.org/about/licence">License (BSD)</a>]</td>
</tr>

<tr>
	<td align="center"><img height=30 src="../av/pymol.gif"></td>
	<td align="left"><a href="http://pymol.sourceforge.net/">PyMOL</a></td>
	<td>Freely available [<a href="http://www.kernel.org/pub/linux/kernel/COPYING">License (GPL)</a>]</td>
</tr>

<tr><th colspan=3 bgcolor="#006699"><font color="white">Other tools from which we've benefitted</font></th></tr>
<tr>
	<td align="center"><img height=30 src="../av/wilber-icon.png" alt="GIMP"></td>
	<td align="left"><a href="http://www.gimp.org">theGIMP</a></td>
	<td>Freely available [<a href="http://www.gnu.org/copyleft/gpl.html">License (GPL)</a></td>
</tr>

<tr>
	<td align="center"><img height=30 src="../av/gnome-logo-icon-transparent.png" alt="GNOME"></td>
	<td align="left"><a href="http://www.gnome.org/">GNOME</a></td>
	<td>Freely available [<a href="http://www.gnu.org/copyleft/gpl.html">License (GPL)</a></td>
</tr>

<tr>
	<td align="center"><img height=30 src="../av/oo-logonew.gif" alt="OpenOffice"></td>
	<td align="left"><a href="http://www.openoffice.org">OpenOffice</a></td>
	<td>Varies [<a href="http://www.openoffice.org/license.html">License</a>]</td>
</tr>



<tr><th colspan=3 bgcolor="#006699"><font color="white">Support</span></th></tr>
<tr>
	<td align="center"><img src="../av/genentech.gif"></td>
	<td colspan=2 align="left"><a href="http://www.gene.com">Genentech Corporate site</a>
			<br><a href="http://share.gene.com/">Genentech Bioinformatics public web pages</a></td>
</tr>

</table>



<h2>References</h2>

<dl>

<dt><b>Bioperl</b></dt>
<dd>The Bioperl toolkit: Perl modules for the life sciences.
<br>Stajich JE, Block D, Boulez K, Brenner SE, Chervitz SA, Dagdigian C, Fuellen G, Gilbert JG, Korf I, Lapp H, Lehvaslaiho H, Matsalla C, Mungall CJ, Osborne BI, Pocock MR, Schattner P, Senger M, Stein LD, Stupka E, Wilkinson MD, Birney E.
<br>Genome Res. Oct;12(10):1611-8 (2002). [<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=pubmed&dopt=Abstract&list_uids=12368254&query_hl=5">PubMed</a>]

<dt><b>BLAST</b></dt>
<dd>Basic local alignment search tool.
<br>Altschul, S.F., Gish, W., Miller, W., Myers, E.W. & Lipman, D.J.
<br>J. Mol. Biol. 215:403-410 (1990).  [<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=PubMed&cmd=Retrieve&list_uids=91039304&dopt=Citation">PubMed</a>]

<dt><b>Gene Ontology</b></dt>
<dd>Gene Ontology: tool for the unification of biology.
<br>The Gene Ontology Consortium
<br>Nature Genet. 25: 25-29 (2000). [<a href="http://www.geneontology.org/GO_nature_genetics_2000.pdf">PDF</a>]

<dt><b>HMMER</b></dt>
<dd>Profile Hidden Markov Models.
<br>S. R. Eddy.
<br>Bioinformatics, 14:755-763 (1998). [<a href="http://selab.wustl.edu/publications/Eddy98/Eddy98-reprint.pdf">PDF</a>]

<dt><b>Pfaat</b></dt>
<dd>Protein family annotation in a multiple alignment viewer
<br>Jason M. Johnson, Keith Mason, Ciamac Moallemi, Hualin Xi, Shyamal Somaroo, and Enoch S. Huang
<br>Bioinformatics 19(4):544-5 (2003). [<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=pubmed&dopt=Abstract&list_uids=12611813">PubMed</a>]

<dt><b>Pfam</b></dt>
<dd>The Pfam Protein Families Database
<br>Alex Bateman, Lachlan Coin, Richard Durbin, Robert D. Finn, Volker Hollich, Sam Griffiths-Jones, Ajay Khanna, Mhairi Marshall, Simon Moxon, Erik L. L. Sonnhammer, David J. Studholme, Corin Yeats and Sean R. Eddy
<br>Nucleic Acids Research Database Issue 32:D138-D141 (2004). [<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=pubmed&dopt=Abstract&list_uids=14681378&query_hl=3">PubMed</a>]

<dt><b>PSIPred</b></dt>
<dd>Protein secondary structure prediction based on position-specific scoring matrices.
<br>Jones, D.T.
<br>J. Mol. Biol. 292:195-202 (1999).

<dt><b>SCOP</b></dt>
<dd>Andreeva A., Howorth D., Brenner S.E., Hubbard T.J.P., Chothia C., Murzin A.G..
<br>SCOP database in 2004: refinements integrate structure and sequence family data.
<br>Nucl. Acid Res. 32:D226-D229 (2004). [<a href="http://scop.mrc-lmb.cam.ac.uk/scop/ref/nar2004.pdf">PDF</a>]

<dt><b>UniProt</b></dt>
<dd>The Universal Protein Resource (UniProt)
<br>Bairoch A, Apweiler R, Wu CH, Barker WC, Boeckmann B, Ferro S, Gasteiger E, Huang H, Lopez R, Magrane M, Martin MJ, Natale DA, O'Donovan C, Redaschi N, Yeh LS
Nucleic Acids Res. 33: D154-159 (2005). [<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=pubmed&dopt=Abstract&list_uids=15608167">PubMed</a>]

</dl>

EOHTML

