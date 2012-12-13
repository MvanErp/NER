Persons & Organization extraction from viaf;

1)download viaf-20120524-clusters-rdf.xml.gz from http://viaf.org/viaf/data/
2)Run $ perl extractviaf.pm  (20 h on macbook pro)
3)Run $ perl countviaf.pm   (1h on a macbook)

Results:
-organisations_c3.txt (3869588 organizations)
-names_c3.txt (13933605 names, Surname|First Names)

extractviaf.pm
	perl extractviaf.pm
	Input:
		Expects viaf-20120524-clusters-rdf.xml.gz (downloaded from the 
		web)
		It may be that the file is no longer available from viaf.
		You should download a version from http://viaf.org/viaf/data/.
		and adapt the filename in extractviaf.pm
		
	Output:
		results1.txt
		errors1.txt
	Description:
		Reads viaf-20120524-clusters-rdf.xml content,
		- parses each line as xml
		- analyses the rdf:Description tags:
		We check whether we are dealing with a
		http://rdvocab.info/uri/schema/FRBRentitiesRDA/Person
		http://rdvocab.info/uri/schema/FRBRentitiesRDA/CorporateBody
		http://dbpedia.org/ontology/Place
		leading to $type = person, organisation or place
		and print for each foaf:name entry
		We count number of names: $nl
		$type$nl-$index\t$name
		The file will contain entries:
results1.txt:
KIND		LINE
person1-1       Scotellari, D
person2-1       Regaldi, Giuseppe, 1809-1883
person2-2       Regaldi, Giuseppe
person4-1       Delbet, Jules
person4-2       Delbet, Jules 1836-1910
person4-3       Delbet Charles-Auguste-Jules 1836-1910
person6-1       Bausset-Roquefort, Pierre-François-Gabriel-Raimond-Ferdinand de 1757-1829
person6-2       Bausset-Roquefort, Pierre 1757-1829
person6-3       Bausset-Roquefort, Comte de 1757-1829
person6-5       Roquefort Pierre-François-Gabriel-Raimond-Ferdinand de Bausset- 1757-1829
(missing index values point to empty foaf:name values)
(the complex representation of the KINDs adding person$count-$index was used to
be able to distinguish single entries, alternatives)

STATUS:  A verification run has been done on DEC 6, 2012 with 
extractviaf7dec2012.pm. 
The results: results1.txt :
-rw-r--r--  11 lourens  staff  1521048566 Dec  7 06:09 results1.txt
which will probably not be made available through github. The run took about 
20 h on a macbook pro( 10.7.5, 2.66 GHz Intel core i7, 8GB 1067 MHz DDR3).
	 We will leave this perl-script unchanged for later verification by
	 others. The statistics, output to stdout was copied to a file
	 results/extractviaf.pm.logdec7.2012:
	 Line:21920000
          'person' => 27721757,
          'place' => 769371,
          'organization' => 8807081
	 extractviaf.pm will probably be edited without doing a complete new 
	 run. 

	  
		    
		
	
countviaf.pm
	perl countviaf.pm
	Input:
		results1.txt
	Output:
		* names_c3.txt
		* organisations_c3.txt
		For analysis of the results:
		    errors_c3.txt (mostly unparsed lines)
		    results_c3.txt (all candidate names in a cluster with 
		    their parse result)
		    log_c3.txt: Additional information
log_c3.txt
global statistics followed by unrecognized snippets.
37298209 lines, person names containing digits skipped:282764
foundpersons:16231327, 13933605 parsed persons
Meaning:
37298209 lines were read (organizations, places + persons)
16231327 person clusters
13933605 parsed persons : person clusters with an entry recognized as 
	 containing a surname plus optional first names.

The unrecognized snippets are parts of a line where the parser could
not decide how to split surname/firstname.(598548 such snippets were identified;
the sums do not add up as there are multiple person names per snippet)
In log_c3.txt there are listings of
>SNIPPET<  Numberofoccurrences Line1|Line2|..
ordered by highest occurrence.
(showing how we could improve the name recognition.)



Dcumentation

countviaf.pm
reads the lines from PHASE1:
- parse line
- handleentry($type, $varlength, \@content)
  -> handleperson($content)
  -> handleorganisation($content)

$ perl countviaf8dec.pm took 66 m on a macbook pro.


Lots of way how to optimize the process, most notably use gzipped 
input and output files.

persons:

We determine out of all entries in one cluster the best candidate
for a well recognized first and last name:
all foaf:names in one cluster:
We clean up the set of names:
Each name: we remove trailing dates, with various recognized formats,
           determined experimentally in such a way that we tried to minimize
           resulting names containing numbers. Name containing numbers are
	   skipped. see sub rmdate()
	   we remove trailing comma's, and trailing text starting with a "(".
and we only take unique names: see sub rmduplicatesrmdates()

Then, each name is parsed by parsename($cleanedupstage1name)
resulting in
{
lastname,
firstnames,
confidence
}
A name should contain a single comma
The first part is tested for last name:
UC LC+   optional - UC LC+ /^[A-Z][a-z]+(-[A-Z][a-z]+|)$/
Then, the second part is analysed:
handlefirstnamessetconf():
we check for possible last name prefixes:
we skip all single upper case letters followed by a ".".
we detect special characters indicating a last name prefix.
We put them manually in a list of recognized entries of the kind and 
mark the remaining ones for later analysis.
The confidence simply assures that the person with the highest number
of first names is chosen.

Effectively for now, only names having a single comma
are parsed, and only if it start with upper case letters.
If the part after the comma is recognized as a common last name prefix

These results are printed into results_c3.txt
One single entry from the cluster is
used in the cleaned up set (currently the one with the most first names):
leading to
names_c3.txt  containing:
lastname|firstname1 firstname2 

Organizations are simply copied from the source into 
organisations_c3.txt




