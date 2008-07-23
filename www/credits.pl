#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison;
use Unison::Exceptions;
use Unison::WWW::Page qw(skip_db_connect);


my $p = new Unison::WWW::Page();

print $p->render('Credits', <<EOBODY);
<table class="credits" align="center" width="100%">
  <tr><th colspan=3><font color="white">People</font></th></tr>
  <tr>
	<td>Reece Hart</td>
	<td>Initial concept, overall database design, and web and perl coding.
	  <br>Please <a href="mailto:unison\@unison-db.org">contact Reece</a> with
	  suggestions, bugs, or comments.
	</td>
  </tr>
  <tr>
	<td>David Cavanaugh</td>
	<td>
	BLAT protein-to-genome alignment and miscellaneous programming support.
	</td>
  </tr>
  <tr>
	<td>Kiran Mukhyala</td>
	<td>
	Many features, including JMol structure view, modelset refactoring,
	PMAP protein-to-genome alignment, and genome view.  Also responsible
	for data loading and Genentech internal releases.
	</td>
  </tr>
</table>

<br>

<p>We gratefully acknowledge the following groups and projects for their
freely distributable contributions to the community.  Please cite
appropriate references for any data or methods you use. </p>

<table class="credits" align="center" width="100%">

<!-- TEMPLATE:
<tr>
	<td align="center"></td>
	<td align="left"><a href=""></a></td>
	<td></td>
</tr>
-->

<!--
NOTE ABOUT IMAGES:
Images are included with the Unison web pages because I've had trouble
with changing image urls, ugly rescaling, and variable server
responsiveness.  I often add transparency to images.  If anyone's
particularly offended by this, please send the image link you'd like used
to me (Reece).

All images are rescaled to no larger than 100x30, preserving the aspect ratio.
command used: convert -geometry 100x30 imagein imageout
-->


<!-- ##################### DATA ##################### -->
<tr><th colspan=3><font color="white">Data in Unison</font></th></tr>
<tr>
	<td align="center"><a href="http://www.ensembl.org/">
	  <img width=100 height=26 src="av/ensembl.gif" alt="ensembl">
	  <br>Ensembl</a>
	</td>
	<td align="left">
	  <b>Ensembl 2005</b>
	  <br>Hubbard T, <i>et al.</i>
	  <br>Nucleic Acids Res. 33:D447-D453 (Database Issue) (2005). [<a href="http://nar.oupjournals.org/cgi/content/full/33/suppl_1/D447">Full Text</a>]
	  <br>Freely available [<a href="http://www.geneontology.org/GO.cite.shtml">License</a>]
	</td>
</tr>

<tr>
	<td align="center"><a href="http://www.geneontology.org/">
	  <img width=32 height=30 src="av/GOthumbnail.gif" alt="GO">
	  <br>GeneOntology.org</a>
	</td>
	<td>
	  <b>Gene Ontology: tool for the unification of biology.</b>
	  <br>The Gene Ontology Consortium.
	  <br>Nature Genet. 25: 25-29 (2000). [<a href="http://www.geneontology.org/GO_nature_genetics_2000.pdf">PDF</a>]
	  <br>Freely available [<a href="http://www.geneontology.org/GO.cite.shtml">License</a>]
	</td>
</tr>

