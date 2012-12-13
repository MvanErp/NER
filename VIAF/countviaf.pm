
#AUTHOR: Lourens van der Meij, lourens ATT cs.vu.nl

use strict;
use utf8;
use IO::Uncompress::Gunzip;
use XML::Simple qw(:strict);
use Data::Dumper;
use Unicode::Normalize;
binmode(STDOUT, ":utf8");

my @prefixes = ('van','von','de','du','le','del','von der','ten','bin', 'della', 'de la',
    'di', 'el', 'da', 'af', 'van den', 'a', 'ben', 'ter', 'van der', 'zu',
'van de', 'dos', 'um', 'in \'t', 'la', 'ab','vom', 'den', 'de los', 'do',
'des', 'de las', 'zur', 'dal', 'von und zu', 'von dem', 'vander', 'zum', 'im',
'degli', 'lo', 'ag', 'd');
my %prefixesposted = ();
my %avstats = ();
foreach my $p (@prefixes) {
    $prefixesposted{$p} = 1;
}
my %unrecognizedpostfixes = ();

my $input = "results1.txt"; # the name of the results file of extractviaf.pm


open my $istr, "<", $input;
binmode($istr, ":utf8");
my $run = "_c4";   # part of filename, change this for different experiments
my $stopatline = 0;  # if <= 0 do not stop
if ($stopatline > 0) {
    $run = $run."-".$stopatline;
}



open my $rstr, ">", "results$run.txt";
binmode($rstr, ":utf8");

open my $fstr, ">", "names$run.txt";
binmode($fstr, ":utf8");

open my $ostr, ">", "organisations$run.txt";
binmode($ostr, ":utf8");

open my $estr, ">", "errors$run.txt";
binmode($estr, ":utf8");

open my $lstr, ">", "log$run.txt";
binmode($lstr, ":utf8");
sub olog {
    my ($message) = @_;
    print $message;
    print $lstr $message;
}
my $lineno = 0;
my $misseddigits = 0;
my $skipped = 0;
my @content = ();
my $type;
my $varlength;
my $parsedpersons = 0;
my $foundpersons = 0;
my $lindex = 100; # we will expect start of a new cluster if $index < $lindex
# but, apparantly the first index name of a cluster always has content.
while (my $line = <$istr>) {
    $stopatline --;
    if ($stopatline == 0) { last;}
    $lineno++;
    if ($lineno % 100000 == 0) {
	my $prefixcount = scalar(keys %unrecognizedpostfixes);
	print "Line:$lineno ($prefixcount unrecognized postfixes)\n";
    }
    #print $line;
    # combine entry back:
    chomp($line);
    # e.g.person3-2   
    if ($line =~ /^([a-z]*)([0-9]*)-([0-9]*)\t(.*)$/) {
	my $type1 = $1;
	my $varlength1 = $2;  #how many foaf:names in cluster (
	my $index1 = $3;      # name index in cluster, some will not be there
	my $content = $4;
	if ($index1 == 1 || $index1 < $lindex) {
	    if ($index1 != 1) {
		olog("WARNING:Line $lineno has suspect cluster\n");
		# NEVER OCCURRED
	    }
	    if (defined($type)) {  # handle previous cluster
		handleentry($type, $varlength1, \@content);
	    }
	    @content = ();
	    $type = $type1;
	    $varlength = $varlength1;
	}
	push @content, $content;
	if ($type1 != $type) { die "TT";}
	if ($varlength != $varlength1) { die "VL";} 
	$lindex = $index1;
    } else {
	die "Wrong line:$line";
    }
}
close $rstr;
close $estr;
close $fstr;
close $ostr;
olog("$lineno lines, peron names containing digits skipped:$misseddigits\n");
olog("foundpersons:$foundpersons, $parsedpersons parsed persons\n");
olog("Unrecognized postfixes:\n");
foreach my $p (sort {scalar(@{$unrecognizedpostfixes{$b}}) <=> scalar(@{$unrecognizedpostfixes{$a}})} keys %unrecognizedpostfixes) {
    my $cc = scalar(@{$unrecognizedpostfixes{$p}});
    olog(">$p<\t".$cc."\t".join('|',@{$unrecognizedpostfixes{$p}})."\n");
}

sub handleentry {
    my ($type, $length, $content) = @_;
    if ($type eq "person") {
	$foundpersons++;
	handleperson($content);
    } elsif ($type eq "organization") {
	handleorganization($content);
    }
}

