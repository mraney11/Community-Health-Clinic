# Chapter 02: Data Understanding, Screening, and Analytical Readiness Report

**File Name:** `reports/02_data_screening_and_readiness_report.md`  
**Project Root:** `/Users/michaelraney/Antigravity/Community Health Clinic Operations Analysis`  
**Analytics Environment:** R (RStudio / Quarto)  
**Author:** Senior Healthcare Data Analyst & Research Methodologist  
**Date:** July 2026  

---

## 1. Executive Overview

This report documents the diagnostic screening and analytical readiness assessment of the raw dataset (`data/community_health_clinic_raw_v2.csv`) for the Community Health Clinic Operations Analysis. The primary objective is to verify whether the raw data can support the hypotheses, outcomes, and multivariable modeling plan proposed in Chapter 01.

### Overall Data Quality
The raw dataset consists of **303 scheduled appointments** and **35 variables** spanning calendar year 2025. While the dataset represents a solid foundation, several significant structural, clinical, and operational data quality issues have been identified:
1. **Structural Duplicates:** Exactly 3 rows are identical, redundant duplicates that inflate sample size and must be removed.
2. **Implausible Values (Errors):** We observed negative values for age (`-5` years) and appointment lag time (`-3` wait days), alongside biochemically impossible values for blood sugar control (`a1c = 1.5%`).
3. **Clinical Outliers:** Hypertensive crisis levels of systolic blood pressure (`systolic_bp = 280 mmHg`) are recorded for three patients.
4. **Casing & Abbreviation Mismatches:** Inconsistent coding in `insurance_status` ("medicaid" vs "Medicaid") and `transportation_access` ("y" vs "Yes") artificial expands category counts.
5. **Missingness:** Blank strings represent missing values for `clinic_location` (8 rows) and `visit_reason` (8 rows), while `bmi` (8 NAs) and `a1c` (7 NAs) have standard missing values.

### Key Analytical Constraints
* **Primary Outcome Class Imbalance:** In the **RAW dataset (before deduplication, $N = 303$)**, the primary outcome `appointment_completed` has a 90.1% completion rate (273 "Yes" vs. 30 "No"); in the **cleaned sample after removing 3 exact duplicate rows ($N = 300$)**, there are **270 completed (90.0%) and 30 missed (10.0%)** appointments. With only 30 event cases of noncompletion, multivariable logistic regression modeling is highly constrained in degrees of freedom (risk of overfitting).
* **Data Leakage:** Six variables (e.g., `patient_satisfaction`, `estimated_visit_cost`, `missed_appointment_cost`) represent post-appointment operational or clinical outcomes. They cannot be used as predictors for the primary completion model.
* **Rare Secondary Outcome:** The secondary outcome `emergency_referral` contains only 1 "Yes" case, making it entirely unsuitable for multivariable modeling.

### Recommendation on Progress
**The project is Ready with important cautions to proceed to Chapter 03 (Data Cleaning).** The issues are major but rectifiable through systematic cleaning. No analysis should proceed without executing the data-cleaning protocols outlined in this report.

---

## 2. Dataset Identity and Unit of Analysis

* **Dataset Filename:** `data/community_health_clinic_raw_v2.csv`
* **Dimensions:** 303 rows, 35 columns
* **Observation Period:** Calendar year 2025
* **Population Represented:** Underserved patients scheduling appointments at three clinic locations (North, Central, South).
* **Dataset Nature:** Simulated transactional appointment-level data.
* **Identifier Structure:** The primary key is `patient_id`. 
  * Total records: 303
  * Unique patient IDs: 300
  * Repeated patient IDs: 3 (`patient_id` values 16, 88, and 151 appear twice).
  * Exact duplicate rows: 3 (rows 301, 302, and 303 are exact duplicates of rows 16, 88, and 151, respectively).

