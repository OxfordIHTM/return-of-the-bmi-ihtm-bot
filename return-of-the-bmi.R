# Return of the BMI exercise - 28 November 2023 --------------------------------


## Load libraries ----
library(dplyr)        ## for data manipulation
library(openxlsx)     ## for reading XLSX files
library(zscorer)      ## for calculating z-scores


## Read data ----

### Read CSV file from GitHub teaching_datasets repository ----
nut_data <- read.table(
  file = "https://raw.githubusercontent.com/OxfordIHTM/teaching_datasets/main/school_nutrition.csv",
  sep = ",", header = TRUE
)

### Download CSV file into data directory and then read the data ----
download.file(
  url = "https://raw.githubusercontent.com/OxfordIHTM/teaching_datasets/main/school_nutrition.csv",
  destfile = "data/school_nutrition.csv"
)

nut_data <- read.table(file = "data/school_nutrition.csv", sep = ",", header = TRUE)

### Read XLSX file from GitHub teaching datasets repository ----
nut_data_xlsx <- read.xlsx(xlsxFile = "https://raw.githubusercontent.com/OxfordIHTM/teaching_datasets/main/school_nutrition.xlsx")

### Download XLSX file into data directory and then read the data ----
download.file(
  url = "https://raw.githubusercontent.com/OxfordIHTM/teaching_datasets/main/school_nutrition.xlsx",
  destfile = "data/school_nutrition.xlsx",
  mode = "wb"
)

nut_data_xlsx <- read.xlsx(xlsxFile = "data/school_nutrition.xlsx")


## Create functions ----
## NOTE: I place all the functions I created in this section of my script so
## that they are all in one place and will be loaded into the environment when
## I run my script. After this section, I can use any of these functions in the
## subsequent lines of code.

### Function for calculating BMI ----

## NOTE: This function assumes that weight and height are in the desired or
## appropriate units; if not, values should be converted first

calculate_bmi <- function(weight, height) {
  weight / height ^ 2
}

### Function for classifying adult BMI using compound ifelse statements ----

classify_bmi <- function(bmi) {
  ifelse(
    bmi >= 30, "obese",
    ifelse(
      bmi < 30 & bmi >= 25, "overweight",
      ifelse(
        bmi < 25 & bmi >= 18.5, "normal", "underweight"
      )
    )
  )
}

### Function for classifying adult BMI using cut function ----
### NOTE: issue ?cut command to see how to use cut function

classify_bmi <- function(bmi) {
  cut(
    x = bmi,
    breaks = c(0, 18.5, 25, 30, Inf),
    labels = c("underweight", "normal", "overweight", "obese"),
    include.lowest = FALSE, right = TRUE
  )
}

### Function for classifying children BMI z-scores with compound ifelse statements ----

classify_bmi_children <- function(bmiz) {
  ifelse(
    bmiz > 2, "obese",
    ifelse(
      bmiz <= 2 & bmiz > 1, "overweight",
      ifelse(
        bmiz <= 1 & bmiz >= -2, "normal",
        ifelse(
          bmiz >= -3 & bmiz < -2, "thin", "severely thin"
        )
      )
    )
  )
}

### Function for classifying children BMI z-scores using cut function ----
### NOTE: issue ?cut command to see how to use cut function

classify_bmi_children <- function(bmiz) {
  cut(
    x = bmiz,
    breaks = c(-Inf, -3, -1.9999, 1, 2, Inf),
    labels = c("severely thin", "thin", "normal", "overweight", "obese"),
    include.lowest = FALSE, right = TRUE
  )
}


## Data processing ----

### Calculating BMI ----
### NOTE: I show here how to calculate BMI in different ways and store the 
### results in a new variable called bmi in the nut_data object.

#### Calculate BMI using basic operations and assigning to the bmi variable ----
nut_data$bmi <- nut_data$weight / (nut_data$height / 100) ^ 2

#### Calculate BMI using the function created for this purpose ----
nut_data$bmi <- calculate_bmi(nut_data$weight, nut_data$height / 100)

#### Calculate BMI using dplyr functions to add to the nut_data object ----
#### NOTE: Make sure that I have dplyr installed and that I have loaded the
#### package at the start of my script.

nut_data <- nut_data %>%
  mutate(bmi = calculate_bmi(weight, height / 100))


### Calculating BMI-for-age z-score using zscorer package ----
### NOTE: Make sure that I have zscorer installed and that I have loaded the
### package at the start of my script.

#### Calculate bmi-for-age z-score ----

nut_data$age_days <- nut_data$age_months * (365.25 / 12) ## addWGSR function requires age in days

nut_data <- addWGSR(
  data = nut_data, 
  sex = "sex", 
  firstPart = "weight", 
  secondPart = "height", 
  thirdPart = "age_days", 
  index = "bfa"
)

### Classify BMI-for-age z-score using ifelse (Approach 1) ----

nut_data$bmiz_classification_1 <- ifelse(
  nut_data$bfaz > 2, "obese",
  ifelse(
    nut_data$bfaz > 1 & nut_data$bfaz <= 2, "overweight",
    ifelse(
      nut_data$bfaz >= -3 & nut_data$bfaz < -2, "thin",
      ifelse(
        nut_data$bfaz < -3, "severely thin", "normal"
      )
    )
  )
)

### Classify BMI-for-age z-score using classify_bmi_children function (Approach 2) ----

nut_data$bmiz_classification_2 <- classify_bmi_children(nut_data$bfaz)

### Classify BMI-for-age z-score using dplyr (Approach 3) ----
nut_data <- nut_data %>%
  mutate(
    bmiz_classification_3 = case_when(
      bfaz > 2 ~ "obese",
      bfaz > 1 & bfaz <= 2 ~ "overweight",
      bfaz >= -3 & bfaz < -2 ~ "thin",
      bfaz < -3 ~ "severely thin",
      .default = "normal"
    )
  )

### Classify BMI-for-age z-score using dplyr and classify_bmi_children function (Approach 4) ----
nut_data <- nut_data %>%
  mutate(bmiz_classification_4 = classify_bmi_children(bfaz))

