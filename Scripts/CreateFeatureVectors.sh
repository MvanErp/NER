#!/bin/bash 

# To gather the stats for the geographical features, first concatenate all files
# then select only those tokens that are capitalised (to not use up your GeoNames 
# query limit with terms that are not locations) 
echo "Gathering stats for geographical features. Querying GeoNames, this may take a while."
for x in *ner.xml ; do cat $x >> concatenated ; done 
perl selectTokensForGeoLookup.pl concatenated > TokensForGeoNamesQuery

# query GeoNames
perl queryGeonames.pl TokensForGeoNamesQuery GeoFeatures.txt 

# Clean up
rm concatenated 

# Make sure you are not concatenating your output to a previously generated output file
if [ -f Data/EuropeanaMetadata.csv ];
then
    rm Data/EuropeanaMetadata.csv
fi

# Create the tab separated input file 
echo "Writing the features to file. This will take a while."
for x in EuropeanaMetadataAnnotatedNamedEntities/*ner.xml ; do perl GenerateFeatures.pl $x >> Data/EuropeanaMetadata.csv ; echo "$x: done" ;  done  