### Unit of Analysis Verification
A single row represents **one scheduled clinic appointment**. 
* **Legitimate Repeated Observations vs. Duplicates:** Because the repeated `patient_id` records (rows 301–303) are exact duplicates across all 35 columns (including `visit_date` and clinical readings), they represent data entry duplication rather than legitimate longitudinal or repeated appointments.
* **Conclusion:** Once the 3 exact duplicate rows are removed, the dataset contains exactly 300 unique rows for 300 unique patients. Thus, this dataset functions as a cross-sectional, appointment-level dataset with no active longitudinal patient tracking.

> [!NOTE]
> **Analyst Learning Note: Unit of Analysis**
> The unit of analysis is the major entity that is being analyzed in a study (e.g., patient, appointment, clinic). An identifier variable (like `patient_id`) repeating does not automatically indicate an error. In longitudinal or transactional datasets, a patient can have multiple appointments. However, if two rows sharing a patient ID are identical in all fields (especially timestamps and clinical measurements), they represent database duplicate errors rather than separate appointments.

---

## 3. Variable Intelligence Overview

We constructed a comprehensive [02_variable_intelligence_table.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/02_variable_intelligence_table.csv) to map all 35 variables. The variables fall into these major conceptual domains:
* **Demographic:** `age`, `gender`, `race_ethnicity`, `preferred_language`
* **Socioeconomic:** `insurance_status`, `employment_status`, `housing_status`, `income_level`
* **Access-related:** `transportation_access`, `distance_to_clinic`
* **Clinical:** `bmi`, `systolic_bp`, `diastolic_bp`, `a1c`, `chronic_conditions`, `diabetes`, `hypertension`, `smoking_status`, `exercise_days_per_week`, `mental_health_screen`
* **Operational/Scheduling:** `visit_date`, `clinic_location`, `provider_type`, `visit_reason`, `appointment_wait_days`, `previous_no_shows`
* **Outcome (Primary & Secondary):** `appointment_completed`, `followup_required`, `emergency_referral`, `health_improved`, `patient_satisfaction`, `estimated_visit_cost`, `missed_appointment_cost`

### Measurement Timing & Leakage Risks
Each variable was classified by its measurement timing:
* **T0 (Historical):** Known prior to scheduling (e.g. demographics, housing, smoking status).
* **T1 (Pre-Appointment):** Measured at booking or clinic check-in (e.g. wait days, visit reason, blood pressure).
* **T2 (Outcome):** The main event being predicted (`appointment_completed`).
* **T3 (During/Post-Visit):** Clinical and operational outcomes generated during or immediately after the appointment (e.g. satisfaction, follow-up status).
* **T4 (Post-Visit Administrative):** Financial measures calculated based on the appointment outcome (e.g. visit cost, no-show cost).

> [!IMPORTANT]
> Post-appointment variables (T3 and T4) represent significant data leakage risk. Including them as predictors when modeling `appointment_completed` (T2) violates the chronological order of clinical operations.

---

## 4. Structural Data Quality Findings

A systematic audit of the data structure revealed several inconsistencies. The full frequencies are detailed in [02_categorical_level_audit.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/02_categorical_level_audit.csv).

### Categorical Audits
1. **`insurance_status`:** Contains both `"Medicaid"` (82 rows) and `"medicaid"` (5 rows). This casing mismatch must be standardized.
2. **`transportation_access`:** Contains `"Yes"` (255 rows), `"No"` (43 rows), and `"y"` (5 rows). The `"y"` abbreviation must be consolidated into `"Yes"`.
3. **`clinic_location`:** Contains 8 blank strings (`""`). These represent missing operational values.
4. **`visit_reason`:** Contains 8 blank strings (`""`). These represent missing scheduling values.

### Missingness Audit
The missingness counts are programmatically summary in [02_missingness_summary.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/02_missingness_summary.csv):
* `bmi`: 8 missing values (`NA` / 2.64%)
* `clinic_location`: 8 missing values (blank strings / 2.64%)
* `visit_reason`: 8 missing values (blank strings / 2.64%)
* `a1c`: 7 missing values (`NA` / 2.31%)
* Other 31 variables: 0 missing values (100% complete)