<tr>
	<td align="center"><a href="http://www.genenames.org/">
	  <img width=60 height=30 src="av/hgnclogo.png" alt="HGNC">
	  <br>HGNC</a>
	</td>
	<td>
	  <b>HUGO Gene Nomenclature Committee (HGNC)</b>
	  <br>Department of Biology, University College London, Wolfson House
	  <br>4 Stephenson Way, London NW1 2HE, UK
	  <br>http://www.genenames.org/
	  <br>See <a href="about_origins.pl">Unison Origins</a> for
	  download date.
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://mint.bio.uniroma2.it/mint/index.php"><img width=84 height=30 src="av/mint.gif">
	  <br>MINT</a>
	</td>
	<td>
	 <b>MINT: a Molecular INTeraction database</b>
	 <br>Zanzoni A, Montecchi-Palazzi L, Quondam M, Ausiello G, Helmer-Citterich M, Cesareni G 
	 <br>FEBS Lett. 513: 135-140 (2002) [<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=PubMed&list_uids=11911893">PubMed</a>]
	 <br>Freely available for research [<a href="http://mint.bio.uniroma2.it/mint/release/main.php">License</a>]
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://www.ncbi.nlm.nih.gov/"><img width=87 height=30 src="av/ncbi.gif" alt="NCBI">
	  <br>Entrez Gene, HomoloGene, Taxonomy</a>
	</td>
	<td>
	  <b>Database resources of the National Center for Biotechnology Information.</b>
	  <br>Wheeler DL, <i>et al.</i>
	  <br>Nucleic Acids Res. 36:D13-21 (2008). [<a href="http://www.ncbi.nlm.nih.gov/pubmed/18045790">PubMed</a>]
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://www.rcsb.org/pdb"><img width=78 height=30 src="av/pdb.gif">
	  <br>PDB</a></td>
	<td>
	  <b>The Protein Data Bank (PDB)</b>
	  <br>Berman HM, Westbrook J, Feng Z, Gilliland G, Bhat TN, Weissig H, Shindyalov IN, Bourne PE.
	  <br>Nucleic Acids Res. 28: 235-242 (2000). [<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=pubmed&dopt=Abstract&list_uids=10592235">PubMed</a>]
	  <br>Public domain
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://pfam.wustl.edu/"><font face="sans-serif" size="6pt" color="#990000"><strong>Pfam</strong></font></a>
	</td>
	<td>
	  <b>The Pfam Protein Families Database</b>
	  <br>Bateman A, Coin L, Durbin R, Finn RD, Hollich V, Griffiths-Jones S, Khanna A, Marshall M, Moxon S, Sonnhammer ELL, Studholme DJ, Yeats C, Eddy SR
	  <br>Nucleic Acids Research Database Issue 32:D138-D141 (2004). [<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=pubmed&dopt=Abstract&list_uids=14681378&query_hl=3">PubMed</a>]
	  <br>Freely available [<a href="ftp://ftp.genetics.wustl.edu/pub/Pfam/COPYRIGHT">License (GPL)</a>]
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://scop.berkeley.edu/"><img width=94 height=30 src="av/scop.gif" alt="SCOP">
	  <br>SCOP - Structural Classifcation of Proteins</a>
	</td>
	<td>
	  <b>SCOP database in 2004: refinements integrate structure and sequence family data.</b>
	  <br>Andreeva A, Howorth D, Brenner SE, Hubbard TJP, Chothia C, Murzin AG.
	  <br>Nucleic Acid Res. 32:D226-D229 (2004). [<a href="http://scop.mrc-lmb.cam.ac.uk/scop/ref/nar2004.pdf">PDF</a>]
	  <br>Freely available without license after July 1, 2004 [<a href="http://scop.mrc-lmb.cam.ac.uk/scoplic/licence.html">License</a>]
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://string.embl.de/"><img width=36 height=36 src="av/string.gif" alt="STRING">
	  <br>STRING</a>
	</td>
	<td>
	  <b>STRING 7--recent developments in the integration and prediction of protein interactions.</b>
	  <br>von Mering C, Jensen LJ, Kuhn M, Chaffron S, Doerks T, Krüger B, Snel B, Bork P. 
	  <br>Nucleic Acids Res. 35:D358-62 (2006). [<a href="http://www.ncbi.nlm.nih.gov/pubmed/17098935?dopt=Abstract">PubMed</a>]
	  <br>Sequence data released under <a rel="license" href="http://creativecommons.org/licenses/by/3.0/us/">Creative Commons Attribution 3.0 License</a>.
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://www.uniprot.org/"><img width=100 height=25 src="av/UNIPROT.jpg">
	  <br>UniProt</a></td>
	<td>
	  <b>The Universal Protein Resource (UniProt)</b>
	  <br>Bairoch A, Apweiler R, Wu CH, Barker WC, Boeckmann B, Ferro S, Gasteiger E, Huang H, Lopez R, Magrane M, Martin MJ, Natale DA, O'Donovan C, Redaschi N, Yeh LS.
	  <br>Nucleic Acids Res. 33: D154-159 (2005). [<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=pubmed&dopt=Abstract&list_uids=15608167">PubMed</a>]
	  <br>Freely distributable after Jan 1, 2005 [<a href="http://www.pir.uniprot.org/start/faq.shtml#redistribution">License</a>]
	</td>
</tr>


<!-- ##################### SCIENTIFIC SOFTWARE ##################### -->
<tr><th colspan=3><font color="white">Software and algorithms used by Unison</font></th></tr>

<tr>
	<td align="center">
	  <!--a href=""><img width=27 height=30 src="av/.gif" alt=""-->
	  <br>Big-PI GPI prediction</a>
	</td>
	<td>
	  <b>Prediction of potential GPI-modification sites in proprotein sequences</b>
	  <br>Eisenhaber B, Bork P, Eisenhaber F.
	  <br>JMB 292:3, 741-758 (1999).
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://www.bioperl.org/"><img src="av/BioPerlLogo.png"></a>
	</td>
	<td>
	  <b>The Bioperl toolkit: Perl modules for the life sciences.</b>
	  <br>Stajich JE, Block D, Boulez K, Brenner SE, Chervitz SA, Dagdigian C, Fuellen G, Gilbert JG, Korf I, Lapp H, Lehvaslaiho H, Matsalla C, Mungall CJ, Osborne BI, Pocock MR, Schattner P, Senger M, Stein LD, Stupka E, Wilkinson MD, Birney E.
	  <br>Genome Res. 12(10):1611-8 (2002). [<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=pubmed&dopt=Abstract&list_uids=12368254&query_hl=5">PubMed</a>]
	  <br>Freely available [<a href="http://www.bioperl.org/License.shtml">License (Artistic)</a>]
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://www.ncbi.nlm.nih.gov/"><img width=87 height=30 src="av/ncbi.gif" alt="NCBI">
	  <br>NCBI</a>
	</td>
	<td>
	  <b>Basic local alignment search tool.</b>
	  <br>Altschul SF, Gish W, Miller W, Myers EW, Lipman DJ.
	  <br>J. Mol. Biol. 215:403-410 (1990).  [<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=PubMed&cmd=Retrieve&list_uids=91039304&dopt=Citation">PubMed</a>]
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://www.ist.temple.edu/disprot/predictor.php">Disprot VL3H</a>
	</td>
	<td>
	  <b>Predicting intrinsic disorder from amino acid sequence.</b>
	  <br>Obradovic Z, Peng K, Vucetic S, Radivojac P, Brown CJ, Dunker AK.
	  <br>Proteins. 53 Suppl 6:566-72 (2003). [<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=PubMed&list_uids=14579347&dopt=Abstract">PubMed</a>]
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://emboss.sourceforge.net/"><img width=93 height=30 src="av/emboss.png"><br>EMBOSS</a>
	</td>
	<td>
	  <b>EMBOSS: The European Molecular Biology Open Software Suite</b>
	  <br>Rice P, Longden I, Bleasby A.
	  <br>Trends in Genetics 16(6): 276-277 (2000).
	  <br>Freely available [<a href="http://emboss.sourceforge.net/licence/">License (GPL and LGPL)</a>]

	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://www.gene.com/share/gmap/">GMAP/PMAP</a>
	</td>
	<td>
	  <b>GMAP: A Genomic Mapping and Alignment Program for mRNA and EST Sequences</b>
	  <br>Wu TD, Watanabe CK.
	  <br>Bioinformatics 31:1869-75 (2005). [<a href="http://bioinformatics.oupjournals.org/cgi/content/abstract/21/9/1859">Abstract</a> | <a href="http://www.gene.com/share/gmap/paper/gmap.pdf">Manuscript PDF</a>]
	  <br>Freely available [see file `COPYING' in package]
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://hmmer.wustl.edu/"><img width=34 height=30 src="av/hammer_sm.gif" alt="HMMER"><br>HMMER</a>
	</td>
	<td>
	  <b>Profile Hidden Markov Models.</b>
	  <br>Eddy SR.
	  <br>Bioinformatics, 14:755-763 (1998). [<a href="http://selab.wustl.edu/publications/Eddy98/Eddy98-reprint.pdf">PDF</a>]
	  <br>Freely available [<a href="ftp://ftp.genetics.wustl.edu/pub/eddy/hmmer/CURRENT/COPYRIGHT">License (GPL)</a>]
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://jmol.sourceforge.net/"><img width=64 height=30 src="av/jmol.gif"><br>JMol</a>
	</td>
	<td>
	  <a href="http://jmol.sourcefource.net">http://jmol.sourcefource.net</a>
	  <br>Freely available [<a href="http://www.kernel.org/pub/linux/kernel/COPYING">License (GPL)</a>]
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://logicaldepth.com/">Logical Depth</a> HMMer
	</td>
	<td>
	  Accelerated HMMer
	  <br>Freely distributable derived data is identical to Sean Eddy's
	  academic HMMer.
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://www.bioinformaticssolutions.com">Prospect</a>
	</td>
	<td>
	  <b>Protein threading using PROSPECT: Design and evaluation.</b>
	  <br>Xu Y, Xu D.
	  <br>Proteins: Structure, Function, and Genetics. 40(3):343-54 (2000).
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://insulin.brunel.ac.uk/psiform.html">PSIPred</a>
	</td>
	<td>
	  <b>Protein secondary structure prediction based on position-specific scoring matrices.</b>
	  <br>Jones DT.
	  <br>J. Mol. Biol. 292:195-202 (1999).
	  <br>Freely available (Para 8: "...may be made available...if access is granted free of charge...")
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://pymol.sourceforge.net/"><img width=54 height=30 src="av/pymol.gif">
	  <br>PyMOL</a>
	</td>
	<td>
	  <b>The PyMOL Molecular Graphics System</b>
	  <br>DeLano WL.
	  <br><a href="http://www.pymol.org">http://www.pymol.org</a> (2002).
	  <br>Freely available [<a href="http://cvs.sourceforge.net/viewcvs.py/*checkout*/pymol/pymol/LICENSE">License</a>]
	</td>
</tr>

<tr>
	<td align="center">
	  <!--a href=""><img width=27 height=30 src="av/" alt=""-->
	  <br>SignalP 3.0</a>
	</td>
	<td>
	  <b>Improved prediction of signal peptides: SignalP 3.0.</b>
	  <br>Bendtsen JD, Nielsen H, von Heijne G, and Brunak S.
	  <br>J. Mol. Biol., 340:783-795 (2004). [<a href="http://www.cbs.dtu.dk/services/SignalP/paper-3.0.pdf">PDF</a>]
	</td>
</tr>

<tr>
	<td align="center">
	  <a href=""><img width=27 height=30 src="av/tmhmm.gif" alt="TMHMM">
	  <br>TMHMM 2.0c</a>
	</td>
	<td>
	  <b>Predicting Transmembrane Protein Topology with a Hidden Markov Model: Application to Complete Genomes.</b>
	  <br>Krogh A, Larsson B, von Heijne G, and Sonnhammer ELL.
	  <br>J. Mol. Biol. 305:567-580 (2001).
	</td>
</tr>


<!-- ##################### OTHER SOFTWARE ##################### -->
<tr><th colspan=3><font color="white">Other Software used by Unison</font></th></tr>
<tr>
	<td align="center">
	  <a href="http://www.apache.org/"><img width=100 height=28 src="av/feather.gif"><br>Apache web server</a>
	</td>
	<td>
	  Freely available [<a href="http://www.apache.org/licenses/LICENSE-2.0">License (Apache)</a>]
    </td>
</tr>

<tr>
	<td align="center">
	  <a href="http://www.gimp.org"><img width=30 height=30 src="av/wilber-icon.png" alt="GIMP">
	  <br>GIMP</a>
	</td>
	<td>
	  Freely available [<a href="http://www.gnu.org/copyleft/gpl.html">License (GPL)</a>
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://www.gnome.org/"><img width=30 height=30 src="av/gnome-logo-icon-transparent.png" alt="GNOME">
	  <br>GNOME</a>
	</td>
	<td>
	  Freely available [<a href="http://www.gnu.org/copyleft/gpl.html">License (GPL)</a>
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://www.gnu.org"><img width=32 height=30 src="av/gnu-head-sm.png" alt="GNU/FSF"><br>GNU/Free Software Foundation</a> tools
	</td>
	<td>
	  Free, of course [<a href="http://www.gnu.org/licenses/gpl.txt">License (GPL or LGPL)</a>]
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://www.linux.org/"><img width=26 height=30 src="av/linux-penguin-sm.gif" alt="Linux"><br>Linux</a>
	</td>
	<td>
	  Freely available [<a href="http://www.kernel.org/pub/linux/kernel/COPYING">License (GPL)</a>]
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://www.openoffice.org"><img width=100 height=29 src="av/oo-logonew.gif" alt="OpenOffice">
	  <br>OpenOffice</a>
	</td>
	<td>
	  Varies [<a href="http://www.openoffice.org/license.html">License</a>]
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://www.perl.com/"><img width=30 height=30 src="av/camel.png"><br>Perl</a>
	</td>
	<td>
	  Freely available [<a href="http://www.perl.com/pub/a/language/misc/Artistic.html">License (Artistic)</a>]
	</td>
</tr>

<tr>
	<td align="center">
	  <a href="http://www.postgresql.org"><img width=90 height=30 src="av/poweredby_postgresql.gif"><br>PostgreSQL</a>
	</td>
	<td>
	  Freely available [<a href="http://www.postgresql.org/about/licence">License (BSD)</a>]
	</td>
</tr>


<!-- ##################### SUPPORT ##################### -->
<tr><th colspan=3 bgcolor="#006699"><font color="white">Support</span></th></tr>
<tr>
	<td align="center"><a href="http://www.genentech.com/"><img width=116 height=27 src="av/genentech.gif"></a></td>
	<td colspan=2 align="left"><a href="http://www.gene.com">Genentech Corporate site</a>
			<br><a href="http://share.gene.com/">Genentech Bioinformatics public web pages</a></td>
</tr>

</table>	  
	  
EOBODY
