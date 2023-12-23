# Return of the BMI exercise - 28 November 2023 --------------------------------


## Load libraries ----
library(dplyr)        ## for data manipulation
library(tidyr)        ## for data manipulation to complement dplyr
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


## Data analysis ----

### Testing the normality of the BMI-for-age z-score ----

#### Boxplot of BMI-for-age z-score ----

boxplot(nut_data$bfaz,
        ylab = "BMI-for-age z-score",                ## Add y-axis label
        main = "Boxplot of BMI-for-age z-score",     ## add a title to plot
        frame.plot = FALSE)                          ## remove plot frame

boxplot(bfaz ~ sex,                                  ## use formula method
        data = nut_data,
        names = c("Male", "Female"),                 ## Name each boxplot instead of 1 and 2
        ylab = "BMI-for-age z-score",
        main = "Boxplot of BMI-for-age z-score by sex",
        frame.plot = FALSE)

#### Histogram of BMI-for-age z-score ----

##### Histogram of BMI-for-age z-score for all students ----
hist(nut_data$bfaz,
     xlab = "BMI-for-age z-score",
     main = "Distribution of BMI-for-age z-score")

##### Histogram of BMI-for-age z-score by sex ----
par(mfrow = c(1, 2))        ## Create 2 plotting regions side-by-side

with(
  nut_data,
  {
    hist(bfaz[sex == 1],    ## bfaz for males
         xlim = c(-7, 2),   ## expand limits of x-axis
         ylim = c(0, 50),   ## set limits of y-axis
         xlab = "Male",     ## set x-axis label to Male
         main = "")         ## remove plot title for males
    hist(bfaz[sex == 2],    ## bfaz for females
         xlim = c(-7, 2),   ## expand limits of x-axis
         ylim = c(0, 50),   ## set limits of y-axis
         xlab = "Female",   ## set x-axis label to Female
         main = "")         ## remove plot title for females
  }
)

par(mfrow = c(1, 1))        ## return graphical window back to one plot region
title(
  main = "Distribution of BMI-for-age z-score by sex",
  xlab = "BMI-for-age z-score"
)

#### Test normality of BMI-for-age z-score statistically ----

##### Test normality of BMI-for-age z-score for all students ----
shapiro.test(nut_data$bfaz)

##### Test normality of BMI-for-age z-score for male and female students ----
with(nut_data, tapply(bfaz, sex, shapiro.test))


## Summarising BMI data using base R functions ----

### Mean bfaz
mean_overall_bfaz <- mean(nut_data$bfaz)                     ## Overall mean
mean_sex_bfaz <- with(nut_data, tapply(bfaz, sex, mean))     ## mean by sex
mean_bfaz <- c(mean_sex_bfaz, mean_overall_bfaz)             ## concatenate
names(mean_bfaz) <- c("Males", "Females", "Overall")

### classify nutrition status to undernourished and overnourished ----
nut_data$nut_status <- ifelse(
  nut_data$bmiz_classification_4 %in% c("thin", "severely thin"), "undernourished",
  ifelse(
    nut_data$bmiz_classification_4 %in% c("normal"), "normal", "overnourished"
  )
)

### Tabulate numbers by nutrition status ----
nut_count_overall <- with(nut_data, table(nut_status))   ## overall counts
nut_count_sex <- with(nut_data, table(sex, nut_status))  ## counts by sex

nut_status_count <- data.frame(                          ## concatenate to 
  rbind(nut_count_sex, nut_count_overall)                ## single table
)
row.names(nut_status_count) <- c("Males", "Females", "Overall") ## tidy row names

### Tabulate proportions by nutrition status ----
nut_prop_overall <- prop.table(nut_count_overall)         ## overall proportions
nut_prop_sex <- prop.table(nut_count_sex)                 ## proportions by sex

nut_status_prop <- data.frame(                            ## concatenate to
  rbind(nut_prop_sex, nut_prop_overall)                   ## single table
)
row.names(nut_status_prop) <- c("Males", "Females", "Overall")  ## tidy row names

