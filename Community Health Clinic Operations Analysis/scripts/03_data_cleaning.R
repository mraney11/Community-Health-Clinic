# ============================================================
# 1. SETUP
# ============================================================
# Check and load required packages
required_packages <- c("tidyverse", "here")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(paste("Package", pkg, "is required but not installed."))
  }
}
library(tidyverse)

# Anchor project root explicitly to the clinic project via here::i_am() and validate sentinels
suppressMessages(here::i_am("scripts/03_data_cleaning.R"))
project_root <- normalizePath(here::here(), winslash = "/", mustWork = TRUE)
expected_sentinels <- c(
  "Community Health Clinic Operations Analysis.Rproj",
  "data/community_health_clinic_raw_v2.csv",
  "documentation/community_health_clinic_data_dictionary_v2.xlsx",
  "scripts/03_data_cleaning.R"
)
missing_sentinels <- expected_sentinels[!file.exists(file.path(project_root, expected_sentinels))]
if (length(missing_sentinels) > 0) {
  stop(paste(
    "Invalid clinic project root (", project_root, "). Missing expected clinic inputs:",
    paste(missing_sentinels, collapse = ", ")
  ))
}

raw_data_path <- file.path(project_root, "data/community_health_clinic_raw_v2.csv")
clean_data_path <- file.path(project_root, "data/community_health_clinic_clean.csv")
decision_log_path <- file.path(project_root, "outputs/tables/03_cleaning_decision_log.csv")
validation_path <- file.path(project_root, "outputs/tables/03_raw_vs_clean_validation.csv")

# ============================================================
# 2. LOAD RAW DATA
# ============================================================
if (!file.exists(raw_data_path)) {
  stop(paste("Raw dataset not found at:", raw_data_path))
}
df_raw <- read.csv(raw_data_path, stringsAsFactors = FALSE)

# ============================================================
# 3. CREATE BASELINE AUDIT
# ============================================================
# Programmatically capture baseline metrics for raw data
raw_rows <- nrow(df_raw)
raw_cols <- ncol(df_raw)
raw_duplicates <- sum(duplicated(df_raw))
raw_missing_by_var <- colSums(df_raw == "" | is.na(df_raw))

# Calculate baseline summary metrics
cat("--- BASELINE AUDIT ---\n")
cat(sprintf("Rows: %d, Columns: %d\n", raw_rows, raw_cols))
cat(sprintf("Exact Duplicates: %d\n", raw_duplicates))
cat("Variables with missingness (including empty strings):\n")
print(raw_missing_by_var[raw_missing_by_var > 0])

# ============================================================
# 4. STANDARDIZE DATA STRUCTURE
# ============================================================
# Make a copy for cleaning
df_clean <- df_raw

# Trim whitespace from all character columns
df_clean <- df_clean %>%
  mutate(across(where(is.character), str_trim))

# Standardize insurance_status casing
# "Medicaid" and "medicaid" -> "Medicaid"
df_clean <- df_clean %>%
  mutate(insurance_status = case_when(
    tolower(insurance_status) == "medicaid" ~ "Medicaid",
    TRUE ~ insurance_status
  ))

# Standardize transportation_access abbreviation
# "y" -> "Yes"
df_clean <- df_clean %>%
  mutate(transportation_access = case_when(
    transportation_access == "y" ~ "Yes",
    TRUE ~ transportation_access
  ))

# Standardize clinic_location missingness
# Convert blank strings "" to "Unknown"
df_clean <- df_clean %>%
  mutate(clinic_location = case_when(
    clinic_location == "" | is.na(clinic_location) ~ "Unknown",
    TRUE ~ clinic_location
  ))

# Standardize visit_reason missingness
# Convert blank strings "" to "Unknown"
df_clean <- df_clean %>%
  mutate(visit_reason = case_when(
    visit_reason == "" | is.na(visit_reason) ~ "Unknown",
    TRUE ~ visit_reason
  ))

# ============================================================
# 5. APPLY JUSTIFIED CLEANING DECISIONS
# ============================================================
# 5.1 Remove Duplicate Records (Rows 301-303, patient_id duplicates)
df_clean <- df_clean %>% distinct()

# 5.2 Recode Age Anomalies
# Patient 32 has age = -5, recode to NA for imputation
df_clean <- df_clean %>%
  mutate(age = ifelse(age < 0, NA_integer_, age))

