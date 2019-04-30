#define the function dataPreprocess to clean the dataset, 
#and convert hourly observation to daily observation (calculate the mean)
dataPreprocess <- function(fileName){
  #load the csv file
  df <- read.csv(fileName)
  head(df)
  #look at structure and summary of dataset
  str(df)
  summary(df)
  #set categorical variables as factors and merge year,month,day to a variable date
  df$season <- as.factor(df$season)
  df$date <- as.Date(with(df, paste(year, month, day,sep="-")), "%Y-%m-%d")
  #drop unnecessary variables
  df$No <- NULL
  #PM_Dongsi,PM_Dongsihuan and PM_Nongzhanguan (different monitoring stations) have a lot of missing values
  #so we only keep PM_US.post here
  df$PM_Dongsi <- NULL
  df$PM_Dongsihuan <- NULL
  df$PM_Nongzhanguan <- NULL
  df$cbwd <- NULL
  #Iprec is the cumulated precipitation and is not necessary to keep 
  #since we already have hourly precipitation measurement
  df$Iprec <- NULL
  
  #rename variable names
  colnames(df)[6] <- "PM"
  colnames(df)[11] <- "WS"
  colnames(df)[12] <- "PREC"
  
  #the original data frame has hourly measurement from 2010 to 2015 (6 years)
  #>50,000 observations, so MCMC would take very long time.
  #in order to reduce number of obervations, we calculate the mean of each variable by day and return a new dataframe
  
  names(df)
  library(plyr)
  df_day <- ddply(df, .(date), summarize,  PM=mean(PM), DEWP=mean(DEWP), HUMI=mean(HUMI), PRES=mean(PRES), TEMP=mean(TEMP), WS=mean(WS), PREC=mean(PREC))
  
  summary(df_day)
  
  #remove rows of miss values
  df_day <- na.omit(df_day)
  
  return(df_day)
}

#define the function eda to perform exploratory data analysis
eda <- function(df){
  
  #check the histogram of response variable PM
  par(mfrow=c(1,2))
  hist(df$PM, xlab="PM 2.5", main="PM 2.5")
  #the response variable PM is highly skewed,so we do log transformation
  hist(log(df$PM), xlab="Log PM 2.5", main="Log PM 2.5")
  
  #check the histogram of predictor variables
  par(mfrow=c(2,3))
  hist(df$DEWP, xlab="Dew point", main="Dew point")
  hist(df$HUMI, xlab="humidity", main= "humidity")
  hist(df$PRES, xlab="pressure", main="pressure")
  hist(df$TEMP, xlab="temperature", main="temperature")
  #hist(df$WS, xlab="wind speed", main= " wind speed")
  #hist(df$PREC, xlab="precipitation", main="precipitation")
  #the predictors Iws and precipitation are highly skewed
  #so we also check the histrogram of log transformation
  hist(log(df$WS), xlab="Log wind speed", main= "Log wind speed")
  hist(log(df$PREC), xlab="Log precipitation", main="Log precipitation")
  
  #plot the trend of PM2.5 with date
  library(ggplot2)
  g1 <- ggplot(df, aes(x=date, y=PM)) + geom_bar(stat="identity", fill="steelblue")+ xlab("Date")+ ylab("PM 2.5")
  print(g1)
  
  #log transformation before correlation analysis
  df$PM <- log(df$PM)
  df$WS <- log(df$WS)
  df$PREC <- log(df$PREC+0.01) #precipitation has lots of zero so use log(x+1)
  
  #plot the response variable over each predictor
  library(reshape2)
  df_melt <- melt(df[,-1], id="PM")
  g2 <- ggplot(df_melt,aes(x=value, y=PM)) + facet_wrap(~variable, scales = "free") + 
    geom_point(size=1)
  print(g2)

  #Check the correlation matrix and multi-colliearity
  library(corrplot)
  Corr = cor(df[,-1])
  round(Corr,2)
  par(mfrow=c(1,1))
  corrplot(Corr, method = "number", type="lower", tl.srt=45)
  
  #fit a linear model
  model <- lm(PM ~ ., data=df[,-1])
  print(summary(model))
  plot(model)
  
  model2 <- lm(PM ~ HUMI + WS , data=df[,-1])
  print(summary(model2))
}