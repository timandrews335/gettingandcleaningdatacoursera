


#read in the variable names
vars <- read.table("features.txt")

#read in test & train data
test <- read.table("./test/X_test.txt")
train <- read.table("./train/X_train.txt")

#read in the activities
ytest <- read.table("./test/y_test.txt")
ytrain <- read.table("./train/y_train.txt")
activitylabels <- read.table("./data/UCI/activity_labels.txt")

ytest <- merge(ytest, activitylabels, by.x = "V1", by.y = "V1")
ytrain <- merge(ytrain, activitylabels, by.x = "V1", by.y = "V1")

colnames(ytest) = c("activityid", "activity")
colnames(ytrain) = c("activityid", "activity")


#update the variable names in the test & train data to meaningful descriptions
#based on the names provided
colnames(test) =  vars$V2
colnames(train) = vars$V2

#remove the columns from the datasets which do not deal with means or standard deviations 
train <- (train[grep("*mean\\(\\)|*std\\(\\)", names(train))])
test <- (test[grep("*mean\\(\\)|*std\\(\\)", names(test))])

#update the activities in each data frame
test <- cbind(test, ytest$activity)
train <- cbind(train, ytrain$activity)

colnames(test)[67] = "activity"
colnames(train)[67] = "activity"

#update the subject for each row
testsubject <- read.csv("./test/subject_test.txt", header = FALSE)
trainsubject <- read.csv("./train/subject_train.txt", header = FALSE)


test <- cbind(test, testsubject$V1)
train <- cbind(train, trainsubject$V1)

colnames(test)[68] = "subject"
colnames(train)[68] = "subject"

#add a column to each data frame for the data set type
test$datasettype <- "test"
train$datasettype <- "train"


#merge the data frames together
bigdata <- merge(train, test, all=TRUE)


library(reshape2)

#we want to pivot the data frame so that each row tracks just
#one variable.  We want to summarize by the first 66 columns (the variables)
bigmelt <- melt(bigdata, id=colnames(bigdata)[67:69], measure.vars=colnames(bigdata)[1:66])

#we now want to get the mean value by activity, subject and variable
aggdata <- aggregate(x=bigmelt$value, by=list(bigmelt$activity, bigmelt$subject, bigmelt$variable), FUN=mean)

colnames(aggdata) = c("activity", "subject", "variable", "meanValue")


#write out the final data set
write.table(aggdata, file="SmartphoneAggregates.txt", sep=",", row.name=FALSE)
