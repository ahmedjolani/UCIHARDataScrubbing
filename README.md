# UCIHARDataScrubbing Project

## The structure of the scripts
The project consits of two main scripts:

1. getDataset.R
2. run_analysis.R

Generally, both scripts should be in the same directory. The entry point is the main() function defined in the run_analysis.R script.

## Pre-requisites / Dependencies
The scripts depend on the following libraries:

1. tools (getDataset.R)
2. LaF (run_analysis.R)
3. reshape2 (run_analysis.R)

The above library must be installed in order for the scripts to run successfully.

## getDataset.R
This script is concerned with downloading and extracting the raw dataset from the source https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
The script creates a directory called "rawDataset" if it does not exist. On each run, it wipes out the content and fills it with a fresh extract of the raw dataset file. After preparing the working directory, it attempts to download the raw dataset file if the cache option was set to FALSE, or the cached file for some reason was invalid. The workflow of this script is triggered through the only function getDataset.

The header of the getDataset function:
getDataset <- function(cache = FALSE, wd = "") {...}

### Arguments

cache: if TRUE, the script will not delete the downloaded raw dataset file, and will store it in a temp cache.
wd: if specified, it will be the working directory of the script. If not, the current working directory is used.

### Value
The script returns the relative path to the "rawDataset" directory. This directory contains the UCI HAR raw dataset. The user shall not be concerned with this directory at all.

## run_analysis.R
This script runs the getDataset function with the cache parameter set to TRUE and the wd set to "." The script sources the getDataset script obviously, and assumes that it's in the same directory as its. The script consists of 6 different functions, however the only function that the user should be concerned about is the main function. This script does the meaty work. Briefly, it merges the training and test datasets, extracts only the mean and standard deviation readings and creates a tidy dataset and dumps it to a file.

The main function starts the workflow, the same workflow is briefly described in the CodeBook, please refer to the "The process of cleaning the raw dataset" section for general overview. Both the run_analysis.R and getDataset.R contain comments and pretty clear on their structure.

There are no arguments to the main function.

### Value
The main function returns the tidy dataset described in the CodeBook. It also writes the tidy and the semi-tidy datasets to the "tidyDataset.csv" and "semiTidyDataset.csv", respectively.

## How to run the analysis script?
First of all, download both the getDataset.R and run_analysis.R scripts. Set your working directory to whatever you like, and then copy both scripts to this directory. BOTH scripts must be in the same directory. Source the run_analysis.R script e.g. source("~/run_analysis.R") then run type tidyDataset <- main() and hit return. The main funciton runs visibly, so to avoid the evaluation of its output, set that to a "tidyDataset" variable for example. Upon completion of the main function, the same working directory should have two extra files, belonging to the tidy and semi-tidy datasets.

Enjoy! 