### Spacial & Categorical Sparsity Warnings
* `gender` contains a small group of `"Nonbinary"` patients (12 rows / 3.96%). While sparse, this category should be retained to maintain demographic inclusivity.
* `race_ethnicity` contains `"Other"` (15 rows / 4.95%), which is acceptable.
* `emergency_referral` has only 1 `"Yes"` case (0.33%), representing extreme sparsity.

---

## 5. Questionable Values: Errors vs. Unusual Observations

We classified questionable observations into the formal issue categories:

### A. Clearly Impossible Values (High Severity)
* **Negative Age (`age = -5`):** Record 32 (a Female patient) has an age of `-5`. This is a clear data entry error. 
  * *Analytical Consequence:* Artificially drags down the mean age and distorts demographic summaries.
  * *Recommendation:* Set to `NA` in Chapter 03 and impute.
* **Negative Wait Days (`appointment_wait_days = -3`):** Records 31, 112, 117, and 132 have wait days of `-3`. It is chronologically impossible to attend an appointment before booking it.
  * *Analytical Consequence:* Represents a calendar sync or data entry lag error.
  * *Recommendation:* Recode to `0` wait days in Chapter 03, assuming same-day walk-ins.

### B. Logically or Clinically Inconsistent Values (High Severity)
* **Implausible Blood Sugar (`a1c = 1.5%`):** Records 99, 172, and 251 have an A1C level of `1.5%`. Furthermore, patients 172 and 251 are marked as diabetic. An A1C below 3.0% is biochemically incompatible with life, and diabetic patients typically exhibit A1C > 6.5%.
  * *Analytical Consequence:* Severe measurement or translation error.
  * *Recommendation:* Recode to `NA` in Chapter 03 and impute.

### C. Clinically Extreme but Potentially Valid Values (Moderate Severity)
* **Hypertensive Crisis Blood Pressure (`systolic_bp = 280 mmHg`):** Records 181, 209, and 268 exhibit a systolic BP of `280 mmHg` (with diastolic readings of 68, 93, and 71). A systolic BP of 280 mmHg represents an extreme hypertensive crisis.
  * *Analytical Consequence:* These function as high-leverage outliers in statistical models.
  * *Recommendation:* Mark for clinical review; in Chapter 03, we recommend setting these to `NA` or winsorizing to a high percentile (e.g. 180 mmHg) because such extreme systolic pressures alongside near-normal diastolic pressures are highly suggestive of transcription errors (e.g., typing 280 instead of 180).
* **Centenarian Patients (`age = 115`):** Records 47, 93, and 236 have an age of `115`. 
  * *Analytical Consequence:* While humanly possible, three centenarians of the exact same age in a small sample of 303 is highly suspicious and suggests a default placeholder value in the Electronic Health Record (EHR).
  * *Recommendation:* Retain but flag for sensitivity analyses in modeling.

> [!NOTE]
> **Analyst Learning Note: Detection vs. Correction**
> Detecting a data anomaly (e.g., identifying age = -5) is a mathematical certainty. Correcting it (e.g., deciding to replace it with the median age of 53) is an analytical assumption. Imputation does not recover the truth; it preserves statistical power under explicit assumptions. We must document these decisions transparently rather than silently "fixing" data.

---

## 6. Missing-Data Assessment

Missingness is concentrated in four variables and affects a small percentage of the records (~2.5% per variable).

### Missingness Concentration & Associations
* We tested whether the 8 missing clinic locations or the 8 missing visit reasons were associated with specific patient subgroups. They appear randomly distributed across genders and clinic outcomes, suggesting a **Missing Completely at Random (MCAR)** pattern.
* For `bmi` (8 NAs) and `a1c` (7 NAs), missingness is common in clinic settings where clinical measures are not captured if not clinically indicated for a particular visit type (e.g., a simple acute illness visit may not require an A1C draw). This points to a **Missing Value at Random (MAR)** pattern.

