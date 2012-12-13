#!/bin/bash

# Make sure you have generated the EuropeanaMetadata.csv file in the Data directory by running CreateFeatureVectors.sh in Scripts.

# Also make sure you have mallet-2.0.7 installed in the NER root directory

# Check if the file contains 12510 lines 
split -l 1251 Data/EuropeanaMetadata.csv 

# Concatenate different parts to create training data 
cat  xab xac xad xae xaf xag xah xai xaj | sed 's/ //g ; s/"//g ; s/,/ /' >> Data/TrainingRun01.csv
cat  xaa xac xad xae xaf xag xah xai xaj | sed 's/ //g ; s/"//g ; s/,/ /'  >> Data/TrainingRun02.csv
cat  xaa xab xad xae xaf xag xah xai xaj | sed 's/ //g ; s/"//g ; s/,/ /'  >> Data/TrainingRun03.csv
cat  xaa xab xac xae xaf xag xah xai xaj | sed 's/ //g ; s/"//g ; s/,/ /'  >> Data/TrainingRun04.csv
cat  xaa xab xac xad xaf xag xah xai xaj  | sed 's/ //g ; s/"//g ; s/,/ /' >> Data/TrainingRun05.csv
cat  xaa xab xac xad xae xag xah xai xaj  | sed 's/ //g ; s/"//g ; s/,/ /' >> Data/TrainingRun06.csv
cat  xaa xab xac xad xae xaf xah xai xaj  | sed 's/ //g ; s/"//g ; s/,/ /' >> Data/TrainingRun07.csv
cat  xaa xab xac xad xae xaf xag xai xaj | sed 's/ //g ; s/"//g ; s/,/ /'  >> Data/TrainingRun08.csv
cat  xaa xab xac xad xae xaf xag xah xaj  | sed 's/ //g ; s/"//g ; s/,/ /' >> Data/TrainingRun09.csv
cat  xaa xab xac xad xae xaf xag xah xai  | sed 's/ //g ; s/"//g ; s/,/ /' >> Data/TrainingRun10.csv

# 
cat  xaa | sed 's/ //g ; s/"//g ; s/,/ /'  >> Data/TestRun01.csv
cat  xab | sed 's/ //g ; s/"//g ; s/,/ /'  >> Data/TestRun02.csv
cat  xac  | sed 's/ //g ; s/"//g ; s/,/ /' >> Data/TestRun03.csv
cat  xad | sed 's/ //g ; s/"//g ; s/,/ /'  >> Data/TestRun04.csv
cat  xae | sed 's/ //g ; s/"//g ; s/,/ /'  >> Data/TestRun05.csv
cat  xaf | sed 's/ //g ; s/"//g ; s/,/ /'  >> Data/TestRun06.csv
cat  xag | sed 's/ //g ; s/"//g ; s/,/ /'  >> Data/TestRun07.csv
cat  xah | sed 's/ //g ; s/"//g ; s/,/ /'  >> Data/TestRun08.csv
cat  xai | sed 's/ //g ; s/"//g ; s/,/ /'  >> Data/TestRun09.csv
cat  xaj | sed 's/ //g ; s/"//g ; s/,/ /'  >> Data/TestRun10.csv

if [ -f Data/GoldStandard.csv ];
then
    rm Data/GoldStandard.csv
fi

cat xaa xab xac xad xae xaf xag xah xai xaj | cut -f1,59 -d"," | sed 's/"//g' >> Data/GoldStandard.csv

# Clean up
rm xaa xab xac xad xae xaf xag xah xai xaj

### 
#  This is where the mallet experiments take place, make sure to have mallet-2.0.7 
#  installed in the root directory
###

CURRENTDIR=`pwd`

cd mallet-2.0.7.

## Run 01 
java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:/$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --orders 4 --train true --model-file $CURRENTDIR/Data/Run01_4orders $CURRENTDIR/Data/TrainingRun01.csv

java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --include-input true --model-file $CURRENTDIR/Data/Run01_4orders $CURRENTDIR/Data/TestRun01.csv > $CURRENTDIR/Data/Run01_4orders.csv

## Run 02
java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --orders 4 --train true --model-file $CURRENTDIR/Data/Run02_4orders $CURRENTDIR/Data/TrainingRun02.csv


