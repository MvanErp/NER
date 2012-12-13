#!/usr/bin/perl -w

use strict ; 
use Lingua::Wordnet;
use Lingua::Wordnet::Analysis;
use Lingua::EN::Tokenizer::Offsets qw/token_offsets get_tokens/;
use HTML::Entities ;  
use utf8 ; 
use Encode ; 
use Encode qw(encode_utf8) ;

my $sep = ",";
#print "focus,minthree,mintwo,minone,plusone,plustwo,fnfreq,lnfreq,ncfreq,orgfreq,geo,n,v,a,adv,pn,cap,allcaps,beg,end,length,capfreq,class\n" ;
#print "focus,window,fnfreq,lnfreq,ncfreq,orgfreq,geo,n,v,a,adv,pn,cap,allcaps,beg,end,length,capfreq,class\n" ;

#### Load the GeoNames values
my %geo ; 
open GEO, "../Data/GeoFeatures.txt" or die "Couldn't open file: $! GEO" ; 
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
	$file =~ s/,/ ,/g ; 
	$file =~ s/\./ \./g ; 
	$file =~ s/--/-- /g ;
	$file = "_ _ _".$file."_ _ _" ; 
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
			if ($part =~ m/"PERSON">/)
				{
				$part =~ s/ /NERI-PER /g ;
				$part =~ s/$/NERI-PER /g ;
				$part =~ s/"PERSON">// ;
				}
			elsif ($part =~ m/"LOCATION">/)
				{
				$part =~ s/ /NERI-LOC /g ;
				$part =~ s/$/NERI-LOC /g ;
				$part =~ s/"LOCATION">// ;
				}
			elsif($part =~ m/"ORGANIZATION">/)
				{
				$part =~ s/ /NERI-ORG /g ;
				$part =~ s/$/NERI-ORG /g ;
				$part =~ s/"ORGANIZATION">// ;
				} 
			$part =~ s/^\s/ /;
			$part =~ s/\s$/ /;
			$part =~ s/\s+/ /g ;
			$longstring = $longstring." ".$part ; 
			$longstring =~ s/\s+/ /g ;
			}

	my $text = $longstring ; 
	my $tokens = get_tokens($text);     
	@array = @$tokens ;
	
	for(my $r = 0 ; $r < @array; $r++)
		{
		$array[$r] =~ s/"/DQUOTE/g ;
		$array[$r] =~ s/'/SQUOTE/g ;
		$array[$r] =~ s/,/COMMA/g ;
		}

#######
# First Name Stats
#######
open FN, "../Data/FirstNamesFreqs.txt"  or die "Couldn't open file: $! FirstNames" ;
my %fn ; 
while(my $input = <FN>)
	{
	chomp $input ; 
	my @parts = split/\t/,$input ; 
	$fn{$parts[0]} = $parts[1] ;
	}
close FN ;

open LN, "../Data/LastNamesFreqs.txt"  or die "Couldn't open file: $! LastNames" ;
my %ln ; 
while(my $input = <LN>)
	{
	chomp $input ; 
	my @parts = split/\t/,$input ; 
	$ln{$parts[0]} = $parts[1] ;
	}
close LN ; 
	
open NC, "../Data/nonCapitalsFreqs.txt"  or die "Couldn't open file: $! nonCaps" ;
my %nc ; 
while(my $input = <NC>)
	{
	chomp $input ; 
	my @parts = split/\t/,$input ; 
	$nc{$parts[0]} = $parts[1] ;
	}	
close NC ; 