### Planned Mitigation (Chapter 03)
* **Complete-Case Deletion:** If we delete every record with any missing value, we would lose 31 records (~10.2% of our sample). Given our already small sample size (N=303) and primary outcome sparsity, complete-case deletion is highly discouraged.
* **Imputation Plan:** We recommend imputing continuous clinical variables (`bmi`, `a1c`) using median imputation or multivariable imputation (MICE). Categorical variables (`clinic_location`, `visit_reason`) will be recoded to a new category level: `"Unknown"`.

---

## 7. Primary Outcome Intelligence

The primary outcome is **`appointment_completed`** (reported below for both the **RAW dataset before deduplication [$N = 303$]** and the **cleaned sample after deduplication [$N = 300$]**):
* **Completed (`Yes`):** 273 appointments (90.1%) in **RAW** data before deduplication; **270 appointments (90.0%)** in the **cleaned** sample ($N = 300$)
* **Noncompleted/Missed (`No`):** 30 appointments (9.9% in RAW data; **10.0% in the cleaned sample**)

### Finding → Interpretation → Consequence Framework

* **Finding:** Only 30 scheduled appointments resulted in noncompletion, leading to a 9:1 class ratio.
* **Interpretation:** There is a severe class imbalance in the outcome variable. 
* **Analytical Consequence:** The total number of events (noncompletions) is small ($E = 30$). Under statistical guidelines, we should limit model complexity to avoid overfitting. A common heuristic is the "Events Per Variable" (EPV) rule, suggesting 10–15 events per predictor degree of freedom. With $E = 30$, our model should contain no more than **2 to 3 predictor degrees of freedom** in a multivariable logistic regression. Attempting to model all eligible predictors simultaneously (demographics, clinical, socioeconomic) will lead to extreme overfitting, wide confidence intervals, and unstable coefficients.
* **Recommended Next Action:** For Chapter 05 modeling, we must prioritize predictors based on substantive theory (e.g., transportation access and previous no-shows) and avoid over-parameterized models. We must also run sensitivity analyses and evaluate model calibration carefully.

---

## 8. Secondary Outcome Readiness

The potential secondary outcomes from Chapter 01 were audited for readiness:

| Outcome Variable | Type | Distribution / Levels | Modeling Readiness | Cautions & Limitations |
| :--- | :--- | :--- | :--- | :--- |
| **`followup_required`** | Binary | No: 135 (44.6%), Yes: 168 (55.4%) | **Ready for modeling** | Post-visit timing; must be modeled separately and excluded as a predictor from the primary model. |
| **`health_improved`** | Binary | No: 132 (43.6%), Yes: 171 (56.4%) | **Ready for modeling** | Post-visit timing; must be modeled separately. |
| **`emergency_referral`** | Binary | No: 302 (99.7%), Yes: 1 (0.33%) | **Unsuitable for modeling** | Only 1 positive event. Multivariable models will fail to converge. Analyze descriptively only. |
| **`patient_satisfaction`** | Ordinal | 1: 15 (5%), 2: 54 (17.8%), 3: 111 (36.6%), 4: 93 (30.7%), 5: 30 (9.9%) | **Ready for modeling** | Post-visit ordinal score. Exclude from primary model. Can be modeled in Chapter 05 using ordinal logistic regression. |
| **`estimated_visit_cost`** | Continuous | Range: [$80.93, $348.22], Mean: $152.48 | **Ready for modeling** | Continuous financial outcome. Exclude from primary model. Model via multiple linear regression. |
| **`missed_appointment_cost`**| Continuous | Range: [$0.00, $149.05], Mean: $9.16 | **Ready for modeling** | Bimodal cost distribution. Exclude from primary model. Note: cost is exactly $0 for completed visits, and >$0 for missed visits. |

---

## 9. Measurement Timing and Data Leakage

To prevent invalid predictive modeling, we mapped variables into a chronological timing framework:

