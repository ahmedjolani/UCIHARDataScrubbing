### SCRIPT INFO ###
# Name: run_analysis.R
# Details: Merges the training and test datasets, extracts only the mean and standard deviation readings and creates a tidy dataset and dumps it to a file.
# Version: 0.1
# Author: Ahmed Jolani (ahmed.jolani@gmail.com)

source(file.path("getDataset.R"))
library(LaF)
library(reshape2)

# the path where the dataset will be extracted
datasetPath <- NULL
# dataset column names
columnNames <- NULL
# test dataset names
testDatasets <- c(features = "X_test.txt", labels = "y_test.txt", subjects = "subject_test.txt")
# train dataset names
trainDatasets <- c(features = "X_train.txt", labels = "y_train.txt", subjects = "subject_train.txt")
# activity labels
activityLabels <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING")

init <- function() {
    # cache the dataset file and extract it to the current directory
    datasetPath <<- getDataset(TRUE, ".")
}

getColNames <- function() {
    if (is.null(columnNames)) {
        # read column names
        columnNames <<- read.table(file.path(datasetPath, "features.txt"), colClasses = c("integer", "character"), sep = " ")
        # add the activity column
        columnNames <<- rbind(columnNames, list(nrow(columnNames) + 1, "Activity"))
        # add the subject column
        columnNames <<- rbind(columnNames, list(nrow(columnNames) + 1, "Subject"))
    }
    
    # return column names
    columnNames
}

constructDatasets <- function() {
    # number of features
    featuresCount <- 561
    # width of each feature in bytes (ASCII)
    featureWidth <- 16
    # get test features
    testFeatures <- laf_open_fwf(file.path(datasetPath, "test", testDatasets["features"]), rep("numeric", featuresCount), rep(featureWidth, featuresCount))[,]
    # get training features
    trainFeatures <- laf_open_fwf(file.path(datasetPath, "train", trainDatasets["features"]), rep("numeric", featuresCount), rep(featureWidth, featuresCount))[,]
    
    # get test labels
    testLabels <- laf_open_fwf(file.path(datasetPath, "test", testDatasets["labels"]), "integer", 1)[,]
    # get training labels
    trainLabels <- laf_open_fwf(file.path(datasetPath, "train", trainDatasets["labels"]), "integer", 1)[,]
    
    # get test subjects
    testSubjects <- read.table(file.path(datasetPath, "test", testDatasets["subjects"]), colClasses = "factor", sep = " ")
    # get training subjects
    trainSubjects <- read.table(file.path(datasetPath, "train", trainDatasets["subjects"]), colClasses = "factor", sep = " ")
    
    columnNames <- getColNames()
    
    message("Constructing the test dataset...")
    # merge test datasets
    testDataset <- cbind(testFeatures, testLabels, testSubjects)
    # clean up test variables
    rm(testFeatures, testLabels, testSubjects)
    
    message("Constructing the training dataset...")
    # merge training datasets
    trainDataset <- cbind(trainFeatures, trainLabels, trainSubjects)
    # clean up training variables
    rm(trainFeatures, trainLabels, trainSubjects)
    
    # set test column names
    names(testDataset) <- columnNames[, 2]
    # set training column names
    names(trainDataset) <- columnNames[, 2]
    
    # return a list of datasets (training and test)
    list(testDataset, trainDataset)
}

mergeDatasets <- function(datasetA, datasetB) {
    columnNames <- getColNames()
    # extract *mean()*, *std()*, Activity and Subject columns only
    columns <- grep("(Activity|Subject)|((mean|std)\\(\\))", columnNames[, 2])
    datasetA <- datasetA[, columns]
    datasetB <- datasetB[, columns]
    
    # merge and return the datasets
    message("Merging training and test datasets...")
    rbind(datasetA, datasetB)
}

dumpDataset <- function(dataset, file) {
    message(sprintf("Writing dataset to file %s...", file))
    write.table(dataset, file, sep = ",", row.names = FALSE)
}

main <- function() {
    # download and extract the datasets
    init()
    # construct the test and training datasets
    datasets <- constructDatasets()
    # merge the training and test datasets
    datasets <- mergeDatasets(datasets[[1]], datasets[[2]])
    # remap the Activity factor levels to descriptive names
    datasets$Activity <- factor(datasets$Activity, levels = 1:6, labels = activityLabels)
    # melt the datasets to summarise by each variable, Activity and Subject
    datasetsMolten <- melt(datasets, id = c("Activity", "Subject"))
    # save the semi-tidy dataset
    dumpDataset(datasets, "semiTidyDataset.csv")
    # clean up old datasets
    rm(datasets)
    # create the tidy dataset and save it
    dumpDataset(ddply(datasetsMolten, .(Activity, Subject, variable), summarise, average = mean(value)), "tidyDataset.csv")
    message(sprintf("The tidy dataset has been created and saved to %s.", "tidyDataset.csv"))
}