# Chapter 03: Data Cleaning, Preparation, and Validation Report

**File Name:** `reports/03_data_cleaning_and_preparation_report.md`  
**Project Root:** `/Users/michaelraney/Antigravity/Community Health Clinic Operations Analysis`  
**Analytics Environment:** R (RStudio / Quarto)  
**Author:** Senior Healthcare Data Analyst & Statistical Research Methodologist  
**Date:** July 2026  

---

## 1. Executive Overview

The purpose of Chapter 03 is to transition the raw Community Health Clinic dataset (`data/community_health_clinic_raw_v2.csv`) from its raw, unscreened state into a documented, reproducible, validated, and analysis-ready format. This chapter inherits the diagnostic screening findings and constraints from Chapters 01 and 02 to apply precise, justified data adjustments.

Overall, the clinic's raw dataset is of moderate quality. While the underlying structures (e.g., patient demographics, scheduling patterns, and operational clinical metrics) are solid, the raw data suffered from data entry errors (negative age, negative lag time), clinical implausibility concerns (impossible blood sugar levels, extreme blood pressure spikes), categorical coding variations (casing and abbreviation mismatches), and missing data. 

Through systematic implementation of decision-based cleaning, we resolved these issues without losing statistical power. The raw dataset remains entirely unchanged, and all modifications are handled via a reproducible R cleaning script. The cleaning required a **moderate level of intervention**, affecting a total of 15 distinct issues and adjusting variables for a small subset of records. The final cleaned dataset is fully validated and prepared for exploratory data analysis (Chapter 04).

---

## 2. Cleaning Philosophy and Decision Rules

Our data cleaning process is governed by the following core principles:

1. **Anomaly vs. Error:** A value is not automatically an error simply because it is statistically unusual or lies in the tail of a distribution. We only change data when there is a clear, defensible clinical or operational reason to conclude the value is incorrect.
2. **Preservation of Raw Data:** The raw source data is authoritative and must remain pristine and unmodified. All cleaning must occur programmatically in R.
3. **Traceability and Audit Trail:** Every single data alteration must be traceable from the initial screening finding, through the justification, to the exact programmatic change. 
4. **Restraint in Imputation:** We avoid automated wholesale imputation or deletion. Imputation is applied selectively to protect sample size and prevent selection bias, under transparent clinical assumptions.

---

## 3. Inputs Reviewed

To ensure alignment across the analysis lifecycle, the following project inputs were loaded and reviewed:
* **Raw Clinic Dataset:** `data/community_health_clinic_raw_v2.csv` (303 rows, 35 columns).
* **Chapter 01 Analytical Framing:** `01_project_overviewCH.md`, establishing the primary outcome (`appointment_completed`) and secondary outcomes.
* **Chapter 02 Screening Report:** `reports/02_data_screening_and_readiness_report.md`, detailing structural and numeric anomalies.
* **Chapter 02 Quality Issue Register:** `outputs/tables/02_data_quality_issue_register.csv`, linking issues to variable categories.
* **Chapter 02 Variable Intelligence Table:** `outputs/tables/02_variable_intelligence_table.csv`, defining ranges and expected levels.
* **Data Dictionary:** `documentation/community_health_clinic_data_dictionary_v2.xlsx`, validating variable meanings and structures.

---

## 4. Major Cleaning Decisions

A summarized record of our major cleaning decisions is documented in the table below. For detailed record-level mapping, see the [03_cleaning_decision_log.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/03_cleaning_decision_log.csv).

