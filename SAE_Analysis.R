library(jsonlite)
library(tidyverse)
library(rms)
library(brms)
library(bayesplot)


#Link and download temp file (Q4 2019 Serious Adverse Events reported to the FDA)
link <- 'https://download.open.fda.gov/animalandveterinary/event/2019q4/animalandveterinary-event-0001-of-0001.json.zip'
temp <- tempfile()
download.file(link, temp)

#unzip file and flatten relevant JSON as much as possible initially
json_data_source <- fromJSON(unz(temp, 'animalandveterinary-event-0001-of-0001.json'), flatten=TRUE)
json_data <- json_data_source$results


#Extract any observation classified as a serious adverse event
#Provided that a reaction was recorded and at least 1 animal was affected
json_data_stage1 <- (as.data.frame(json_data[json_data$serious_ae=='true', ])
              %>% filter(reaction != "NULL")
              %>% filter(number_of_animals_affected != "NA"))

#Reaction and drug columns contain multiple events and descriptors per reported instance
#map each event out individually as one distinct row of data

json_data_stage2 <- (json_data_stage1 %>% unnest_wider(outcome, simplify = TRUE, names_repair = "universal") 
                     %>% unnest_wider(drug, simplify = TRUE)
                     %>% unnest_longer(reaction, simplify=TRUE))

#Objective: find serious adverse events with known outcomes, see if relationship exists between outcome and drug/breed, age, weight, etc.
#Multinomial logistic regression, clustering/classification, neural networks possible, though sparsity is an issue
#Consider regularization/shrinkage in approaches
