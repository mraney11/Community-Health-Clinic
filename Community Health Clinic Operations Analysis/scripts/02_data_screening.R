# Chapter 02 — Data Understanding, Screening, and Analytical Readiness
# File Name: scripts/02_data_screening.R
# Purpose: Programmatic screening of the raw health clinic dataset, 
#          generating diagnostic tables and visualizations.
# Note: Bracket indexing (e.g., df[["var"]]) is strictly used to bypass 
#       the dollar-sign operator ($) environment bug.

# 1. Environment Setup ----
cat("[INFO] Loading required packages...\n")
if (!requireNamespace("here", quietly = TRUE)) {
  stop("[ERROR] Package 'here' is required for project-relative root resolution.")
}
suppressMessages(here::i_am("scripts/02_data_screening.R"))
project_root <- normalizePath(here::here(), winslash = "/", mustWork = TRUE)
expected_sentinels <- c(
  "Community Health Clinic Operations Analysis.Rproj",
  "data/community_health_clinic_raw_v2.csv",
  "documentation/community_health_clinic_data_dictionary_v2.xlsx",
  "scripts/02_data_screening.R"
)
missing_sentinels <- expected_sentinels[!file.exists(file.path(project_root, expected_sentinels))]
if (length(missing_sentinels) > 0) {
  stop("[ERROR] Invalid clinic project root (", project_root, "). Missing expected inputs: ",
       paste(missing_sentinels, collapse = ", "))
}
setwd(project_root)

library(tidyverse)
library(readxl)
library(janitor)
library(skimr)
library(scales)

# Ensure output directories exist
dir.create(file.path(project_root, "outputs/tables"), recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(project_root, "outputs/figures"), recursive = TRUE, showWarnings = FALSE)

# 2. Load Raw Dataset ----
cat("[INFO] Loading raw dataset...\n")
raw_data_path <- file.path(project_root, "data/community_health_clinic_raw_v2.csv")
if (!file.exists(raw_data_path)) {
  stop("[ERROR] Raw CSV file not found at: ", raw_data_path)
}

df <- read.csv(raw_data_path, stringsAsFactors = FALSE)
n_rows <- nrow(df)
n_cols <- ncol(df)
cat(sprintf("[INFO] Loaded %d rows and %d variables.\n", n_rows, n_cols))

