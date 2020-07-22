#!/usr/bin/perl 
####################################################################################################
# Name: Diamond2eggMapper.pl
#
# Author: Rafael Bargiela, PhD. Bangor University. 2019.
#
# Resume: Perl script to transform DIAMOND output as Orthologs file for annotation 
#         process with EggMapper
####################################################################################################
use strict;
####################################################################################################

print "#query_name\tbest_hit_eggNOG_ortholog\tbest_hit_evalue\tbest_hit_score\n";
open(FILE,"<$ARGV[0]") || subdie($ARGV[0]);
  while(my $l=<FILE>){
    chomp($l);
    my @a=split("\t",$l);
    print "$a[0]\t$a[1]\t$a[10]\t$a[11]\n";
  }
close(FILE);

exit;
##############0######################################################################################
sub subdie{

  die"
####################################################################################################
# Name: Diamond2eggMapper.pl
#
# Author: Rafael Bargiela, PhD. Bangor University. 2018.
#
# Resume: Perl script to transform DIAMOND output as Orthologs file for annotation 
#         process with EggMapper
####################################################################################################
  ";
}
