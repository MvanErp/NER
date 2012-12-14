#!/bin/bash

# Make sure you have generated the EuropeanaMetadata.csv file in the Data directory by running CreateFeatureVectors.sh in Scripts.

# Also make sure you have stanford-ner-2012-05-22 and stanford-postagger-full-2012-11-11 installed in the NER directory as well as the conll.distsim.iob2.crf.ser.gz model installed in the stanford-ner-2012-05-22/classifiers folder. This model is available from http://nlp.stanford.edu/software/conll.distsim.iob2.crf.ser.gz

### 
#  This is where the POS Tagging takes place
#  
###

cut -f1 -d"," < ../Data/EuropeanaMetadata.csv | sed 's/"//g ' > ../Data/EuopeanaMetadata_onlyTokens.txt 

cut -f59 -d"," < ../Data/EuropeanaMetadata.csv | sed 's/"//g ' > ../Data/EuopeanaMetadata_onlyNERTags.txt 

cd ../stanford-postagger-full-2012-11-11/

java -mx2g -classpath stanford-postagger.jar edu.stanford.nlp.tagger.maxent.MaxentTagger -model models/english-bidirectional-distsim.tagger -textFile ../Data/EuopeanaMetadata_onlyTokens.txt  -outputFormat tsv -tokenize false | grep -v "^$" | tr "\t" " " > ../Data/EuopeanaMetadata_TokensAndPOS.txt 

paste -d" " ../Data/EuopeanaMetadata_TokensAndPOS.txt ../Data/EuopeanaMetadata_onlyNERTags.txt > ../Data/EuropeanaMetadata_POS.csv 

cd ../stanford-ner-2012-05-22/

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier classifiers/conll.distsim.iob2.crf.ser.gz -testFile ../Data/EuropeanaMetadata_POS.csv | cut -f1,4,5 | sed 's/\t/ /g' | grep -v "^$" > ../Data/StanfordBaseline.csv

perl ../Scripts/conlleval.pl < ../Data/StanfordBaseline.csv 






