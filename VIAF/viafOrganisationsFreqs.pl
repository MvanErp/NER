#!/usr/bin/perl -w 

use strict ; 
use Encode ;

open FILE, $ARGV[0] ;
open ORGS, "> ../Data/organisationsFreqs.txt" ; 

my %tokens ;

while(my $file = <FILE>)
	{
	$file = decode_utf8($file) ;
	chomp $file ;
	my @words = split/ /,$file ; 
	foreach my $word (@words)
		{ 
		next if($word =~ /[^A-Za-z]/) ; 
		if(exists($tokens{$word}))
			{
			$tokens{$word} = $tokens{$word}+1; 
			}
		else
			{
			$tokens{$word} = 1 ; 
			}
		}
	}

my(%freqstokens) = &realValue(\%tokens) ;
for my $key (keys %freqstokens)
	{
	print ORGS $key."\t".$freqstokens{$key}."\n" ; 
	}


sub realValue()
	{
	my %FN = %{$_[0]} ;
	my $totalFN = 0 ; 
	my $countFN = keys %FN;
	my %results ; 
	
	for my $key (keys %FN)
		{
		#print $key ;
		$totalFN = $totalFN + $FN{$key} ; 
		}

	print $totalFN."\n" ; 

	for my $key (keys %FN)
		{
		my $personFirstName = log(1 + $FN{$key} / (($totalFN - $FN{$key}) / $countFN) ) ;
		#print $key."\t".$personFirstName."\n" ; 
		$results{$key} = $personFirstName  ;
		}
	return (%results) ; 
	}