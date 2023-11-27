
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Return of the BMI (Data processing and statistical analysis in R)

<!-- badges: start -->
<!-- badges: end -->

This repository is an exercise in processing data and performing
statistical analysis in R using a dataset from a Pakistan school
nutrition survey of students older than 10 years old.

By this time, you should already know how to clone this repository into
your local machine using RStudio. If you need a refresher, the following
tutorial shows the steps on how to do this -
<https://oxford-ihtm.io/ihtm-handbook/clone-repository.html>.

## Instructions for the assignment

The following tasks have been designed to help students get familiar
with processing of data and performing statistical analysis in R.

The students are expected to go through the tasks and appropriately
write R code/script to fulfil the tasks and/or to answer the question/s
being asked within the tasks. R code/script should be written inside a
single R file named `return_of_the_bmi.R` and saved in the project’s
root directory.

## Task 1: Honey, I lost the data!

For some reason, the data `school_nutrition.csv` has been lost and is
not found within the `data` folder within the project directory.

Thankfully, this data is available via Oxford IHTM’s GitHub repository
called `teaching_datasets` found at
<https://github.com/OxfordIHTM/teaching_datasets>. In this repository,
there are two files in different formats that both contain the dataset
we need for this exercise. There is the CSV file called
`school_nutrition.csv` which is the exact same dataset that you had in
the previous exercise and there is also the XLSX file called
`school_nutrition.xlsx` which is the exact same dataset but as an Excel
file.

For this task, you should look into ways to get back the school
nutrition data and read it into R as we did previously.

1.  Looking deeper into the `read.table()` function (`?read.table`), is
    there a way to read a CSV file directly from a URL or web link? If
    so, write code that does this.

2.  You may want to be able to download the dataset and save it back
    into the `data` directory. The function `download.file()`
    (`?download.file`) can be used for this purpose. Write code that
    would download the CSV file into the `data` directory of the project
    and then read the CSV file from the `data` directory into R.

3.  It would be good to learn how to read data from an XLSX file as it
    will not be uncommon these days to have data in XLSX format. For
    this purpose, the `openxlsx` package will be useful, specifically
    its `read.xlsx()` function. Install `openxlsx` (if you haven’t done
    so already), load it into your environment (`library(openxlsx)`),
    and then read up on the `read.xlsx()` function (`?read.xlsx`) to
    figure out how to read the `student_nutrition.xlsx` file via URL
    using the `read.xlsx()` function. Write code that shows these steps.

## Task 2: Calculate BMI

Now that you have the school nutrition data into your R environment,
write code that would calculate the BMI for each student in the dataset
and then add this value as a new variable called `bmi` in the student
nutrition dataset object.

To make this more challenging, please write a function that will
specifically make this calculation of BMI. You have done this already
earlier so make sure you pick up on feedback provided earlier to improve
the function you have written.

## Task 3: Calculating age-standardised BMI

Unlike adults, BMI for children need to be age-standardised. For this,
calculation of z-scores is the statistical approach used.

Read up on z-scores and how they are calculated. Then try to find an R
package that has function/s that will calculate z-scores for BMI that
adjusts for sex and age. Once you have found such package, learn how to
use the specific function/s and then implement this in your code by
calculating the BMI-for-age z-score for each student and then add this
value as a new variable called `bfaz` in the student nutrition dataset
object.

Once you have calculated `bfaz`, create an R function that will classify
the BMI status of each student based on their BMI-for-age z-score.
Following are the cut-offs for BMI-for-age z-score based on the WHO
Growth Standards:

| BMI-for-age z-score range              | Classification |
|:---------------------------------------|:---------------|
| BMI-for-age z-score \> 2 SD            | Obese          |
| 2 SD \>= BMI-for-age z-score \> 1 SD   | Overweight     |
| 1 SD \>= BMI-for-age z-score \>= -2 SD | Normal         |
| -2 SD \> BMI-for-age z-score \>= -3 SD | Thin           |
| BMI-for-age z-score \< -3 SD           | Severely thin  |

## Task 4: Show and test the normality of the distribution of the BMI-for-age z-score variable

Write code that tests the normality of the BMI variable and answer the
following questions:

- Is the BMI-for-age z-score of all students in the sample normally
  distributed?

- Is the BMI-for-age z-score of all the male students in the sample
  normally distributed?

- Is the BMI-for-age z-score of all the female students in the sample
  normally distributed?

Please write a script that shows normality **graphically** and through
**formal statistical test/s**.

## Task 5: Summarising BMI data

Write code that summarises the data as follows:

- Mean value of BMI-for-age z-score for male and female students and
  overall;

- Number and proportion of children who are undernourished based on
  BMI-for-age z-score (at least thin);

- Number and proportion of children who are over-nourished based on
  BMI-for-age z-score (at least overweight).

Please show your results as rectangular data (data.frame or table
format) with the rows for values for males, females, and overall and
columns showing the summaries of interest (mean, sum, proportion) as
shown in the dummy table below:

| **grouping** | **mean_bfaz** | **n_undernourished** | **prop_undernourished** | **n_overnourished** |
|:-------------|:--------------|:---------------------|:------------------------|:--------------------|
| **females**  |               |                      |                         |                     |
| **males**    |               |                      |                         |                     |
| **overall**  |               |                      |                         |                     |

## Task 6: Statistical tests

Knowing what you know now about performing statistical tests from your
Epi/Stats lectures, please answer the following questions by writing
appropriate R code/script:

- Is there a difference between the mean BMI-for-age z-score of male
  students compared to the female students?

- Is there a difference between the proportion of undernourished male
  students compared to undernourished female students?

- Is there a difference between the proportion of overnourished male
  students compared to overnourished female students?