### Combine counts and proportions ----
nut_status_tab <- data.frame(nut_status_count, nut_status_prop)
names(nut_status_tab) <- c(
  "n_normal", "n_overnourished", "n_undernourished", 
  "prop_normal", "prop_overnourished", "prop_undernourished"
)

### Add mean bmi-for-age z-score to table ----
nut_status_tab <- data.frame(
  mean_bfaz, nut_status_tab
)

### Arrange table columns ----
nut_status_tab <- nut_status_tab[ , c("mean_bfaz", "n_normal", "prop_normal", "n_overnourished", "prop_overnourished", "n_undernourished", "prop_undernourished")]


## Summarising BMI data using dplyr and tidyr functions ----

nut_status_summary <- nut_data %>%
  group_by(sex) %>%
  summarise(mean_bfaz = mean(bfaz), .groups = "drop") %>%   ## get mean z-score by sex
  mutate(sex = ifelse(sex == 1, "Males", "Females")) %>%    ## recode sex
  rbind(
    nut_data %>% 
      summarise(sex = "Overall", mean_bfaz = mean(bfaz))    ## Get mean z-score for all
  ) %>%
  left_join(
    nut_data %>%
      mutate(n_total = n()) %>%
      group_by(sex) %>%
      add_count(nut_status) %>%         ## count per nut_status value
      group_by(sex, nut_status) %>%
      summarise(n_total = unique(n_total), n = unique(n), .groups = "drop") %>%
      mutate(prop = n / n_total) %>%    ## calculate proportion of nut_status by sex
      pivot_wider(names_from = nut_status, values_from = n:prop) %>%    ## spread the table
      mutate(sex = ifelse(sex == 1, "Males", "Females")) %>%            ## recode sex
      select(-n_total) %>%                                              ## remove n_total column           
      rbind(
        nut_data %>%
          mutate(n_total = n()) %>%
          add_count(nut_status) %>%
          group_by(nut_status) %>%
          summarise(n_total = unique(n_total), n = unique(n), .groups = "drop") %>%
          mutate(prop = n / n_total) %>%
          pivot_wider(names_from = nut_status, values_from = n:prop) %>%
          mutate(sex = "Overall", .before = n_total) %>%
          select(-n_total)
      ),
    by = "sex"
  ) %>%
  mutate(n_overnourished = ifelse(is.na(n_overnourished), 0, n_overnourished))


## Statistical tests ----

### Test whether difference in mean z-score for males and females is ----
### statistically significant

#### t.test for difference in mean BMI-for-age z-score for males and females ---
#### using default method
t_test_result <- t.test(
  x = nut_data$bfaz[nut_data$sex == 1], 
  y = nut_data$bfaz[nut_data$sex == 2]
)

#### t.test for difference in mean BMI-for-age z-score for males and females ---
#### using formula method
t_test_result <- t.test(bfaz ~ sex, data = nut_data)

### Test whether the nutritional status distribution in males and females ----
### is statistically significant
chisq.test(with(nut_data, table(nut_status, sex)), simulate.p.value = TRUE)
fisher.test(with(nut_data, table(nut_status, sex)), simulate.p.value = TRUE)

### Test whether proportion of overnourished is different between males ----
### and females using chi-square test or fisher exact test
nut_data$overnourished <- ifelse(nut_data$nut_status == "overnourished", 1, 0)
chisq.test(with(nut_data, table(overnourished, sex)), simulate.p.value = TRUE)
fisher.test(with(nut_data, table(overnourished, sex)))

### Test whether proportion of undernourished is different between males ----
### and females using chi-square test or fisher exact test
nut_data$undernourished <- ifelse(nut_data$nut_status == "undernourished", 1, 0)
chisq.test(with(nut_data, table(undernourished, sex)), simulate.p.value = TRUE)
fisher.test(with(nut_data, table(undernourished, sex)))
