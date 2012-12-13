#!/bin/bash

# Make sure you have generated the EuropeanaMetadata.csv file in the Data directory by running CreateFeatureVectors.sh in Scripts.

# Also make sure you have stanford-ner-2012-05-22 and stanford-postagger-full-2012-11-11 installed in the NER root directory

### 
#  This is where the POS Tagging takes place
#  
###

cut -f1 -d"," < ../Data/EuropeanaMetadata.csv | sed 's/"//g ' > ../Data/EuopeanaMetadata_onlyTokens.txt 

cut -f59 -d"," < ../Data/EuropeanaMetadata.csv | sed 's/"//g ' > ../Data/EuopeanaMetadata_onlyNERTags.txt 

cd ../stanford-postagger-full-2012-11-11/

java -mx2g -classpath stanford-postagger.jar edu.stanford.nlp.tagger.maxent.MaxentTagger -model models/english-bidirectional-distsim.tagger -textFile OnlyTokens.txt -outputFormat tsv -tokenize false | grep -v "^$" | tr "\t" " " > ../Data/EuopeanaMetadata_TokensAndPOS.txt 

paste -d" " ../Data/EuopeanaMetadata_TokensAndPOS.txt ../Data/EuropeanaMetadata_onlyNERTags.txt > ../Data/EuropeanaMetadata_POS.csv 

# Don't forget to check if the file contains 12510 lines 
split -l 1251 ../Data/EuropeanaMetadata_POS.csv

# Concatenate different parts to create training data 
cat  xab xac xad xae xaf xag xah xai xaj >> ../Data/TrainingRun01StanfordPOS.csv
cat  xaa xac xad xae xaf xag xah xai xaj >> ../Data/TrainingRun02StanfordPOS.csv
cat  xaa xab xad xae xaf xag xah xai xaj >> ../Data/TrainingRun03StanfordPOS.csv
cat  xaa xab xac xae xaf xag xah xai xaj >> ../Data/TrainingRun04StanfordPOS.csv
cat  xaa xab xac xad xaf xag xah xai xaj >> ../Data/TrainingRun05StanfordPOS.csv
cat  xaa xab xac xad xae xag xah xai xaj >> ../Data/TrainingRun06StanfordPOS.csv
cat  xaa xab xac xad xae xaf xah xai xaj >> ../Data/TrainingRun07StanfordPOS.csv
cat  xaa xab xac xad xae xaf xag xai xaj >> ../Data/TrainingRun08StanfordPOS.csv
cat  xaa xab xac xad xae xaf xag xah xaj >> ../Data/TrainingRun09StanfordPOS.csv
cat  xaa xab xac xad xae xaf xag xah xai >> ../Data/TrainingRun10StanfordPOS.csv

# Create test data 
cat  xaa >> ../Data/TestRun01StanfordPOS.csv
cat  xab >> ../Data/TestRun02StanfordPOS.csv
cat  xac >> ../Data/TestRun03StanfordPOS.csv
cat  xad >> ../Data/TestRun04StanfordPOS.csv
cat  xae >> ../Data/TestRun05StanfordPOS.csv
cat  xaf >> ../Data/TestRun06StanfordPOS.csv
cat  xag >> ../Data/TestRun07StanfordPOS.csv
cat  xah >> ../Data/TestRun08StanfordPOS.csv
cat  xai >> ../Data/TestRun09StanfordPOS.csv
cat  xaj >> ../Data/TestRun10StanfordPOS.csv

### 
#  This is where where the NER takes place
#  
###

cd ../stanford-ner-2012-05-22/

## Run 01
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrainPOS.prop -trainFile ../Data/TrainingRun01StanfordPOS.csv -serializeTo ../Data/POSRun1.ser.gz

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/POSRun1.ser.gz -testFile ../Data/TestRun01StanfordPOS.csv > ../Data/Run01_POS.csv

## Run 02
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrainPOS.prop -trainFile ../Data/TrainingRun02StanfordPOS.csv -serializeTo ../Data/POSRun2.ser.gz

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/POSRun2.ser.gz -testFile ../Data/TestRun02StanfordPOS.csv > ../Data/Run02_POS.csv

## Run 03
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrainPOS.prop -trainFile ../Data/TrainingRun03StanfordPOS.csv -serializeTo ../Data/POSRun3.ser.gz 

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/POSRun3.ser.gz -testFile ../Data/TestRun03StanfordPOS.csv > ../Data/Run03_POS.csv

## Run 04
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrainPOS.prop -trainFile ../Data/TrainingRun04StanfordPOS.csv -serializeTo ../Data/POSRun4.ser.gz 

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/POSRun4.ser.gz -testFile ../Data/TestRun04StanfordPOS.csv > ../Data/Run04_POS.csv

## Run 05
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrainPOS.prop -trainFile ../Data/TrainingRun05StanfordPOS.csv -serializeTo ../Data/POSRun5.ser.gz 

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/POSRun5.ser.gz -testFile ../Data/TestRun05StanfordPOS.csv > ../Data/Run05_POS.csv

## Run 06
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrainPOS.prop -trainFile ../Data/TrainingRun06StanfordPOS.csv -serializeTo ../Data/POSRun6.ser.gz 

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/POSRun6.ser.gz -testFile ../Data/TestRun06StanfordPOS.csv > ../Data/Run06_POS.csv

## Run 07
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrainPOS.prop -trainFile ../Data/TrainingRun07StanfordPOS.csv -serializeTo ../Data/POSRun7.ser.gz 


java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/POSRun7.ser.gz -testFile ../Data/TestRun07StanfordPOS.csv > ../Data/Run07_POS.csv

## Run 08
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrainPOS.prop -trainFile ../Data/TrainingRun08StanfordPOS.csv -serializeTo ../Data/POSRun8.ser.gz

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/POSRun8.ser.gz -testFile ../Data/TestRun08StanfordPOS.csv > ../Data/Run08_POS.csv 

## Run 09
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrainPOS.prop -trainFile ../Data/TrainingRun09StanfordPOS.csv -serializeTo ../Data/POSRun9.ser.gz 

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/POSRun9.ser.gz -testFile ../Data/TestRun09StanfordPOS.csv > ../Data/Run09_POS.csv

## Run 10
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrainPOS.prop -trainFile ../Data/TrainingRun10StanfordPOS.csv -serializeTo ../Data/POSRun10.ser.gz 

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/POSRun10.ser.gz -testFile ../Data/TestRun10StanfordPOS.csv > ../Data/Run10_POS.csv

### 
#  This is where where the Evaluation takes place
###

for x in ../Data/Run*_StanfordPOS.csv ; do sed 's/\t/ /g' $x | grep -v "^$" >> ../Data/StanfordPOSSingleFile.csv ; done

cd ../Scripts

perl conlleval.pl < ../Data/StanfordPOSSingleFile.csv > ResultsStanfordPOS.txt

perl conlleval.pl < ../Data/StanfordPOSSingleFile.csv

 

