#the driver file for final project
#author: Mengjie Zhang

#I.Preprocess the data
source("EDA.R")
#load the data and preprocess the data
data_Beijing <- dataPreprocess(fileName="../Data/BeijingPM.csv")

#II.perform the exploratory data analysis
eda(data_Beijing)

#III.perform variable selection using bayesian hierarchical model selection

#take a subset of data (the year 2010) for training purpose
data_Beijing_training <- subset(data_Beijing, date < "2011-01-01")
#------------------------------------------------------------------------------- 
# specify the dataset and specity column names of x (predictors) and y (predicted):
myData = data_Beijing_training
yName = "PM" ; xName = c("DEWP","HUMI","PRES","TEMP","WS","PREC")
# Specify name of folder (i.e., directory) in which to save output files:
dirName="VariableSelection"
# Create the folder:
if(!dir.exists(dirName)){dir.create(dirName)}
# Specify prefix (i.e., filename root) for names of saved output files:
fileNameRoot = paste0(dirName,"/FinalProject-VarSelect-")
numSavedSteps=15000 ; thinSteps=20
graphFileType = "png" 
#------------------------------------------------------------------------------- 
# Load the relevant model into R's working memory:
source("VariableSelection.R")
#-------------------------------------------------------------------------------  
# Generate the MCMC chain:
mcmcCoda = genMCMC( data=myData , xName=xName , yName=yName , 
                    numSavedSteps=numSavedSteps , thinSteps=thinSteps , 
                    saveName=fileNameRoot )
#------------------------------------------------------------------------------- 
# Display diagnostics of chain, for specified parameters:
parameterNames = varnames(mcmcCoda) # get all parameter names
for ( parName in parameterNames ) {
  diagMCMC( codaObject=mcmcCoda , parName=parName , 
            saveName=fileNameRoot , saveType=graphFileType )
}
#------------------------------------------------------------------------------- 
# Get summary statistics of chain:
summaryInfo = smryMCMC( mcmcCoda , 
                        saveName=fileNameRoot )
show(summaryInfo)
#------------------------------------------------------------------------------- 
# Display posterior information:
plotMCMC( mcmcCoda , data=myData , xName=xName , yName=yName , 
          pairsPlot=TRUE , showCurve=FALSE ,
          saveName=fileNameRoot , saveType=graphFileType )
#------------------------------------------------------------------------------- 

# IV. Fit bayesian linear model
# specify the dataset and response variable and predictors:
myData = data_Beijing
yName = "PM" ; xName = c("HUMI","PRES","TEMP","WS","PREC")#the 5 variables selected in last step
dirName="BayesianLinearModel"
# Create the folder:
if(!dir.exists(dirName)){dir.create(dirName)}
# Specify prefix (i.e., filename root) for names of saved output files:
fileNameRoot = paste0(dirName,"/BayesianLinearModel-")
numSavedSteps=15000 ; thinSteps=5
graphFileType = "png" 
#------------------------------------------------------------------------------- 
# Load the relevant model into R's working memory:
source("BayesianLinearModel.R")
#------------------------------------------------------------------------------- 
# Generate the MCMC chain:
mcmcCoda = genMCMC( data=myData , xName=xName , yName=yName , 
                    numSavedSteps=numSavedSteps , thinSteps=thinSteps , 
                    saveName=fileNameRoot )

#------------------------------------------------------------------------------- 
# Display diagnostics of chain, for specified parameters:
parameterNames = varnames(mcmcCoda) # get all parameter names
for ( parName in parameterNames ) {
  diagMCMC( codaObject=mcmcCoda , parName=parName , 
            saveName=fileNameRoot , saveType=graphFileType )
}
#------------------------------------------------------------------------------- 
# Get summary statistics of chain:
summaryInfo = smryMCMC( mcmcCoda , 
                        saveName=fileNameRoot )
show(summaryInfo)
#------------------------------------------------------------------------------- 
# Display posterior information:
plotMCMC( mcmcCoda , data=myData , xName=xName , yName=yName , 
          pairsPlot=TRUE , showCurve=FALSE ,
          saveName=fileNameRoot , saveType=graphFileType )
#------------------------------------------------------------------------------- 

#V. Baeyesian model averaging
library(BAS)
bma_PM = bas.lm(PM ~ ., data = data_Beijing[,-1], prior = "BIC", 
                       modelprior = uniform(), method = "MCMC")
summary(bma_PM)
plot(bma_PM, which = 4, ask=FALSE)

#plot posterior distribution of model parameters
plot(coef(bma_PM),  ask=F)
plot(confint(coef(bma_PM)))
#use four estimator options
estimatorResults <- data.frame(BMA=double(),BPM=double(),MPM=double(),HPM=double(),stringsAsFactors=FALSE)
for (estimatorName in colnames(estimatorResults)) {
  print(coef(bma_PM,estimator = estimatorName))
}
## 95% credible intervals for these coefficients
confint(coef(bma_PM,estimator = estimatorName),level = 0.95)
yPred <- fitted(bma_PM, type = "response", estimator = "BMA")
library(ggplot2)
#plot predicted vs. observed PM 2.5
qplot(data_Beijing$PM, yPred, xlab = "Observed PM 2.5", ylab = "Predicted PM 2.5",
      main = "Predicted Vs Observed PM 2.5", xlim=c(0,300), ylim=c(0,300)) + 
      geom_abline(intercept = 0, slope = 1)

for (estimatorName in colnames(estimatorResults)) {
  y<- data_Beijing$PM
  y_pred = predict(bma_PM, data_Beijing, estimator=estimatorName)$fit
  #calculate R square and print out
  SST <- sum((y-mean(y))^2)
  SSE <- sum((y-y_pred)^2)
  R2 <- 1 - SSE/SST
  print(paste0("R square ",estimatorName," ",R2 ,sep = ""))
  
  #calculate RMSE 
  library(Metrics)
  RMSE = rmse(y, y_pred)
  print(paste0("RMSE ",estimatorName," ",RMSE ,sep = ""))
}

