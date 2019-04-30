# Capstone-2019Spring
This is my Data Science Capstone Project. This project aims to predict PM2.5 using two different approaches: Bayesian Hierarchical Model and LSTM network.  
## Dataset
The dataset is downloaded from UCI Machine Learning Repository (http://archive.ics.uci.edu/ml/datasets/PM2.5+Data+of+Five+Chinese+Cities). 
## Dataset Processing
The data processing for Bayesian model is in EDA.R in Bayesian_Model directory.
The data processing for LSTM model is in preprocess.ipynb, processed files are saved in processedData directory.
## Bayesian Hierachical Model
The results are generated in Bayesian_Model.R, include variable selection, bayesian linear regression, and bayesian model averaging.

Variable selection --model with highest probablity
![variable selection --model with highest probablity](Figures/variable_selection.png)

Bayesian linear model <br />
![](Figures/Bayesian_linear_model.png)

Bayesian model averaging
![](Figures/Bayesian_model_averging.png)

## LSTM Model
The results are generated in LSTM_model.ipynb, include timeseries plots, loss function history, and model prediction.

Timeseries plots of PM2.5 and predictors
![](Figures/timeseries_plots.png)

Timeseries plots of Pm2.5 in five cities
![](Figures/Five_cities_timeseries.png)

LSTM network training --loss function
![](Figures/loss_function.png)

Model prediction -- e.g. Chengdu <br />
![](Figures/model_prediction_chengdu.png)
