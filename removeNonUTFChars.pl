#!/usr/bin/perl -w 

use strict ;
use HTML::Entities ;
use Lingua::EN::Tokenizer::Offsets qw/token_offsets get_tokens/;
use Encode ;

open FILE, $ARGV[0] or die ("Cannot open file") ;
my $input = join("", <FILE>);

$input =~ s/&amp;/&/g ; 
my $text = decode_entities($input);
my $dtext = decode_utf8($text) ; 
# $dtext = unidecode($text) ;
print $dtext ;

exit ; 

#$dtext =~ s/<ENAMEX TYPE=.*?>//g ; 
#$dtext =~ s/<\/ENAMEX>//g ; 

my $string = $dtext ;
#if($dtext =~ m/<dc:description .*<\/dc:description>/)
#	{
#	$string = $& ; 
#	}

#$string =~ s/<dc:description lang=.*?>// ; 
#$string =~ s/<\/dc:description>//g; 

my $longstring = "" ;
	
my @parts = split/<ENAMEX TYPE=|<\/ENAMEX>/, $string ; 
		foreach my $part (@parts)
			{ 
			#print $part."\t" ; 
			if ($part =~ m/"PERSON">/)
				{
				$part =~ s/ /NERPERSON /g ;
				$part =~ s/$/NERPERSON /g ;
				$part =~ s/"PERSON">// ;
			#	print $part."\n" ; 
				}
			elsif ($part =~ m/"LOCATION">/)
				{
				$part =~ s/ /NERLOCATION /g ;
				$part =~ s/$/NERLOCATION /g ;
				$part =~ s/"LOCATION">// ;
				}
			elsif ($part =~ m/"ORGANIZATION">/)
				{
				$part =~ s/ /NERORGANIZATION /g ;
				$part =~ s/$/NERORGANIZATION /g ;
				$part =~ s/"ORGANIZATION">// ;
				} 
			$part =~ s/^\s/ /;
			$part =~ s/\s$/ /;
			$part =~ s/\s+/ /g ;	
			my $stringtokens = get_tokens($part);     
			my @terms = @$stringtokens ;
			for(my $x = 0 ; $x < @terms ; $x++)
				{
				$longstring = $longstring." ".$terms[$x] ; 
				}
			}
			
my $tokens = get_tokens($longstring);  

my @array = @$tokens ;

for(my $x = 0 ; $x < @array ; $x++)
	{
	#$array[$x] =~ s/[^[:ascii:]]+//g;
	$array[$x] =~ s/NERPERSON/\tPERSON/g;
	$array[$x] =~ s/NERLOCATION/\tLOCATION/g;
	$array[$x] =~ s/NERORGANIZATION/\tORGANIZATION/g;
	if($array[$x] !~ /\t/)
		{
		$array[$x] = $array[$x]."\tO" ; 
		}
	print $array[$x]."\n" ;
	}