```
  [ T0: Historical ] ────> [ T1: Pre-Appointment ] ────> [ T2: Outcome ] ────> [ T3: During/Post-Visit ] ────> [ T4: Admin/Financial ]
  (Age, Race, Housing)     (Wait Days, Systolic BP)      (Completed: Y/N)      (Followup, Satisfaction)     (Estimated Visit Cost)
```

### Data Leakage Assessment
For the primary predictive task (predicting whether an appointment will be completed, T2):
* **Leakage Variables:** `followup_required` (T3), `emergency_referral` (T3), `health_improved` (T3), `patient_satisfaction` (T3), `estimated_visit_cost` (T4), and `missed_appointment_cost` (T4) represent information that does not exist at the time of prediction.
* **Analytical Consequence:** If `missed_appointment_cost` is included in the primary model, the model will achieve 100% accuracy because cost is perfectly collinear with noncompletion (cost > 0 only if completed = No). This is classic **outcome-derived leakage** and renders the model useless for clinic operations.
* **Recommended Next Action:** Formally exclude all T3 and T4 variables from the predictor set of the primary logistic model in Chapter 05.

---

## 10. Predictor Role Assessment

We mapped all candidate predictors in [02_predictor_role_map.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic Operations%20Analysis/outputs/tables/02_predictor_role_map.csv).

### Conceptual Redundancy & Multicollinearity
* **Clinical Redundancy:** There is a high conceptual overlap between the count variable `chronic_conditions` and the binary clinical indicators `diabetes` and `hypertension`. 
* **Analytical Consequence:** Including `chronic_conditions`, `diabetes`, and `hypertension` simultaneously in a regression model will inflate standard errors due to multicollinearity.
* **Recommendation:** Chapter 05 should evaluate Variance Inflation Factors (VIF) and consider modeling either the count or the individual indicator flags, but not both, unless clinically justified.

### Confounding and Covariate Roles
* Socioeconomic status (`income_level`, `insurance_status`) and demographics (`age`) are key potential confounders that correlate with both access barriers (e.g., transportation access) and clinic appointment completion. These must be included in multivariable models to isolate the independent effect of access barriers.

---

## 11. Hypothesis Feasibility Review

We reviewed the feasibility of the 5 hypotheses proposed in Chapter 01 against the actual dataset characteristics. The full review is saved in [02_hypothesis_feasibility_review.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/02_hypothesis_feasibility_review.csv).

