
#AUTHOR: Lourens van der Meij, lourens ATT cs.vu.nl
use strict;
use utf8;
use IO::Uncompress::Gunzip;
use XML::Simple qw(:strict);
use Data::Dumper;
binmode(STDOUT, ":utf8");


my %counts = ();





my $viafrdfsource = "viaf-20120524-clusters-rdf.xml";

#open my $vstr, "<", $viafrdfsource;
my $vstr;
open($vstr, "gunzip --stdout $viafrdfsource|")|| die "Missing file $viafrdfsource";
binmode($vstr, ":utf8");

#my $run = "";
my $run = "1";
my $stopatline = 0;  # if <= 0 do not stop
my $stopid;
if ($stopatline > 0) {
    $run = $run."-".$stopatline;
}
open my $rstr, ">", "results$run.txt";
binmode($rstr, ":utf8");
open my $estr, ">", "errors$run.txt";
binmode($estr, ":utf8");
my $lineno = 0;

while (my $line = <$vstr>) {
    $stopatline --;
    if ($stopatline == 0) { last;}
    $lineno++;
    #print $line;
    handlerdfclusterline($line,$lineno);
    if ($lineno % 10000 == 0) {
	print "Line:$lineno\n";
    }
}

print Dumper(\%counts);

sub error {
    my ($text) = @_;
    print $estr  "ERROR:$text\n";
    print "ERROR:$text\n";
}
sub gettypefromtypes {
    my ($types) = @_;
    my %types = ();
    foreach my $res (@{$types}) {
	my $resval = $res->{'rdf:resource'};
	if (!$resval) { 
	    error("no res, skipping whole record\n");
	    return undef;
	} else {
	    $types{$resval}++;
	}
    }
    if ($types{'http://rdvocab.info/uri/schema/FRBRentitiesRDA/Person'}) {
	if (scalar(@{$types}) > 2) {
	    error("no res, skipping whole record");
	    return undef;
	}
	if (!$types{'http://xmlns.com/foaf/0.1/Person'}) {
	    
	    error("suspect person:".Dumper($types));
	    return undef;
	}
	return "person";
    } elsif ($types{'http://rdvocab.info/uri/schema/FRBRentitiesRDA/CorporateBody'}) {
	if (scalar(@{$types}) > 2) {
	    error("extra type:".Dumper($types));
	    return undef;
	}
	if (!$types{'http://xmlns.com/foaf/0.1/Organization'}) {
	    error("suspect org:".Dumper($types));
	    return undef;
	}
	return "organization";
    } elsif ($types{'http://dbpedia.org/ontology/Place'}) {
	if (scalar(@{$types}) > 1) {
	    error("extra type:".Dumper($types));
	    return undef;
	}
	# later addition, earlier had no return, leading to empty string.
	return "place";
    } else {
	error("MISSED TYPES:".Dumper($types));
	return undef;
    }
}

my $didtypeerror = 0;
sub handlerdfclusterline {
    my ($line, $lineno) = @_;
    chomp($line);
    my $pres = XMLin($line, 'ForceArray'=> 1, 'KeyAttr' => "",);
    my $ok = 0;
    foreach my $key (keys %{$pres}) {
	#print "KEY:".$key."\n";
	if ($key =~ /^xmlns:/) {
	} elsif ($key eq 'xml:base') {
	} elsif ($key eq 'skos:Concept') {
	} elsif ($key eq 'foaf:Document') {
	} elsif ($key eq 'rdf:Description') {
	    $ok = 1;
	    my $ok1 = 0;
	    foreach my $descr (@{$pres->{$key}}) {
		my $types = $descr->{'rdf:type'};
		if ($types) {
		    if ($ok1) {
			error("Multiple typed entries:".Dumper($pres));
			return;
		    } else {
			$ok1 = 1;
			$ok = 1;
		    }
		    my $type = gettypefromtypes($types);
		    if (! defined($type)) {
			return;
		    }
		    my $names = $descr->{'foaf:name'};
		    my $nl = scalar(@{$names});
		    my $index = 0;
		    foreach my $name (@{$names}) {
			$index++;
			my $ref = ref $name;
			if ($ref eq 'HASH') {
			    if (scalar(%{$name}) > 0) {
				print Dumper($descr);
				error("HASH:".Dumper($name));
				return;
			    }
			} else {
			    print $rstr "$type$nl-$index\t$name\n";
			    $counts{$type}++;
			} 
		    }
		}
	    }
	    if (!$ok1) { 
		if (!$didtypeerror) {
		    error("missing typed descr".Dumper($pres));
		}
		$didtypeerror++;
	    }
	} else {
	    error("Unexpected prop $key:".Dumper($pres));
	    return;
	}
    }
    if (!$ok) { error("not descr:".Dumper($pres));}
}

close $rstr;
