# Project Framing & Analytical Design Report: Community Health Clinic Operations Analysis

**File Name:** `01_project_overviewCH.md`  
**Author:** Senior Healthcare Data Analyst & Applied Statistician  
**Target Audience:** Clinic Leadership, Operations Managers, Program Directors, and Portfolio Reviewers  
**Analytics Environment:** R (RStudio / Quarto)  
**Project Root:** `/Users/michaelraney/Antigravity/Community Health Clinic Operations Analysis`  

---

## 1. Problem Definition

### The Operational Challenge
Nonprofit community health clinics operate within environments of severe resource constraints. One of the most persistent challenges they face is **appointment attrition**—patients scheduling visits but failing to complete them (no-shows and late cancellations). When appointments are missed, clinic operations are disrupted in several ways:
1. **Inefficient Resource Allocation:** Highly trained medical staff (physicians, nurse practitioners, physician assistants) experience idle time, reducing clinical throughput.
2. **Impeded Patient Access:** Other patients in need of care are blocked from booking those slots, lengthening wait times.
3. **Financial Leakage:** Missed appointments incur administrative overhead and represent lost opportunity costs, which directly impacts the clinic's ability to maintain its nonprofit services.
4. **Poor Continuity of Care:** Patients who miss appointments are at a higher risk of developing uncontrolled chronic conditions (e.g., diabetes, hypertension), which can lead to costly emergency referrals and adverse health events.

### Why This Analysis Matters
By utilizing data-driven insights, the clinic can move from reactive scheduling to proactive intervention. Understanding the demographic, socioeconomic, clinical, and operational factors associated with appointment completion allows clinic leadership to:
* **Target Interventions:** Deploy limited resources (e.g., transportation assistance, language interpreters, automated text reminders) to the patients who need them most.
* **Optimize Scheduling and Staffing:** Align provider schedules with peak patient volumes and specific visit reasons.
* **Quantify Financial Impact:** Measure the direct cost of missed appointments to build strong business cases for grant funding or operational improvements.
* **Improve Longitudinal Outcomes:** Support continuity of care, leading to improved long-term health markers for vulnerable, underserved populations.

---

## 2. Primary Outcome

### Selected Primary Outcome
The primary outcome for this analytical plan is **`appointment_completed`** (derived from the raw dataset and converted into a binary format).

### Operational and Business Rationale
* **Direct Measure of Access and Efficiency:** Appointment completion is the single most direct indicator of whether a patient successfully accessed the healthcare system for their scheduled visit and whether the clinic successfully utilized its allocated slot.
* **Actionable Variable:** While clinical outcomes (e.g., blood pressure control, A1C reduction) are ultimate goals, they cannot be achieved without the patient first entering the exam room. Improving appointment completion is the gateway to improving all subsequent clinical measures.
* **Logistic Regression Fit:** For modeling purposes, `appointment_completed` will be recoded into a binary variable:
  $$\text{appointment\_completed} = \begin{cases} 1 & \text{if "Yes" (Patient completed the appointment)} \\ 0 & \text{if "No" (Patient missed or cancelled the appointment)} \end{cases}$$
  This binary structure is perfectly suited for multivariable logistic regression modeling, allowing us to estimate the likelihood of completion based on diverse patient and operational characteristics.

---

## 3. Secondary Outcomes

To provide a comprehensive view of clinical efficacy, resource utilization, and patient experience, we identify several secondary outcomes from the dataset:

* **`followup_required` (Binary: Yes/No):** Measures whether a patient requires additional scheduled care. Modeling this outcome helps program directors anticipate future clinical demand and identify patient subgroups requiring intensive care coordination.
* **`health_improved` (Binary: Yes/No):** Serves as a clinical success metric, indicating whether the patient's overall health status improved. Associating this with clinical and socioeconomic predictors helps evaluate program effectiveness.
* **`emergency_referral` (Binary: Yes/No):** Represents a critical, high-cost clinical event. Predicting which patient characteristics are associated with emergency referrals helps clinical staff intervene early to prevent acute escalations.
* **`patient_satisfaction` (Ordinal/Continuous: 1–5 scale):** Measures the patient-reported quality of their clinic experience. High satisfaction is linked to better compliance and long-term retention.
* **`missed_appointment_cost` (Continuous: USD):** Captures the direct financial loss incurred when an appointment is missed. This serves as a key metric for clinic leadership and grant providers to quantify the return on investment (ROI) for no-show reduction programs.
* **`estimated_visit_cost` (Continuous: USD):** Measures the estimated operational cost of providing care, helping managers analyze resource allocation and clinic budgeting.

