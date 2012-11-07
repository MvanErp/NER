#!/usr/bin/perl 

use strict ; 
use Geo::GeoNames;
use Data::Dumper;

my $geo = new Geo::GeoNames();

open FILE, $ARGV[0] ; 
open OUTPUT, $ARGV[1] ; 
#my $query = "and" ; 

while(my $query = <FILE>)
	{
	chomp $query ; 
	# make a query based on placename
	my $result = $geo->search(q => $query, maxRows => 1);

	# print the first result
	#print " Name: " . $result->[0]->{name};
	#print " Longitude: " . $result->[0]->{lng};
	#print " Lattitude: " . $result->[0]->{lat};

	#print Dumper($result) ; 

#	sleep(5) ; 
	print $query."\n" ;
    print OUTPUT $query ; 
	if(lc $result->[0]->{name} eq lc $query) 
		{
		if($result->[0]->{fcl} eq "A")
			{
			print OUTPUT "\t1\t".$result->[0]->{geonameId}."\t".$result->[0]->{fcl} ;
			}
		elsif($result->[0]->{fcl} eq "P")
			{
			print OUTPUT  "\t0.8\t".$result->[0]->{geonameId}."\t".$result->[0]->{fcl} ; 
			}
		elsif($result->[0]->{fcl} eq "T" || $result->[0]->{fcl} eq "H")
			{
			print OUTPUT "\t0.6\t".$result->[0]->{geonameId}."\t".$result->[0]->{fcl} ; 
			}
		elsif($result->[0]->{fcl} eq "S" || $result->[0]->{fcl} eq "R"|| $result->[0]->{fcl} eq "V"|| $result->[0]->{fcl} eq "L")
			{
			print OUTPUT "\t0.1\t".$result->[0]->{geonameId}."\t".$result->[0]->{fcl} ; 
			}
		}
	else
		{
		print OUTPUT "\t0\t".$result->[0]->{geonameId}."\t".$result->[0]->{name} ; 
		}
	print OUTPUT "\n" ; 
	#sleep(5) ; 
	}