# need to detect comma
# need to detect von, van, 
# need to detect letters
#Scotellari, D
#Regaldi, Giuseppe
#Mariotti, G.
#Cohen, Guy.
#Durand, Georges-Matthieu de
=aap
Durand, Georges-Matthieu de, O.P.
De Durand, Georges Matthieu
Durand, G.-M. de
Durand, Georges Matthieu de
Kieffer Capitaine de corvette
Pétillon
Pétillon, René
Bonnefois, Geneviève Pierrat-
Pierrat, Geneviève
Pierrat-Bonnefois, Geneviève
j Bonnefois Geneviève Pierrat-
Starý, Fr.
Starý, František.
Dias, Eduardo Mayone
Dias, Eduardo M.
Mathieu d'Escaudoeuvres Georges Victor Adolphe
Mathieu, Georges French painter, sculptor, designer and illustrator
Georges Mathieu
Mathieu, Georges
Vilches de Frutos, María Francisca
Vilches de Frutos, Ma. Francisca
Fesch Cardinal
Fesch, Joseph, card.
Romulo, Carlos P., Mrs.
Day Romulo, Beth
Lockhart, Jamie Bruce-
Bruce-Lockhart, James Robert
Lestelle, Charles-Henri
---
Bellet, Jocelyne Luiset-
Luiset-Bellet, Jocelyne
Akutagava, Rjunoskè.
Radnóti Aladárné Alföldi Mária
R.-Alföldi, Maria
Alföldi, Maria R.-
R.-Alföldi, Maria.
Alföldi, Maria R.-
Radnóti-Alföldi, Maria
R.-, Maria Alföldi
Radnoti-Alföldi, Maria
Alföldi, Maria Radnoti-
j Alföldi Maria R.-
Alföldi, Maria R.-.
Radnóti-Alföldi, Maria
j Alföldi Maria Radnoti-
Dutruc-Rosset, Daniel
Rosset Daniel Dutruc-
Ozu, Yasujirō Japanese film director
Robert, Jean, docteur en droit
Brabeck, Werner von
Fondern, Manfred van
Van Fonderen, Manfred
Cueto, ... del
Cueto, José A. del
Hazebrouck, Malte van
Kap-herr, Alexander von
Linden, Herman vander.
Linden Herman Vander
Van Der Linden Herman
Vander Linden, Herman
Van der Linden, Herman
Linden, Herman Van der
Der Linden, Herman van
Linden, H. vander
Linden, Herman vander
Linden, Herman van der
Vander Linden, H.
VanDerLinden, Herman
DerLinden, Herman van
Wiel, Henry van der

A lastname:
start with UC, can contain one - followed by UC
or start with 
Van der
Van den
Van Den
parsename
->
{
lastname,
firstnames,
confidence
}

perl character classes regex
perl character classes unicode

confidence last*(0.5+0.5*confidencefirst)

NFC (compact,slow),NFD
=cut

sub parsename {
    my ($input1) = @_;
    #my $input = NFC($input1);
    my $input = $input1;
    my %result = ('input'=>$input,);
    my $confidence = 0;
    my @try1 = split(',',$input);
    my $lconf;
    if (scalar(@try1) == 2) {
	my $f1 = $try1[0];
	my $f2 = $try1[1];
	if ($f1 =~ /^[A-Z][a-z]+(-[A-Z][a-z]+|)$/) {
	    $result{'last'} = $f1;
	    $lconf = 1;
	} elsif ($f1 =~ /^[A-Z][a-z]+-[a-z]+$/) {
	    $result{'last'} = $f1;
	    $lconf = $lconf*0.9;
	} # UTF 
	elsif ($f1 =~ /^\p{Lu}\p{Ll}+(-\p{Lu}\p{Ll}+|)$/) {
	    if (0&&$input =~ /^P.*tillon,.*/) {
		die "okooo";
	    }
	    $result{'last'} = $f1;
	    $lconf = 1;
	} elsif ($f1 =~ /^\p{Lu}\p{Ll}+-\p{Ll}+$/) {
	    $result{'last'} = $f1;
	    $lconf = $lconf*0.9;
	} else {
	    $lconf = 0;
	}

	if ($lconf > 0) {
	    handlefirstnamessetconf($f2, $lconf, \%result,$input1);
	    return \%result;
	}
    } 
    $result{'confidence'} = $confidence;
    return \%result;
}