# 3. Dynamic Variable Stats Helper ----
cat("[INFO] Computing variable statistics...\n")
get_variable_stats <- function(data) {
  stats_list <- lapply(names(data), function(col) {
    val <- data[[col]]
    
    # Missingness: NA or blank string
    is_miss <- is.na(val) | as.character(val) == ""
    missing_n <- sum(is_miss)
    missing_pct <- round((missing_n / length(val)) * 100, 2)
    
    # Valid values
    valid_val <- val[!is_miss]
    unique_n <- length(unique(valid_val))
    
    # R Class
    observed_r_type <- class(val)[1]
    
    # Range / levels representation
    if (observed_r_type %in% c("numeric", "integer")) {
      if (length(valid_val) > 0) {
        observed_range_or_levels <- sprintf("[%s, %s]", as.character(min(valid_val)), as.character(max(valid_val)))
      } else {
        observed_range_or_levels <- "N/A"
      }
    } else {
      unique_levels <- sort(unique(as.character(valid_val)))
      if (length(unique_levels) == 0) {
        observed_range_or_levels <- "Empty"
      } else if (length(unique_levels) > 6) {
        observed_range_or_levels <- sprintf("%s, ... (%d total)", paste(unique_levels[1:5], collapse = ", "), length(unique_levels))
      } else {
        observed_range_or_levels <- paste(unique_levels, collapse = ", ")
      }
    }
    
    data.frame(
      variable_name = col,
      observed_r_type = observed_r_type,
      missing_n = missing_n,
      missing_pct = missing_pct,
      unique_n = unique_n,
      observed_range_or_levels = observed_range_or_levels,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, stats_list)
}

dynamic_stats <- get_variable_stats(df)

# 4. Generate Variable Intelligence Table ----
cat("[INFO] Building Variable Intelligence Table...\n")

static_metadata <- data.frame(
  variable_name = c(
    "patient_id", "visit_date", "age", "gender", "race_ethnicity", "preferred_language",
    "insurance_status", "employment_status", "housing_status", "income_level",
    "transportation_access", "distance_to_clinic", "food_insecurity_risk", "bmi",
    "systolic_bp", "diastolic_bp", "a1c", "chronic_conditions", "diabetes", "hypertension",
    "smoking_status", "exercise_days_per_week", "mental_health_screen", "clinic_location",
    "provider_type", "visit_reason", "appointment_wait_days", "previous_no_shows",
    "appointment_completed", "followup_required", "emergency_referral", "health_improved",
    "patient_satisfaction", "estimated_visit_cost", "missed_appointment_cost"
  ),
  original_definition = c(
    "Patient Id", "Visit Date", "Age", "Gender", "Race Ethnicity", "Preferred Language",
    "Insurance Status", "Employment Status", "Housing Status", "Income Level",
    "Transportation Access", "Distance To Clinic", "Food Insecurity Risk", "Bmi",
    "Systolic Bp", "Diastolic Bp", "A1C", "Chronic Conditions", "Diabetes", "Hypertension",
    "Smoking Status", "Exercise Days Per Week", "Mental Health Screen", "Clinic Location",
    "Provider Type", "Visit Reason", "Appointment Wait Days", "Previous No Shows",
    "Appointment Completed", "Followup Required", "Emergency Referral", "Health Improved",
    "Patient Satisfaction", "Estimated Visit Cost", "Missed Appointment Cost"
  ),
  supplemental_analytical_definition = c(
    "Unique identifier assigned to each patient.",
    "The calendar date on which the clinic appointment was scheduled to occur.",
    "The age of the patient in years at the time of the scheduled appointment.",
    "The self-reported gender identity of the patient.",
    "The self-reported racial and ethnic category of the patient.",
    "The language in which the patient prefers to receive communication and care.",
    "The primary health insurance status or coverage type of the patient.",
    "The current employment status of the patient.",
    "The housing stability status reported by the patient.",
    "The broad income category of the patient's household.",
    "Whether the patient has reliable access to transportation for clinic visits.",
    "The direct geographical distance in miles from the patient's residence to the clinic.",
    "The patient-reported risk level of food insecurity.",
    "Body Mass Index, calculated as weight in kilograms divided by height in meters squared.",
    "The systolic blood pressure reading in mmHg recorded at the visit or most recently.",
    "The diastolic blood pressure reading in mmHg recorded at the visit or most recently.",
    "Glycated hemoglobin percentage, indicating average blood sugar control over the past 3 months.",
    "The total count of diagnosed chronic health conditions for the patient.",
    "Binary indicator of whether the patient has been diagnosed with diabetes.",
    "Binary indicator of whether the patient has been diagnosed with hypertension.",
    "Binary indicator of whether the patient is a current tobacco smoker.",
    "Self-reported number of days the patient engages in physical exercise per week.",
    "Categorical result of clinical screening for depression or anxiety (e.g. PHQ/GAD).",
    "The specific physical clinic location where the appointment was scheduled.",
    "The type of healthcare provider scheduled for the appointment.",
    "The primary clinical or operational reason for scheduling the appointment.",
    "The number of elapsed days between the booking date and the scheduled appointment date.",
    "The historical count of appointments the patient previously scheduled but did not complete.",
    "Primary outcome: whether the patient completed the scheduled appointment.",
    "Secondary outcome: whether additional follow-up care is required after this visit.",
    "Secondary outcome: whether the patient required an emergency referral during or after the visit.",
    "Secondary outcome: patient-reported or clinician-assessed health improvement status.",
    "Secondary outcome: patient-reported satisfaction score with the clinic visit experience.",
    "Secondary outcome: estimated operational cost of providing care for a completed visit.",
    "Secondary outcome: estimated financial cost or loss associated with a missed visit."
  ),
  conceptual_data_type = c(
    "Identifier", "Date", "Continuous numeric", "Nominal categorical", "Nominal categorical", "Nominal categorical",
    "Nominal categorical", "Nominal categorical", "Nominal categorical", "Ordinal categorical",
    "Binary categorical", "Continuous numeric", "Ordinal categorical", "Continuous numeric",
    "Continuous numeric", "Continuous numeric", "Continuous numeric", "Discrete count", "Binary categorical", "Binary categorical",
    "Binary categorical", "Discrete count", "Ordinal categorical", "Nominal categorical",
    "Nominal categorical", "Nominal categorical", "Continuous numeric", "Discrete count",
    "Binary categorical", "Binary categorical", "Binary categorical", "Binary categorical",
    "Ordinal categorical", "Continuous numeric", "Continuous numeric"
  ),
  units = c(
    "N/A (ID)", "YYYY-MM-DD", "Years", "Categories", "Categories", "Categories",
    "Categories", "Categories", "Categories", "Categories (Low/Moderate/High)",
    "Yes/No (with casing issues)", "Miles", "Categories (Low/Moderate/High)", "kg/m^2",
    "mmHg", "mmHg", "Percentage (%)", "Count of conditions (0-6)", "Yes/No", "Yes/No",
    "Yes/No", "Days per week (0-7)", "Categories (Negative/Mild/Moderate/Severe)", "Categories (North/Central/South)",
    "Categories", "Categories", "Days (lag time)", "Count of missed visits (0-4)",
    "Yes/No", "Yes/No", "Yes/No", "Yes/No",
    "Score (1-5)", "USD ($)", "USD ($)"
  ),
  analytical_domain = c(
    "Identifier", "Operational", "Demographic", "Demographic", "Demographic", "Demographic",
    "Socioeconomic", "Socioeconomic", "Socioeconomic", "Socioeconomic",
    "Access-related", "Access-related", "Socioeconomic", "Clinical",
    "Clinical", "Clinical", "Clinical", "Clinical", "Clinical", "Clinical",
    "Behavioral", "Behavioral", "Clinical", "Operational",
    "Operational", "Operational", "Scheduling", "Scheduling",
    "Outcome", "Outcome", "Outcome", "Outcome",
    "Outcome", "Financial", "Financial"
  ),
  measurement_timing = c(
    "T0", "T1", "T0", "T0", "T0", "T0",
    "T1", "T0", "T0", "T0",
    "T1", "T0", "T0", "T1",
    "T1", "T1", "T1", "T1", "T1", "T1",
    "T0", "T0", "T1", "T1",
    "T1", "T1", "T1", "T0",
    "T2", "T3", "T3", "T3",
    "T3", "T4", "T4"
  ),
  proposed_analytical_role = c(
    "Identifier", "Supporting predictor", "Predictor", "Predictor", "Predictor", "Predictor",
    "Predictor", "Predictor", "Predictor", "Predictor",
    "Predictor", "Predictor", "Predictor", "Predictor",
    "Predictor", "Predictor", "Predictor", "Predictor", "Predictor", "Predictor",
    "Predictor", "Predictor", "Predictor", "Predictor",
    "Predictor", "Predictor", "Predictor", "Predictor",
    "Primary Outcome", "Secondary Outcome", "Secondary Outcome", "Secondary Outcome",
    "Secondary Outcome", "Secondary Outcome", "Secondary Outcome"
  ),
  expected_range_or_levels = c(
    "Unique IDs", "Calendar year 2025", ">= 0 and <= 100", "Female, Male, Nonbinary", "Asian, Black, Hispanic, Other, White", "English, Spanish, Other",
    "Medicaid, Medicare, Private, Uninsured", "Employed, Part-time, Retired, Unemployed", "Stable, Temporary, Unstable", "Low, Moderate, High",
    "Yes, No", ">= 0.0", "Low, Moderate, High", "18.5 - 40.0",
    "90 - 180 mmHg", "60 - 110 mmHg", "4.0% - 10.0%", "0 - 6", "Yes, No", "Yes, No",
    "Yes, No", "0 - 7", "Negative, Mild, Moderate, Severe", "North, Central, South",
    "Physician, Physician Assistant, Nurse Practitioner", "Chronic Disease, Acute Illness, Primary Care, Preventive Care", ">= 0", "0 - 4",
    "Yes, No", "Yes, No", "Yes, No", "Yes, No",
    "1 - 5", ">= 0.0", ">= 0.0"
  ),
  potential_quality_issue = c(
    "None (3 exact duplicate rows present in raw dataset)",
    "None",
    "Contains negative value (-5) and extreme values (115)",
    "None",
    "None",
    "None",
    "Casing mismatch (Medicaid vs medicaid)",
    "None",
    "None",
    "None",
    "Abbreviation mismatch (Yes vs y)",
    "None",
    "None",
    "Contains 8 missing values (NAs)",
    "Contains extreme value (280 mmHg)",
    "None",
    "Contains 7 missing values (NAs) and extreme low values (1.5%)",
    "Potential conceptual redundancy with diabetes and hypertension",
    "Potential conceptual redundancy with chronic_conditions",
    "Potential conceptual redundancy with chronic_conditions",
    "None",
    "None",
    "None",
    "Contains 8 missing values (stored as blank strings)",
    "None",
    "Contains 8 missing values (stored as blank strings)",
    "Contains negative values (-3)",
    "None",
    "High class imbalance (90% Yes, 10% No)",
    "Post-outcome variable (Data Leakage for primary model)",
    "Post-outcome variable (Leakage) & rare category (only 1 Yes)",
    "Post-outcome variable (Data Leakage for primary model)",
    "Post-outcome variable (Data Leakage for primary model)",
    "Post-outcome variable (Data Leakage for primary model)",
    "Post-outcome variable (Data Leakage for primary model)"
  ),
  potential_leakage_risk = c(
    "No", "No", "No", "No", "No", "No",
    "No", "No", "No", "No",
    "No", "No", "No", "No",
    "No", "No", "No", "No", "No", "No",
    "No", "No", "No", "No",
    "No", "No", "No", "No",
    "Outcome", "Yes (Temporal Leakage)", "Yes (Temporal Leakage)", "Yes (Temporal Leakage)",
    "Yes (Temporal Leakage)", "Yes (Outcome-derived Leakage)", "Yes (Outcome-derived Leakage)"
  ),
  recommended_next_action = c(
    "Remove duplicate rows in Chapter 03.",
    "Keep as supporting predictor to extract month and day.",
    "Recode -5 to NA in Chapter 03; keep 115 but document.",
    "Retain as primary/supporting predictor.",
    "Retain as primary/supporting predictor.",
    "Retain as primary/supporting predictor.",
    "Consolidate 'medicaid' and 'Medicaid' to 'Medicaid' in Chapter 03.",
    "Retain as primary/supporting predictor.",
    "Retain as primary/supporting predictor.",
    "Retain as primary/supporting predictor.",
    "Consolidate 'y' and 'Yes' to 'Yes' in Chapter 03.",
    "Retain as primary predictor of interest.",
    "Retain as primary/supporting predictor.",
    "Impute missing values using median/MICE in Chapter 03.",
    "Set 280 to NA or winsorize in Chapter 03.",
    "Retain as supporting predictor.",
    "Recode 1.5 to NA and impute missing values in Chapter 03.",
    "Retain but evaluate multicollinearity / VIF in Chapter 05.",
    "Retain but evaluate multicollinearity / VIF in Chapter 05.",
    "Retain but evaluate multicollinearity / VIF in Chapter 05.",
    "Retain as supporting predictor.",
    "Retain as supporting predictor.",
    "Retain as supporting predictor.",
    "Recode blanks to 'Unknown' or impute in Chapter 03.",
    "Retain as supporting predictor.",
    "Recode blanks to 'Unknown' or impute in Chapter 03.",
    "Recode negative wait days to 0 in Chapter 03.",
    "Retain as primary predictor of interest.",
    "Model as binary primary outcome via logistic regression.",
    "Exclude from primary model; model separately in Chapter 05.",
    "Exclude from primary model; treat descriptively only.",
    "Exclude from primary model; model separately in Chapter 05.",
    "Exclude from primary model; model separately in Chapter 05.",
    "Exclude from primary model; model separately in Chapter 05.",
    "Exclude from primary model; model separately in Chapter 05."
  ),
  interpretation_caution = c(
    "Ensure duplicates are removed before count verification.",
    "None",
    "Negative ages are errors; very high ages may distort mean estimates.",
    "None",
    "None",
    "None",
    "Unstandardized coding artificial increases category count.",
    "None",
    "None",
    "None",
    "Unstandardized coding splits the positive response class.",
    "None",
    "None",
    "Missingness may bias estimates if not handled.",
    "280 mmHg represents hypertensive crisis or input error.",
    "None",
    "1.5% is biochemically invalid for living humans; represents error.",
    "Overlap with specific disease flags may cause multicollinearity.",
    "Overlap with chronic conditions count.",
    "Overlap with chronic conditions count.",
    "None",
    "None",
    "None",
    "Blanks must be handled; represents operational uncertainty.",
    "None",
    "Blanks must be handled; represents scheduling uncertainty.",
    "Negative lag indicates calendar or booking entry error.",
    "History is strongly predictive but may suffer from recall bias.",
    "High completion rate limits number of predictors we can model.",
    "Determined during visit; cannot predict completion.",
    "Determined during visit; only 1 event makes modeling impossible.",
    "Determined after visit; cannot predict completion.",
    "Determined after visit; cannot predict completion.",
    "Calculated post-visit; cannot predict completion.",
    "Calculated post-visit; cannot predict completion."
  ),
  stringsAsFactors = FALSE
)

# Merge static metadata with dynamic stats
var_intel_table <- merge(static_metadata, dynamic_stats, by = "variable_name", all.x = TRUE)
# Reorder to match column index of original dataframe
var_intel_table <- var_intel_table[match(names(df), var_intel_table[["variable_name"]]), ]

write.csv(var_intel_table, "outputs/tables/02_variable_intelligence_table.csv", row.names = FALSE)
cat("[INFO] Saved outputs/tables/02_variable_intelligence_table.csv\n")

# 5. Generate Missingness Summary Table ----
cat("[INFO] Building Missingness Summary Table...\n")
missingness_summary <- data.frame(
  variable_name = dynamic_stats[["variable_name"]],
  missing_count = dynamic_stats[["missing_n"]],
  missing_percentage = dynamic_stats[["missing_pct"]],
  non_missing_count = n_rows - dynamic_stats[["missing_n"]],
  stringsAsFactors = FALSE
)
write.csv(missingness_summary, "outputs/tables/02_missingness_summary.csv", row.names = FALSE)
cat("[INFO] Saved outputs/tables/02_missingness_summary.csv\n")

# 6. Generate Categorical Level Audit Table ----
cat("[INFO] Auditing categorical levels...\n")
categorical_vars <- c(
  "gender", "race_ethnicity", "preferred_language", "insurance_status",
  "employment_status", "housing_status", "income_level", "transportation_access",
  "food_insecurity_risk", "diabetes", "hypertension", "smoking_status",
  "mental_health_screen", "clinic_location", "provider_type", "visit_reason",
  "appointment_completed", "followup_required", "emergency_referral", "health_improved"
)

cat_audit_list <- lapply(categorical_vars, function(col) {
  val <- df[[col]]
  tbl <- table(val, useNA = "always")
  df_tbl <- as.data.frame(tbl, stringsAsFactors = FALSE)
  names(df_tbl) <- c("observed_category", "frequency")
  
  df_tbl[["variable_name"]] <- col
  df_tbl[["percentage"]] <- round((df_tbl[["frequency"]] / n_rows) * 100, 2)
  
  # Audit logic
  df_tbl[["potential_coding_inconsistency"]] <- "No"
  df_tbl[["potential_duplicate_category"]] <- "No"
  df_tbl[["sparse_category_warning"]] <- "No"
  df_tbl[["recommended_chapter_03_action"]] <- "Retain as is"
  
  # Set missing for blank string
  df_tbl[["observed_category"]][is.na(df_tbl[["observed_category"]]) | df_tbl[["observed_category"]] == ""] <- "[Missing]"
  
  # Specific audits
  for (i in 1:nrow(df_tbl)) {
    cat_val <- df_tbl[i, "observed_category"]
    freq <- df_tbl[i, "frequency"]
    
    if (col == "insurance_status" && cat_val == "medicaid") {
      df_tbl[i, "potential_coding_inconsistency"] <- "Yes"
      df_tbl[i, "potential_duplicate_category"] <- "Yes (Medicaid)"
      df_tbl[i, "recommended_chapter_03_action"] <- "Recode to Title Case 'Medicaid'"
    }
    if (col == "transportation_access" && cat_val == "y") {
      df_tbl[i, "potential_coding_inconsistency"] <- "Yes"
      df_tbl[i, "potential_duplicate_category"] <- "Yes (Yes)"
      df_tbl[i, "recommended_chapter_03_action"] <- "Recode to 'Yes'"
    }
    if (cat_val == "[Missing]") {
      df_tbl[i, "potential_coding_inconsistency"] <- "Yes"
      df_tbl[i, "recommended_chapter_03_action"] <- "Recode blanks to 'Unknown' or impute"
    }
    if (col == "appointment_completed") {
      df_tbl[i, "recommended_chapter_03_action"] <- "Retain as is (RAW pre-deduplication N=303: 273 Yes, 30 No; cleaned post-deduplication N=300: 270 Yes, 30 No)"
    }
    # Sparse warnings (freq < 15 and not missing or rare outcome)
    if (freq < 15 && freq > 0 && cat_val != "[Missing]") {
      df_tbl[i, "sparse_category_warning"] <- "Yes"
      if (col == "gender" && cat_val == "Nonbinary") {
        df_tbl[i, "recommended_chapter_03_action"] <- "Retain with caution due to clinical value"
      } else if (col == "emergency_referral" && cat_val == "Yes") {
        df_tbl[i, "recommended_chapter_03_action"] <- "Exclude from modeling, treat descriptively only"
      }
    }
  }
  
  df_tbl[, c("variable_name", "observed_category", "frequency", "percentage", 
             "potential_coding_inconsistency", "potential_duplicate_category", 
             "sparse_category_warning", "recommended_chapter_03_action")]
})

categorical_level_audit <- do.call(rbind, cat_audit_list)
write.csv(categorical_level_audit, "outputs/tables/02_categorical_level_audit.csv", row.names = FALSE)
cat("[INFO] Saved outputs/tables/02_categorical_level_audit.csv\n")

# 7. Generate Outcome Readiness Assessment Table ----
cat("[INFO] Building Outcome Readiness Assessment...\n")
outcomes_meta <- data.frame(
  variable_name = c(
    "appointment_completed", "followup_required", "emergency_referral",
    "health_improved", "patient_satisfaction", "estimated_visit_cost", "missed_appointment_cost"
  ),
  outcome_type = c("Primary", "Secondary", "Secondary", "Secondary", "Secondary", "Secondary", "Secondary"),
  description = c(
    "Appointment completed (binary outcome predicted in primary model).",
    "Additional scheduled clinical care required.",
    "Emergency referral required during or after the visit.",
    "Patient health improvement observed/assessed.",
    "Patient satisfaction score (1-5 scale).",
    "Operational cost of completed visit (USD).",
    "Operational cost/loss of missed visit (USD)."
  ),
  stringsAsFactors = FALSE
)

outcomes_stats <- lapply(outcomes_meta[["variable_name"]], function(col) {
  val <- df[[col]]
  is_miss <- is.na(val) | as.character(val) == ""
  n_valid <- sum(!is_miss)
  n_missing <- sum(is_miss)
  
  # Distribution string
  valid_val <- val[!is_miss]
  if (class(valid_val)[1] %in% c("numeric", "integer")) {
    dist_str <- sprintf("Min: %s, Max: %s, Mean: %s, Median: %s", 
                        as.character(min(valid_val)), as.character(max(valid_val)),
                        as.character(round(mean(valid_val), 2)), as.character(median(valid_val)))
  } else {
    tbl <- table(valid_val)
    dist_str <- paste(sapply(names(tbl), function(k) sprintf("%s: %d (%.1f%%)", k, tbl[k], (tbl[k]/length(valid_val))*100)), collapse = "; ")
  }
  
  # Modeling readiness and cautions
  if (col == "appointment_completed") {
    dist_str <- paste0("RAW (before deduplication, N = 303): ", dist_str, "; Cleaned (after deduplication, N = 300): No: 30 (10.0%); Yes: 270 (90.0%)")
    modeling_readiness <- "Ready with cautions"
    modeling_limitations_or_cautions <- "Severe class imbalance in RAW data before deduplication (273 Yes [90.1%] vs 30 No [9.9%], N = 303); cleaned sample after deduplication (N = 300) has 270 Yes (90.0%) and 30 No (10.0%). Restricts model complexity to avoid overfitting."
  } else if (col == "emergency_referral") {
    modeling_readiness <- "Unsuitable for modeling"
    modeling_limitations_or_cautions <- "Extremely rare category (only 1 positive case). Multivariable modeling will fail/be unstable. Treat descriptively."
  } else if (col %in% c("followup_required", "health_improved")) {
    modeling_readiness <- "Ready for separate modeling"
    modeling_limitations_or_cautions <- "Post-outcome measurement (occurs after/during appointment). Exclude from primary model."
  } else if (col == "patient_satisfaction") {
    modeling_readiness <- "Ready for separate modeling"
    modeling_limitations_or_cautions <- "Ordinal 1-5 score, post-outcome. Exclude from primary model. Model via ordinal logistic or linear regression."
  } else {
    # Costs
    modeling_readiness <- "Ready for separate modeling"
    modeling_limitations_or_cautions <- "Continuous currency. Exclude from primary model. Model via multiple linear regression."
  }
  
  data.frame(
    variable_name = col,
    n_valid = n_valid,
    n_missing = n_missing,
    observed_distribution = dist_str,
    modeling_readiness = modeling_readiness,
    modeling_limitations_or_cautions = modeling_limitations_or_cautions,
    stringsAsFactors = FALSE
  )
})

outcome_readiness <- merge(outcomes_meta, do.call(rbind, outcomes_stats), by = "variable_name")
# Sort so primary is first
outcome_readiness <- outcome_readiness[order(outcome_readiness[["outcome_type"]] == "Primary", decreasing = TRUE), ]

write.csv(outcome_readiness, "outputs/tables/02_outcome_readiness_assessment.csv", row.names = FALSE)
cat("[INFO] Saved outputs/tables/02_outcome_readiness_assessment.csv\n")

# 8. Generate Predictor Role Map Table ----
cat("[INFO] Building Predictor Role Map...\n")
# Filter out patient_id and outcomes from predictor pool, but keep relevant metadata
predictors_meta <- var_intel_table[!(var_intel_table[["proposed_analytical_role"]] %in% c("Identifier", "Primary Outcome")), ]

predictor_role_map <- data.frame(
  variable_name = predictors_meta[["variable_name"]],
  substantive_domain = predictors_meta[["analytical_domain"]],
  measurement_timing = predictors_meta[["measurement_timing"]],
  analytical_function = sapply(predictors_meta[["variable_name"]], function(col) {
    if (col %in% c("distance_to_clinic", "transportation_access", "previous_no_shows", "appointment_wait_days", "visit_reason", "housing_status", "food_insecurity_risk")) {
      "Primary predictor of interest"
    } else if (col %in% c("followup_required", "emergency_referral", "health_improved", "patient_satisfaction", "estimated_visit_cost", "missed_appointment_cost")) {
      "Leakage / Secondary outcome"
    } else if (col %in% c("diabetes", "hypertension")) {
      "Potential confounder / Overlapping measure"
    } else if (col == "chronic_conditions") {
      "Supporting predictor / Potential confounder"
    } else {
      "Supporting predictor"
    }
  }),
  primary_model_eligibility = sapply(predictors_meta[["variable_name"]], function(col) {
    timing <- predictors_meta[predictors_meta[["variable_name"]] == col, "measurement_timing"]
    issues <- predictors_meta[predictors_meta[["variable_name"]] == col, "potential_quality_issue"]
    
    if (timing %in% c("T3", "T4")) {
      "Ineligible (temporal leakage)"
    } else if (issues != "None") {
      "Eligible with caution (requires cleaning)"
    } else {
      "Eligible candidate"
    }
  }),
  reasoning = sapply(predictors_meta[["variable_name"]], function(col) {
    role <- predictors_meta[predictors_meta[["variable_name"]] == col, "proposed_analytical_role"]
    if (role == "Secondary Outcome") {
      "Post-outcome variable, cannot be used to predict the appointment completion itself."
    } else if (col %in% c("distance_to_clinic", "transportation_access")) {
      "Central access-barrier variables directly hypothesized to affect completion."
    } else if (col == "previous_no_shows") {
      "Direct measure of historical behavioral compliance."
    } else if (col == "appointment_wait_days") {
      "Measures scheduling lag time, hypothesized to decrease completion probability."
    } else if (col %in% c("housing_status", "food_insecurity_risk")) {
      "Measures of socioeconomic vulnerability hypothesized to create competing priorities."
    } else {
      "Standard demographic or clinical covariate to control for confounding."
    }
  }),
  data_quality_constraint = predictors_meta[["potential_quality_issue"]],
  potential_redundancy = sapply(predictors_meta[["variable_name"]], function(col) {
    if (col %in% c("diabetes", "hypertension", "chronic_conditions")) {
      "Yes (High redundancy among chronic disease counts and specific disease binary indicators)"
    } else {
      "No"
    }
  }),
  potential_confounding_role = sapply(predictors_meta[["variable_name"]], function(col) {
    if (col %in% c("income_level", "insurance_status", "employment_status", "age")) {
      "Yes (Confounder of relationship between access barriers and appointment completion)"
    } else {
      "No"
    }
  }),
  potential_effect_modification_role = sapply(predictors_meta[["variable_name"]], function(col) {
    if (col == "visit_reason") {
      "Yes (Hypothesized to modify the effect of wait days on completion)"
    } else {
      "No"
    }
  }),
  leakage_status = sapply(predictors_meta[["variable_name"]], function(col) {
    timing <- predictors_meta[predictors_meta[["variable_name"]] == col, "measurement_timing"]
    if (timing %in% c("T3", "T4")) "Leakage Risk (Exclude)" else "Safe"
  }),
  recommended_next_step = predictors_meta[["recommended_next_action"]],
  stringsAsFactors = FALSE
)

write.csv(predictor_role_map, "outputs/tables/02_predictor_role_map.csv", row.names = FALSE)
cat("[INFO] Saved outputs/tables/02_predictor_role_map.csv\n")

# 9. Generate Hypothesis Feasibility Review Table ----
cat("[INFO] Building Hypothesis Feasibility Review...\n")
hypothesis_feasibility <- data.frame(
  hypothesis_id = paste0("H", 1:5),
  hypothesis_summary = c(
    "Transportation access barriers and greater distance to clinic associate with lower likelihood of appointment completion.",
    "Higher count of previous no-shows is linked to a lower probability of current appointment completion.",
    "Longer wait times relate to lower likelihood of completion, and this relationship is modified by visit reason (stronger for preventive/primary vs acute).",
    "Socioeconomic vulnerability (housing instability, food insecurity risk) is associated with lower likelihood of completion.",
    "Higher clinical burden (chronic conditions count, diabetes, hypertension) is associated with higher likelihood of follow-up care and emergency referrals."
  ),
  required_outcome = c("appointment_completed", "appointment_completed", "appointment_completed", "appointment_completed", "followup_required, emergency_referral"),
  required_predictors = c(
    "transportation_access, distance_to_clinic",
    "previous_no_shows",
    "appointment_wait_days, visit_reason",
    "housing_status, food_insecurity_risk",
    "chronic_conditions, diabetes, hypertension"
  ),
  variables_present = rep("Yes", 5),
  data_quality_concerns = c(
    "transportation_access has casing issues ('y' vs 'Yes')",
    "None",
    "appointment_wait_days has negative values (-3), visit_reason has 8 blank strings",
    "None",
    "emergency_referral is extremely rare (1 positive case); chronic_conditions, diabetes, and hypertension have conceptual overlap"
  ),
  sufficient_variation = c("Yes", "Yes", "Yes", "Yes", "No (emergency_referral only has 1 event)"),
  timing_legitimate = c("Yes", "Yes", "Yes", "Yes", "Yes (both outcomes are T3, predictors are T1/T0)"),
  leakage_concern = c("No", "No", "No", "No", "No"),
  sparse_category_concern = c("Yes (transportation_access 'y' has 5 rows)", "No", "Yes (visit_reason has 8 blanks)", "No", "Yes (emergency_referral is extremely sparse)"),
  missingness_concern = c("No", "No", "Yes (8 blanks in visit_reason)", "No", "No"),
  can_be_tested_as_written = c("Yes (after cleaning)", "Yes", "Yes (after cleaning)", "Yes", "No (for emergency_referral part)"),
  recommended_status = c("Supported after cleaning", "Supported as written", "Supported after cleaning", "Supported as written", "Requires modification"),
  recommended_modification = c(
    "Consolidate 'y' to 'Yes' in transportation_access.",
    "None",
    "Recode -3 wait days to 0; recode blank visit reasons to 'Unknown' or impute.",
    "None",
    "Test clinical burden against followup_required using regression, but analyze emergency_referral using descriptive methods only."
  ),
  stringsAsFactors = FALSE
)

write.csv(hypothesis_feasibility, "outputs/tables/02_hypothesis_feasibility_review.csv", row.names = FALSE)
cat("[INFO] Saved outputs/tables/02_hypothesis_feasibility_review.csv\n")

# 10. Generate Data Quality Issue Register Table ----
cat("[INFO] Building Data Quality Issue Register...\n")
issue_register <- data.frame(
  issue_id = sprintf("ISSUE_%02d", 1:15),
  variable = c(
    "patient_id", "age", "age", "systolic_bp", "a1c", "appointment_wait_days",
    "insurance_status", "transportation_access", "clinic_location", "visit_reason",
    "bmi", "a1c", "appointment_completed", "emergency_referral", 
    "multiple_variables"
  ),
  issue_type = c(
    "Exact duplicate", "Invalid value", "Extreme value", "Clinical plausibility concern",
    "Clinical plausibility concern", "Chronological inconsistency", "Category inconsistency",
    "Category inconsistency", "Missing data", "Missing data", "Missing data", "Missing data",
    "Outcome imbalance", "Rare outcome", "Data leakage"
  ),
  finding = c(
    "3 exact duplicate rows found (rows 301-303, copying rows 16, 88, 151).",
    "Age of -5 years found for patient 32.",
    "Age of 115 years found for patients 47, 93, 236.",
    "Systolic BP of 280 mmHg found for patients 181, 209, 268.",
    "A1C of 1.5% found for patients 99, 172, 251 (two are diabetic).",
    "Wait days of -3 found for patients 31, 112, 117, 132.",
    "Casing mismatch: 5 rows contain lowercase 'medicaid' instead of 'Medicaid'.",
    "Value mismatch: 5 rows contain abbreviation 'y' instead of 'Yes'.",
    "8 blank string values found representing missing clinic locations.",
    "8 blank string values found representing missing visit reasons.",
    "8 NA values found in Body Mass Index.",
    "7 NA values found in A1C blood measure.",
    "Severe class imbalance in RAW data (before deduplication, N = 303): 30 missed appointments (9.9%) vs 273 completed (90.1%); cleaned sample (N = 300) has 270 completed (90.0%) and 30 missed (10.0%).",
    "Rare outcome: only 1 'Yes' case out of 303 rows.",
    "6 post-outcome variables (satisfaction, costs, health improvement, etc.) included in raw predictors."
  ),
  n_affected = c(3, 1, 3, 3, 3, 4, 5, 5, 8, 8, 8, 7, 303, 303, 303),
  severity = c(
    "High", "High", "Moderate", "High", "High", "Moderate", "Low", "Low", 
    "Moderate", "Moderate", "Moderate", "Moderate", "High", "High", "High"
  ),
  interpretation = c(
    "Represents duplicate data entry errors.",
    "Clear data-entry error as negative age is impossible.",
    "Physiologically extreme but possible; could also be a placeholder.",
    "Physiologically extreme, representing severe hypertensive crisis or input error.",
    "Biochemically impossible for a living human (normal range is 4-5.6%; diabetic is >6.5%).",
    "Booking date recorded as after visit date, which is chronologically impossible.",
    "Simple case mismatch during data entry.",
    "Abbreviation inconsistency during data entry.",
    "Missing operational location identifier.",
    "Missing scheduling reason.",
    "Missing clinical measurement.",
    "Missing clinical measurement.",
    "Severe class imbalance in the primary outcome variable.",
    "Outcome has almost zero variation.",
    "Post-outcome variables cannot be used to predict the outcome itself."
  ),
  analytical_consequence = c(
    "Artificially inflates sample size and can lead to biased model estimation.",
    "Biases age distribution and parameter estimates if left uncorrected.",
    "Can function as highly influential leverage points in regression models.",
    "Outliers will distort blood pressure coefficients and linear assumptions.",
    "Distorts A1C clinical significance in predictive models.",
    "Distorts lag time modeling.",
    "Splits one category into two separate levels in modeling, increasing parameters.",
    "Splits the positive response class into two levels, reducing group power.",
    "Reduces sample size if complete-case analysis is used.",
    "Reduces sample size if complete-case analysis is used.",
    "Reduces sample size if complete-case analysis is used.",
    "Reduces sample size if complete-case analysis is used.",
    "Limits the degrees of freedom for modeling (overfitting risk; high events-per-variable constraint).",
    "Cannot be modeled using logistic regression (unstable/singular models).",
    "Creates temporal leakage, artificially inflating predictive power."
  ),
  recommended_action = c(
    "Remove duplicate rows in Chapter 03.",
    "Recode -5 to NA in Chapter 03.",
    "Retain but flag for sensitivity analysis in Chapter 05.",
    "Recode to NA or winsorize in Chapter 03.",
    "Recode to NA in Chapter 03.",
    "Recode to 0 (interpreting as same-day scheduling lag) in Chapter 03.",
    "Convert all to Title Case 'Medicaid' in Chapter 03.",
    "Convert all 'y' to 'Yes' in Chapter 03.",
    "Recode blanks to 'Unknown' or impute in Chapter 03.",
    "Recode blanks to 'Unknown' or impute in Chapter 03.",
    "Impute using median or multiple imputation (MICE) in Chapter 03.",
    "Impute using median or multiple imputation (MICE) in Chapter 03.",
    "Restrict model complexity (limit predictor degrees of freedom) in Chapter 05.",
    "Treat descriptively only; do not model in regression.",
    "Exclude post-outcome variables from predictor pool of primary model."
  ),
  decision_required = c(
    "Analyst Decision Required", "Analyst Decision Required", "Analyst Decision Required",
    "Analyst Decision Required", "Analyst Decision Required", "Analyst Decision Required",
    "No", "No", "Analyst Decision Required", "Analyst Decision Required",
    "Analyst Decision Required", "Analyst Decision Required", "Analyst Decision Required",
    "Analyst Decision Required", "Analyst Decision Required"
  ),
  action_chapter = c(
    "Chapter 03", "Chapter 03", "Chapter 03", "Chapter 03", "Chapter 03", "Chapter 03",
    "Chapter 03", "Chapter 03", "Chapter 03", "Chapter 03", "Chapter 03", "Chapter 03",
    "Chapter 05", "Chapter 05", "Chapter 05"
  ),
  status = rep("Open", 15),
  resolution = rep("", 15),
  stringsAsFactors = FALSE
)

write.csv(issue_register, "outputs/tables/02_data_quality_issue_register.csv", row.names = FALSE)
cat("[INFO] Saved outputs/tables/02_data_quality_issue_register.csv\n")


# 11. Create Diagnostic Figures ----
cat("[INFO] Generating diagnostic figures...\n")

# Figure 1: Missingness Overview ----
# Compute missingness counts for variables with > 0 missingness
miss_data <- missingness_summary[missingness_summary[["missing_count"]] > 0, ]
miss_data <- miss_data[order(miss_data[["missing_percentage"]], decreasing = TRUE), ]

fig1 <- ggplot(miss_data, aes(x = reorder(variable_name, missing_percentage), y = missing_percentage)) +
  geom_bar(stat = "identity", fill = "#4A90E2", width = 0.6) +
  geom_text(aes(label = sprintf("%d (%.1f%%)", missing_count, missing_percentage)), 
            hjust = -0.1, size = 3.5, color = "#333333") +
  coord_flip() +
  scale_y_continuous(limits = c(0, 5)) +
  labs(
    title = "Missingness Overview by Variable",
    subtitle = "Variables with missing values (out of N = 303 scheduled appointments)",
    x = "Variable Name",
    y = "Missing Percentage (%)"
  ) +
  theme_minimal(base_family = "sans") +
  theme(
    plot.title = element_text(face = "bold", size = 14, color = "#2C3E50"),
    plot.subtitle = element_text(size = 10, color = "#7F8C8D"),
    axis.text = element_text(size = 10),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank()
  )

ggsave("outputs/figures/02_missingness_overview.png", plot = fig1, width = 7, height = 4, dpi = 150)
cat("[INFO] Saved outputs/figures/02_missingness_overview.png\n")


# Figure 2: Primary Outcome Balance ----
outcome_counts <- as.data.frame(table(df[["appointment_completed"]]), stringsAsFactors = FALSE)
names(outcome_counts) <- c("Status", "Count")
outcome_counts[["Pct"]] <- outcome_counts[["Count"]] / sum(outcome_counts[["Count"]]) * 100

fig2 <- ggplot(outcome_counts, aes(x = Status, y = Count, fill = Status)) +
  geom_bar(stat = "identity", width = 0.5, show.legend = FALSE) +
  geom_text(aes(label = sprintf("%d (%.1f%%)", Count, Pct)), 
            vjust = -0.3, fontface = "bold", size = 4) +
  scale_fill_manual(values = c("Yes" = "#2ECC71", "No" = "#E74C3C")) +
  scale_y_continuous(limits = c(0, 310)) +
  labs(
    title = "Primary Outcome Class Balance",
    subtitle = "Distribution of appointment completion status (N = 303)",
    x = "Appointment Completed?",
    y = "Number of Appointments"
  ) +
  theme_minimal(base_family = "sans") +
  theme(
    plot.title = element_text(face = "bold", size = 14, color = "#2C3E50"),
    plot.subtitle = element_text(size = 10, color = "#7F8C8D"),
    axis.text = element_text(size = 11),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )

ggsave("outputs/figures/02_primary_outcome_balance.png", plot = fig2, width = 6, height = 4, dpi = 150)
cat("[INFO] Saved outputs/figures/02_primary_outcome_balance.png\n")


# Figure 3: Numeric Screening (Anomalous Variables) ----
# Create a multi-panel plot containing diagnostic subplots for anomalous variables.
# Since gridExtra or cowplot might not be installed, we will use basic ggplot panel/faceting 
# or generate individual plots and combine them using basic graphics or just create a 
# facet-like structure by melting the variables.
# Let's subset to: age, systolic_bp, a1c, and appointment_wait_days.

numeric_issues <- df[, c("age", "systolic_bp", "a1c", "appointment_wait_days")]
# Remove NAs for melting
numeric_issues_long <- numeric_issues %>%
  pivot_longer(cols = everything(), names_to = "Variable", values_to = "Value") %>%
  filter(!is.na(Value))

fig3 <- ggplot(numeric_issues_long, aes(x = Value)) +
  geom_histogram(fill = "#5D6D7E", color = "white", bins = 25) +
  facet_wrap(~Variable, scales = "free", ncol = 2) +
  labs(
    title = "Diagnostic Distributions of Anomalous Numeric Variables",
    subtitle = "Visualizing extreme values, impossible values, and outliers in raw variables",
    x = "Value",
    y = "Frequency"
  ) +
  theme_light(base_family = "sans") +
  theme(
    plot.title = element_text(face = "bold", size = 14, color = "#2C3E50"),
    plot.subtitle = element_text(size = 10, color = "#7F8C8D"),
    strip.text = element_text(face = "bold", size = 11, color = "black"),
    strip.background = element_rect(fill = "#EAEDED")
  )

ggsave("outputs/figures/02_numeric_screening.png", plot = fig3, width = 8, height = 6, dpi = 150)
cat("[INFO] Saved outputs/figures/02_numeric_screening.png\n")

cat("[INFO] Chapter 02 Data Screening Script Completed Successfully!\n")
