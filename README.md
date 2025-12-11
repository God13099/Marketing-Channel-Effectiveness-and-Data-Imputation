# Advanced Business Analytics: Marketing Channel Effectiveness & Data Imputation

**Course:** Advanced Business Analytics (Group X6 - Dataset A5)  
**Institution:** SGH Warsaw School of Economics  
**Authors:** Ky Anh Le, Giang Nguyen, Mengzhen Shang, Liyuan Cao 
**Professor:** Adam Korczyński 

## 📌 Project Overview

The primary objective of this study is to evaluate the effectiveness of customer outreach channels. Specifically, the research determines whether contacting customers through **Communication Channel A** leads to a higher likelihood of purchasing a new financial product compared to **Communication Channel B**.

A critical challenge in this dataset was handling missing values in the target variable (`y_newdeposit`), which accounted for 16% of the data.

## 📂 Repository Structure

* **`GroupX6(A5)_Task1_report.pdf`**: The detailed analytical report containing exploratory data analysis, missing data diagnostics, and model interpretation.
* **`GroupX6(A5)_Task1_code.R`**: The R script used for data processing, visualization, statistical testing, and multiple imputation (MICE).
* **`a5.csv`**: The raw dataset used for the analysis, containing 9,947 observations of bank marketing campaigns.

## 🛠 Methodology

The analysis follows a rigorous statistical framework:

1.  **Exploratory Data Analysis (EDA):** Analyzed distributions of Age, Education, Housing Loans, and Contact methods.
2.  **Missing Data Mechanism Analysis:**
    * Performed t-tests and Chi-square tests to compare observed vs. missing groups.
    * Identified the mechanism as **Missing At Random (MAR)**, driven by variables like Age and Contact Channel.
3.  **Imputation:**
    * Used **MICE (Multivariate Imputation by Chained Equations)** with `m=100` imputations to handle missing data.
    * Diagnostic checks using Relative Increase in Variance (RIV) and Fraction of Missing Information (FMI) confirmed stability at $m \ge 100$.
4.  **Modeling:**
    * Compared a **Complete-Case Analysis (Logit)** against the **Pooled Multiple Imputation Model**.
    * Channel B was set as the reference category to measure the relative effectiveness of Channel A.

## 📊 Key Findings

* **Channel Effectiveness:** The analysis found **no statistically significant difference** between Channel A and Channel B (Estimate = -0.101, p = 0.508).
* **Impact of No Contact:** Not contacting customers significantly reduces purchase odds compared to using Channel B.
* **Key Predictors:** The strongest predictor of a purchase is a **previous successful campaign outcome**. Housing loans and older age are associated with a lower likelihood of purchase.

## 💻 Dependencies

To run the R code, the following libraries are required:

```r
library(tidyverse)
library(VIM)
library(naniar)
library(gridExtra)
library(multcomp)
library(mice)