---

## 4. Variables

The dataset contains 303 rows and 35 distinct variables. To build a robust multivariable model, these variables are categorized below:

### Outcome Variables
* **`appointment_completed` (Primary):** Binary indicator ("Yes", "No") of whether the patient completed the visit.
* **`followup_required` (Secondary):** Binary indicator ("Yes", "No") of whether follow-up care is required.
* **`health_improved` (Secondary):** Binary indicator ("Yes", "No") of patient health improvement.
* **`emergency_referral` (Secondary):** Binary indicator ("Yes", "No") of referral to emergency care.
* **`patient_satisfaction` (Secondary):** Numeric score (1–5) representing patient satisfaction.
* **`missed_appointment_cost` (Secondary):** Financial cost of a missed appointment (ranges from $0 for completed appointments up to $149.05).
* **`estimated_visit_cost` (Secondary):** Financial cost of a completed appointment (ranges from $80.93 to $348.22).

### Predictor Variables

| Category | Variable | Type | Description / Values |
| :--- | :--- | :--- | :--- |
| **Demographic** | `age` | Numeric (Continuous) | Age of the patient (Note: raw data contains values from -5 to 115). |
| | `gender` | Categorical | Gender identity: `"Female"`, `"Male"`, `"Nonbinary"`. |
| | `race_ethnicity` | Categorical | Self-reported race/ethnicity: `"Hispanic"`, `"Asian"`, `"White"`, `"Black"`, `"Other"`. |
| | `preferred_language` | Categorical | Language preference: `"English"`, `"Spanish"`, `"Other"`. |
| **Socioeconomic** | `insurance_status` | Categorical | Insurance type: `"Medicaid"`, `"Private"`, `"Medicare"`, `"medicaid"` (case mismatch), `"Uninsured"`. |
| | `employment_status` | Categorical | Employment type: `"Part-time"`, `"Retired"`, `"Unemployed"`, `"Employed"`. |
| | `housing_status` | Categorical | Housing stability: `"Stable"`, `"Unstable"`, `"Temporary"`. |
| | `income_level` | Categorical | Income category: `"Low"`, `"Moderate"`, `"High"`. |
| | `transportation_access`| Categorical | Reliable transit access: `"Yes"`, `"y"` (abbreviation mismatch), `"No"`. |
| | `food_insecurity_risk` | Categorical | Risk level: `"Low"`, `"Moderate"`, `"High"`. |
| **Clinical** | `bmi` | Numeric (Continuous) | Body Mass Index (contains 8 missing values). |
| | `systolic_bp` | Numeric (Continuous) | Systolic blood pressure in mmHg (contains extreme value 280). |
| | `diastolic_bp` | Numeric (Continuous) | Diastolic blood pressure in mmHg. |
| | `a1c` | Numeric (Continuous) | Glycated hemoglobin percentage (contains 7 missing values). |
| | `chronic_conditions` | Numeric (Discrete) | Count of diagnosed chronic diseases (0 to 6). |
| | `diabetes` | Categorical | Diabetes status: `"No"`, `"Yes"`. |
| | `hypertension` | Categorical | Hypertension status: `"No"`, `"Yes"`. |
| | `smoking_status` | Categorical | Tobacco use: `"No"`, `"Yes"`. |
| | `exercise_days_per_week`| Numeric (Discrete) | Self-reported weekly exercise days (0 to 7). |
| | `mental_health_screen` | Categorical | PHQ/GAD screen result: `"Negative"`, `"Mild"`, `"Moderate"`, `"Severe"`. |
| **Operational** | `visit_date` | Date | Date of the scheduled visit (calendar year 2025). |
| | `clinic_location` | Categorical | Location of the clinic: `"North"`, `"Central"`, `"South"` (contains 8 missing values). |
| | `provider_type` | Categorical | Practitioner type: `"Physician"`, `"Physician Assistant"`, `"Nurse Practitioner"`. |
| | `visit_reason` | Categorical | Reason for booking: `"Chronic Disease"`, `"Acute Illness"`, `"Primary Care"`, `"Preventive Care"` (8 missing values). |
| | `appointment_wait_days`| Numeric (Continuous) | Days between booking and visit date (contains negative values down to -3). |
| | `previous_no_shows` | Numeric (Discrete) | Count of prior missed appointments (0 to 4). |
| | `distance_to_clinic` | Numeric (Continuous) | Distance in miles between patient residence and clinic (0.5 to 23.5 miles). |

