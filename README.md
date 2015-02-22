---
title: "README"
author: "Francisco J Franco"
date: "Sunday, February 22, 2015"
output: html_document
---

Summary: this script takes the training and testing datasets from the Samsung data found in <https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip> and transforms the data until a single tidy dataset is produced, for which the mean and standard deviation variables are averaged for each Activity-subject pair. The result of this script is a table exported to a .txt file in the working directory with the name "Data set Step 5.txt".

This script assumes that the Samsung dataset is available in the working directory, starting with the "UCI HAR Dataset" folder. However, the dataset can also be downloaded and uncompressed by uncommenting the following section of the code:   

```r
# url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"   
# filename<-"Data.zip"  
# download.file(url,filename,method="auto",mode="wb")  
# unzip(filename)  
```


The first step involces combining the training and testing datasets via the row binding function:  

```r
#Combine test and train data into one (subject, x, and y still separate)  
subject<-rbind(subject_test,subject_train)  
X<-rbind(X_test,X_train)  
y<-rbind(y_test,y_train)  
```

Then we read the features table

```r
features<-read.table("UCI HAR Dataset\\features.txt")
```

The next step involves looking for feature names that include the words mean, Mean or std and extract those columns from the X data frame.
```r
#Get a logical vector indicating which features contain the words mean, Mean or std
isMeanOrStd<-grepl("mean",features[,2])|grepl("Mean",features[,2])|grepl("std",features[,2])

#Exctract features for means and standard deviation using the logical index from previous step
X_means_std_features<-X[,isMeanOrStd]
```

We then read the activity lables table, unify the column names of this and the y data in order to use the merge function to link the tables.
```r
#Read activity lables table
activity_labels<-read.table("UCI HAR Dataset\\activity_labels.txt")

#Rename activity lable columns
colnames(y)<-"Activity_ID"
colnames(activity_labels)<-c("Activity_ID","Activity_label")

#Substitute the activity IDs in y with descriptive labels 
activity<-merge(y,activity_labels,by="Activity_ID",sort=FALSE)
```

We now assign descriptive names to the variables of our main data frame with the means and standard deviations. The names are already existing in the features table and we have the locations of the corresponding names in the isMeanOrStd variable
```r
#Assign descriptive names to the columns in the X data
colnames(X_means_std_features)<-features[isMeanOrStd,2]
```

We assign a descriptive name to the subject table
```r
#Assign a descriptive column name to subject vector
colnames(subject)<-"Subject_ID"
```

Finaly, we join all tables into one main tidy_dataset by column-binding the subject, activity and the main measures with the means and standard deviations. One last step involves eliminating a redundant column containing the activity ID since we already have another column with the lables.
```r
#Join all into one dataset by binding the columns
tidy_dataset<-cbind(subject,activity,X_means_std_features)

#Eliminate the Activity ID column since it is redundant
tidy_dataset<-tidy_dataset[-2]
```

At this point we have the full tidy dataset in one table. Now we must average the variables along the activity and subject.

In order to achieve this, we split the part of the dataset corresponding to the measurements by the Activity and Subject, which are the first two columns

```r

#Split dataset by activity label and subject ID
split_by_activity_subject<-split(tidy_dataset[c(-1,-2)],list(tidy_dataset$Activity_label,tidy_dataset$Subject_ID))
```

Then we use sapply, to apply an anonymous function that takes the column means of all the measurement variables to the elements of the list resulting from the split step
```r
#Using an anonymous function that calculates the column means of the measurements, use sapply to execute that anonymous function to the elements of the list resulting from the split
dataset2_average_by_activity_subject<-sapply(split_by_activity_subject, function(x) colMeans(x[,names(tidy_dataset[c(-1,-2)])], na.rm=TRUE))
```

We need to transpose the results so that the variables are in the columns
```r
#Transpose the resulting data frame so that the columns are the variables
dataset2_average_by_activity_subject<-t(dataset2_average_by_activity_subject)
```


Recover the original identifiers for Activity lables and Subject ID by splitting the row names of the new dataset and reshaping the resulting vector into a matrix.
The result is a 180x2 matrix. One column for the Activity lables and the other one for the Subject ID. We bind this matrix to the data frame in order to have a full dataset.  

```r
factor_vector<-unlist(strsplit(rownames(dataset2_average_by_activity_subject),"[.]"))
dataset2_activity_subject_cols<-matrix(factor_vector,nrow=180,byrow=TRUE)

#Bind the matrix from the last step to the data frame in order to have a full data set
dataset2_average_by_activity_subject<-cbind(dataset2_activity_subject_cols,dataset2_average_by_activity_subject)
```

Rename the recently added columns with descriptive labels
```r
colnames(dataset2_average_by_activity_subject)[c(1,2)]<-c("Activity_label","Subject_ID")
```


Export resulting data frame to a .txt file without the row names
```r
write.table(dataset2_average_by_activity_subject,"Data set Step 5.txt",row.names=FALSE)
```
