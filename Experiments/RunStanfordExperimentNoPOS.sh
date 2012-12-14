#!/bin/bash

# Make sure you have generated the EuropeanaMetadata.csv file in the Data directory by running CreateFeatureVectors.sh in Scripts.

# Also make sure you have stanford-ner-2012-05-22 installed in the NER root directory

# Check if the file contains 12510 lines 
split -l 1251 ../Data/EuropeanaMetadata.csv 

# Concatenate different parts to create training data 
cat  xab xac xad xae xaf xag xah xai xaj | sed 's/ //g ; s/"//g ; s/,/ /g' | cut -f1,59 -d" " >> ../Data/TrainingRun01StanfordNoPOS.csv
cat  xaa xac xad xae xaf xag xah xai xaj | sed 's/ //g ; s/"//g ; s/,/ /g' | cut -f1,59 -d" "  >> ../Data/TrainingRun02StanfordNoPOS.csv
cat  xaa xab xad xae xaf xag xah xai xaj | sed 's/ //g ; s/"//g ; s/,/ /g'| cut -f1,59 -d" "  >> ../Data/TrainingRun03StanfordNoPOS.csv
cat  xaa xab xac xae xaf xag xah xai xaj | sed 's/ //g ; s/"//g ; s/,/ /g' | cut -f1,59 -d" "  >> ../Data/TrainingRun04StanfordNoPOS.csv
cat  xaa xab xac xad xaf xag xah xai xaj  | sed 's/ //g ; s/"//g ; s/,/ /g'| cut -f1,59 -d" " >> ../Data/TrainingRun05StanfordNoPOS.csv
cat  xaa xab xac xad xae xag xah xai xaj  | sed 's/ //g ; s/"//g ; s/,/ /g' | cut -f1,59 -d" " >> ../Data/TrainingRun06StanfordNoPOS.csv
cat  xaa xab xac xad xae xaf xah xai xaj  | sed 's/ //g ; s/"//g ; s/,/ /g' | cut -f1,59 -d" " >> ../Data/TrainingRun07StanfordNoPOS.csv
cat  xaa xab xac xad xae xaf xag xai xaj | sed 's/ //g ; s/"//g ; s/,/ /g' | cut -f1,59 -d" " >> ../Data/TrainingRun08StanfordNoPOS.csv
cat  xaa xab xac xad xae xaf xag xah xaj  | sed 's/ //g ; s/"//g ; s/,/ /g' | cut -f1,59 -d" " >> ../Data/TrainingRun09StanfordNoPOS.csv
cat  xaa xab xac xad xae xaf xag xah xai  | sed 's/ //g ; s/"//g ; s/,/ /g' | cut -f1,59 -d" " >> ../Data/TrainingRun10StanfordNoPOS.csv

# 
cat  xaa | sed 's/ //g ; s/"//g ; s/,/ /g' | cut -f1,59 -d" " >> ../Data/TestRun01StanfordNoPOS.csv
cat  xab | sed 's/ //g ; s/"//g ; s/,/ /g' | cut -f1,59 -d" " >> ../Data/TestRun02StanfordNoPOS.csv
cat  xac | sed 's/ //g ; s/"//g ; s/,/ /g' | cut -f1,59 -d" " >> ../Data/TestRun03StanfordNoPOS.csv
cat  xad | sed 's/ //g ; s/"//g ; s/,/ /g' | cut -f1,59 -d" " >> ../Data/TestRun04StanfordNoPOS.csv
cat  xae | sed 's/ //g ; s/"//g ; s/,/ /g' | cut -f1,59 -d" " >> ../Data/TestRun05StanfordNoPOS.csv
cat  xaf | sed 's/ //g ; s/"//g ; s/,/ /g' | cut -f1,59 -d" " >> ../Data/TestRun06StanfordNoPOS.csv
cat  xag | sed 's/ //g ; s/"//g ; s/,/ /g' | cut -f1,59 -d" " >> ../Data/TestRun07StanfordNoPOS.csv
cat  xah | sed 's/ //g ; s/"//g ; s/,/ /g' | cut -f1,59 -d" " >> ../Data/TestRun08StanfordNoPOS.csv
cat  xai | sed 's/ //g ; s/"//g ; s/,/ /g' | cut -f1,59 -d" " >> ../Data/TestRun09StanfordNoPOS.csv
cat  xaj | sed 's/ //g ; s/"//g ; s/,/ /g' | cut -f1,59 -d" " >> ../Data/TestRun10StanfordNoPOS.csv