* **Hypothesis 1 (Transportation & Distance):** **Supported after cleaning.** (Requires standardizing `transportation_access` casing issues).
* **Hypothesis 2 (Previous No-Shows):** **Supported as written.** (Predictor and outcome have 100% complete data with strong variation).
* **Hypothesis 3 (Scheduling Lag & Visit Reason):** **Supported after cleaning.** (Requires recoding `-3` wait days to `0`, and standardizing blank strings in `visit_reason` to `"Unknown"`).
* **Hypothesis 4 (Socioeconomic Vulnerability):** **Supported as written.** (Predictors `housing_status` and `food_insecurity_risk` are complete and well-distributed).
* **Hypothesis 5 (Clinical Burden Outcomes):** **Requires modification.** The clinical burden predictors are viable. However, the hypothesis contains two outcomes: `followup_required` and `emergency_referral`. While `followup_required` is modelable, `emergency_referral` has only 1 positive event, making regression modeling impossible. We recommend testing clinical burden against `followup_required` using logistic regression, and evaluating the relationship with `emergency_referral` using descriptive statistics (e.g., Fisher's exact test).

---

## 12. Diagnostic Visualization Findings

Three diagnostic figures were generated during this screening:

### A. Missingness Overview
This plot confirms that missingness is localized to four variables, all below 3.0% missingness:
![Missingness Overview](/Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/figures/02_missingness_overview.png)

### B. Primary Outcome Class Balance
This visualization highlights the severe class imbalance (9:1 ratio) in the primary outcome, emphasizing the risk of model overfitting:
![Primary Outcome Balance](/Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/figures/02_primary_outcome_balance.png)

### C. Numeric Screening
This plot displays the distributions of our four anomalous numeric variables, clearly showing the impossible negative age, negative wait days, low A1C values, and extreme systolic blood pressure outliers:
![Numeric Screening](/Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/figures/02_numeric_screening.png)

---

## 13. Data Quality Issue Register Summary

A formal [02_data_quality_issue_register.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/02_data_quality_issue_register.csv) has been created. In summary:
* **High Severity Issues:** 8 (Structural duplicates, negative age, extreme systolic BP, implausible A1C, outcome class imbalance, rare secondary outcome, data leakage).
* **Moderate Severity Issues:** 5 (Negative wait days, extreme centenarian ages, missing clinic locations, missing visit reasons, missing clinical measures).
* **Low Severity Issues:** 2 (Casing mismatch in `insurance_status`, abbreviation mismatch in `transportation_access`).

---

## 14. Chapter 03 Handoff: Prioritized Cleaning Work Plan

Chapter 03 must execute the following prioritized transformations. **No values should be changed silently; all actions must be logged.**

1. **Duplicate Removal (Definite):** Drop rows 301, 302, and 303 (exact duplicates).
2. **Standardize Categorical Variables (Definite):**
   * Convert `"medicaid"` to `"Medicaid"` in `insurance_status`.
   * Convert `"y"` to `"Yes"` in `transportation_access`.
3. **Recode Chronological Errors (Likely):** Recode `appointment_wait_days = -3` to `0` (same-day walk-ins).
4. **Handle Biochemically Impossible Values (Likely):** Recode `a1c = 1.5` to `NA` (requires imputation).
5. **Handle Outliers (Analyst Judgment Required):** 
   * For `systolic_bp = 280`, we recommend recoding to `NA` or winsorizing to `180 mmHg` (the threshold for hypertensive crisis), as a systolic BP of 280 mmHg with normal diastolic BP is highly indicative of key-entry error.
   * For centenarians (`age = 115`), retain as valid but flag for sensitivity testing.
6. **Handle Missingness (Analyst Judgment Required):**
   * Recode empty strings `""` in `clinic_location` and `visit_reason` to `"Unknown"`.
   * Impute missing clinical values in `bmi` (8 NAs) and `a1c` (7 NAs + 3 recoded NAs = 10 total) using median imputation or multiple imputation (MICE).

---

## 15. Chapter 04 Handoff: Substantive EDA Questions

Chapter 04 (Exploratory Data Analysis) should focus on investigating the following substantive relationships:
1. **Access Barriers:** Construct bivariate plots and contingency tables of `transportation_access` and `distance_to_clinic` against `appointment_completed`.
2. **Behavioral History:** Assess the completion rate across levels of `previous_no_shows`.
3. **Scheduling Lag:** Plot completion rate as a function of `appointment_wait_days`, stratified by `visit_reason` (to examine Hypothesis 3).
4. **Vulnerability Profiles:** Analyze the joint distribution of `housing_status` and `food_insecurity_risk` against appointment completion.
5. **Clinical Burden & Costs:** Summarize clinical burden metrics (`chronic_conditions`, `diabetes`, `hypertension`) against `followup_required` and investigate operational costs (`estimated_visit_cost`, `missed_appointment_cost`).

---

## 16. Chapter 05 Handoff: Modeling Constraints and Considerations

Chapter 05 (Statistical Modeling) must adhere to these structural constraints:
1. **Model Complexity Boundary:** With only 30 event cases of noncompletion, multivariable logistic regression must be limited to **2 to 3 predictor degrees of freedom** to prevent overfitting.
2. **Predictor Selection:** Avoid automatic variable selection methods (e.g. stepwise regression) based solely on p-values. Select predictors based on clinical/operational significance and the Chapter 01 hypotheses.
3. **Leakage Exclusion:** Exclude all post-outcome variables (`followup_required`, `emergency_referral`, `health_improved`, `patient_satisfaction`, `estimated_visit_cost`, `missed_appointment_cost`) from the predictor pool.
4. **Secondary Modeling:** Fit separate regression models for secondary outcomes (e.g. multiple linear regression for `estimated_visit_cost`, ordinal logistic regression for `patient_satisfaction`).
5. **Model Diagnostics:** Evaluate multicollinearity using Variance Inflation Factors (VIF) (especially for chronic conditions vs specific diagnoses) and check model calibration.

---

## 17. Chapter 01 Revisions Recommended

Based on our screening of the actual dataset, we recommend the following modifications to the Chapter 01 analytical plan:
* **Hypothesis 5 Modification:** Defer the regression modeling of `emergency_referral` due to having only 1 event case in the entire dataset. Analyze the relationship between clinical burden and emergency referrals using Fisher's exact test or descriptive summaries.
* **Predictor Reduction:** Reduce the proposed set of covariates in the primary model to focus strictly on transportation access, previous no-shows, and scheduling lag, in order to respect the Events Per Variable (EPV) constraint.

---

## 18. Overall Analytical Readiness Assessment

| Readiness Rating | Justification |
| :--- | :--- |
| **Ready with important cautions** | The dataset is structurally sound and represents the target population. However, it contains several critical data entry errors (negative age, negative wait days, impossible A1C), structural duplicates, and a severe class imbalance in the primary outcome. Progression is approved provided that the cleaning plan in Chapter 03 and modeling constraints in Chapter 05 are strictly followed. |

---

## 19. Analyst Learning Notes

### Analyst Learning Note 1: Data Type vs. Conceptual Type
A computer storage type (e.g., character, integer) does not dictate its analytical meaning. For example, `patient_satisfaction` is stored as an integer, but conceptually it is an ordinal categorical rating. Treating it as a continuous variable in linear regression assumes equal intervals between scores (e.g., that the difference between 1 and 2 is identical to the difference between 4 and 5), which may not be true. Analysts must distinguish storage types from measurement scales.

### Analyst Learning Note 2: Data Leakage (Temporal & Outcome-Derived)
Data leakage occurs when information from the future or the outcome itself is included in the predictor pool. 
* *Temporal Leakage:* Using a variable measured during the visit (e.g., `followup_required`) to predict whether the patient will show up for the visit.
* *Outcome-Derived Leakage:* Using a variable that is a direct function of the outcome (e.g., `missed_appointment_cost`, which is only > $0 if the appointment was missed).
Leakage leads to models that perform perfectly in validation but fail completely in clinical production because the predictor variables do not exist at the time of prediction.

### Analyst Learning Note 3: Events Per Variable (EPV) and Model Complexity
In logistic regression, the sample size constraint is determined by the number of observations in the *minority class* (the "events"), not the total sample size. If a dataset has 300 rows but only 30 events, modeling 10 predictors will result in severe overfitting. The model will "memorize" the 30 event cases, leading to unstable coefficients, massive standard errors, and poor generalizability. A minimum of 10–15 events per predictor degree of freedom is recommended.

---

## 20. Further Study References

1. **On Missing Data Analysis & Imputation:**
   * Little, R. J., & Rubin, D. B. (2019). *Statistical Analysis with Missing Data* (3rd ed.). John Wiley & Sons.
   * *Why it matters:* This is the authoritative reference on missing data mechanisms (MCAR, MAR, MNAR) and provides the theoretical foundation for multiple imputation methods.
2. **On Regression Model Diagnostics and Complexity:**
   * Harrell, F. E. (2015). *Regression Modeling Strategies: With Applications to Linear Models, Logistic and Ordinal Regression, and Survival Analysis* (2nd ed.). Springer.
   * *Why it matters:* Chapter 4 discusses steps for stabilizing models under sample size limitations, focusing on the Events Per Variable (EPV) rule and the dangers of unguided variable selection.
