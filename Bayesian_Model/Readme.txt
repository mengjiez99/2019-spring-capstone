This is readme file for final project:
Predict Beijing PM2.5 with bayesian approaches
Authors: Mengjie Zhang, Yilin Wang

First install the following packages that will be used for this project:
plyr, ggplot2, reshape2, corrplot, runjags, rjags, BAS 

The FinalProject.R is the driver for this project. It includes five parts:
1. Preprocess the data.
   use a function dataPreprocess defined in EDA.R to preprocess the data.
   return a new data frame.

2. Exploratory data analysis.
   use a function eda defined in EDA.R to perform exploratory data analysis.
   check histograms of variables
   correlation analysis
   multiple linear model

3. Variable selection
   This step can take ~15 minutes.
   use bayesian hierarchical model comparison to select the the most credible model (set of predictors).
   use a training dataset to save time. 
   generate MCMC trace plots for each model parameter, the model probability plot of 6 models, the posterior marginal plot. 
   create a folder "VariableSelection" and save all plots there. 

4. Fit bayesian linear model
   This step can take 20~30 minutes. 
   generate MCMC trace plots for each model parameter, the pair correlation plot of parameters, the posterior marginal plot. 

5. Bayesian Model Averaging
   summary of the model
   plot posterior distribution of model parameters
   plot predicted vs. observed PM 2.5
   calculate R square and print out