| Decision ID | Variable | Chapter 02 Finding | Decision Category | Action Taken | Rationale & Analytical Consequence |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **DEC_01** | `patient_id` | 3 exact duplicate rows | `EXCLUDE_WITH_JUSTIFICATION` | Dropped duplicate rows 301, 302, 303. | Prevents artificial inflation of sample size and potential model estimation bias. |
| **DEC_02** | `age` | Age of -5 years | `CORRECT` | Recoded -5 to NA; imputed to median age (53). | Negative age is physiologically impossible. Imputation maintains statistical power. |
| **DEC_03** | `age` | Age of 115 years (3 cases) | `RETAIN_AS_VALID` | Retained values unchanged. | Centenarians are biologically possible and represent real-world outliers. |
| **DEC_04** | `systolic_bp` | Systolic BP of 280 mmHg | `CORRECT` | Recoded to NA; imputed to median systolic BP (121 mmHg). | Systolic BP of 280 with normal diastolic BP is clinically implausible and indicates entry error. |
| **DEC_05** | `a1c` | A1C of 1.5% (3 cases) | `CORRECT` | Recoded to NA; imputed to median A1C (5.8%). | A1C < 3.0% is incompatible with human life. Corrects clinical validity. |
| **DEC_06** | `appointment_wait_days` | Wait days of -3 (4 cases) | `CORRECT` | Recoded negative wait days to 0. | Booking date cannot follow visit date. 0 wait days represents same-day/walk-in. |
| **DEC_07** | `insurance_status` | Lowercase 'medicaid' | `STANDARDIZE` | Consolidated to Title Case 'Medicaid'. | Prevents R from treating 'medicaid' as a separate level, saving degrees of freedom. |
| **DEC_08** | `transportation_access` | Abbreviation 'y' (5 cases) | `STANDARDIZE` | Consolidated 'y' to 'Yes'. | Standardizes binary predictor levels for correct statistical comparison. |
| **DEC_09** | `clinic_location` | 8 blank string values | `RECODE` | Recoded blank values to 'Unknown'. | Retains records in categorical analysis and avoids selection bias. |
| **DEC_10** | `visit_reason` | 8 blank string values | `RECODE` | Recoded blank values to 'Unknown'. | Retains records in categorical analysis and avoids selection bias. |
| **DEC_11** | `bmi` | 8 NA values in BMI | `RECODE` | Imputed missing values to median BMI (29.1). | Prevents loss of observations in multivariable models. |
| **DEC_12** | `a1c` | 7 NA values in A1C | `RECODE` | Imputed 10 total NAs (7 raw + 3 recoded) to median (5.8%). | Prevents loss of observations in clinical predictor models. |
| **DEC_13** | `appointment_completed` | Severe class imbalance (RAW $N = 303$: 273 completed [90.1%] vs. 30 missed [9.9%]; cleaned $N = 300$: 270 completed [90.0%] vs. 30 missed [10.0%]) | `DEFER_TO_MODELING` | Retained original values unchanged. | Modeling must restrict predictor degrees of freedom (EPV constraint) to prevent overfitting. |
| **DEC_14** | `emergency_referral` | Rare outcome (1 'Yes' case) | `DEFER_TO_EDA` | Retained original values unchanged. | Modeling will fail due to singular variance; analysis must remain descriptive. |
| **DEC_15** | `multiple_variables` | 6 post-outcome variables | `DEFER_TO_MODELING` | Retained variables in clean dataset. | Post-visit variables represent data leakage and must be excluded from predictor set. |

---

## 5. Missing Data Decisions

Missingness in our raw dataset was concentrated in four variables: `bmi` (8 NAs), `a1c` (7 NAs), `clinic_location` (8 blank strings), and `visit_reason` (8 blank strings). Additionally, setting negative ages, impossible blood sugar levels, and implausible blood pressures to `NA` introduced 7 more missing clinical values.

If we had performed complete-case deletion (dropping any row containing a missing value), the sample size would have shrunk by **31 records (~10.2% of the cohort)**. In a dataset of only 303 rows with an already sparse primary outcome (30 noncompletions), a 10% reduction in sample size represents a severe loss of statistical power and introduces high selection bias risk.

* **Categorical Missingness:** Blank strings `""` for `clinic_location` and `visit_reason` were recoded to a new explicit category level, `"Unknown"`. This preserves the operational records and allows us to assess whether "unknown" clinics or scheduling reasons are associated with appointment completion.
* **Continuous Imputation:** Continuous clinical variables (`bmi`, `a1c`, `age`, `systolic_bp`) were imputed using **median imputation** computed from the cleaned, non-anomalous subset of data. This prevents distortion of the variable means while preserving sample size for multivariable modeling.

---

## 6. Duplicate and Record Integrity Review

A database integrity check confirmed that rows 301, 302, and 303 were exact duplicate records of rows 16, 88, and 151, sharing identical patient IDs, dates, clinical metrics, and outcomes. 
Because these rows are identical across all 35 columns, they represent transactional duplicate entries rather than separate longitudinal appointments. Retaining them would violate the assumption of independent observations in our statistical models.
* **Action:** The 3 duplicate rows were removed, resulting in exactly 300 unique rows for 300 unique patients. Record integrity remains fully intact.

