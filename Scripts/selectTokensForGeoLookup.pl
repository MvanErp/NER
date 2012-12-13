#!/usr/bin/perl -w

use strict ;
use Lingua::EN::Tokenizer::Offsets qw/token_offsets get_tokens/;
use Encode ; 

open FILE, $ARGV[0] or die "Couldn't open file: $!"; 

my $longstring = "" ;
while(my $file = <FILE>)
	{
	$file = decode_utf8($file) ;
	chomp $file ; 
if($file =~ m/<dc:description.*<\/dc:description>/)
 	{ 
 	$file =~ s/<dc:description.*?>// ; 
	$file =~ s/<\/dc:description>//g; 
	$longstring = $longstring.$file ;
 	}
elsif($file =~ m/<dc:title.*<\/dc:title>/)
	{ 
 	$file =~ s/<dc:title.*?>// ; 
	$file =~ s/<\/dc:title>//g; 
	$longstring = $longstring.$file ;
	}
elsif($file =~ m/<dc:creator.*<\/dc:creator>/)
	{
 	$file =~ s/<dc:creator.*?>// ; 
	$file =~ s/<\/dc:creator>//g; 
	$longstring = $longstring.$file ;
	}
elsif($file =~ m/<dc:contributor.*<\/dc:contributor>/)
	{
 	$file =~ s/<dc:contributor.*?>// ; 
	$file =~ s/<\/dc:contributor>//g; 
	$longstring = $longstring.$file ;
	}
elsif($file =~ m/<dc:subject.*<\/dc:subject>/)
	{
 	$file =~ s/<dc:subject.*?>// ; 
	$file =~ s/<\/dc:subject>//g; 
	$longstring = $longstring.$file ;
	}
elsif($file =~ m/<dc:coverage.*<\/dc:coverage>/)
	{
 	$file =~ s/<dc:coverage.*?>// ; 
	$file =~ s/<\/dc:coverage>//g; 
	$longstring = $longstring.$file ;
	}
elsif($file =~ m/<dcterms:tableOfContents.*<\/dcterms:tableOfContents>/)
	{
 	$file =~ s/<dcterms:tableOfContents.*?>// ; 
	$file =~ s/<\/dcterms:tableOfContents>//g; 
	$longstring = $longstring.$file ;
	}
elsif($file =~ m/<dc:publisher.*<\/dc:publisher>/)
	{
 	$file =~ s/<dc:publisher.*?>// ; 
	$file =~ s/<\/dc:publisher>//g; 
	$longstring = $longstring.$file ; 
	}
}

$longstring =~ s/<ENAMEX TYPE=".*?">//g ;
$longstring =~ s/<\/ENAMEX>//g ;
my $tokens = get_tokens($longstring);
my @array = @$tokens ;

for(my $x = 0 ; $x < @array ; $x++)
	{
	if(substr($array[$x], 0, 1) =~ /[A-Z]/)
		{
		print $array[$x]."\n" ;
		}
	}