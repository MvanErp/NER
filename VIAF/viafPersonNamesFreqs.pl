#!/usr/bin/perl -w 

use strict ; 
use Encode ; 

open FILE, $ARGV[0] ;
open FNAMES, "> ../Data/FirstNamesFreqs.txt " ;
open LNAMES, "> ../Data/LastNamesFreqs.txt" ;
open NCAPS, "> ../Data/noncapitalsFreqs.txt" ;

my %fntokens ;
my %lntokens ;
my %nctokens ;

while(my $file = <FILE>)
	{
	chomp $file ;
	$file = decode_utf8($file) ;
	my @words = split/\|/,$file ; 
	if(defined($words[1]))
		{
		my @fnnames = split/ /, $words[1] ;
		foreach my $word (@fnnames)
 			{ 
 			next if($word =~ /[^A-Za-z]/) ;
 			if(substr($word,0,1) =~ /[a-z]/)
 				{
 				if(exists($nctokens{$word}))
 					{
 					$nctokens{$word} = $nctokens{$word} + 1 ;
 					}
 				else
 					{
 					$nctokens{$word} = 1 ; 
 					} 
 				}
 			if(exists($fntokens{$word}))
 				{
 				$fntokens{$word} = $fntokens{$word}+1; 
 				}
 			else
 				{
 				$fntokens{$word} = 1 ; 
 				}
 			}
 		}
 	if(defined($words[0]))
 		{
 		my @lnnames = split/ /, $words[0] ; 
 		foreach my $word (@lnnames)
 			{ 
 			next if($word =~ /[^A-Za-z]/) ;
 			if(substr($word,0,1) =~ /[a-z]/)
 				{
 				if(exists($nctokens{$word}))
 					{
 					$nctokens{$word} = $nctokens{$word} + 1 ;
 					}
 				else
 					{
 					$nctokens{$word} = 1 ; 
 					}
 				} 
 			elsif(exists($lntokens{$word}))
 				{
 				$lntokens{$word} = $lntokens{$word}+1; 
 				}
 			else
 				{
 				$lntokens{$word} = 1 ; 
 				}
 			}
		}
	}
	
my(%freqsfntokens) = &realValue(\%fntokens) ;
for my $key (keys %freqsfntokens)
	{
	print FNAMES $key."\t".$freqsfntokens{$key}."\n" ; 
	}
	
my(%freqslntokens) = &realValue(\%lntokens) ;
for my $key (keys %freqslntokens)
 	{
 	print LNAMES $key."\t".$freqslntokens{$key}."\n" ; 
 	}
 
my(%freqsnctokens) = &realValue(\%nctokens) ;
for my $key (keys %freqsnctokens)
 	{
 	print NCAPS $key."\t".$freqsnctokens{$key}."\n" ; 
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