java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --include-input true --model-file $CURRENTDIR/Data/Run02_4orders $CURRENTDIR/Data/TestRun02.csv > $CURRENTDIR/Data/Run02_4orders.csv


## Run 03
java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --orders 4 --train true --model-file $CURRENTDIR/Data/Run03_4orders $CURRENTDIR/Data/TrainingRun03.csv

java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --include-input true --model-file $CURRENTDIR/Data/Run03_4orders $CURRENTDIR/Data/TestRun03.csv > $CURRENTDIR/Data/Run03_4orders.csv

## Run 04
java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --orders 4 --train true --model-file $CURRENTDIR/Data/Run04_4orders $CURRENTDIR/Data/TrainingRun04.csv

java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --include-input true --model-file $CURRENTDIR/Data/Run04_4orders $CURRENTDIR/Data/TestRun04.csv > $CURRENTDIR/Data/Run04_4orders.csv


## Run 05
java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --orders 4 --train true --model-file $CURRENTDIR/Data/Run05_4orders $CURRENTDIR/Data/TrainingRun05.csv

java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --include-input true --model-file $CURRENTDIR/Data/Run05_4orders $CURRENTDIR/Data/TestRun05.csv > $CURRENTDIR/Data/Run05_4orders.csv


## Run 06
java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --orders 4 --train true --model-file $CURRENTDIR/Data/Run06_4orders $CURRENTDIR/Data/TrainingRun06.csv

java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --include-input true --model-file $CURRENTDIR/Data/Run06_4orders $CURRENTDIR/Data/TestRun06.csv > $CURRENTDIR/Data/Run06_4orders.csv


## Run 07
java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --orders 4 --train true --model-file $CURRENTDIR/Data/Run07_4orders $CURRENTDIR/Data/TrainingRun07.csv

java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --include-input true --model-file $CURRENTDIR/Data/Run07_4orders $CURRENTDIR/Data/TestRun07.csv > $CURRENTDIR/Data/Run07_4orders.csv


## Run 08
java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --orders 4 --train true --model-file $CURRENTDIR/Data/Run08_4orders $CURRENTDIR/Data/TrainingRun08.csv

java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --include-input true --model-file $CURRENTDIR/Data/Run08_4orders $CURRENTDIR/Data/TestRun08.csv > $CURRENTDIR/Data/Run08_4orders.csv


## Run 09
java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --orders 4 --train true --model-file $CURRENTDIR/Data/Run09_4orders $CURRENTDIR/Data/TrainingRun09.csv

java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --include-input true --model-file $CURRENTDIR/Data/Run09_4orders $CURRENTDIR/Data/TestRun09.csv > $CURRENTDIR/Data/Run09_4orders.csv


## Run 10
java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --orders 4 --train true --model-file $CURRENTDIR/Data/Run10_4orders $CURRENTDIR/Data/TrainingRun10.csv

java -mx4g -cp "$CURRENTDIR/mallet-2.0.7/class:$CURRENTDIR/mallet-2.0.7/lib/mallet-deps.jar" cc.mallet.fst.SimpleTagger --include-input true --model-file $CURRENTDIR/Data/Run10_4orders $CURRENTDIR/Data/TestRun10.csv > $CURRENTDIR/Data/Run10_4orders.csv

# Concatenate the different output files and extract the classifier's predictions
for x in $CURRENTDIR/Data/Run*_4orders.csv ; do grep -v "^$" < $x | cut -f1 -d" " | cat >> $CURRENTDIR/Data/Run4ordersOneFile.csv ; done 

# Combine the classifier's predictions with the gold standard predictions 
paste -d" " $CURRENTDIR/Data/GoldStandard.csv $CURRENTDIR/Data/Run4ordersOneFile.csv > $CURRENTDIR/Data/Run4ordersForConll.csv 

# Run the evaluation script
perl ../Scripts/conlleval.pl < $CURRENTDIR/DataRun4ordersForConll.csv > $CURRENTDIR/Data/4OrdersConllsresults.txt

perl ../Scripts/conlleval.pl < $CURRENTDIR/DataRun4ordersForConll.csv 

cd ..


