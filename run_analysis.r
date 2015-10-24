#Installs Packages
install.packages("dplyr")
install.packages("plyr")
install.packages("sqldf")

#Loads Required Packages
library(dplyr)
library(plyr)
library(sqldf)

#Creates Directory if doesn't Exist
if(!file.exists("./Wearables")) {dir.create("./Wearables")}

#Sets Vector to Wearables
dir <- "wearables"

#Downloads DataSet and Unzips
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl,destfile="Wearables\\WearablesData.zip")
unzip("Wearables\\WearablesData.zip", list = FALSE,exdir="Wearables", overwrite = TRUE)

#Sets Working Directory
setwd("C:\\Users\\rvoorhees\\Documents\\Wearables\\UCI HAR Dataset")

#Read Files into vectors
Labels <- read.csv(file="activity_labels.txt",header=FALSE, sep="")
#Training 
x_train <- read.csv(file="train\\X_train.txt",header=FALSE, sep="")
y_train <- read.csv(file="train\\y_train.txt",header=FALSE, sep="")
#Subject 
Sub_Train <- read.csv(file="train\\subject_train.txt",header=FALSE, sep="")
Sub_Test <- read.csv(file="test\\subject_test.txt",header=FALSE, sep="")
#Testing 
x_test <- read.csv(file="test\\x_test.txt",header=FALSE, sep="")
y_test <- read.csv(file="test\\y_test.txt",header=FALSE, sep="")
#Features 
Feat <- read.csv(file="features.txt",header=FALSE, sep="")
FeatI <- read.csv(file="features_info.txt",header=FALSE, sep="")

#Renames Columns
Labels <- rename(Labels, c(V1="ActivityKey", V2="Activity"))
y_test <- rename(y_test, c(V1="ActivityKey"))
y_train <- rename(y_train, c(V1="ActivityKey"))
Feat <- rename(Feat,c(V1="FeatureKey",V2="FeatureName"))

##Merge Labels and Train Lables
y_train <- inner_join(y_train,Labels, by="ActivityKey")
y_test <- inner_join(y_test,Labels, by="ActivityKey")

#Combines Training and Test Datasets
x_b <- bind_rows(x_train,x_test)
y_b <- bind_rows(y_train,y_test)
subject <- bind_rows(Sub_Train, Sub_Test)

##Filter Measures
features <- sqldf("Select FeatureKey, FeatureName from Feat where FeatureName like '%mean()%' or FeatureName like '%std()%'")

#Matches Column Index with Feature Key
x_b <- x_b[, (features$FeatureKey)]
names(x_b) <- gsub("\\(|\\)", "", (features$FeatureName))

#Rename Columns
names(subject) = "Subjects"

#Combined the DataSets By Columns
CombinedData <- bind_cols(subject, y_b, x_b)

#Removes ActivityKey Column 
CombinedData$ActivityKey <- NULL

#Creates Combined Datset for Average of each variable for each Subject and Activity
CombinedData_Avg <- aggregate(CombinedData,list(CombinedData$Subjects, CombinedData$Activity), FUN=mean, row.names = FALSE)

#Removes and Renames Columns
CombinedData_Avg$Subjects <- NULL
CombinedData_Avg$Activity <- NULL
CombinedData_Avg <- rename(CombinedData_Avg,c(Group.1="Subject",Group.2="Activity"))



#Creates Txt File for CombinedData_Avg
write.csv2(CombinedData_Avg, file="CombinedData_Avg.txt", sep=",",row.names = FALSE)



