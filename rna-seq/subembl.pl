#!/usr/local/bin/perl
use Getopt::Long;

use Bio::SeqIO;


GetOptions("infile=s" => \$infile,
	   "start=i" => \$start,
	   "end=i"  => \$end,
	   "identifier=s" => \$ident,
	   "format:s" => \$format
	   );

unless ($infile and $start and $end) {

print <<"OPTIONS";

Options:

-infile       the big embl file
-start        starting nucleotide position
-end          ending nucleotide position
-identifier   identifier to be put in the ID field
             of the output embl file
-format       output format

If the format specified is fasta then just the
sequence is output. If it is embl then the 
associated features are output as well.

OPTIONS

exit;
}

unless ($format) {
$format='fasta';
}




$inembl=Bio::SeqIO->new('-file' => $infile);
$outembl=Bio::SeqIO->new('-fh' => \*STDOUT,
			 -format => $format);

$inseqobj=$inembl->next_seq();

$outseq=$inseqobj->subseq($start, $end);

$outseqobj=Bio::Seq->new('-seq' => $outseq,
			 '-id' => $ident
			);

unless($format=~m/fasta/i) {
@features=$inseqobj->get_all_SeqFeatures();

foreach $feature (@features) {
  unless($feature->primary_tag() =~ m/CDS|tRNA|rRNA/) { next; }
  if($feature->has_tag("product")) {
    $feature->remove_tag("product");
  }
  if($feature->has_tag("note")) {
    $feature->remove_tag("note");
  }
  if($feature->has_tag("gene")) {
    $feature->remove_tag("gene");
  }
  if($feature->has_tag("locus_tag")) {
    my @lt = $feature->remove_tag("locus_tag");
    my $lt = $lt[0]; $lt =~ s/^PFLU/Str26_/;
    $feature->add_tag_value("locus_tag", $lt);
  }

  if($feature->start() > $start and $feature->end() < $end) {
    $oldstart=$feature->start();
    $oldend=$feature->end();
    $newstart=$oldstart-$start+1;
    $newend=$oldend-$start+1;
    $feature->start($newstart);
    $feature->end($newend);
    $outseqobj->add_SeqFeature($feature);
  }


}

}

$outembl->write_seq($outseqobj);