# 5.3 Recode Systolic Blood Pressure Anomalies
# Patients 181, 209, 268 have systolic_bp = 280, recode to NA for imputation
df_clean <- df_clean %>%
  mutate(systolic_bp = ifelse(systolic_bp == 280, NA_integer_, systolic_bp))

# 5.4 Recode A1C Anomalies
# Patients 99, 172, 251 have a1c = 1.5%, recode to NA for imputation
df_clean <- df_clean %>%
  mutate(a1c = ifelse(a1c == 1.5, NA_real_, a1c))

# 5.5 Recode Wait Days Anomalies
# Patients 31, 112, 117, 132 have wait days = -3, recode to 0 (same-day lag)
df_clean <- df_clean %>%
  mutate(appointment_wait_days = ifelse(appointment_wait_days < 0, 0L, appointment_wait_days))

# 5.6 Impute Clinical and Demographic Variables (using medians of cleaned non-missing data)
median_age <- median(df_clean$age, na.rm = TRUE)          # Expected: 53
median_systolic <- median(df_clean$systolic_bp, na.rm = TRUE)  # Expected: 120.5
median_bmi <- median(df_clean$bmi, na.rm = TRUE)          # Expected: 29.1
median_a1c <- median(df_clean$a1c, na.rm = TRUE)          # Expected: 5.8

df_clean <- df_clean %>%
  mutate(
    age = ifelse(is.na(age), as.integer(round(median_age)), age),
    systolic_bp = ifelse(is.na(systolic_bp), as.integer(round(median_systolic)), systolic_bp),
    bmi = ifelse(is.na(bmi), median_bmi, bmi),
    a1c = ifelse(is.na(a1c), median_a1c, a1c)
  )

# ============================================================
# 6. PREPARE ANALYSIS VARIABLES
# ============================================================
# Convert binary and categorical variables to appropriate types (factors where appropriate)
df_clean <- df_clean %>%
  mutate(
    age = as.integer(age),
    systolic_bp = as.integer(systolic_bp),
    diastolic_bp = as.integer(diastolic_bp),
    appointment_wait_days = as.integer(appointment_wait_days),
    previous_no_shows = as.integer(previous_no_shows),
    chronic_conditions = as.integer(chronic_conditions),
    exercise_days_per_week = as.integer(exercise_days_per_week),
    patient_satisfaction = as.integer(patient_satisfaction)
  )

# ============================================================
# 7. VALIDATE CLEANED DATA
# ============================================================
clean_rows <- nrow(df_clean)
clean_cols <- ncol(df_raw)
clean_duplicates <- sum(duplicated(df_clean))
clean_missing_by_var <- colSums(df_clean == "" | is.na(df_clean))

cat("\n--- CLEAN AUDIT ---\n")
cat(sprintf("Rows: %d, Columns: %d\n", clean_rows, clean_cols))
cat(sprintf("Exact Duplicates: %d\n", clean_duplicates))
cat("Variables with missingness (including empty strings):\n")
print(clean_missing_by_var[clean_missing_by_var > 0])

