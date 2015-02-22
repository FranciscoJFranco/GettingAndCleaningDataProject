#Francisco J Franco
#Project for Getting and Cleaning Data Course

#Download and unzip files
# url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
# filename<-"Data.zip"
# download.file(url,filename,method="auto",mode="wb")
# unzip(filename)

#Read test data
subject_test<-read.table("UCI HAR Dataset\\test\\subject_test.txt")
X_test<-read.table("UCI HAR Dataset\\test\\X_test.txt")
y_test<-read.table("UCI HAR Dataset\\test\\y_test.txt")


#Read train data
subject_train<-read.table("UCI HAR Dataset\\train\\subject_train.txt")
X_train<-read.table("UCI HAR Dataset\\train\\X_train.txt")
y_train<-read.table("UCI HAR Dataset\\train\\y_train.txt")


#Combine test and train data into one (subject, x, and y still separate)
subject<-rbind(subject_test,subject_train)
X<-rbind(X_test,X_train)
y<-rbind(y_test,y_train)


#Read features table
features<-read.table("UCI HAR Dataset\\features.txt")

#Get a logical vector indicating which features contain the words mean, Mean or std
isMeanOrStd<-grepl("mean",features[,2])|grepl("Mean",features[,2])|grepl("std",features[,2])

#Exctract features for means and standard deviation using the logical index from previous step
X_means_std_features<-X[,isMeanOrStd]

#Read activity lables table
activity_labels<-read.table("UCI HAR Dataset\\activity_labels.txt")

#Rename activity lable columns
colnames(y)<-"Activity_ID"
colnames(activity_labels)<-c("Activity_ID","Activity_label")

#Substitute the activity IDs in y with descriptive labels 
activity<-merge(y,activity_labels,by="Activity_ID",sort=FALSE)

#Assign descriptive names to the columns in the X data
colnames(X_means_std_features)<-features[isMeanOrStd,2]

#Assign a descriptive column name to subject vector
colnames(subject)<-"Subject_ID"

#Join all into one dataset by binding the columns
tidy_dataset<-cbind(subject,activity,X_means_std_features)

#Eliminate the Activity ID column since it is redundant
tidy_dataset<-tidy_dataset[-2]



#Split dataset by activity label and subject ID
split_by_activity_subject<-split(tidy_dataset[c(-1,-2)],list(tidy_dataset$Activity_label,tidy_dataset$Subject_ID))

#Using an anonymous function that calculates the column means of the measurements, use sapply to execute that anonymous function to the elements of the list resulting from the split
dataset2_average_by_activity_subject<-sapply(split_by_activity_subject, function(x) colMeans(x[,names(tidy_dataset[c(-1,-2)])], na.rm=TRUE))

#Transpose the resulting data frame so that the columns are the variables
dataset2_average_by_activity_subject<-t(dataset2_average_by_activity_subject)

#Recover the original identifiers for Activity lables and Subject ID by splitting the row names of the new dataset and reshaping the resulting vector into a matrix.
#The result is a 180x2 matrix. One column for the Activity lables and the other one for the Subject ID
factor_vector<-unlist(strsplit(rownames(dataset2_average_by_activity_subject),"[.]"))
dataset2_activity_subject_cols<-matrix(factor_vector,nrow=180,byrow=TRUE)

#Bind the matrix from the last step to the data frame in order to have a full data set
dataset2_average_by_activity_subject<-cbind(dataset2_activity_subject_cols,dataset2_average_by_activity_subject)


#Rename the recently added columns with descriptive labels
colnames(dataset2_average_by_activity_subject)[c(1,2)]<-c("Activity_label","Subject_ID")

#Export resulting data frame to a .txt file without the row names
write.table(dataset2_average_by_activity_subject,"Data set Step 5.txt",row.names=FALSE)
