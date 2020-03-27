#!/usr/bin/perl

=head1 NAME

diamond2graph.pl

=head1 AUTHOR

Arnaud MENG PhD student (UPMC-IBPS)

=head1 DESCRIPTION

A Perl utility to transform DIAMOND tabular (TSV) to graph files

    date : 03-2018

=head1 USAGE

    diamond2graph.pl --input <diamond_tsv>

=head1 NOTE

    Only works on DIAMOND results formated as TSV :
    
    6 qseqid qlen qstart qend sseqid slen sstart send length pident ppos score evalue bitscore 	    

=cut

#~ Objective : to obtain two files formated as follow : 

#~ > actors
       #~ name age gender
#~ 1     Alice  48      F
#~ 2       Bob  33      M
#~ 3     Cecil  45      F
#~ 4     David  34      M
#~ 5 Esmeralda  21      F

#~ > relations
       #~ from    to same.dept friendship advice
#~ 1       Bob Alice     FALSE          4      4
#~ 2     Cecil   Bob     FALSE          5      5
#~ 3     Cecil Alice      TRUE          5      5
#~ 4     David Alice     FALSE          2      4
#~ 5     David   Bob     FALSE          1      2
#~ 6 Esmeralda Alice      TRUE          1      3

#~ http://www.inside-r.org/packages/cran/igraph/docs/graph.data.frame

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use File::Basename;

# Retrieving arguments
my $h = 0;
my $help = 0;

# Prefix regex (modify is needed)
my $prefix_regex = "^([A-Za-z0-9\-]+)";

# File variable
my $diamond_tsv;

GetOptions('help|?' => \$help, 
            man => \$h,
           'input=s' => \$diamond_tsv) or pod2usage(2);
            
pod2usage(1) if $help;
pod2usage(-exitval => 0, -verbose => 2) if $h;

# Defining output files names
my $vertices_files = $diamond_tsv . ".vertices";
my $edges_files = $diamond_tsv . ".edges";

# reading DIAMOND file
open(my $fin, '<:encoding(UTF-8)', $diamond_tsv) 
or die "Could not open file '$diamond_tsv' $!";

# defining hash table for vertices and edges
my %vertices = ();
my %edges = ();
my $prefix;

# opening output files
open(my $vfile, '>', $vertices_files) or die "Could not open file $vertices_files' $!";
print $vfile "name;prefix\n";

open(my $efile, '>', $edges_files) or die "Could not open file $edges_files' $!";
print $efile "from;to;query_length;subject_length;alignment_len;pident;evalue;bitscore\n";

while (my $line = <$fin>) {

    chomp $line;
    
    # retrieve line informations
    my @tab = split(/\s+/, $line);

    my $qseqid   = $tab[0];
    my $qlen     = $tab[1];
    my $sseqid   = $tab[4];
    my $slen     = $tab[5];
    my $len      = $tab[8];
    my $pident   = $tab[9];
    my $evalue   = $tab[12];
    my $bitscore = $tab[13];

    # Check if qseqid already exists in vertices
    if (not (exists $vertices{$qseqid})) {
        
        # adding qseqid to vertices
        $prefix = ($qseqid =~ m/$prefix_regex/)[0];
        $vertices{$qseqid} = $prefix;
        print $vfile "$qseqid;$prefix\n";
                    
    }
        
    # Check if sseqid already exists in vertices
    if (not (exists $vertices{$sseqid})) {
                
        # adding sseqid to vertices
        $prefix = ($sseqid =~ m/$prefix_regex/)[0];
        $vertices{$sseqid} = $prefix;
        print $vfile "$sseqid;$prefix\n";
                                
    }
            
    # and adding corresponding edges informations
    print $efile "$qseqid;$sseqid;$qlen;$slen;$len;$pident;$evalue;$bitscore\n";

}