---

## 5. Hypotheses

The following 5 testable, non-causal hypotheses will guide the statistical analysis:

1. **Hypothesis 1 (Socioeconomic Barriers & Access):**  
   * **Statement:** Patients who report lacking reliable transportation (`transportation_access` == "No") and reside at a greater distance from the clinic (`distance_to_clinic`) are associated with a lower likelihood of appointment completion (`appointment_completed` == "Yes").
   * **Variables:** `transportation_access` (Socioeconomic), `distance_to_clinic` (Operational), `appointment_completed` (Outcome).

2. **Hypothesis 2 (Behavioral History):**  
   * **Statement:** A higher number of previous no-shows (`previous_no_shows`) is linked to a lower probability of current appointment completion (`appointment_completed` == "Yes").
   * **Variables:** `previous_no_shows` (Operational), `appointment_completed` (Outcome).

3. **Hypothesis 3 (Scheduling Lag & Visit Reason):**  
   * **Statement:** Longer scheduling lag times (`appointment_wait_days`) are related to a lower likelihood of appointment completion, and this relationship is stronger for preventive and primary care visits (`visit_reason` in "Preventive Care", "Primary Care") than for acute illness visits (`visit_reason` == "Acute Illness").
   * **Variables:** `appointment_wait_days` (Operational), `visit_reason` (Operational), `appointment_completed` (Outcome).

4. **Hypothesis 4 (Socioeconomic Vulnerability):**  
   * **Statement:** Socioeconomic vulnerability—indicated by housing instability (`housing_status` in "Unstable", "Temporary") and high food insecurity risk (`food_insecurity_risk` == "High")—is associated with a lower likelihood of appointment completion.
   * **Variables:** `housing_status` (Socioeconomic), `food_insecurity_risk` (Socioeconomic), `appointment_completed` (Outcome).

5. **Hypothesis 5 (Clinical Burden & Continuity of Care):**  
   * **Statement:** A higher clinical burden—indicated by a higher count of chronic conditions (`chronic_conditions`), diabetes (`diabetes` == "Yes"), and hypertension (`hypertension` == "Yes")—is associated with a higher likelihood of requiring additional follow-up care (`followup_required` == "Yes") and a higher probability of emergency referrals (`emergency_referral` == "Yes").
   * **Variables:** `chronic_conditions` (Clinical), `diabetes` (Clinical), `hypertension` (Clinical), `followup_required` (Outcome), `emergency_referral` (Outcome).

---

## 6. Analysis Plan

### Part A: Exploratory Data Analysis (EDA)
Before proceeding to formal statistical modeling, a thorough exploratory analysis will be conducted in R to understand the raw data structure:
1. **Summary Statistics:** Utilize `skimr::skim()` and `summary()` to obtain central tendency, dispersion, and range metrics for all continuous variables, and `janitor::tabyl()` for categorical frequency tables.
2. **Missing Data Assessment:** Map the prevalence and patterns of missingness (e.g., the 8 NAs in `bmi` and `clinic_location`, 7 NAs in `a1c`, and 8 NAs in `visit_reason`) to evaluate whether data are Missing Completely at Random (MCAR) or show systematic patterns.
3. **Distribution Analysis:** Plot histograms and density curves for continuous predictors (`age`, `bmi`, `systolic_bp`, `diastolic_bp`, `a1c`, `appointment_wait_days`, `distance_to_clinic`) using `ggplot2` to assess skewness and identify potential extreme values or errors (e.g., negative ages, negative wait days).
4. **Correlation Analysis:** Construct a correlation matrix of numeric clinical predictors (`systolic_bp`, `diastolic_bp`, `bmi`, `a1c`, `chronic_conditions`) to screen for multicollinearity.
5. **Group Comparisons:** Create boxplots and perform two-sample t-tests (or Wilcoxon rank-sum tests) comparing continuous variables (e.g., `distance_to_clinic`, `appointment_wait_days`, `age`) across levels of `appointment_completed` (Yes vs. No).
6. **Outcome Balance:** Generate a bar plot of `appointment_completed` to evaluate class balance, which informs model interpretation and sensitivity.
7. **Temporal & Seasonal Trends:** Using `visit_date`, extract the month and day of the week using `lubridate` functions. We will plot:
   * Monthly patient volume.
   * Monthly appointment completion (no-show) rates to identify seasonal fluctuations (e.g., higher no-shows in winter months).
   * Daily/weekly clinic activity over time.

