CodeBook.md
================

Code Walkthrough
----------------

This section describes the variables, the data, and any transformations or work performed to clean up the data. Moreover this shows how the different code sippets of `run_analysis.R` work.

#### Import required libraries

The `dplyr` library is used to clean and transform the raw dataset

``` r
suppressWarnings(library(dplyr)) 
```

#### Create `cc_project` folder if it doesn't exist and dowload the raw dataset to this folder

``` r
if(!file.exists("./cc_project")){dir.create("./cc_project")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./cc_project/Dataset.zip",method="curl")
```

#### Unpack the `Dataset.zip` file

``` r
unzip(zipfile="./cc_project/Dataset.zip", exdir="./cc_project")
```

#### Unzipped files are in the folder UCI HAR Dataset. Get the list of the files

``` r
path_data <- file.path("./cc_project" , "UCI HAR Dataset")
files<-list.files(path_data, recursive=TRUE)
files
```

### files in the Inertial Signals folder *won't* be used in merging the training and test data

#### read activity data

``` r
dataActivityTest<- read.table(file.path(path_data, "test" , "y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_data, "train", "y_train.txt"),header = FALSE)
```

#### read subject data

``` r
dataSubjectTrain <- read.table(file.path(path_data, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest<- read.table(file.path(path_data, "test" , "subject_test.txt"),header = FALSE)
```

#### read features data

``` r
dataFeaturesTest<- read.table(file.path(path_data, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_data, "train", "X_train.txt"),header = FALSE)
```

#### merge the train and test data to one dataset, concatenate tables by rows

``` r
dataSubject <- bind_rows(dataSubjectTrain, dataSubjectTest)
dataActivity<- bind_rows(dataActivityTrain, dataActivityTest)
dataFeatures<- bind_rows(dataFeaturesTrain, dataFeaturesTest)
```

#### set appropriate variable names

``` r
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_data, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2
```

#### merge all columns to form a unified dataset, convert to local dataframe

``` r
dataCombine <- bind_cols(dataSubject, dataActivity)
Data <- bind_cols(dataFeatures, dataCombine)
Data <- tbl_df(Data)
```

#### extract only the measurements on the mean and standard deviation for each measurement

``` r
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
```

#### subset the data frame Data by seleted names of Features and show structure of dataframe

``` r
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)
glimpse(Data)
```

#### use descriptive activity names to name the activities in the data set

``` r
activityLabels <- read.table(file.path(path_data, "activity_labels.txt"),header = FALSE)
Data$activity <- factor(Data$activity, levels=activityLabels$V1, labels=activityLabels$V2)
head(Data$activity,30)
```

#### set descriptive variable names to Data column names via regular expressions

``` r
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))
```

#### create a second, independent tidy data set with the average of each variable for each activity and each subject

``` r
tidy_data <- Data %>% group_by(activity, subject) %>% summarise_each(funs(mean))
```

#### output tidydata to .txt file `tidydata.txt`

``` r
write.table(tidy_data, file = "tidydata.txt", row.name= FALSE)
```