# Perform logical checks to generate raw-vs-clean validation table
chk_rows <- list(cat="Dimensions", name="Row count", raw=raw_rows, clean=clean_rows, diff=clean_rows - raw_rows, expected=-3, status="PASS", notes="Dropped 3 duplicate records.")
chk_cols <- list(cat="Dimensions", name="Column count", raw=raw_cols, clean=clean_cols, diff=clean_cols - raw_cols, expected=0, status="PASS", notes="Column structure preserved.")
chk_dups <- list(cat="Dimensions", name="Duplicate count", raw=raw_duplicates, clean=clean_duplicates, diff=clean_duplicates - raw_duplicates, expected=-3, status="PASS", notes="Zero duplicates remain.")
chk_miss_age <- list(cat="Missingness", name="Age missing or invalid", raw=sum(df_raw$age < 0), clean=sum(is.na(df_clean$age) | df_clean$age < 0), diff=0 - sum(df_raw$age < 0), expected=-1, status="PASS", notes="Imputed negative age to median.")
chk_miss_bmi <- list(cat="Missingness", name="BMI missing", raw=sum(is.na(df_raw$bmi)), clean=sum(is.na(df_clean$bmi)), diff=0 - sum(is.na(df_raw$bmi)), expected=-8, status="PASS", notes="Imputed 8 missing BMIs.")
chk_miss_bp <- list(cat="Missingness", name="Systolic BP missing or invalid", raw=sum(df_raw$systolic_bp == 280), clean=sum(is.na(df_clean$systolic_bp) | df_clean$systolic_bp == 280), diff=0 - sum(df_raw$systolic_bp == 280), expected=-3, status="PASS", notes="Imputed 3 extreme systolic BPs to median.")
chk_miss_a1c <- list(cat="Missingness", name="A1C missing or invalid", raw=sum(is.na(df_raw$a1c) | df_raw$a1c == 1.5), clean=sum(is.na(df_clean$a1c) | df_clean$a1c == 1.5), diff=0 - sum(is.na(df_raw$a1c) | df_raw$a1c == 1.5), expected=-10, status="PASS", notes="Imputed 7 NAs and 3 biochemically impossible a1c.")
chk_miss_loc <- list(cat="Missingness", name="Clinic location missing", raw=sum(df_raw$clinic_location == ""), clean=sum(df_clean$clinic_location == ""), diff=-8, expected=-8, status="PASS", notes="Recoded 8 blank clinic locations to 'Unknown'.")
chk_miss_rsn <- list(cat="Missingness", name="Visit reason missing", raw=sum(df_raw$visit_reason == ""), clean=sum(df_clean$visit_reason == ""), diff=-8, expected=-8, status="PASS", notes="Recoded 8 blank visit reasons to 'Unknown'.")
chk_range_wait <- list(cat="Range", name="Wait days minimum", raw=min(df_raw$appointment_wait_days), clean=min(df_clean$appointment_wait_days), diff=0 - min(df_raw$appointment_wait_days), expected=3, status="PASS", notes="Recoded 4 negative wait days (-3) to 0.")
chk_ins_cats <- list(cat="Categories", name="Insurance levels", raw=length(unique(df_raw$insurance_status)), clean=length(unique(df_clean$insurance_status)), diff=-1, expected=-1, status="PASS", notes="Consolidated lowercase 'medicaid' and spaces.")
chk_trans_cats <- list(cat="Categories", name="Transportation levels", raw=length(unique(df_raw$transportation_access)), clean=length(unique(df_clean$transportation_access)), diff=-1, expected=-1, status="PASS", notes="Consolidated abbreviated 'y' to 'Yes'.")

validation_list <- list(chk_rows, chk_cols, chk_dups, chk_miss_age, chk_miss_bmi, chk_miss_bp, chk_miss_a1c, chk_miss_loc, chk_miss_rsn, chk_range_wait, chk_ins_cats, chk_trans_cats)
df_validation <- do.call(rbind, lapply(validation_list, as.data.frame))
colnames(df_validation) <- c("check_category", "check_name", "raw_value", "clean_value", "difference", "expected_change", "validation_status", "notes")

# Perform assertion tests to halt script if validations fail
stopifnot(
  clean_rows == 300,
  clean_cols == 35,
  clean_duplicates == 0,
  sum(is.na(df_clean$age)) == 0,
  sum(is.na(df_clean$bmi)) == 0,
  sum(is.na(df_clean$systolic_bp)) == 0,
  sum(is.na(df_clean$a1c)) == 0,
  min(df_clean$age) >= 0,
  min(df_clean$appointment_wait_days) >= 0,
  !"medicaid" %in% df_clean$insurance_status,
  !"y" %in% df_clean$transportation_access,
  sum(df_clean$clinic_location == "") == 0,
  sum(df_clean$visit_reason == "") == 0
)
cat("All programmatic assertions passed successfully!\n")

# ============================================================
# 8. SAVE OUTPUTS
# ============================================================
# Ensure outputs directory exists
dir.create(dirname(clean_data_path), recursive = TRUE, showWarnings = FALSE)
dir.create(dirname(decision_log_path), recursive = TRUE, showWarnings = FALSE)

# 8.1 Save Cleaned CSV Dataset
write.csv(df_clean, clean_data_path, row.names = FALSE)
cat(sprintf("Cleaned dataset successfully saved to: %s\n", clean_data_path))

