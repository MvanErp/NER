Experiments
==

The shell scripts in this section contain all the steps that were carried out to obtain the results presented in tables 3 and 4 in the paper. 

Check the comments in the scripts for prerequisites and details. 

Three experiments were carried out:

- RunMalletExperiments.sh	: This script will carry out the replication experiments with the Mallet toolkit and full feature set as described in Section 4 in the paper.
- RunStanfordExperimentsNoPOS.sh	: This script will carry out the experiments in which the stanford NER tagger is trained on the Europeana data in a ten-fold cross-validation experiment as described in Section 5 of the paper.
- RunStanfordExperimentsPOS.sh	: This script carries out similar experiments to the previous one, except that it first POS tags the training and test data. See Section 5 of the paper for details. 


Experimental Results
==

In Results/ the output files of the experiments described in the paper can be found. 

The following results can be found:

- Mallet4thOrderFreireFeaturesResultsForConll.csv	: The results of our replication experiments, as found in Table 3 in the paper

- StanfordNoPOSSingleFile.csv 	: The results of retraining the Stanford NER module without part-of-speech tags (i.e., only tokens). See Table 5 in the paper

- StanfordPOSSingleFile.csv	: The results of retraining the Stanford NER mod
ule with part-of-speech tags. See Table 5 in the paper.
 
