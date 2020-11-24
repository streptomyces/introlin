#!/usr/bin/perl
use 5.14.0;
use utf8;
use Carp;
use lib qw(/home/sco /home/sco/mnt/smoke/perllib);
use File::Basename;
use Getopt::Long;
use Sco::Common qw(tablist linelist tablistE linelistE tabhash tabhashE tabvals
    tablistV tablistVE linelistV linelistVE tablistH linelistH
    tablistER tablistVER linelistER linelistVER tabhashER tabhashVER csvsplit);
use File::Spec;
use File::Temp qw(tempfile tempdir);
use Cwd;
use File::Copy;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;
my $command = join(" ", $0, @ARGV);
my $workingdir = getcwd();

# {{{ Getopt::Long
my $indir;
my $fofn;
my $outex; # extension for the output filename when it is derived on infilename.
my $conffile = qq(local.conf);
my $errfile;
my $ip;
my $reportrun = 0;
my $runfile;
my $testCnt = 0;
our $verbose;
my $skip = 0;
my $help;
GetOptions (
"indir:s" => \$indir,
"fofn:s" => \$fofn,
"ip:s" => \$ip,
"extension:s" => \$outex,
"conffile:s" => \$conffile,
"reportrun|rr!" => \$reportrun,
"errfile:s" => \$errfile,
"runfile:s" => \$runfile,
"testcnt:i" => \$testCnt,
"skip:i" => \$skip,
"verbose" => \$verbose,
"help" => \$help
);
# }}}

# {{{ POD

=head1 Name

insert.pl

=head2 Examples

 perl code/insert.pl -ip $fire -- index.html

=head2 Description

=cut

# }}}

if($help) {
exec("perldoc $0");
exit;
}

# {{{ open the errfile
if($errfile) {
open(ERRH, ">", $errfile);
print(ERRH "$0", "\n");
close(STDERR);
open(STDERR, ">&ERRH"); 
}
# }}}

# {{{ Populate %conf if a configuration file 
my %conf;
if(-s $conffile ) {
  open(my $cnfh, "<", $conffile);
  my $keyCnt = 0;
  while(my $line = readline($cnfh)) {
    chomp($line);
    if($line=~m/^\s*\#/ or $line=~m/^\s*$/) {next;}
    my @ll=split(/\s+/, $line, 2);
    $conf{$ll[0]} = $ll[1];
    $keyCnt += 1;
  }
  close($cnfh);
}
elsif($conffile ne "local.conf") {
linelistE("Specified configuration file $conffile not found.");
}
# }}}

# {{{ Temporary directory and template.
my $tempdir = qw(/mnt/volatile);
my $template="replacemeXXXXX";
if(exists($conf{template})) {
  $template = $conf{template};
}
# my($tmpfh, $tmpfn)=tempfile($template, DIR => $tempdir, SUFFIX => '.tmp');
# somewhere later you need to do this
# unlink($tmpfn);
# unlink(glob("$tmpfn*"));
# }}}

# {{{ populate @infiles
my @infiles;
if(-e $fofn and -s $fofn) {
open(FH, "<", $fofn);
while(my $line = readline(FH)) {
chomp($line);
if($line=~m/^\s*\#/ or $line=~m/^\s*$/) {next;}
my $fn;
if($indir) {
$fn = File::Spec->catfile($indir, $line);
}
else {
$fn = $line;
}

push(@infiles, $fn);
}
close(FH);
}
else {
@infiles = @ARGV;
}

# }}}

my $infile = $infiles[0];
my $bakfile = $infile . ".bak";
copy($infile, $bakfile);

my ($noex, $dir, $ext)= fileparse($bakfile, qr/\.[^.]*/);
my $bn = $noex . $ext;
# tablistE($bakfile, $bn, $noex, $ext);
my $ifh;
open($ifh, "<$bakfile") or croak("Could not open $bakfile");

open(my $ofh, ">", $infile);
select $ofh;



my $lineCnt = 0;
while(my $line = readline($ifh)) {
  chomp($line);
  # if($line =~ m/^\s*\#/ or $line =~ m/^\s*$/) {next;}
  if($line =~ m/\d+\.\d+\.\d+\.\d+/) {
    $line =~ s/\d+\.\d+\.\d+\.\d+/$ip/;
  }
  linelist($line);
  $lineCnt += 1;
  if($testCnt and $lineCnt >= $testCnt) { last; }
  if($runfile and (not -e $runfile)) { last; }
}
close($ifh);

exit;

# {{{ sub reportrun
sub reportrun {
  my $fh = shift(@_);
  my $oldfh;
  if($fh) { $oldfh = select($fh); }
  linelist("#RC: $command");
  linelist("#RD: $workingdir");
  my $ts = localtime();
  linelist("#RT: $ts");
  if($oldfh) {
    select($oldfh);
  }
}
# }}}


# Multiple END blocks run in reverse order of definition.
END {
close($ofh);
close(STDERR);
close(ERRH);
# $handle->disconnect();
}

__END__