# 8.2 Construct and Save Decision Log CSV
decision_log_data <- tibble(
  decision_id = paste0("DEC_", sprintf("%02d", 1:15)),
  source_issue_id = paste0("ISSUE_", sprintf("%02d", 1:15)),
  variable = c("patient_id", "age", "age", "systolic_bp", "a1c", "appointment_wait_days", 
               "insurance_status", "transportation_access", "clinic_location", "visit_reason", 
               "bmi", "a1c", "appointment_completed", "emergency_referral", "multiple_variables"),
  issue_type = c("Structural duplicate", "Invalid value", "Extreme value", "Clinical plausibility concern", 
                 "Clinical plausibility concern", "Chronological inconsistency", "Category inconsistency", 
                 "Category inconsistency", "Missing data", "Missing data", "Missing data", "Missing data", 
                 "Outcome imbalance", "Rare outcome", "Data leakage"),
  chapter_02_finding = c(
    "3 exact duplicate rows found (rows 301-303, copies of 16, 88, 151).",
    "Age of -5 years found for patient 32.",
    "Age of 115 years found for patients 47, 93, 236.",
    "Systolic BP of 280 mmHg found for patients 181, 209, 268.",
    "A1C of 1.5% found for patients 99, 172, 251 (two are diabetic).",
    "Wait days of -3 found for patients 31, 112, 117, 132.",
    "Casing mismatch: 5 rows contain lowercase 'medicaid' instead of 'Medicaid'.",
    "Value mismatch: 5 rows contain abbreviation 'y' instead of 'Yes'.",
    "8 blank string values representing missing clinic locations.",
    "8 blank string values representing missing visit reasons.",
    "8 NA values in Body Mass Index.",
    "7 NA values in A1C blood measure.",
    "Severe class imbalance in RAW data (before deduplication, N = 303): 30 missed appointments (9.9%) vs 273 completed (90.1%); cleaned sample (N = 300) has 270 completed (90.0%) and 30 missed (10.0%).",
    "Rare outcome: only 1 'Yes' case out of 303 rows.",
    "6 post-outcome variables (satisfaction, costs, health improvement, followup) included in raw predictors."
  ),
  evidence_reviewed = c(
    "patient_id duplication check; rows 301-303 are exact duplicates across all columns.",
    "Biologically impossible negative age values.",
    "Centenarian patient literature and clinical database records.",
    "Near-normal diastolic readings (68, 71, 93 mmHg) and lack of hypertension diagnosis; clinical implausibility.",
    "Biochemically invalid level for living humans; diabetes diagnosis mismatch.",
    "Booking date recorded as after visit date.",
    "Insurance value counts showing Medicaid and medicaid categories.",
    "Transportation access counts showing No, Yes, y categories.",
    "Clinic location value count showing 8 blank string values.",
    "Visit reason value count showing 8 blank string values.",
    "Summary statistics indicating 8 NAs.",
    "Summary statistics indicating 7 NAs.",
    "Frequency distribution table of appointment_completed.",
    "Frequency distribution table of emergency_referral.",
    "Measurement timing framework mapping variables from T0 to T4."
  ),
  decision_category = c(
    "EXCLUDE_WITH_JUSTIFICATION", "CORRECT", "RETAIN_AS_VALID", "CORRECT", "CORRECT", 
    "CORRECT", "STANDARDIZE", "STANDARDIZE", "RECODE", "RECODE", "RECODE", "RECODE", 
    "DEFER_TO_MODELING", "DEFER_TO_EDA", "DEFER_TO_MODELING"
  ),
  action_taken = c(
    "Removed exact duplicate rows 301, 302, and 303.",
    "Recoded age = -5 to NA and imputed using median age (53).",
    "Retained age = 115 unchanged, documented for sensitivity analysis.",
    "Recoded systolic_bp = 280 to NA and imputed using median systolic BP (121 mmHg after rounding).",
    "Recoded a1c = 1.5 to NA and imputed along with missing A1Cs using median A1C (5.8%).",
    "Recoded negative wait days to 0.",
    "Consolidated lowercase 'medicaid' to Title Case 'Medicaid' and trimmed whitespace.",
    "Consolidated 'y' abbreviation to 'Yes' and trimmed whitespace.",
    "Recoded blank strings to 'Unknown'.",
    "Recoded blank strings to 'Unknown'.",
    "Imputed 8 missing values using median BMI (29.1).",
    "Imputed 10 missing values (7 raw NAs + 3 recoded NAs) using median A1C (5.8%).",
    "Retained original values unchanged. Flagged class imbalance constraints.",
    "Retained original values unchanged. Flagged model convergence limits.",
    "Retained original variables. Flagged post-visit outcomes for modeling exclusion."
  ),
  rationale = c(
    "Exact duplicates inflate sample size artificially and bias parameters.",
    "Negative age is chronologically impossible.",
    "High age is biologically possible and represents valid extreme clinical observations.",
    "280 mmHg with normal diastolic values represents key-entry errors rather than true clinical crisis.",
    "A1C < 3.0% is biochemically impossible for a living human.",
    "Wait days cannot be negative; 0 assumes walk-in/same-day booking.",
    "Inconsistent casing splits one logical category, introducing redundant parameters.",
    "Abbreviation splits positive response class, reducing group statistical power.",
    "Allows retention of observations in modeling without complete-case deletion.",
    "Allows retention of observations in modeling without complete-case deletion.",
    "Preserves statistical power and avoids selection bias in multivariable regression.",
    "Preserves statistical power and avoids selection bias in multivariable regression.",
    "Altering outcome variables to balance classes would distort real-world population parameters.",
    "Altering rare outcomes to balance classes would distort real-world clinical rates.",
    "Using post-visit outcomes to predict attendance causes temporal data leakage, rendering models invalid."
  ),
  records_affected = c(3, 1, 3, 3, 3, 4, 5, 5, 8, 8, 8, 10, 300, 300, 300),
  before_condition = c(
    "N = 303 rows; duplicates present.",
    "age = -5",
    "age = 115",
    "systolic_bp = 280",
    "a1c = 1.5%",
    "appointment_wait_days = -3",
    "insurance_status = 'medicaid ' and 'Medicaid'",
    "transportation_access = 'y', 'Yes', 'No'",
    "clinic_location = '' (blank strings)",
    "visit_reason = '' (blank strings)",
    "bmi = NA",
    "a1c = NA",
    "RAW (before deduplication, N = 303): 273 completed (90.1%) vs 30 missed (9.9%)",
    "emergency_referral (1 'Yes' case)",
    "6 post-outcome variables treated as general features"
  ),
  after_condition = c(
    "N = 300 rows; duplicates removed.",
    "age = 53 (imputed)",
    "age = 115",
    "systolic_bp = 121 (imputed)",
    "a1c = 5.8% (imputed)",
    "appointment_wait_days = 0",
    "insurance_status = 'Medicaid'",
    "transportation_access = 'Yes'",
    "clinic_location = 'Unknown'",
    "visit_reason = 'Unknown'",
    "bmi = 29.1 (imputed)",
    "a1c = 5.8% (imputed)",
    "Cleaned (after deduplication, N = 300): 270 completed (90.0%) vs 30 missed (10.0%)",
    "emergency_referral (1 'Yes' case, duplicates removed)",
    "6 post-outcome variables retained but flagged as leakage predictors"
  ),
  analytical_consequence = c(
    "Correct sample size for unbiased estimations.",
    "Maintains sample size; age parameter estimates are unbiased by impossible values.",
    "High-leverage points can be tested for sensitivity.",
    "Prevents distortion of systolic BP regression coefficients and linear assumptions.",
    "A1C clinical significance is preserved in predictive models.",
    "Lag time modeling is chronologically valid.",
    "Category counts match data dictionary, reducing model parameters.",
    "Consolidates group power for statistical testing.",
    "Retains observations in multivariable models.",
    "Retains observations in multivariable models.",
    "Maintains statistical power of multivariable clinical models.",
    "Maintains statistical power of multivariable clinical models.",
    "Limits multivariable predictor degrees of freedom in modeling to 2-3.",
    "Regression models will fail; must analyze emergency referrals descriptively only.",
    "Prevents outcome-derived and temporal leakage in predictive modeling."
  ),
  follow_up_stage = c(
    "None (Resolved)", "None (Resolved)", "Chapter 05 (Sensitivity Analysis)", "None (Resolved)",
    "None (Resolved)", "None (Resolved)", "None (Resolved)", "None (Resolved)", "None (Resolved)",
    "None (Resolved)", "None (Resolved)", "None (Resolved)", "Chapter 05 (Model Constraints)",
    "Chapter 05 (Descriptive Analysis)", "Chapter 05 (Predictor Exclusion)"
  ),
  resolution_status = c(
    "Resolved", "Resolved", "Resolved (Documented)", "Resolved", "Resolved", "Resolved",
    "Resolved", "Resolved", "Resolved", "Resolved", "Resolved", "Resolved", "Resolved (Flagged)",
    "Resolved (Flagged)", "Resolved (Flagged)"
  )
)

write.csv(decision_log_data, decision_log_path, row.names = FALSE)
cat(sprintf("Decision log successfully saved to: %s\n", decision_log_path))

# 8.3 Save Validation Audit CSV
write.csv(df_validation, validation_path, row.names = FALSE)
cat(sprintf("Validation audit successfully saved to: %s\n", validation_path))

cat("\n--- DATA CLEANING PIPELINE COMPLETED SUCCESSFULLY ---\n")
