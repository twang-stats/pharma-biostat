library(jsonlite)
library(dplyr)
library(rms)
library(brms)
library(bayesplot)


#Link and download temp file (Q4 2019 Serious Adverse Events reported to the FDA)
link <- 'https://download.open.fda.gov/animalandveterinary/event/2019q4/animalandveterinary-event-0001-of-0001.json.zip'
temp <- tempfile()
download.file(link, temp)

#unzip file and flatten relevant JSON as much as possible initially
json_data_source <- fromJSON(unz(temp, 'animalandveterinary-event-0001-of-0001.json'), flatten=TRUE)
json_data <- flatten(json_data_source$results)


#Extract any observation classified as a serious adverse event
#Remove null rows of things like drug expiry (we want health events only here)
drug_data <- (as.data.frame(json_data[json_data$serious_ae=='true', ])
              %>% filter(reaction != "NULL"))

#Reaction column contains multiple events and descriptors per animal
#map each event out individually as one distinct row of data
#Loop over the rest of the dataset to do so
#Note that the drug column is like this as well

clean2 <- c()
for (i in 1:(dim(drug_data)[1])){
  sae <- drug_data$reaction[[i]]
  ainfo <- drug_data[i, -c(1)] %>% slice(rep(1, dim(sae)[1]))
  clean2 <- bind_rows(clean2, bind_cols(sae, ainfo))
}

#Extract drug information
#Row 11 is problematic - entered as list, all other rows are as characters

rows <- c()
for (i in 1:11){
  newdrug <- unlist(drug[i], recursive = FALSE)
  rows <- bind_rows(rows,drug[i])
}

  
#Objective: find serious adverse events with known outcomes, see if relationship exists between outcome and drug/breed, age, weight, etc.
#Multinomial logistic regression, clustering/classification, neural networks possible, though sparsity is an issue
#Consider regularization/shrinkage in approaches