---

## 7. Categorical and Coding Standardization

Categorical text fields in the raw database were standardized to ensure clean grouping during statistical analysis:
* **Insurance Casing:** The variable `insurance_status` contained five occurrences of `"medicaid"` alongside `"Medicaid"`. Standardizing all instances to Title Case `"Medicaid"` (and trimming trailing whitespace) resolved this discrepancy.
* **Transportation Abbreviations:** The variable `transportation_access` contained five occurrences of `"y"` alongside `"Yes"`. These were consolidated to `"Yes"`.
* **String Cleaning:** Trimmed leading and trailing spaces from all character variables to ensure matching groups.

---

## 8. Numeric Range and Extreme-Value Decisions

Several numeric anomalies required correction:
* **Negative Age:** Patient 32's age was recorded as `-5`. This was recoded to `NA` and imputed using the median age of `53` to prevent skewing age-based summaries.
* **Negative Wait Days:** Four patients had wait times of `-3` days. A negative lag time implies a booking date after the appointment date. These were recoded to `0` wait days under the operational assumption that they represent same-day walk-in scheduling.
* **Clinical Implausibilities:** 
  - Systolic BP of `280 mmHg` (three patients) represents a hypertensive crisis. Given near-normal diastolic readings (68, 71, 93 mmHg) and a lack of diagnosed hypertension, these are highly suggestive of data entry errors. They were recoded to `NA` and imputed with the median systolic BP of `121 mmHg` (rounded from 120.5).
  - A1C of `1.5%` (three patients) is biochemically impossible for a living human. These were recoded to `NA` and imputed with the cleaned median A1C of `5.8%`.

---

## 9. Variable Preparation

All variables were checked for proper data types:
* Demographics (`age`), clinical discrete metrics (`chronic_conditions`, `exercise_days_per_week`), operational lag (`appointment_wait_days`, `previous_no_shows`), and ratings (`patient_satisfaction`) were stored as integers.
* Continuous values (`bmi`, `a1c`, `distance_to_clinic`, and cost fields) were stored as numeric.
* Post-outcome variables (e.g. `estimated_visit_cost`, `followup_required`) are retained in the cleaned CSV to support secondary analysis but are formally documented as excluded from the predictor pool for modeling `appointment_completed`.

---

## 10. Raw-to-Clean Reconciliation

A programmatic reconciliation was executed to verify that the R cleaning script performed as expected. The validation metrics are recorded in the table below. For detail check records, see the [03_raw_vs_clean_validation.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/03_raw_vs_clean_validation.csv).

### Programmatic Reconciliation Table

| Check Category | Check Name | Raw Value | Clean Value | Difference | Expected Change | Validation Status | Notes / Rationale |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Dimensions** | Row count | 303 | 300 | -3 | -3 | **PASS** | Dropped 3 duplicate records. |
| **Dimensions** | Column count | 35 | 35 | 0 | 0 | **PASS** | Column structure preserved. |
| **Dimensions** | Duplicate count | 3 | 0 | -3 | -3 | **PASS** | Zero duplicates remain. |
| **Missingness** | Age missing/invalid | 1 | 0 | -1 | -1 | **PASS** | Imputed negative age (-5) to median (53). |
| **Missingness** | BMI missing | 8 | 0 | -8 | -8 | **PASS** | Imputed 8 missing BMIs to median (29.1). |
| **Missingness** | Systolic BP missing/invalid | 3 | 0 | -3 | -3 | **PASS** | Imputed 3 extreme BPs (280) to median (121). |
| **Missingness** | A1C missing/invalid | 10 | 0 | -10 | -10 | **PASS** | Imputed 7 NAs + 3 biochemically impossible A1C (1.5) to median (5.8). |
| **Missingness** | Clinic location missing | 8 | 0 | -8 | -8 | **PASS** | Recoded 8 blank strings to "Unknown". |
| **Missingness** | Visit reason missing | 8 | 0 | -8 | -8 | **PASS** | Recoded 8 blank strings to "Unknown". |
| **Range** | Wait days minimum | -3 | 0 | 3 | 3 | **PASS** | Recoded 4 negative wait days to 0. |
| **Categories** | Insurance levels | 5 | 4 | -1 | -1 | **PASS** | Consolidated lowercase "medicaid" to Title Case. |
| **Categories** | Transportation levels | 3 | 2 | -1 | -1 | **PASS** | Consolidated "y" abbreviation to "Yes". |

