# Advanced Business Analytics: Marketing Channel Effectiveness & Data Imputation

**Course:** Advanced Business Analytics (Group X6 - Dataset A5)  
**Institution:** SGH Warsaw School of Economics  
[cite_start]**Authors:** Ky Anh Le, Giang Nguyen, Mengzhen Shang, Liyuan Cao [cite: 5]  
[cite_start]**Professor:** Adam Korczyński [cite: 6]

## 📌 Project Overview

The primary objective of this study is to evaluate the effectiveness of customer outreach channels. [cite_start]Specifically, the research determines whether contacting customers through **Communication Channel A** leads to a higher likelihood of purchasing a new financial product compared to **Communication Channel B**[cite: 10].

[cite_start]A critical challenge in this dataset was handling missing values in the target variable (`y_newdeposit`), which accounted for 16% of the data[cite: 63, 64].

## 📂 Repository Structure

* **`GroupX6(A5)_Task1_report.pdf`**: The detailed analytical report containing exploratory data analysis, missing data diagnostics, and model interpretation.
* **`GroupX6(A5)_Task1_code.R`**: The R script used for data processing, visualization, statistical testing, and multiple imputation (MICE).

## 🛠 Methodology

The analysis follows a rigorous statistical framework:

1.  **Exploratory Data Analysis (EDA):** Analyzed distributions of Age, Education, Housing Loans, and Contact methods.
2.  **Missing Data Mechanism Analysis:**
    * Performed t-tests and Chi-square tests to compare observed vs. missing groups.
    * [cite_start]Identified the mechanism as **Missing At Random (MAR)**, driven by variables like Age and Contact Channel[cite: 89].
3.  **Imputation:**
    * [cite_start]Used **MICE (Multivariate Imputation by Chained Equations)** with `m=100` imputations to handle missing data[cite: 116].
    * [cite_start]Diagnostic checks using Relative Increase in Variance (RIV) and Fraction of Missing Information (FMI) confirmed stability at $m \ge 100$[cite: 158].
4.  **Modeling:**
    * Compared a **Complete-Case Analysis (Logit)** against the **Pooled Multiple Imputation Model**.
    * [cite_start]Channel B was set as the reference category to measure the relative effectiveness of Channel A[cite: 119].

## 📊 Key Findings

* [cite_start]**Channel Effectiveness:** The analysis found **no statistically significant difference** between Channel A and Channel B (Estimate = -0.101, p = 0.508)[cite: 162].
* [cite_start]**Impact of No Contact:** Not contacting customers significantly reduces purchase odds compared to using Channel B[cite: 127].
* [cite_start]**Key Predictors:** The strongest predictor of a purchase is a **previous successful campaign outcome**[cite: 136]. [cite_start]Housing loans and older age are associated with a lower likelihood of purchase[cite: 130, 129].

## 💻 Dependencies

To run the R code, the following libraries are required:

```r
library(tidyverse)
library(VIM)
library(naniar)
library(gridExtra)
library(multcomp)
library(mice)
---
*Disclaimer: This project was conducted for academic purposes at SGH Warsaw School of Economics.*