my $db = 0;
sub handlefirstnamessetconf {
    my ($f2, $lconf, $result, $line) = @_;
    $f2 =~ s/^\s+//;
    $f2 =~ s/\s+$//;
    my @words = split('\s', $f2);
    my $possibleprefix = 0;
    my $skipped = 0;
    my @names = ();
    my $gotlcword = 0;
    my @lcwords = ();
    foreach my $word (@words) {
	if ($gotlcword) {
	    push @lcwords,$word;
	} elsif (!$gotlcword&&$word =~ /^[A-Z]\.?$/) {
	    $skipped++;
	} elsif (!$gotlcword&&$word =~ /^\p{Lu}\.?$/) {
	    $skipped++;
	} else {
	    if (!$gotlcword&& ($word =~ /^[A-Z][a-z]+(-[A-Z][a-z]+)*$/ ||
		$word =~ /^\p{Lu}\p{Ll}+(-\p{Lu}\p{Ll}+)*$/)) {
		if (is_prefixpart($word)) {
		    $gotlcword = 1;
		    push @lcwords,$word;
		} else {
		    push @names, $word;
		}
	    } else {
		# start of non firstname part, accept anything
		$gotlcword = 1;
		push @lcwords,$word; 
	    } 
	}
    }
    if (scalar(@lcwords)) {
	my $p = join(' ',@lcwords);
	# debugging...
=old debugging
Used to initally detect the special characters:
	if (0&&$line =~ /^Hagen, Helmut Peter\s(.*)von(.*)$/) {
	    $db = 1;
	    if ($1 eq "" && $2 eq "") {
		die "SSS";
	    } else {
		if ($1 eq "") {
		    print "1empty\n";
		} else {
		    print "1:".ord($1)."\n";
		}
		if ($2 eq "") {
		    print "2empty\n";
		} else {
		    print "2:".ord($2)."\n";
		}
	    }
	    #die ">$1<,>$line<";
	}
=cut
	if (is_prefixpart($p,$line)) {
	    $result->{'prefix'} = $p;
	} else {
	    push @{$unrecognizedpostfixes{$p}}, $line;
	}
    }
    # NEEDLESSLY complex for now: confidence = scalar(@names) woul give identical results
    $result->{'confidence'} = $lconf*(0.5 + 0.5*(1 - exp(-(scalar(@names)+1))));
    $result->{'firstnames'} = \@names;
}

sub is_prefixpart {
    my ($input,$line) = @_;
    #if ($db) { die "DB:$input";}
    if ($input =~ /(.)(.*)(.)/  ) {
	if (ord($1) == 152 && ord($3) == 156) {  # used as recognizer for prefixes
	    if ($prefixesposted{lc($2)}) {
		#die "FD:$2";
		return 1;
	    } else { print $estr "SUSPECT missing pr:>$input<>$line<";return 0;}
	} else {
	    if ($prefixesposted{lc($input)}) {
#		die "expected guard:>$input<";
		return 1;
	    }
	    return 0;
	}
	
	if ($db) { die ord($1)."PP:>$2<".ord($3);}
	#&& ord($1 == 152)&& ord($3 == 156)
    }
    if ($prefixesposted{lc($input)}) {
	return 1;
    }
    return 0;
}
=todo
What is comfortable name, order according to that
aspect and try to parse best fit.
If multiple first names, order according to most.
Regaldi, Giuseppe OK, BUT, check for prefixes, then accept weak
Radnoti-Alföldi, Maria

Lockhart, Jamie Bruce-  => Bruce-Lockhart, Jamie Robert but lower accuracy
without comma, multiple... discard?
trailing content, but from set:
Linden, Herman van der
Linden, Herman van der. (lower  precision)
trailing content, discard lowercase words, after evaluating them
=cut
sub handleperson {
    my ($content) = @_;
    $content = rmduplicatesrmdates($content);
    print $rstr "---\n";
    my $max = 0;
    my $reschosen;
    # find the cluster entry with most number of recognized first names.
    foreach my $n (@{$content}) {
	
	print $rstr "$n\n";
	my $res = parsename($n);
	my $ln = $res->{'last'};
	if ($res->{'prefix'}) {
	    $ln = $res->{'prefix'}.' '.$ln;
	}
	print $rstr "L:".$ln."\n";
	if ($res->{'firstnames'}) {
	    my $fns = $res->{'firstnames'};
	    print $rstr "F:".join(' ', @{$fns})."\n";
	}
	my $c = $res->{'confidence'};
	print $rstr "C:".$res->{'confidence'}."\n";
	if ($c > $max) {
	    $max = $c;
	    $reschosen = $res;
	}
    }
    if ($reschosen) {
	$parsedpersons++;
	addpersonstat($reschosen);
    } else {
	print $estr "MISSED:\n";
	foreach my $n (@{$content}) {
	    print $estr "$n\n";
	}
    }
}
sub handleorganization {
    my ($content) = @_;
    print $ostr $content->[0]."\n";
}

