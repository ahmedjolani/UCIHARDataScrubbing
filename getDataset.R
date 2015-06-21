### SCRIPT INFO ###
# Name: getDataset.R
# Description: downloads and extracts the dataset from the internet to the |datasetPath| directory. The script will create the directory if it does not exist.
# Version: 0.1
# Author: Ahmed Jolani (ahmed.jolani@gmail.com)

getDataset <- function(cache = FALSE, wd = "") {
    # the link to the dataset
    datasetURI <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    datasetChecksum <- "d29710c9530a31f303801b6bc34bd895"
    # the path where the datasetURI will be extracted
    if (wd != "") {
        datasetPath <- file.path(wd, "rawDataset")
    } else {
        # assume current working directory
        datasetPath <- "rawDataset"
    }
    # temp directory to download the dataset ZIP
    tempPath <- file.path("/tmp", "UCIDataset")
    
    # check if the directory does not exist and create if so
    if (!file.exists(datasetPath)) {
        dir.create(datasetPath)
    }
    
    # clean up the |datasetPath| directory
    unlink(file.path(datasetPath, "*"), recursive = TRUE)
    
    datasetFileValid <- FALSE
    # if caching is enabled, check the previous cached file if it is valid
    if (cache) {
        if (file.exists(file.path(tempPath, "dataset.zip"))) {
            library(tools)
            # check if the cached file is valid
            if (md5sum(file.path(tempPath, "dataset.zip")) == datasetChecksum) {
                message("Extracting dataset from cache...")
                datasetFileValid <- TRUE
            }
        }
        if (!datasetFileValid) {
            message("Cache is empty, will try to download the dataset instead.")
        }
    }
    
    # download only if file did not exist in cache
    if (!datasetFileValid) {
        # setting up the temp directory
        unlink(tempPath, recursive = TRUE)
        dir.create(tempPath)
        
        message("Attempting to download the dataset...")
        # try to download the dataset
        retCode <- download.file(datasetURI, file.path(tempPath, "dataset.zip"), method = "curl")
        if (retCode != 0) {
            stop(sprintf("Could not download dataset: %s!", datasetURI))
        }
    }
    
    # extracts the dataset to the |datasetPath| directory
    unzip(file.path(tempPath, "dataset.zip"), exdir = datasetPath)
    
    # delete the cached file if caching is disabled
    if (!cache) {
        # remove the |tempPath| directory
        unlink(tempPath, recursive = TRUE)
    }

    # return the dataset directory path
    file.path(datasetPath, "UCI HAR Dataset")
}