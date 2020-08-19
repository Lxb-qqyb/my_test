#!/usr/bin/perl -w
use strict;
my ($mutanno,$avin,$amp,$del,$amp_threshold,$del_threshold,$white_amp_threshold,$white_del_threshold,$out) = @ARGV;
open (AV,"$avin");
my %hash;
my $i = 1;
while (<AV>){
	chomp;
	my @all = split /\t/,$_;
	my $site = join "\t",@all[0,1,2];
	my @inf = split /\;/,$all[-1];
	my $inf = "$inf[0]\t$inf[1]\t$inf[2]\t$i\t$inf[3]";
	$i++; 
	$hash{$site} = $inf;
}
close AV;
my %amp;my %del;
open (AMP,"$amp");
while(<AMP>){
	chomp;
	$amp{$_} = 1;
}
close AMP;
open (DEL,"$del");
while(<DEL>){
        chomp;
        $del{$_} = 1;
}
close DEL;
open (IN,"$mutanno");
open (OUT,">$out");
<IN>;
my %gene_ratio;
my $head = "GeneName\tlog2Ratio\tCopyNumber\tCNVType\tGeneType";
print OUT "$head\n";
while (<IN>){
	chomp;
	my @line = split /\t/,$_;
	my $chr = $line[0];
	my $start = $line[1];
	my $end = $line[2];
	my $site = "$chr\t$start\t$end";
	if (exists $hash{$site}){
		my @tmp = split /\t/,$hash{$site};
		my $ratio = $tmp[2];
		my $copy_num = $tmp[0];
		my $cnv_type = $tmp[-1];
		my @genes = split /\,/,$line[6];
		foreach my $genes(@genes){
			push @{$gene_ratio{$genes}},"$ratio\t$copy_num\t$cnv_type";
		}
	} else {	
		print "\n$chr\t$start\t$end can not find copy number information,please check $avin\n\n";
	}
}	
close IN;
foreach my $gene(sort keys %gene_ratio){
	my @v_genes = @{$gene_ratio{$gene}};
	my %h;
	for my $i (@v_genes){
		$h{$i} = 1;
	}
	my @tmp2 = keys %h;
	next if @tmp2 > 1;
	my $gene_stat = shift @v_genes;
	$gene_stat =~ s/cnlr_median=//;
	my @gene_stat = split /\t/,$gene_stat;
#	$gene_stat[0] =~ s/cnlr_median=//;
	my $ratio_gene = $gene_stat[0];
#	$ratio_gene =~ s/cnlr_median=//;
	if (exists $amp{$gene}){
		if($ratio_gene >= $white_amp_threshold){
			print OUT "$gene\t$gene_stat\thotgene\n";
		}
	}elsif (exists $del{$gene}){
		if($ratio_gene <= $white_del_threshold){
                        print OUT "$gene\t$gene_stat\thotgene\n";
                }
	}else{
		if($ratio_gene >= $amp_threshold){
                        print OUT "$gene\t$gene_stat\t.\n";
                }elsif($ratio_gene <= $del_threshold){
			print OUT "$gene\t$gene_stat\t.\n";
		}else{
			next;
		}
	}
}
close OUT;