# NOTHING yet, additional stats.
sub avstat {
    my ($type, $name) = @_;
    return;  #INCOMPLETE
    my $av = $avstats{$type};
    if (!$av) {
	my %re = ();
	$avstats{$type} = \%re;
    }
    
}
sub addpersonstat {
    my ($person) = @_;
    my $ln = $person->{'last'};
    if ($person->{'prefix'}) {
	    $ln = $person->{'prefix'}.' '.$ln;
	}
    avstat('lastname',$ln);
    print $fstr $ln."|";
    if ($person->{'firstnames'}) {
	print $fstr join(' ',@{$person->{'firstnames'}}); 
	foreach my $fn (@{$person->{'firstnames'}}) {
	    avstat('firstname',$fn);
	}
    }
    print $fstr "\n";
}

# remove trailing dates and remove duplicate names after that
#
# 
sub rmduplicatesrmdates {
    my ($content) = @_;
    my %res = ();
    foreach my $val (@{$content}) {
	my $trval = rmdate($val);
	$trval = rmcommapar($trval);
	if (defined($trval)) {
	    $res{$trval}++;
	}
    }
    my @vs = keys %res;
    return \@vs; 
}

sub rmcommapar {
    my ($input) = @_;
    $input =~ s/^\s+//;
    $input =~ s/\s+$//;
    if ($input =~ /^(.*[^\s])[\s]*,$/) {
	$input = $1;
	$input =~ s/\s+$//;
    }
  
    if ($input =~ /^(.*)\(.*\)$/) {
	$input = $1;
	$input =~ s/\s+$//;
    } elsif ($input =~ /^(.*)\(.*$/) {
	$input = $1;
	$input =~ s/\s+$//;
    }
    return $input;
}

# Remove dates and suffix
sub rmdate {
    my ($val) = @_;
    my $outval;
    my $poststring;  # Is ignored, but would point to what was discarded.
    if ($val =~ /^(.*[^,\s])[,]*[\s]*\(?\d{4}\??-\d{4}\)?(|([^0-9]*))\.?$/) {
	$outval = $1;
	if ($3 ne $2) {
	    die "CHOICE:>$val<:  >$1<,>$2<,THREE:>$3<";
	}
	$poststring = $2;
    } elsif ($val =~ /^(.*[^,\s])[,]*[\s]*\(?[\d]+\??-[\d]+\)?(|([^0-9]*))\.?$/) {
	$outval = $1;
	if ($3 ne $2) {
	    die "CHOICE:>$val<:  >$1<,>$2<,THREE:>$3<";
	}
	$poststring = $2;
    } elsif (0&&$val =~ /^(.*)[,]*[\s]*\d{3}([^0-9].*)-\d{3}([^0-9].*)$/) {
	#die "FD:$val";
	$outval = $1;
    } elsif ($val =~ /^(.*)[,]*[\s]*\d{4}-\.\.\.\.$/) {
	$outval = $1;
    } elsif ($val =~ /^(.*)[,]*[\s]*(b\. ca\.|d\.|b\.|born)[\s]*\d{4}$/) {
	$outval = $1;
    } elsif ($val =~ /^(.*)[,]*[\s]*\d{4}-$/) {
	$outval = $1;
    } elsif ($val =~ /^(.*)[,]*[\s]*\(\d{4}\??-\d{4}\)\.?$/) {
	$outval = $1;
    } elsif ($val =~ /^(.*)[,]*[\s]*um \d{4}$/) {
	$outval = $1;
    } elsif ($val =~ /^(.*[^,\s])[,]*[\s]*\(?\d\d\.\.\??-\d\d\.\.\)?(|([^0-9]*))\.?$/) {
	$outval = $1;
	if ($3 ne $2) {
	    die "CHOICE:>$val<:  >$1<,>$2<,THREE:>$3<";
	}
	$poststring = $2;
    } elsif ($val =~ /^(.*[^,\s])[,]*[\s]*\(?\d\d\.\.\??-\.\.\.\.\)?(|([^0-9]*))\.?$/) {
	$outval = $1;
	if ($3 ne $2) {
	    die "CHOICE:>$val<:  >$1<,>$2<,THREE:>$3<";
	}
	$poststring = $2;
    } elsif ($val =~ /^(.*[^,\s])[,]*[\s]*\(?\d\d\d\d\??-\.\.\.\)?(|([^0-9]*))\.?$/) {
	$outval = $1;
	if ($3 ne $2) {
	    die "CHOICE:>$val<:  >$1<,>$2<,THREE:>$3<";
	}
	$poststring = $2;

    } elsif ($val =~ /^(.*[^,\s])[,]*[\s]*\(?\d\d\d\d\??-[\s]*\)?(|([^0-9]*))\.?$/) {
	$outval = $1;
	if ($3 ne $2) {
	    die "CHOICE:>$val<:  >$1<,>$2<,THREE:>$3<";
	}
	$poststring = $2;

    } elsif ($val =~ /^(.*[^,\s])[,]*[\s]*\(?\d\d\d\??-\d\d\d\??\)?(|([^0-9]*))\.?$/) {
	$outval = $1;
	if ($3 ne $2) {
	    die "CHOICE:>$val<:  >$1<,>$2<,THREE:>$3<";
	}
	$poststring = $2;
    } elsif ($val =~ /^(.*[^,\s])[,]*[\s]*\(?[\s]*-\d\d\d\d\??\)?(|([^0-9]*))\.?$/) {
	# -1747
	$outval = $1;
	if ($3 ne $2) {
	    die "CHOICE:>$val<:  >$1<,>$2<,THREE:>$3<";
	}
	$poststring = $2;
    } elsif ($val =~ /^(.*[^,\s])[,]*[\s]*\(?[\s]*-\d\d\d\??\)?(|([^0-9]*))\.?$/) {
	# -811
	$outval = $1;
	if ($3 ne $2) {
	    die "CHOICE:>$val<:  >$1<,>$2<,THREE:>$3<";
	}
	$poststring = $2;
    } elsif ($val =~ /^(.*[^,\s])[,]*[\s]*\(?(ca\.)[\s]*\d\d\d\??-\d\d\d\??\)?\.?$/) {
	# ca. ddd - ddd
	$outval = $1;

    } elsif ($val =~ /^(.*[^,\s])[,]*[\s]*\(\d+th cent\.?\)?(|([^0-9]*))\.?$/) {
	# -811
	$outval = $1;
	if ($3 ne $2) {
	    die "CHOICE:>$val<:  >$1<,>$2<,THREE:>$3<";
	}
	$poststring = $2;
    }  elsif ($val =~ /^(.*[^,\s])[,]*[\s]*\(?(ca\.)?[\s]*\d\d\d\d-(ca\.)?[\s]*\d\d\d\d\??\)?\.?$/) {
	# ca. ddd - ddd
	$outval = $1;
    } elsif ($val =~ /^(.*[^,\s])[,]*[\s]*\((n.|b.|d.)?[\s]*(ca\.)?[\s]*\d\d\d\d\)?\.?$/) {
	# b. ca 1917
	$outval = $1;
    } elsif ($val =~ /^(.*[^,\s])[,]*[\s]*\(?(m.|n.|b.|d.)?[\s]*(ca\.)?[\s]*\d\d\d\d(.*)$/) {
	# b. ca 1917
	$outval = $1;
	$poststring = "JUNK:".$4;
    } else {
	if ($val =~ /[0-9]/) {
	    $misseddigits++;
	    print $estr "MISSED:>$val<\n";
	    if (0&&$misseddigits>10000) {
		die "missed too much($lineno)";
	    }
	} else {
	    return $val;
	}
    }
    if ($outval =~ /\d/) {
	print  $estr "SKIPPED:$val:Is this a name with a digit\n";
	$skipped++;
	return undef;
    }
    if ($poststring) {
#	print $estr "WITH POSTSTRING: $val|$outval|$poststring\n";
    }
    return $outval;
}
