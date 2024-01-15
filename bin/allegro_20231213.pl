S#!/usr/bin/perl

#########################################################################
##                                                                     ##
##     allegro_20231212.pl                                             ##
##                                                                     ##
##     Alexandre Mathieu                                               ##
##     GHFC                                                            ##
##     Neuroscience Department                                         ##
##     Institut Pasteur Paris                                          ##
##                                                                     ##
##     Gael A. Millot                                                  ##
##     Bioinformatics and Biostatistics Hub                            ##
##     Institut Pasteur Paris                                          ##
##                                                                     ##
#########################################################################



# Start script for genome wide Allegro scan , chromosome by chromosome 
# (c) 2004 Franz Rueschendorf 

# usage: perl allegro_start.pl [chr]

use Cwd;
use strict;
use File::Copy;

my $chr=$ARGV[0];

if ( -d "c$chr") {
	chdir "c${chr}";
	print "Chromosome $chr\n";
	if (-f "allegro.log") {unlink "allegro.log";}
	if (-f "param_mpt.$chr") {unlink "param_mpt.$chr";}
	open (OUT,">allegro.in") || die "could not open allegro.in :$!\n";
 	print OUT "MAXMEMORY  64000\n"; # memory max in GB ???
	print OUT "HAPLOTYPE\n";
	print OUT "PREFILE pedin.$chr\n"; 
	print OUT "DATFILE datain.$chr\n";
	close (OUT);
	system ("allegro allegro.in");
	chdir  ".." ;
}