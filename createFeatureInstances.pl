#!/usr/bin/perl -w

use strict ; 
use Lingua::Wordnet;
use Lingua::Wordnet::Analysis;
use Lingua::EN::Tokenizer::Offsets qw/token_offsets get_tokens/;
use HTML::Entities ;  
use utf8 ; 
use Encode ; 
use Encode qw(encode_utf8) ;

#print "focus,minthree,mintwo,minone,plusone,plustwo,fnfreq,lnfreq,ncfreq,orgfreq,geo,n,v,a,adv,pn,cap,allcaps,beg,end,length,capfreq,class\n" ;

#### Load the GeoNames values
my %geo ; 
open GEO, "GeoFeatures" or die "Couldn't open file: $! GEO" ; 
while(my $geo = <GEO>)
	{
	chomp $geo ; 
	my @parts = split/\t/,$geo ; 
	if(defined($parts[1]))
		{
		$geo{$parts[0]} = $parts[1] ; 
		}
	else
		{
		$geo{$parts[0]} = "0" ; 
		}
	}
close(GEO) ;

# Check whether this is indeed the location of your WordNet copy
my $wn = new Lingua::Wordnet("/usr/local/WordNet-3.0/dict");
$wn->unlock();

open FILE, $ARGV[0] or die "Couldn't open file: $!"; 
my $filename = $ARGV[0] ;
 
my $texttype = "" ; 
my %ner ;
my @array ;