---

### Part B: Statistical Modeling

#### Primary Model: Logistic Regression
Since `appointment_completed` is a binary outcome, logistic regression is the appropriate statistical framework to model the probability of completion:

$$\log\left(\frac{P(Y = 1)}{1 - P(Y = 1)}\right) = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \dots + \beta_k X_k$$

Where:
* $Y = 1$ indicates `appointment_completed` is "Yes".
* $X_1, X_2, \dots, X_k$ represent the demographic, socioeconomic, clinical, and operational predictors.
* $\beta_0$ is the intercept, and $\beta_i$ represents the change in the log-odds of completion per unit change in $X_i$, holding all other variables constant.

* **Odds Ratios (OR):** To make the model accessible to clinic leadership, coefficients ($\beta_i$) will be exponentiated ($e^{\beta_i}$) to represent Odds Ratios.
  * An $OR > 1$ indicates that an increase in the predictor is associated with a higher likelihood of appointment completion.
  * An $OR < 1$ indicates that an increase in the predictor is associated with a lower likelihood of appointment completion.
* **Confidence Intervals (CI):** 95% Wald confidence intervals will be calculated for all odds ratios. If the CI does not cross 1.0, the association is considered statistically significant at the $\alpha = 0.05$ level.
* **Diagnostics:** 
  * **Multicollinearity:** Variance Inflation Factors (VIF) will be evaluated using `car::vif()`; any variable with a VIF > 5 will be investigated.
  * **Goodness of Fit:** The Hosmer-Lemeshow test will be used to evaluate calibration.
  * **Classification Power:** The Receiver Operating Characteristic (ROC) curve and Area Under the Curve (AUC) will be generated to assess the model's discriminative ability.

#### Secondary Model: Multiple Linear Regression
To analyze the operational costs associated with clinic disruption, a secondary multiple linear regression model will be fitted for the continuous outcome **`missed_appointment_cost`** (for missed visits) or **`estimated_visit_cost`** (for completed visits):

$$Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \dots + \beta_k X_k + \epsilon$$

Where:
* $Y$ is the continuous cost variable (`missed_appointment_cost`).
* $\beta_i$ represents the dollar change in missed appointment costs associated with a one-unit change in predictor $X_i$, holding other variables constant.
* $\epsilon$ is the random error term, assumed to be $\sim N(0, \sigma^2)$.

* **Interpretation:** 
  * Coefficients ($\beta_i$) will be interpreted as the direct financial impact of each predictor. For example, a coefficient of 5.5 for `distance_to_clinic` would indicate that each additional mile of distance is associated with an average increase of $5.50 in missed appointment costs.
  * The Coefficient of Determination ($R^2$) will measure the proportion of variance in costs explained by the model.
