library(dplyr)
library(data.table)

if(!file.exists("./cc_project")){dir.create("./cc_project")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./cc_project/Dataset.zip",method="curl")

unzip(zipfile="./cc_project/Dataset.zip", exdir="./cc_project")

path_data <- file.path("./cc_project" , "UCI HAR Dataset")
files<-list.files(path_data, recursive=TRUE)
files

dataActivityTest<- read.table(file.path(path_data, "test" , "y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_data, "train", "y_train.txt"),header = FALSE)

dataSubjectTrain <- read.table(file.path(path_data, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest<- read.table(file.path(path_data, "test" , "subject_test.txt"),header = FALSE)

dataFeaturesTest<- read.table(file.path(path_data, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_data, "train", "X_train.txt"),header = FALSE)

dataSubject <- bind_rows(dataSubjectTrain, dataSubjectTest)
dataActivity<- bind_rows(dataActivityTrain, dataActivityTest)
dataFeatures<- bind_rows(dataFeaturesTrain, dataFeaturesTest)

names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_data, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

dataCombine <- bind_cols(dataSubject, dataActivity)
Data <- bind_cols(dataFeatures, dataCombine)
Data <- tbl_df(Data)

subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)
glimpse(Data)

activityLabels <- read.table(file.path(path_data, "activity_labels.txt"),header = FALSE)
Data$activity <- factor(Data$activity, levels=activityLabels$V1, labels=activityLabels$V2)
head(Data$activity,30)

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))
names(Data)

tidy_data <- Data %>% group_by(activity, subject) %>% summarise_each(funs(mean))

write.csv(tidy_data, file = "tidydata.csv")