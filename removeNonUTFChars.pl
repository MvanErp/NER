#!/usr/bin/perl -w 

use strict ;
use HTML::Entities ;
use Lingua::EN::Tokenizer::Offsets qw/token_offsets get_tokens/;
use Encode ;

open FILE, $ARGV[0] or die ("Cannot open file") ;
my $input = join("", <FILE>);

$input =~ s/&amp;/&/g ; 
my $dtext = decode_utf8($text) ; 
print $dtext ;