* **Diagnostics:** 
  * Linear regression assumptions will be verified using diagnostic plots: Residuals vs. Fitted (linearity), Normal Q-Q (normality of residuals), Scale-Location (homoscedasticity), and Residuals vs. Leverage (influential outliers / Cook's distance).

---

## 7. Risks and Data Issues

Based on a preliminary inspection of the raw dataset, the following data quality issues and methodological risks must be addressed during preprocessing:

1. **Missing Data:**
   * **Observed:** 8 missing values in `bmi` and `clinic_location`, 7 in `a1c`, and 8 in `visit_reason`.
   * **Mitigation:** Evaluate missingness patterns. For categorical variables, code missingness as an "Unknown" level or impute using the mode. For continuous clinical indicators (`bmi`, `a1c`), use median imputation or multiple imputation (MICE) rather than complete-case analysis to prevent selection bias and preserve sample size.
2. **Outliers and Anomalies:**
   * **Observed:** `age` contains a minimum of -5.00 and a maximum of 115.00. `systolic_bp` reaches a maximum of 280.00.
   * **Mitigation:** Implausible values like negative age must be treated as errors and replaced (either with NA or median age of the group). The age of 115 and systolic BP of 280 are physiologically extreme; we will check if they represent single-digit entry errors (e.g., typing 280 instead of 180) and apply winsorization or handle them as missing if unresolvable.
3. **Inconsistent Categorical Coding:**
   * **Observed:** `insurance_status` contains both `"Medicaid"` and `"medicaid"` (casing mismatch). `transportation_access` contains `"Yes"`, `"y"`, and `"No"` (abbreviation mismatch).
   * **Mitigation:** Standardize text strings using `stringr` and `mutate(across(..., tolower))` or explicit `case_when()` mapping to ensure categories are consolidated.
4. **Implausible Operational Values:**
   * **Observed:** `appointment_wait_days` has a minimum value of -3.00.
   * **Mitigation:** A negative wait time is chronologically impossible (a patient cannot be seen before booking). These records will be investigated. If the negative values represent same-day walk-ins where visit date was recorded slightly before the booking timestamp, they will be recoded to 0 wait days.
5. **Selection Bias:**
   * **Risk:** The dataset only contains patients who actively scheduled an appointment in 2025. It does not represent patients in the community who face such severe barriers that they never attempt to schedule an appointment. 
   * **Interpretation Warning:** Findings will only generalize to *active clinic-scheduling patients* and not to the broader community population.
6. **Confounding Variables:**
   * **Risk:** Socioeconomic variables (e.g., `income_level`, `housing_status`) are likely correlated with both the predictor of interest (e.g., `distance_to_clinic`) and the outcome (`appointment_completed`). For instance, lower-income patients may live further away in affordable areas and have poorer transportation access.
   * **Mitigation:** Multivariable models must simultaneously include these potential confounders to control for their effects and isolate the independent associations of interest.

---

## 8. Expected Insights

The outcomes of this analysis are designed to translate directly into operational solutions for the clinic:

* **Targeted Transportation Support:** If the hypothesis holds that distance and lack of transit access are associated with missed appointments, the clinic can allocate resources to provide rideshare vouchers or coordinate mobile health vans for high-risk postal codes.
* **Proactive Scheduling Adjustments:** Identifying the optimal scheduling window (`appointment_wait_days`) before no-show rates spike will allow scheduler templates to limit booking lag for specific visit types.
* **Recall and Text Reminder Optimization:** Patients with a history of no-shows (`previous_no_shows`) or specific demographic profiles can be enrolled in high-frequency, multi-channel reminder protocols (e.g., phone calls, SMS, secure emails in preferred languages).
* **Clinical Intervention Pathways:** By linking chronic condition counts with higher follow-up needs, the clinic can design dedicated nurse-led navigation programs to guide complex patients through their care pathway.
* **Nonprofit Resource Advocacy:** By quantifying the financial impact via `missed_appointment_cost`, the clinic will have empirical, R-validated cost data to support grant applications, demonstrating how an investment in transportation or scheduling coordination will save the organization money.

---

## 9. Workflow Summary

* **Files Created/Modified:**
  * Created project overview file: [01_project_overviewCH.md](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/01_project_overviewCH.md) in the project root.
  * Generated raw CSV dataset: [community_health_clinic_raw_v2.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/data/community_health_clinic_raw_v2.csv) exported from the Apple Numbers file.
* **Key Decisions Made:**
  * Selected `appointment_completed` as the primary binary outcome variable, justifying its use as the operational gateway to care.
  * Categorized all 35 variables into standard clinical/operational frameworks to guide preprocessing.
  * Formulated 5 non-causal hypotheses focusing on access barriers, history of missed visits, wait times, socioeconomic vulnerability, and chronic disease burden.
* **Data Quality Concerns Identified:**
  * Implausible negatives (age of -5, wait days of -3).
  * Extreme outliers (age of 115, systolic BP of 280).
  * String casing/abbreviation inconsistencies in `insurance_status` ("Medicaid" vs "medicaid") and `transportation_access` ("Yes", "y", "No").
  * Missingness in `bmi`, `a1c`, `clinic_location`, and `visit_reason`.
* **Recommended Next Step:**
  * Proceed to **Prompt 02 — Data Screening** to clean and prepare the raw dataset for exploratory visualization and modeling.
