# ==============================================================================
# SGH Advanced Business Analytics - Data Imputation Techniques - Assignment 1
# Group: X6 - Dataset A5
# ==============================================================================

# Load required libraries
library(tidyverse)  # Data processing & visualization (ggplot2, dplyr, readr)
library(VIM)        # Missing data visualization (aggr)
library(naniar)     # Missing data analysis
library(gridExtra)  # Arrange multiple plots
library(multcomp)
library(stats)
library(dplyr)
library(mice)

# Import data
file_path <- "https://e-web.sgh.waw.pl/akorczy/files/aba/data/task01/a5.csv"
data <- read_csv(file_path)

# Data preprocessing
# Convert categorical variables to factors.

data_clean <- data %>%
  mutate(
    contact = factor(contact, levels = c(0, 1, 2), 
                     labels = c("No Communication", "Channel A", "Channel B")),
    house_loan = factor(house_loan),
    education = factor(education),
    poutcome = factor(poutcome),
    y_newdeposit = factor(y_newdeposit, levels = c(0, 1), labels = c("No", "Yes"))
  )

# Check structure and basic summary of data
str(data_clean)
summary(data_clean)

# ==============================================================================
# Exploratory Data Analysis
# ==============================================================================

# --- Continuous variable: Age ---

p1 <- ggplot(data_clean, aes(x = age)) +
  geom_histogram(binwidth = 2, fill = "steelblue", color = "white") +
  theme_minimal() +
  labs(title = "Distribution of Age", x = "Age", y = "Count")

p2 <- ggplot(data_clean, aes(y = age)) +
  geom_boxplot(fill = "lightblue") +
  theme_minimal() +
  labs(title = "Boxplot of Age")

# --- Categorical variables: Contact, Education, House_loan, Poutcome ---
# Custom function for bar plots
plot_bar <- function(df, col_name, title) {
  ggplot(df, aes(x = .data[[col_name]], fill = .data[[col_name]])) +
    geom_bar() +
    theme_minimal() +
    theme(legend.position = "none") +
    labs(title = title, x = col_name, y = "Count") +
    coord_flip()
}

p3 <- plot_bar(data_clean, "contact", "Contact Channel Distribution")
p4 <- plot_bar(data_clean, "education", "Education Level")
p5 <- plot_bar(data_clean, "house_loan", "Housing Loan Status")
p6 <- plot_bar(data_clean, "poutcome", "Previous Outcome")

grid.arrange(p1, p2, p3, p4, p5, p6, ncol = 2)

# ==============================================================================
# Missing Data Analysis
# ==============================================================================

# Missing data proportions
missing_summary <- data_clean %>%
  summarise_all(~sum(is.na(.))) %>%
  gather(key = "Variable", value = "Missing_Count") %>%
  mutate(Percent = Missing_Count / nrow(data_clean) * 100) %>%
  arrange(desc(Percent))

print("Missing Data Summary:")
print(missing_summary)

# Visualize missingness (VIM package)
aggr_plot <- aggr(data_clean, col=c('navyblue','red'), numbers=TRUE, sortVars=TRUE, 
                  labels=names(data_clean), cex.axis=.7, gap=3, 
                  ylab=c("Histogram of Missing Data","Pattern"))

# Missingness mechanism check
# T-test and Chi-square test
data_check <- data_clean %>%
  mutate(is_missing_y = ifelse(is.na(y_newdeposit), "Missing", "Observed"))

# Compare age distribution between missing vs observed groups
p_miss_age <- ggplot(data_check, aes(x = is_missing_y, y = age, fill = is_missing_y)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Age Distribution by Missingness of Target Variable",
       x = "Y_NewDeposit Status", y = "Age")

print(p_miss_age)

# T-test for age difference between groups
t_test_result <- t.test(age ~ is_missing_y, data = data_check)
print(t_test_result)

# Chi square test for categorical variables between groups
categorical_vars <- c("contact", "house_loan", "education", "poutcome")

for (var in categorical_vars) {
  cat("\n========== Chi-square test for:", var, "============\n")
  
  tab <- table(data_check$is_missing_y, data_check[[var]])
  print(tab)
  
  print(chisq.test(tab))
}

# Create numerical missing indicator (1 = Missing, 0 = Observed)
data_check$is_missing_numeric <- ifelse(data_check$is_missing_y == "Missing", 1, 0)

