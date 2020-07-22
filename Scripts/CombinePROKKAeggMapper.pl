#!/usr/bin/perl
#####################################################################################################
# Name: CombinePROKKAeggMapper.pl

# Author: Rafael Bargiela

# Resume: Patch PROKKA annotation output on .tsv format and eggMapper output file to 
#         combine them in a single file with separate annotations
####################################################################################################
use strict;

#######################################

my %hash; # HASH TO PATCH PROKKA ANNOTATION TSV FILE
my %hash2; # HASH STORE ALL ENTRIES
my %hash3;  # TO PATCH EGGMAPPER ANNOTATION FILE
my %hash4;  # HASH WITH PROKKA ANNOTATION WITHOUT HYPOTHETICAL
my %hash5; # Combine EC numbers

my $head;

open(TB,"<$ARGV[0]") || subdie($ARGV[0]);

while(my $l=<TB>){
  chomp($l);
    my @a=split("\t",$l);
    if($a[1] eq "CDS"){
        my $gene="";
        my $ec="";
        my $def="";
        if($a[2]=~/[a-z]{3}[A-Z]|[a-z]{3}_|[a-z]{3}\d/){
          $gene="$a[2]";
          if($a[3]=~/\d+\.\d+\.\d+\.\d+/ | $a[3]=~/\d+\.\d+\.\d+\.\-/ | $a[3]=~/\d+\.\d+\.\-\.\-/ | $a[3]=~/\d+\.\-\.\-\.\-/){
              $ec="$a[3]";
              $def="$a[4]";            
          }else{
             $def="$a[3]"; 
          }
          $hash{$a[0]}="$gene\t$ec\t$def";
        }elsif($a[2]=~/\d+\.\d+\.\d+\.\d+/ | $a[2]=~/\d+\.\d+\.\d+\.\-/ | $a[2]=~/\d+\.\d+\.\-\.\-/ | $a[2]=~/\d+\.\-\.\-\.\-/){
            $ec="$a[2]";
            $def="$a[3]";
            $hash{$a[0]}="$gene\t$ec\t$def";
        }else{
            $def="$a[2]";
            $hash{$a[0]}="$gene\t$ec\t$def";

        }

    }else{
      next;
    }

}
close(TB);

# Discarding hypothetical proteins from PROKKA annotation
foreach my $en(keys %hash){
  if ($hash{$en}=~/hypothetical protein/i){
    next;
  }else{
    $hash4{$en}="$hash{$en}";
    $hash2{$en}="";
  }
}



# Patching eggMapper annotation file
open (NOG,"<$ARGV[1]") || subdie($ARGV[1]);
  while(my $line=<NOG>){
    chomp($line);
    if($line=~/^#/){
      next;
    }else{
        my @b=split("\t",$line);
        $hash2{$b[0]}="";
        my $egg="$b[1]\t$b[4]\t$b[5]\t$b[6]\t$b[7]\t$b[8]\t$b[9]\t$b[10]\t$b[11]\t$b[12]\t$b[13]\t$b[14]\t$b[15]\t$b[16]\\t$b[18]\t$b[20]\t$b[21]";
        $hash3{$b[0]}=$egg;
    }

  }

close(NOG);


# # # # Combining PROKKA and eggMapper annotations

print "PROTEIN_ID\tGENE\tEC_NUMBER\tEC_definition\teggNOG ortholog\tPredicted taxonomic group\tPredicted protein name\tGene Ontology\tEC_number\tKEGG_KO\tKEGG_pathway\tKEGG_module\tKEGG_Reaction\tKEGG_rclass\tBRITE\tKEGG_TC\tCAZy\teggNOG_OGs\tCOG_cat\teggNOG_description\tCombined_EC_NUMBER\n";

foreach my $prot(sort keys %hash2){
  print "$prot\t";
  my %comEC;
  if(exists $hash4{$prot}){
    print "$hash4{$prot}\t";
    my @c=split("\t",$hash4{$prot});
    $comEC{$c[1]}="";
  }else{
    print "\t\t\t";
  }
  if (exists $hash3{$prot}){
    print "$hash3{$prot}";
    my @d=split("\t",$hash3{$prot});
    my @e=split(",",$d[4]);
    foreach my $ec(@e){
      $comEC{$ec}="";
    }
  }else{
    my $noann="\t" x 19;
    print "$noann";
  }

  my $comEC=join(";",keys %comEC);
  print "\t$comEC\n";
}

exit;

######################################################################################################

sub subdie{

      my $in=$_[0];

      die "
  Couldn't open $in

####################################################################################################
 Name: CombinePROKKAeggMapper.pl

# Author: Rafael Bargiela

# Resume: Patch PROKKA annotation output on .tsv format and eggMapper output file to 
#         combine them in a single file with separate annotations
####################################################################################################

    


";


}