**Validation Outcome:** The cleaning pipeline completed successfully with **100% of checks passing**. No unexpected data loss or modifications occurred.

---

## 11. What Was Intentionally Not Changed

To maintain analytical integrity, several unusual observations were reviewed and intentionally left unchanged:
1. **Centenarian Patients:** Patients 47, 93, and 236 have `age = 115`. While extreme, they represent valid biological values. We chose to retain them rather than recoding them, but flagged them to run sensitivity analyses (with and without these patients) during modeling.
2. **Outcome Imbalance:** The primary outcome `appointment_completed` remains highly imbalanced (RAW before deduplication [$N = 303$]: 273 "Yes" [90.1%] vs. 30 "No" [9.9%]; cleaned sample after deduplication [$N = 300$]: 270 "Yes" [90.0%] vs. 30 "No" [10.0%]). We resisted any mechanical balancing techniques (e.g. SMOTE or downsampling) as they distort real-world population rates. Instead, the constraint will be handled in Chapter 05 by restricting model complexity.
3. **Emergency Referral Sparsity:** The variable `emergency_referral` has only 1 "Yes" case. We retained it for descriptive summaries but flagged it as unsuitable for logistic regression.
4. **Clinical Overlap:** The counts of chronic conditions overlap conceptually with specific flags like `diabetes` and `hypertension`. We chose not to drop these variables, deferring multicollinearity checks (VIF) to the modeling stage.

---

## 12. Remaining Data Limitations

Data cleaning resolves database anomalies, but cannot eliminate fundamental study limitations:
* **Sample Size Constraints:** Even with 100% data completion, the small sample size (N=300) and sparse outcomes limit our statistical modeling degrees of freedom.
* **Selection Bias:** The data only represents patients who actively scheduled visits in 2025. It cannot generalize to individuals facing access barriers so severe that they never scheduled an appointment.
* **Unmeasured Confounders:** Important drivers of appointment completion (e.g., patient trust in healthcare, health literacy, child-care availability) are not captured in the dataset.

---

## 13. Readiness for Chapter 04 EDA

### Conclusion: READY FOR EDA WITH DOCUMENTED CAUTIONS

The data is fully cleaned, structured, and validated. No missing values remain in continuous predictors, and categorical variables have standardized levels. The dataset is ready to proceed to Chapter 04 Exploratory Data Analysis.

#### Documented Cautions for Chapter 04/05:
1. **Model Degrees of Freedom:** The primary model must not exceed 2 to 3 predictor degrees of freedom due to the low event count (30 missed visits).
2. **Post-Visit Predictors (Leakage):** Ensure T3/T4 outcome and cost variables are excluded as predictors when modeling appointment completion.
3. **Descriptive-Only Variables:** `emergency_referral` must not be included in multivariable regression models.
4. **Age Outliers:** Patients aged 115 should be investigated during EDA and marked for sensitivity testing in modeling.

---

## 14. Teaching Notes: What Chapter 03 Demonstrates

This chapter illustrates several key principles of applied health data analytics:
1. **Screening vs. Cleaning:** Screening identifies anomalies; cleaning resolves them. Screening is a statistical rule; cleaning requires human analytical judgment. 
2. **Anomalies are not always Errors:** As shown by the centenarians (retained) versus the negative age (corrected), unusual data points require context before action. Silently removing outliers can delete valuable clinical real-world information.
3. **Imputation is an Assumption:** Replacing missing data with a median is not "recovery" of the truth—it is a statistical assumption designed to preserve sample size. Documenting these assumptions is essential for research credibility.
4. **Data Leakage and Timeline Order:** Chronology dictates validity. A model that predicts a T2 outcome using T3 observations is not a predictive model—it is a circular tautology. Analysts must map measurement timing to prevent leakage.
5. **EPV Rule Constraints:** A dataset's size is not its row count; in binary modeling, it is determined by the size of the minority class. Over-parameterizing a model under EPV constraints guarantees overfitting and poor generalizability.