### Organisation stats
open ORG, "../Data/organisationsFreqs.txt"  or die "Couldn't open file: orgs"; 
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
	$featurevector = "\"".$array[$x]."\"".$sep."\"".$array[$x-3]." ".$array[$x-2]." ".$array[$x-1]." ".$array[$x+1]." ".$array[$x+2]." ".$array[$x+3]."\"".$sep ;
	#### Get the FirstName Frequency value 
	if(exists($fn{$array[$x]}))
		{
		$fn{$array[$x]} = sprintf "%.3f", $fn{$array[$x]} ;
		$featurevector = $featurevector."\"".$fn{$array[$x]}."\"".$sep ; 
		}
	else 
		{ 
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	#### Get the FirstName Frequency value for the following and preceding tokens  
	if($array[$x-1] !~ /[A-Za-z]/)
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	elsif(exists($fn{$array[$x-1]}))
		{
		$fn{$array[$x-1]} = sprintf "%.3f", $fn{$array[$x-1]} ;
		$featurevector = $featurevector."\"".$fn{$array[$x-1]}."\"".$sep ; 
		}
	else 
		{ 
		$featurevector = $featurevector."\"0\"".$sep ; 
		}	
	if($array[$x+1] !~ /[A-Za-z]/)
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	elsif(exists($fn{$array[$x+1]}))
		{
		$fn{$array[$x+1]} = sprintf "%.3f", $fn{$array[$x+1]} ;
		$featurevector = $featurevector."\"".$fn{$array[$x+1]}."\"".$sep ; 
		}
	else 
		{ 
		$featurevector = $featurevector."\"0\"".$sep ; 
		}	 	
	#####################################	
	#### Get the Last Name Frequency value
	if(exists($ln{$array[$x]}))
		{
		$ln{$array[$x]} =  sprintf "%.3f", $ln{$array[$x]} ;
		$featurevector = $featurevector."\"".$ln{$array[$x]}."\"".$sep ; 
		}
	else {$featurevector = $featurevector."\"0\"".$sep ; }
	## And also for following and preceding token
	if($array[$x-1] !~ /[A-Za-z]/)
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	elsif(exists($ln{$array[$x-1]}))
		{
		$ln{$array[$x-1]} =  sprintf "%.3f", $ln{$array[$x-1]} ;
		$featurevector = $featurevector."\"".$ln{$array[$x-1]}."\"".$sep ; 
		}
	else {$featurevector = $featurevector."\"0\"".$sep ; }
	if($array[$x+1] !~ /[A-Za-z]/)
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	elsif(exists($ln{$array[$x+1]}))
		{
		$ln{$array[$x+1]} =  sprintf "%.3f", $ln{$array[$x+1]} ;
		$featurevector = $featurevector."\"".$ln{$array[$x+1]}."\"".$sep ; 
		}
	else {$featurevector = $featurevector."\"0\"".$sep ; }
	#### Get the noncapitalised words in Name Frequency value
	if(exists($nc{$array[$x]}))
		{
		$nc{$array[$x]} =  sprintf "%.3f", $nc{$array[$x]} ;
		$featurevector = $featurevector."\"".$nc{$array[$x]}."\"".$sep ; 
		}
	else { $featurevector = $featurevector."\"0\"".$sep ; }
	## And also for preceding and following token
	if($array[$x-1] !~ /[A-Za-z]/)
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	elsif(exists($nc{$array[$x-1]}))
		{
		$nc{$array[$x-1]} =  sprintf "%.3f", $nc{$array[$x-1]} ;
		$featurevector = $featurevector."\"".$nc{$array[$x-1]}."\"".$sep ; 
		}
	else { $featurevector = $featurevector."\"0\"".$sep ; }
	if($array[$x+1] !~ /[A-Za-z]/)
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	elsif(exists($nc{$array[$x+1]}))
		{
		$nc{$array[$x+1]} =  sprintf "%.3f", $nc{$array[$x+1]} ;
		$featurevector = $featurevector."\"".$nc{$array[$x+1]}."\"".$sep ; 
		}
	else { $featurevector = $featurevector."\"0\"".$sep ; }
	
	#### Get the Organisations frequency value
	if(exists($orgs{$array[$x]}))
		{
		$orgs{$array[$x]} =  sprintf "%.3f", $orgs{$array[$x]} ;
		$featurevector = $featurevector."\"".$orgs{$array[$x]}."\"".$sep ; 
		}
	else { $featurevector = $featurevector."\"0\"".$sep ; }
	### And also for preceding and following tokens 
	if($array[$x-1] !~ /[A-Za-z]/)
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	elsif(exists($orgs{$array[$x-1]}))
		{
		$orgs{$array[$x-1]} =  sprintf "%.3f", $orgs{$array[$x-1]} ;
		$featurevector = $featurevector."\"".$orgs{$array[$x-1]}."\"".$sep ; 
		}
	else { $featurevector = $featurevector."\"0\"".$sep ; }
	if($array[$x+1] !~ /[A-Za-z]/)
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	elsif(exists($orgs{$array[$x+1]}))
		{
		$orgs{$array[$x+1]} =  sprintf "%.3f", $orgs{$array[$x+1]} ;
		$featurevector = $featurevector."\"".$orgs{$array[$x+1]}."\"".$sep ; 
		}
	else { $featurevector = $featurevector."\"0\"".$sep ; }
	
	#########
	# Check whether the name occurs in geonames
	if(exists($geo{$array[$x]}))
		{
		$geo{$array[$x]} = sprintf "%.3f", $geo{$array[$x]} ;
		$featurevector = $featurevector."\"".$geo{$array[$x]}."\"".$sep ; 
		}
	else
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	######### And preceding and following tokens
	if($array[$x-1] !~ /[A-Za-z]/)
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	elsif(exists($geo{$array[$x-1]}))
		{
		$geo{$array[$x-1]} = sprintf "%.3f", $geo{$array[$x-1]} ;
		$featurevector = $featurevector."\"".$geo{$array[$x-1]}."\"".$sep ; 
		}
	else
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	if($array[$x+1] !~ /[A-Za-z]/)
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	elsif(exists($geo{$array[$x+1]}))
		{
		$geo{$array[$x+1]} = sprintf "%.3f", $geo{$array[$x+1]} ;
		$featurevector = $featurevector."\"".$geo{$array[$x+1]}."\"".$sep ; 
		}
	else
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
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
		$featurevector = $featurevector."\"0\"".$sep, ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"".$sep ; 
		}
	## Also for the two preceding and one following token
	my $npm2 = $wn->lookup_synset(encode_utf8(lc($array[$x-2])),"n");
	if($npm2 == "0")
		{
		$featurevector = $featurevector."\"0\"".$sep, ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"".$sep ; 
		}
	
	my $npm1 = $wn->lookup_synset(encode_utf8(lc($array[$x-1])),"n");
	if($npm1 == "0")
		{
		$featurevector = $featurevector."\"0\"".$sep, ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"".$sep ; 
		}
	
	my $npp1 = $wn->lookup_synset(encode_utf8(lc($array[$x+1])),"n");
	if($npp1 == "0")
		{
		$featurevector = $featurevector."\"0\"".$sep, ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"".$sep ; 
		}			
		
	# can it be a verb?
	my $v = $wn->lookup_synset(encode_utf8(lc($array[$x])),"v");
	if($v == "0")
		{
		$featurevector = $featurevector."\"0\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"".$sep ; 
		}
	## Also for the two preceding and one following token 	
	my $vm2 = $wn->lookup_synset(encode_utf8(lc($array[$x-2])),"v");
	if($vm2 == "0")
		{
		$featurevector = $featurevector."\"0\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"".$sep ; 
		}
	
	my $vm1 = $wn->lookup_synset(encode_utf8(lc($array[$x-1])),"v");
	if($vm1 == "0")
		{
		$featurevector = $featurevector."\"0\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"".$sep ; 
		}
		
	my $vp1 = $wn->lookup_synset(encode_utf8(lc($array[$x+1])),"v");
	if($vp1 == "0")
		{
		$featurevector = $featurevector."\"0\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"".$sep ; 
		}
	# can it be an adjective?
	my $adj = $wn->lookup_synset(encode_utf8(lc($array[$x])),"a");
	if($adj == "0")
		{
		$featurevector = $featurevector."\"0\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"".$sep ; 
		}
	## Also for the two preceding and one following token 	
	my $adjm2 = $wn->lookup_synset(encode_utf8(lc($array[$x-2])),"a");
	if($adjm2 == "0")
		{
		$featurevector = $featurevector."\"0\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"".$sep ; 
		}
		
	my $adjm1 = $wn->lookup_synset(encode_utf8(lc($array[$x-1])),"a");
	if($adjm1 == "0")
		{
		$featurevector = $featurevector."\"0\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"".$sep ; 
		}
		
	my $adjp1 = $wn->lookup_synset(encode_utf8(lc($array[$x+1])),"a");
	if($adjp1 == "0")
		{
		$featurevector = $featurevector."\"0\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"".$sep ; 
		}	
	# can it be an adverb?	
	my $adv = $wn->lookup_synset(encode_utf8(lc($array[$x])),"r");
	if($adv == "0")
		{
		$featurevector = $featurevector."\"0\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"".$sep ; 
		}
	## Also for the two preceding and one following token 	
	my $advm2 = $wn->lookup_synset(encode_utf8(lc($array[$x-2])),"r");
	if($advm2 == "0")
		{
		$featurevector = $featurevector."\"0\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"".$sep ; 
		}
	my $advm1 = $wn->lookup_synset(encode_utf8(lc($array[$x-1])),"r");
	if($advm1 == "0")
		{
		$featurevector = $featurevector."\"0\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"".$sep ; 
		}
	my $advp1 = $wn->lookup_synset(encode_utf8(lc($array[$x+1])),"r");
	if($advp1 == "0")
		{
		$featurevector = $featurevector."\"0\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"1\"".$sep ; 
		}			
	
	## Is it capitalised?
	if($array[$x] =~ /^[A-Z]/)
		{
		$featurevector = $featurevector."\"1\"".$sep, ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	### Also for two preceding and two following tokens 
	if($array[$x-2] =~ /^[A-Z]/)
		{
		$featurevector = $featurevector."\"1\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	if($array[$x-1] =~ /^[A-Z]/)
		{
		$featurevector = $featurevector."\"1\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
		if($array[$x+1] =~ /^[A-Z]/)
		{
		$featurevector = $featurevector."\"1\"".$sep;
		}
	else
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	if($array[$x+2] =~ /^[A-Z]/)
		{
		$featurevector = $featurevector."\"1\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}		
	## Is fullCaps
	if($array[$x] eq uc($array[$x]))
		{
		$featurevector = $featurevector."\"1\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	### Also for two preceding and two following tokens 
	if($array[$x-2] eq uc($array[$x-2]))
		{
		$featurevector = $featurevector."\"1\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	if($array[$x-1] eq uc($array[$x-1]))
		{
		$featurevector = $featurevector."\"1\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	if($array[$x+1] eq uc($array[$x+1]))
		{
		$featurevector = $featurevector."\"1\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	if($array[$x+2] eq uc($array[$x+2]))
		{
		$featurevector = $featurevector."\"1\"".$sep ;
		}
	else
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}			
		
	# Beginning of data element
	if($x == 3)
		{
		$featurevector = $featurevector."\"1\"".$sep ; 
		}
	else
		{
		$featurevector = $featurevector."\"0\"".$sep ; 
		}
	# End of data element
	if($x == (scalar(@array)-4))
		{
		$featurevector = $featurevector."\"1\"".$sep."\"" ; 
		}
	else
		{
		$featurevector = $featurevector."\"0\"".$sep."\"" ; 
		}
	## Token length
	$featurevector = $featurevector.length($array[$x])."\"".$sep."\"" ;
	$featurevector = $featurevector.length($array[$x-3])."\"".$sep."\"" ;
	$featurevector = $featurevector.length($array[$x-2])."\"".$sep."\"" ;
	$featurevector = $featurevector.length($array[$x-1])."\"".$sep."\"" ;
	$featurevector = $featurevector.length($array[$x+1])."\"".$sep."\"" ;
	$featurevector = $featurevector.length($array[$x+2])."\"".$sep."\"" ;
	$featurevector = $featurevector.length($array[$x+3])."\"".$sep."\"" ;
	## Capitalisation Frequency  -0.267383995337804
	$featurevector = $featurevector.$capitalisedFrequency."\"" ;
	### Text type
	$featurevector = $featurevector."".$sep."\"".$texttype."\"".$sep ;
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
		return("\"0\"".$sep) ;  
		}
	else
		{
		while($x == 0)
			{
			my @hyper = $synset[0]->hypernyms() ;
			if(!defined($hyper[0]))
				{
				return("\"0\"".$sep) ; 
				$x = 1; 
				}
			else
				{
				my $hype = "$hyper[0]" ;
				if($hype eq $geo || $hype eq $land || $hype eq $dist || $hype eq $water || $hype eq $org || $hype eq $per)
					{
					return("\"1\"".$sep) ;
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