# Logistic model to test missingness mechanism
missing_model <- glm(is_missing_numeric ~ age + contact + education + house_loan + poutcome, 
                     data = data_check, 
                     family = binomial(link = "logit"))

summary(missing_model)

# Odds ratios for interpretation
print("--- Odds Ratios (Exp of Coefficients) ---")
exp(coef(missing_model))

# ==============================================================================
# Building logit model under MCAR and MAR assumptions
# ==============================================================================

# Logit model
model_formula <- y_newdeposit ~ age + contact + house_loan + poutcome + education

# ==============================================================================
# MCAR - Complete Case Analysis (CCA)
# ==============================================================================
# Drop missing rows
data_no_missing <- data_clean %>%
  drop_na()

model_cca <- glm(model_formula,
                 data = data_no_missing,
                 family = binomial(link = "logit"))

print("--- CCA Model Summary (MCAR Assumption) ---")
summary(model_cca)

# ==============================================================================
# MAR - Multiple Imputation
# ==============================================================================

# Build initial imputation model
# m=5 for five imputed datasets - base imputation
# method='logreg' used for binary missing variables
# seed=123 ensures reproducibility
imp_data <- mice(data_clean, m = 5, method = 'logreg', seed = 123, print = FALSE)

print(imp_data$method)

# ==============================================================================
# Estimation on Imputed Data
# ==============================================================================

fit_imp <- with(imp_data, glm(y_newdeposit ~ age + 
                                relevel(contact, ref = "Channel B") +
                                house_loan + education + poutcome, 
                              family = binomial(link = "logit")))

pooled_results <- pool(fit_imp)

print("--- Pooled Results (MAR Assumption) ---")
summary(pooled_results, conf.int = TRUE)

# ==============================================================================
# Diagnostic measure to assess the imputation
# ==============================================================================
# Function to diagnose the imputation model using riv, fmi and trace plot
run_MI_logit <- function(m_value) {
  imp <- mice(data_clean, m = m_value, method = "logreg",
              seed = 123, print = FALSE)
  
  fit <- with(imp, 
              glm(y_newdeposit ~ age +
                    relevel(contact, ref = "Channel B") +
                    house_loan + education + poutcome,
                  family = binomial))
  
  pooled <- pool(fit)
  out <- pooled$pooled
  
  # Extract key stability metrics
  return(list(
    m = m_value,
    pooled = out,
    riv = out$riv,
    fmi = out$fmi,
    coef = out$estimate
  ))
}

# Diagnose initial model
run_MI_logit(m=5)

# Values of m to test
m_values <- c(20, 40, 60, 80, 100, 120, 140)

results <- lapply(m_values, run_MI_logit)

results
# Combine pooled coefficients into a dataframe for comparison
coef_table <- do.call(rbind, lapply(results, function(x) {
  data.frame(
    m = x$m,
    variable = x$pooled$term,
    estimate = x$coef,
    riv = x$riv,
    fmi = x$fmi
  )
}))

print(coef_table)

# Visualization of estimation by m
ggplot(coef_table, aes(x = m, y = estimate, color = variable)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  theme_minimal(base_size = 14) +
  labs(title = "Stability of Coefficients (Beta) Across Different m",
       x = "Number of Imputations (m)",
       y = "Coefficient Estimate") +
  theme(legend.position = "bottom")

# Visualization of riv by m
ggplot(coef_table, aes(x = m, y = riv, color = variable)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  theme_minimal(base_size = 14) +
  labs(title = "Relative Increase in Variance (RIV) Across m",
       x = "Number of Imputations (m)",
       y = "RIV") +
  theme(legend.position = "bottom")

# Visualization of fmi by m
ggplot(coef_table, aes(x = m, y = fmi, color = variable)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  theme_minimal(base_size = 14) +
  labs(title = "Fraction of Missing Information (FMI) Across m",
       x = "Number of Imputations (m)",
       y = "FMI") +
  theme(legend.position = "bottom")

# Build imputation model with m = 100
imp_data_final <- mice(data_clean, m = 100, method = 'logreg', seed = 123, print = FALSE)

print(imp_data_final$method)

# Estimation with imputation
fit_imp_final <- with(imp_data_final, glm(y_newdeposit ~ age + 
                                relevel(contact, ref = "Channel B") +
                                house_loan + education + poutcome, 
                              family = binomial(link = "logit")))

pooled_results_final <- pool(fit_imp_final)

summary(pooled_results_final)