### 
#  This is where the NER takes place  
#  
###

cd ../stanford-ner-2012-05-22/

## Run 01
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrain.prop -trainFile ../Data/TrainingRun01StanfordNoPOS.csv -serializeTo ../Data/StanfordNoPOSRun1.ser.gz 

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/StanfordNoPOSRun1.ser.gz -testFile ../Data/TestRun01StanfordNoPOS.csv > ../Data/Run01_StanfordNoPOS.csv

## Run 02
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrain.prop -trainFile ../Data/TrainingRun02StanfordNoPOS.csv -serializeTo ../Data/StanfordNoPOSRun2.ser.gz

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/StanfordNoPOSRun2.ser.gz -testFile ../Data/TestRun02StanfordNoPOS.csv > ../Data/Run02_StanfordNoPOS.csv

## Run 03
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrain.prop -trainFile ../Data/TrainingRun03StanfordNoPOS.csv -serializeTo ../Data/StanfordNoPOSRun3.ser.gz 

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/StanfordNoPOSRun3.ser.gz -testFile ../Data/TestRun03StanfordNoPOS.csv > ../Data/Run03_StanfordNoPOS.csv

## Run 04
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrain.prop -trainFile ../Data/TrainingRun04StanfordNoPOS.csv -serializeTo ../Data/StanfordNoPOSRun4.ser.gz 

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/StanfordNoPOSRun4.ser.gz -testFile ../Data/TestRun04StanfordNoPOS.csv > ../Data/Run04_StanfordNoPOS.csv

## Run 05
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrain.prop -trainFile ../Data/TrainingRun05StanfordNoPOS.csv -serializeTo ../Data/StanfordNoPOSRun5.ser.gz 

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/StanfordNoPOSRun5.ser.gz -testFile ../Data/TestRun05StanfordNoPOS.csv > ../Data/Run05_StanfordNoPOS.csv

## Run 06
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrain.prop -trainFile ../Data/TrainingRun06StanfordNoPOS.csv -serializeTo ../Data/StanfordNoPOSRun6.ser.gz 

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/StanfordNoPOSRun6.ser.gz -testFile ../Data/TestRun06StanfordNoPOS.csv > ../Data/Run06_StanfordNoPOS.csv

## Run 07
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrain.prop -trainFile ../Data/TrainingRun07StanfordNoPOS.csv -serializeTo ../Data/StanfordNoPOSRun7.ser.gz 

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/StanfordNoPOSRun7.ser.gz -testFile ../Data/TestRun07StanfordNoPOS.csv > ../Data/Run07_StanfordNoPOS.csv

## Run 08
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrain.prop -trainFile ../Data/TrainingRun08StanfordNoPOS.csv -serializeTo ../Data/StanfordNoPOSRun8.ser.gz

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/StanfordNoPOSRun8.ser.gz -testFile ../Data/TestRun08StanfordNoPOS.csv > ../Data/Run08_StanfordNoPOS.csv 

## Run 09
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrain.prop -trainFile ../Data/TrainingRun09StanfordNoPOS.csv -serializeTo ../Data/StanfordNoPOSRun9.ser.gz 

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/StanfordNoPOSRun9.ser.gz -testFile ../Data/TestRun09StanfordNoPOS.csv > ../Data/Run09_StanfordNoPOS.csv

## Run 10
java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -prop ../Data/stanfordRetrain.prop -trainFile ../Data/TrainingRun10StanfordNoPOS.csv -serializeTo ../Data/StanfordNoPOSRun10.ser.gz 

java -mx4g -cp stanford-ner.jar edu.stanford.nlp.ie.crf.CRFClassifier -loadClassifier ../Data/StanfordNoPOSRun10.ser.gz -testFile ../Data/TestRun10StanfordNoPOS.csv > ../Data/Run10_StanfordNoPOS.csv

########################
# This is where the evaluation takes place 
########################

cd ../Scripts

for x in ../Data/Run*_StanfordNoPOS.csv ; do sed 's/\t/ /g' < $x | grep -v "^$" >> ../Data/StanfordNoPOSSingleFile.csv ; done

perl conlleval.pl < ../Data/StanfordNoPOSSingleFile.csv > ResultsStanfordNoPOS.txt

perl conlleval.pl < ../Data/StanfordNoPOSSingleFile.csv

 