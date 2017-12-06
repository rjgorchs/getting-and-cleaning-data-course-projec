
# FILE run_analysis.R

# See README.md for details.


fileName <- "dataset.zip"

## if the file was not already downloaded, download and unzip it:
if (!file.exists(fileName)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, fileName)
  unzip(fileName)
}


## Load activity labels and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

## Select data of mean and standard deviation
selectedFeatures <- grep(".*mean.*|.*std.*", features[,2])
selectedFeatures.names <- features[selectedFeatures,2]


## Load train and test datasets
trainSet <- read.table("UCI HAR Dataset/train/X_train.txt")
trainSet <- trainSet[selectedFeatures]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
trainSet <- cbind(trainSubjects, trainActivities, trainSet)

testSet <- read.table("UCI HAR Dataset/test/X_test.txt")
testSet <- testSet[selectedFeatures]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
testSet <- cbind(testSubjects, testActivities, testSet)

## merge datasets
mergedData <- rbind(trainSet, testSet)

## remove special characters
selectedFeatures.names <- gsub("[\\(\\)-]", "", selectedFeatures.names)

## clean up names
selectedFeatures.names <- gsub("^f", "frequencyDomain", selectedFeatures.names)
selectedFeatures.names <- gsub("^t", "timeDomain", selectedFeatures.names)
selectedFeatures.names <- gsub("Acc", "Accelerometer", selectedFeatures.names)
selectedFeatures.names <- gsub("Gyro", "Gyroscope", selectedFeatures.names)
selectedFeatures.names <- gsub("Mag", "Magnitude", selectedFeatures.names)
selectedFeatures.names <- gsub("Freq", "Frequency", selectedFeatures.names)
selectedFeatures.names <- gsub("mean", "Mean", selectedFeatures.names)
selectedFeatures.names <- gsub("std", "StandardDeviation", selectedFeatures.names)

colnames(mergedData) <- c("subject", "activity", selectedFeatures.names)

## turn activities & subjects into factors
mergedData$activity <- factor(mergedData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
mergedData$subject <- as.factor(mergedData$subject)

mergedData.melted <- melt(mergedData, id = c("subject", "activity"))
mergedData.mean <- dcast(mergedData.melted, subject + activity ~ variable, mean)

write.table(mergedData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