while(my $file = <FILE>)
	{ 
	$file = decode_utf8($file) ; 
	chomp $file ; 
	if($file =~ m/<dc:description.*<\/dc:description>/)
 		{
 		$texttype = "DESC" ; 
 		$file =~ s/<dc:description.*?>// ; 
		$file =~ s/<\/dc:description>//g; 
 		}
	elsif($file =~ m/<dc:title.*<\/dc:title>/)
		{
		$texttype = "TITLE" ; 
 		$file =~ s/<dc:title.*?>// ; 
		$file =~ s/<\/dc:title>//g; 
		}
	elsif($file =~ m/<dc:creator.*<\/dc:creator>/)
		{
		$texttype = "CREATOR" ; 
 		$file =~ s/<dc:creator.*?>// ; 
		$file =~ s/<\/dc:creator>//g; 
		}
	elsif($file =~ m/<dc:contributor.*<\/dc:contributor>/)
		{
		$texttype = "CREATOR" ; # Creator/contributor
 		$file =~ s/<dc:contributor.*?>// ; 
		$file =~ s/<\/dc:contributor>//g; 
		}
	elsif($file =~ m/<dc:subject.*<\/dc:subject>/)
		{
		$texttype = "SUBJECT" ; 
 		$file =~ s/<dc:subject.*?>// ; 
		$file =~ s/<\/dc:subject>//g; 
		}
	elsif($file =~ m/<dc:coverage.*<\/dc:coverage>/)
		{
		$texttype = "COVERAGE" ; 
 		$file =~ s/<dc:coverage.*?>// ; 
		$file =~ s/<\/dc:coverage>//g; 
		}
	elsif($file =~ m/<dcterms:tableOfContents.*<\/dcterms:tableOfContents>/)
		{
		$texttype = "TOC" ;  # Table of Contents
 		$file =~ s/<dcterms:tableOfContents.*?>// ; 
		$file =~ s/<\/dcterms:tableOfContents>//g; 
		}
	elsif($file =~ m/<dc:publisher.*<\/dc:publisher>/)
		{
		$texttype = "PUB" ;	# Publisher 
 		$file =~ s/<dc:publisher.*?>// ; 
		$file =~ s/<\/dc:publisher>//g; 
		}
	elsif($file =~ m/<dc:source.*<\/dc:source>/)
		{
		$texttype = "PUB" ;	# Publisher or source
 		$file =~ s/<dc:source.*?>// ; 
		$file =~ s/<\/dc:source>//g; 
		}
	else
		{
		next ;
		}

my $longstring = "";     
	
my @parts = split/<ENAMEX TYPE=|<\/ENAMEX>/, $file ; 
		foreach my $part (@parts)
			{ 
			$part =~ s/,/ ,/g ; 
			$part =~ s/\./ \./g ; 
			if ($part =~ m/"PERSON">/)
				{
	#			my $d = ($part =~ tr/ //);
	#			if($d == 0)
	#				{
	#				$part =~ s/$/NERB-PER / ;
	#				}
	#			elsif($d == 1)
	#				{
					$part =~ s/ /NERI-PER /g ;
					$part =~ s/$/NERI-PER /g ;
	#				}
	#			else
	#				{
	#				$part =~ s/ /NERI-PER /g ;
					$part =~ s/NERI-PER/NERB-PER/ ;
	#				$part =~ s/$/NERI-PER / ;
	#				}
				$part =~ s/"PERSON">// ;
				}
			elsif ($part =~ m/"LOCATION">/)
				{
	#			my $d = ($part =~ tr/ //);
	#			if($d == 0)
	#				{
	#				$part =~ s/$/NERB-LOC / ;
	#				}
	#			elsif($d == 1)
	#				{
					$part =~ s/ /NERI-LOC /g ;
					$part =~ s/$/NERI-LOC /g ;
	#				}
	#			else
	#				{
	#				$part =~ s/ /NERI-LOC /g ;
					$part =~ s/NERI-LOC/NERB-LOC/ ;
	#				$part =~ s/$/NERI-LOC / ;
	#				}
				$part =~ s/"LOCATION">// ;
				}
			elsif($part =~ m/"ORGANIZATION">/)
				{
	#	 		my $d = ($part =~ tr/ //);
	#			if($d == 0)
	#				{
	#				$part =~ s/$/NERB-ORG / ;
	#				}
	#			elsif($d == 1)
	#				{
					$part =~ s/ /NERI-ORG /g ;
					$part =~ s/$/NERI-ORG /g ;
	#				}
	#			else
	#				{
	#				$part =~ s/ /NERI-ORG /g ;
					$part =~ s/NERI-ORG/NERB-ORG/ ;
	#				$part =~ s/$/NERI-ORG / ;
	#				}
				$part =~ s/"ORGANIZATION">// ;
				} 
			$part =~ s/^\s/ /;
			$part =~ s/\s$/ /;
			$part =~ s/\s+/ /g ;
		#	print $part."\n" ; 
		#	my $stringtokens = get_tokens($part);     
		#	my @terms = @$stringtokens ;
		#	for(my $x = 0 ; $x < @terms ; $x++)
		#		{
				$longstring = $longstring." ".$part ; 
		#		}
			}

	my $text = $longstring ; 
	my $tokens = get_tokens($text);     
	@array = @$tokens ;
		
# 	for(my $x = 0 ; $x < @array ; $x++)
# 		{
# #		print $array[$x]."\t".length($array[$x])."\n" ;
# 		if($array[$x] =~ /^[A-Z]/)
# 			{
# 			$capitalised++ ;
# 			}
# 		else
# 			{
# 			$noncapitalised++ ;
# 		}
#	}

#######
# First Name Stats
#######
open FN, "FirstNamesFreqs.txt"  or die "Couldn't open file: $! FirstNames" ;
my %fn ; 
while(my $input = <FN>)
	{
	chomp $input ; 
	my @parts = split/\t/,$input ; 
	$fn{$parts[0]} = $parts[1] ;
	}
close FN ;

open LN, "LastNamesFreqs.txt"  or die "Couldn't open file: $! LastNames" ;
my %ln ; 
while(my $input = <LN>)
	{
	chomp $input ; 
	my @parts = split/\t/,$input ; 
	$ln{$parts[0]} = $parts[1] ;
	}
close LN ; 
	
open NC, "nonCapitalsFreqs.txt"  or die "Couldn't open file: $! nonCaps" ;
my %nc ; 
while(my $input = <NC>)
	{
	chomp $input ; 
	my @parts = split/\t/,$input ; 
	$nc{$parts[0]} = $parts[1] ;
	}	
close NC ; 

### Organisation stats
open ORG, "organisationsFreq.txt"  or die "Couldn't open file: orgs"; 
my %orgs ; 
while(my $input = <ORG>)
	{
	chomp $input ; 
	my @parts = split/\t/,$input ; 
	$orgs{$parts[0]} = $parts[1] ;
	}
close ORG ; 

my $capitalised = 0 ;
my $noncapitalised = 0 ; 
my $capitalisedFrequency = 0 ;
for(my $x = 0 ; $x < @array ; $x++)
	{
	if(substr($array[$x], 0, 1) =~ /[A-Z]/)
		{
		$capitalised++ ;
		}
	else
		{
		$noncapitalised++ ;
		}
	}

unless($capitalised == 0)
	{
	$capitalisedFrequency = log($capitalised / (1 + $noncapitalised)) ;
	$capitalisedFrequency = sprintf "%.3f", $capitalisedFrequency;
	}

unshift @array, "_" ;
unshift @array, "_" ;
unshift @array, "_" ;
push @array, "_" ;
push @array, "_" ;
push @array, "_" ;


my $geoarea =  $wn->lookup_synset("geographic_area","n", 1);
my $geo = "$geoarea" ;

my $landmass = $wn->lookup_synset("landmass","n",1);
my $land = "$landmass" ;

my $district = $wn->lookup_synset("district","n",1);
my $dist = "$district" ;

my $body_water = $wn->lookup_synset("body_of_water","n",1);
my $water = "$body_water" ;

my $organization = $wn->lookup_synset("organization","n",5);
my $org = "$organization" ;

my $person = $wn->lookup_synset("person","n",1);
my $per = "$person" ;

for(my $x = 3 ; $x < scalar(@array)-3 ; $x++)
	{
	if($array[$x] =~ m/NER.-PER/ && $array[$x+1] =~ m/,/)
		{
		$array[$x+1] = $array[$x+1]."NERI-PER" ;
#		print $array[$x+1]."\n\n" ;
		}
	}

for(my $x = 3 ; $x < scalar(@array)-3 ; $x++)
	{
	my $featurevector = "" ;
#	print length($array[$x])."\t" ;
	if($array[$x] =~ m/^NER/)
		{
	#	die "$array[$x]";
		shift(@array) ;
		next ;
		}
	if($array[$x] =~ /NERB-PER/)
		{
		$array[$x] =~ s/NERB-PER// ;
	#	print $array[$x]."\t" ; 
		$ner{$x} = "B-PER" ;
		}
	elsif($array[$x] =~ /NERI-PER/)
		{
		$array[$x] =~ s/NERI-PER// ;
	#	print $array[$x]."\t" ; 
		$ner{$x} = "I-PER" ;
		}
	elsif($array[$x] =~ /NERB-LOC/)
		{
		$array[$x] =~ s/NERB-LOC// ; 
	#	print $array[$x]."\t" ; 
		$ner{$x} = "B-LOC" ;
		}
	elsif($array[$x] =~ /NERB-ORG/)
		{
		$array[$x] =~ s/NERB-ORG// ;
	#	print $array[$x]."\t" ; 
		$ner{$x} = "B-ORG" ;
		}
	elsif($array[$x] =~ /NERI-LOC/)
		{
		$array[$x] =~ s/NERI-LOC// ; 
	#	print $array[$x]."\t" ; 
		$ner{$x} = "I-LOC" ;
		}
	elsif($array[$x] =~ /NERI-ORG/)
		{
		$array[$x] =~ s/NERI-ORG// ;
	#	print $array[$x]."\t" ; 
		$ner{$x} = "I-ORG" ;
		}
	#print $array[$x]."\t".$ner{$x}."\n";
	#print VANILLA $array[$x]." " ;
	# Window of 3 preceding and 2 following tokens 
	$featurevector = "\"".$array[$x]."\"\t\"".$array[$x-3]."\"\t\"".$array[$x-2]."\"\t\"".$array[$x-1]."\"\t\"".$array[$x+1]."\"\t\"".$array[$x+2]."\"\t\"".$array[$x+3]."\"\t" ;
	#### Get the FirstName Frequency value 
	if(exists($fn{$array[$x]}))
		{
		$fn{$array[$x]} = sprintf "%.3f", $fn{$array[$x]} ;
		$featurevector = $featurevector."\"".$fn{$array[$x]}."\"\t" ; 
		}
	else 
		{ 
		$featurevector = $featurevector."\"0\"\t" ; 
		}
	#### Get the FirstName Frequency value for the following and preceding tokens  
	if(exists($fn{$array[$x-1]}))
		{
		$fn{$array[$x-1]} = sprintf "%.3f", $fn{$array[$x-1]} ;
		$featurevector = $featurevector."\"".$fn{$array[$x-1]}."\"\t" ; 
		}
	else 
		{ 
		$featurevector = $featurevector."\"0\"\t" ; 
		}	
	if(exists($fn{$array[$x+1]}))
		{
		$fn{$array[$x+2]} = sprintf "%.3f", $fn{$array[$x+1]} ;
		$featurevector = $featurevector."\"".$fn{$array[$x+1]}."\"\t" ; 
		}
	else 
		{ 
		$featurevector = $featurevector."\"0\"\t" ; 
		}	 	
	#####################################	
	#### Get the Last Name Frequency value
	if(exists($ln{$array[$x]}))
		{
		$ln{$array[$x]} =  sprintf "%.3f", $ln{$array[$x]} ;
		$featurevector = $featurevector."\"".$ln{$array[$x]}."\"\t" ; 
		}
	else {$featurevector = $featurevector."\"0\"\t" ; }
	## And also for following and preceding token
	if(exists($ln{$array[$x-1]}))
		{
		$ln{$array[$x-1]} =  sprintf "%.3f", $ln{$array[$x-1]} ;
		$featurevector = $featurevector."\"".$ln{$array[$x-1]}."\"\t" ; 
		}
	else {$featurevector = $featurevector."\"0\"\t" ; }
	if(exists($ln{$array[$x+1]}))
		{
		$ln{$array[$x+1]} =  sprintf "%.3f", $ln{$array[$x+1]} ;
		$featurevector = $featurevector."\"".$ln{$array[$x+1]}."\"\t" ; 
		}
	else {$featurevector = $featurevector."\"0\"\t" ; }
	#### Get the noncapitalised words in Name Frequency value
	if(exists($nc{$array[$x]}))
		{
		$nc{$array[$x]} =  sprintf "%.3f", $nc{$array[$x]} ;
		$featurevector = $featurevector."\"".$nc{$array[$x]}."\"\t" ; 
		}
	else { $featurevector = $featurevector."\"0\"\t" ; }
	## And also for preceding and following token
	if(exists($nc{$array[$x-1]}))
		{
		$nc{$array[$x-1]} =  sprintf "%.3f", $nc{$array[$x-1]} ;
		$featurevector = $featurevector."\"".$nc{$array[$x-1]}."\"\t" ; 
		}
	else { $featurevector = $featurevector."\"0\"\t" ; }
	if(exists($nc{$array[$x+1]}))
		{
		$nc{$array[$x+1]} =  sprintf "%.3f", $nc{$array[$x+1]} ;
		$featurevector = $featurevector."\"".$nc{$array[$x+1]}."\"\t" ; 
		}
	else { $featurevector = $featurevector."\"0\"\t" ; }
	
	#### Get the Organisations frequency value
	if(exists($orgs{$array[$x]}))
		{
		$orgs{$array[$x]} =  sprintf "%.3f", $orgs{$array[$x]} ;
		$featurevector = $featurevector."\"".$orgs{$array[$x]}."\"\t" ; 
		}
	else { $featurevector = $featurevector."\"0\"\t" ; }
	### And also for preceding and following tokens 
		if(exists($orgs{$array[$x-1]}))
		{
		$orgs{$array[$x-1]} =  sprintf "%.3f", $orgs{$array[$x-1]} ;
		$featurevector = $featurevector."\"".$orgs{$array[$x-1]}."\"\t" ; 
		}
	else { $featurevector = $featurevector."\"0\"\t" ; }
		if(exists($orgs{$array[$x+1]}))
		{
		$orgs{$array[$x+1]} =  sprintf "%.3f", $orgs{$array[$x+1]} ;
		$featurevector = $featurevector."\"".$orgs{$array[$x+1]}."\"\t" ; 
		}
	else { $featurevector = $featurevector."\"0\"\t" ; }
	
	#########
	# Check whether the name occurs in geonames
	if(exists($geo{$array[$x]}))
		{
		$geo{$array[$x]} = sprintf "%.3f", $geo{$array[$x]} ;
		$featurevector = $featurevector."\"".$geo{$array[$x]}."\"\t" ; 
		}
	else
		{
		$featurevector = $featurevector."\"0\"\t" ; 
		}
	######### And preceding and following tokens
	if(exists($geo{$array[$x-1]}))
		{
		$geo{$array[$x-1]} = sprintf "%.3f", $geo{$array[$x-1]} ;
		$featurevector = $featurevector."\"".$geo{$array[$x-1]}."\"\t" ; 
		}
	else
		{
		$featurevector = $featurevector."\"0\"\t" ; 
		}
	if(exists($geo{$array[$x+1]}))
		{
		$geo{$array[$x+1]} = sprintf "%.3f", $geo{$array[$x+1]} ;
		$featurevector = $featurevector."\"".$geo{$array[$x+1]}."\"\t" ; 
		}
	else
		{
		$featurevector = $featurevector."\"0\"\t" ; 
		}	
	# Proper Noun
	my $propernoun = &traverse($array[$x]) ;
	$featurevector =$featurevector.$propernoun ;
	my $propernounminus2 = &traverse($array[$x-2]) ;
	$featurevector =$featurevector.$propernounminus2 ;
	my $propernounminus1 = &traverse($array[$x-1]) ;
	$featurevector =$featurevector.$propernounminus1 ;
	my $propernounplus1 = &traverse($array[$x+1]) ;
	$featurevector =$featurevector.$propernounplus1 ;
	# can it be a noun?
	my $np = $wn->lookup_synset(encode_utf8(lc($array[$x])),"n");
	if($np == "0")
		{
		$featurevector = $featurevector."\"0\"\t", ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"\t" ; 
		}
	## Also for the two preceding and one following token
	my $npm2 = $wn->lookup_synset(encode_utf8(lc($array[$x-2])),"n");
	if($npm2 == "0")
		{
		$featurevector = $featurevector."\"0\"\t", ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"\t" ; 
		}
	
	my $npm1 = $wn->lookup_synset(encode_utf8(lc($array[$x-1])),"n");
	if($npm1 == "0")
		{
		$featurevector = $featurevector."\"0\"\t", ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"\t" ; 
		}
	
	my $npp1 = $wn->lookup_synset(encode_utf8(lc($array[$x+1])),"n");
	if($npp1 == "0")
		{
		$featurevector = $featurevector."\"0\"\t", ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"\t" ; 
		}			
		
	# can it be a verb?
	my $v = $wn->lookup_synset(encode_utf8(lc($array[$x])),"v");
	if($v == "0")
		{
		$featurevector = $featurevector."\"0\"\t" ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"\t" ; 
		}
	## Also for the two preceding and one following token 	
	my $vm2 = $wn->lookup_synset(encode_utf8(lc($array[$x-2])),"v");
	if($vm2 == "0")
		{
		$featurevector = $featurevector."\"0\"\t" ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"\t" ; 
		}
	
	my $vm1 = $wn->lookup_synset(encode_utf8(lc($array[$x-1])),"v");
	if($vm1 == "0")
		{
		$featurevector = $featurevector."\"0\"\t" ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"\t" ; 
		}
		
	my $vp1 = $wn->lookup_synset(encode_utf8(lc($array[$x+1])),"v");
	if($vp1 == "0")
		{
		$featurevector = $featurevector."\"0\"\t" ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"\t" ; 
		}
	# can it be an adjective?
	my $adj = $wn->lookup_synset(encode_utf8(lc($array[$x])),"a");
	if($adj == "0")
		{
		$featurevector = $featurevector."\"0\"\t" ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"\t" ; 
		}
	## Also for the two preceding and one following token 	
	my $adjm2 = $wn->lookup_synset(encode_utf8(lc($array[$x-2])),"a");
	if($adjm2 == "0")
		{
		$featurevector = $featurevector."\"0\"\t" ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"\t" ; 
		}
		
	my $adjm1 = $wn->lookup_synset(encode_utf8(lc($array[$x-1])),"a");
	if($adjm1 == "0")
		{
		$featurevector = $featurevector."\"0\"\t" ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"\t" ; 
		}
		
	my $adjp1 = $wn->lookup_synset(encode_utf8(lc($array[$x+1])),"a");
	if($adjp1 == "0")
		{
		$featurevector = $featurevector."\"0\"\t" ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"\t" ; 
		}	
	# can it be an adverb?	
	my $adv = $wn->lookup_synset(encode_utf8(lc($array[$x])),"r");
	if($adv == "0")
		{
		$featurevector = $featurevector."\"0\"\t" ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"\t" ; 
		}
	## Also for the two preceding and one following token 	
	my $advm2 = $wn->lookup_synset(encode_utf8(lc($array[$x-2])),"r");
	if($advm2 == "0")
		{
		$featurevector = $featurevector."\"0\"\t" ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"\t" ; 
		}
	my $advm1 = $wn->lookup_synset(encode_utf8(lc($array[$x-1])),"r");
	if($advm1 == "0")
		{
		$featurevector = $featurevector."\"0\"\t" ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"\t" ; 
		}
	my $advp1 = $wn->lookup_synset(encode_utf8(lc($array[$x+1])),"r");
	if($advp1 == "0")
		{
		$featurevector = $featurevector."\"0\"\t" ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"\t" ; 
		}			
	
	## Is it capitalised?
	if($array[$x] =~ /^[A-Z]/)
		{
		$featurevector = $featurevector."\"1\"\t", ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"\t" ; 
		}
	### Also for two preceding and two following tokens 
	if($array[$x-2] =~ /^[A-Z]/)
		{
		$featurevector = $featurevector."\"1\"\t", ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"\t" ; 
		}
	if($array[$x-1] =~ /^[A-Z]/)
		{
		$featurevector = $featurevector."\"1\"\t", ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"\t" ; 
		}
		if($array[$x+1] =~ /^[A-Z]/)
		{
		$featurevector = $featurevector."\"1\"\t", ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"\t" ; 
		}
	if($array[$x+2] =~ /^[A-Z]/)
		{
		$featurevector = $featurevector."\"1\"\t", ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"\t" ; 
		}		
	## Is fullCaps
	if($array[$x] eq uc($array[$x]))
		{
		$featurevector = $featurevector."\"1\"\t", ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"\t" ; 
		}
	### Also for two preceding and two following tokens 
	if($array[$x-2] eq uc($array[$x-2]))
		{
		$featurevector = $featurevector."\"1\"\t", ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"\t" ; 
		}
	if($array[$x-1] eq uc($array[$x-1]))
		{
		$featurevector = $featurevector."\"1\"\t", ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"\t" ; 
		}
	if($array[$x+1] eq uc($array[$x+1]))
		{
		$featurevector = $featurevector."\"1\"\t", ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"\t" ; 
		}
	if($array[$x+2] eq uc($array[$x+2]))
		{
		$featurevector = $featurevector."\"1\"\t", ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"\t" ; 
		}			
		
	# Beginning of data element
	if($x == 3)
		{
		$featurevector = $featurevector."\"1\"\t" ; 
		}
	else
		{
		$featurevector = $featurevector."\"0\"\t" ; 
		}
	# End of data element
	if($x == (scalar(@array)-3))
		{
		$featurevector = $featurevector."\"1\"\t\"" ; 
		}
	else
		{
		$featurevector = $featurevector."\"0\"\t\"" ; 
		}
	## Token length
	$featurevector = $featurevector.length($array[$x])."\"\t\"" ;
	$featurevector = $featurevector.length($array[$x-3])."\"\t\"" ;
	$featurevector = $featurevector.length($array[$x-2])."\"\t\"" ;
	$featurevector = $featurevector.length($array[$x-1])."\"\t\"" ;
	$featurevector = $featurevector.length($array[$x+1])."\"\t\"" ;
	$featurevector = $featurevector.length($array[$x+2])."\"\t\"" ;
	$featurevector = $featurevector.length($array[$x+3])."\"\t\"" ;
	## Capitalisation Frequency  -0.267383995337804
	$featurevector = $featurevector.$capitalisedFrequency."\"" ;
	### Text type
	$featurevector = $featurevector."\t\"".$texttype."\"\t" ;
	### NER CLASS
	$featurevector =~ s/NER.-PER//g ; 
	$featurevector =~ s/NER.-LOC//g ; 
	$featurevector =~ s/NER.-ORG//g ;
	if(exists($ner{$x}))
		{
		$featurevector = $featurevector."\"".$ner{$x}."\"\n" ; 
		}
	else
		{
		$featurevector = $featurevector."\"O\"\n" ; 
		}
	print $featurevector ;
	delete($ner{$x}) ;
	}

# This is a function to traverse the WordNet tree to see if a term is a propernoun, i.e. whether it is a direct or transitive hyponym of geographic area, landmass, district, body or water, organisation or person 
sub traverse()
	{
	my $term = encode_utf8(lc($_[0])) ;
	#print $term."\t" ;
	my $x = 0 ; 
	my @synset = $wn->lookup_synset($term, "n");
	if(!defined($synset[0]))
		{
		return("\"0\"\t") ;  
		}
	else
		{
		while($x == 0)
			{
			my @hyper = $synset[0]->hypernyms() ;
			if(!defined($hyper[0]))
				{
				return("\"0\"\t") ; 
				$x = 1; 
				}
			else
				{
				my $hype = "$hyper[0]" ;
				if($hype eq $geo || $hype eq $land || $hype eq $dist || $hype eq $water || $hype eq $org || $hype eq $per)
					{
					return("\"1\"\t") ;
					$x = 1; 
					}
				else
					{
					$synset[0] = $hyper[0] ; 
					}
				}
			}
		}
	}

}