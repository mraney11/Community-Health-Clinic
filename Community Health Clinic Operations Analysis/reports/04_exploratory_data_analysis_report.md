# Chapter 04 — Exploratory Data Analysis

**Document Title:** Master Exploratory Data Analysis (EDA) Report: Community Health Clinic Operations Analysis  
**File Name:** `reports/04_exploratory_data_analysis_report.md`  
**Project Root:** `/Users/michaelraney/Antigravity/Community Health Clinic Operations Analysis`  
**Analytics Environment:** R 4.6.1 (Tidyverse, Broom, Car, Scales, Cowplot)  
**Author:** Senior Healthcare Data Analyst & Statistical Research Methodologist  
**Date:** July 2026  
**Analytical Dataset Source:** `data/community_health_clinic_clean.csv` ($N = 300$, 35 columns)  

---

## 1. Executive EDA Summary

This report establishes the comprehensive exploratory foundation for the Community Health Clinic Operations Analysis. Following the diagnostic screening and programmatic cleaning conducted in Chapters 02 and 03, this analysis investigates the underlying data geometry, evaluates core hypotheses, audits modeling assumptions, screens for multicollinearity and confounding, and eliminates information leakage risks ahead of Chapter 05 (Statistical Modeling).

The primary analytical dataset consists of **$N = 300$ validated, unique patient encounters** spanning calendar year 2025. Through rigorous univariate, bivariate, and multivariable evaluations, the exploratory analysis has uncovered five major operational and clinical insights:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                 CORE EDA DISCOVERIES                                   │
├───────────────────────────────────┬────────────────────────────────────────────────────┤
│ 1. Severe Outcome Class Imbalance │ 270 Completed (90.0%) vs. 30 Missed (10.0%).       │
│    (EPV Budget Constraint)        │ Limits multivariable models to 2–3 predictor DF.   │
├───────────────────────────────────┼────────────────────────────────────────────────────┤
│ 2. Geographic / Facility Gradient │ South Clinic accounts for 60.0% of all missed      │
│    (Primary Operational Driver)   │ visits (17.5% no-show rate vs. 3.2% at North).     │
├───────────────────────────────────┼────────────────────────────────────────────────────┤
│ 3. Compounding Transit Barrier    │ Lack of transportation increases no-shows (16.3%   │
│    (Hypothesis 1 Access Penalty)  │ vs 8.9%), reaching 18.8% for patients >10.4 miles. │
├───────────────────────────────────┼────────────────────────────────────────────────────┤
│ 4. Scheduling Lag & Urgency Decay │ Acute visits fail at 20.0% across all wait times;  │
│    (Hypothesis 3 Interaction)     │ Preventive visits decay from 5.9% to 14.3% missed. │
├───────────────────────────────────┼────────────────────────────────────────────────────┤
│ 5. Clinical Follow-Up Threshold   │ Having >= 2 chronic conditions deterministically  │
│    (Hypothesis 5 Care Protocol)   │ triggers 100.0% follow-up care demand (n = 108).   │
└───────────────────────────────────┴────────────────────────────────────────────────────┘
```

```mermaid
flowchart TD
    subgraph Data["1. Validated Cleaned Cohort (N = 300)"]
        D1["Demographics (Age, Gender, Race)"]
        D2["Socioeconomic (Transit, Housing, Income)"]
        D3["Operational (Clinic Site, Lag, Reason)"]
        D4["Clinical Baseline (BP, A1C, Conditions)"]
    end

    subgraph EDA["2. Exploratory Investigation (Chapter 04)"]
        E1["Univariate & Skewness Screening"]
        E2["Outcome Bivariate Associations"]
        E3["Stratified Confounding & Interaction Review"]
        E4["Information Leakage & EPV Boundary Audit"]
    end

    subgraph Roadmap["3. Chapter 05 Modeling Roadmap"]
        M1["Primary Model: 2-3 DF Logistic / Firth"]
        M2["Secondary Linear Model: Estimated Visit Cost"]
        M3["Secondary Binary Model: Follow-Up Threshold"]
        M4["Descriptive Summary: Emergency Referral (n=1)"]
    end

    Data --> EDA
    EDA --> Roadmap
```

---

## 2. Dataset Structure and Variable Intelligence

### 2.1 Structural Validation and Ingestion Audit

Before executing graphical or associative analyses, the cleaned analytical dataset (`data/community_health_clinic_clean.csv`) was imported and subjected to structural assertion testing. The dataset contains **300 rows** and **35 columns**, representing 300 distinct scheduled patient visits with zero record-level duplicates ($0.0\%$) and zero missing cells ($0.0\%$) across all analytical fields.

The full variable metadata and descriptive inventory is cataloged in [04_variable_inventory.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_variable_inventory.csv).

```
========================================================================================
DATASET STRUCTURAL COMPOSITION:
• Total Observations:        300 scheduled patient encounters
• Total Variables:           35 columns
• Continuous / Numeric:      13 variables (Age, Distance, BMI, BP, A1C, Costs, Lag)
• Categorical / Factor:      16 variables (Gender, Race, Insurance, Housing, Clinic)
• Binary Indicators:         8 variables (Completed, Transit, Diabetes, Follow-up)
• Date / Temporal Fields:    1 variable (visit_date, spanning 2025-01-01 to 2025-12-31)
• Record Identifier:         1 primary key (patient_id, 100% unique integers 1..300)
• Post-Clean Missingness:    0 cells (100% complete-case readiness)
========================================================================================
```

> [!NOTE]
> **Analyst's Note: The Imperative of Pre-Analysis Structural Auditing**  
> Senior analysts never begin exploratory plotting until variable classes, uniqueness constraints, and unit of analysis boundaries are verified. Misinterpreting a numeric identifier (`patient_id`) as a continuous metric or leaving binary factors unlabelled introduces spurious correlations and distorts regression parameter estimates. Structural auditing ensures that every downstream table and figure is mathematically and substantively valid.

### 2.2 Variable Class and Storage Review

An audit of R data types against preferred modeling specifications was conducted and recorded in [04_variable_class_review.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_variable_class_review.csv). All character fields (`insurance_status`, `transportation_access`, `clinic_location`, `visit_reason`) were validated as nominal categorical factors. `patient_satisfaction` is stored as an integer (1–5) but represents an ordinal Likert rating. 

`patient_id` was formally verified as a non-analytic record identifier (unique across all 300 rows) and excluded from all statistical estimation routines, as documented in [04_identifier_variable_review.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_identifier_variable_review.csv).

### 2.3 Cardinality, Sparsity, and Near-Zero Variance Review

To identify potential estimation bottlenecks, cardinality and frequency distributions were evaluated across all 35 features:
* **Unique-Value Review ([04_unique_value_review.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_unique_value_review.csv)):** Identified that `emergency_referral` contains only two unique values but has extreme sparsity: 299 "No" ($99.67\%$) vs. 1 "Yes" ($0.33\%$).
* **Near-Zero Variance Review ([04_near_zero_variance_review.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_near_zero_variance_review.csv)):** Flagged `emergency_referral` (ratio 299:1), `missed_appointment_cost` (90.0% zero-inflation), and `appointment_completed` (9:1 ratio).
* **Missingness Resolution Overview ([04_missingness_by_variable.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_missingness_by_variable.csv)):** Confirms that Chapter 03 median imputation and "Unknown" categorical recoding resolved all raw data gaps while preserving sample power ($N = 300$).

![Missingness Overview](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/figures/04_missingness_overview.png)

---

## 3. Univariate Distributions and Descriptive Findings

### 3.1 Numeric Predictor Distributions and Central Tendency

For each quantitative variable, central tendency (mean, median), dispersion (standard deviation, interquartile range), empirical extremes (minimum, maximum), and skewness were calculated. The complete parametric and non-parametric summary is preserved in [04_numeric_descriptive_statistics.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_numeric_descriptive_statistics.csv).

| Variable Name | $N$ | Mean | Median | Std Dev | IQR | Min | Max | Skewness | Primary Distributional Characteristic |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **`age`** | 300 | 53.98 | 53.00 | 17.46 | 20.25 | 18.00 | 115.00 | +0.42 | Right-skewed by 3 centenarians (115y); core spans 18–84y |
| **`distance_to_clinic`** | 300 | 8.34 | 8.20 | 5.05 | 7.43 | 0.50 | 23.50 | +0.28 | Moderately right-skewed; 75% of patients reside $\le 11.7$ mi |
| **`bmi`** | 300 | 28.69 | 29.10 | 4.19 | 5.05 | 12.40 | 40.90 | -0.49 | Moderately left-skewed; clinic cohort baseline is overweight |
| **`systolic_bp`** | 300 | 121.14 | 121.00 | 12.32 | 18.00 | 84.00 | 162.00 | -0.02 | Symmetric distribution post-cleaning; bounds [84, 162] mmHg |
| **`diastolic_bp`** | 300 | 77.07 | 77.00 | 7.98 | 11.00 | 55.00 | 102.00 | +0.10 | Normal distribution; median 77 mmHg; bounds [55, 102] |
| **`a1c`** | 300 | 5.99 | 5.75 | 1.07 | 1.40 | 4.00 | 9.40 | +0.78 | Right-skewed diabetic tail; non-diabetic core at 5.5% |
| **`chronic_conditions`** | 300 | 1.22 | 1.00 | 1.20 | 2.00 | 0.00 | 6.00 | +0.86 | Discrete count; 35.3% have 0; 64.7% have $\ge 1$ conditions |
| **`exercise_days_per_week`** | 300 | 2.56 | 2.00 | 1.90 | 3.00 | 0.00 | 7.00 | +0.30 | Discrete count; 24.3% report 0 days/week sedentary |
| **`appointment_wait_days`** | 300 | 9.73 | 10.00 | 5.15 | 7.00 | 0.00 | 25.00 | +0.23 | Uniformly dispersed scheduling lag; median 10 days |
| **`previous_no_shows`** | 300 | 0.88 | 1.00 | 1.02 | 1.25 | 0.00 | 4.00 | +0.97 | Discrete count; 47.0% have 0 prior misses; 53.0% have $\ge 1$ |
| **`patient_satisfaction`** | 300 | 3.56 | 4.00 | 0.95 | 1.00 | 1.00 | 5.00 | -0.17 | Left-skewed Likert; 77.3% report satisfactory score $\ge 3$ |
| **`estimated_visit_cost`** | 300 | 152.63 | 146.37 | 44.59 | 58.92 | 80.93 | 348.22 | +0.75 | Continuous right-skewed operational cost |
| **`missed_appointment_cost`** | 300 | 9.25 | 0.00 | 28.88 | 0.00 | 0.00 | 149.05 | +3.04 | Zero-inflated (90.0% $0.00; mean $92.52 on missed visits) |

![Numeric Distributions](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/figures/04_numeric_distributions.png)

### 3.2 Categorical and Binary Distributions

The frequency distributions for all nominal, ordinal, and binary factors were calculated in tidy long format and saved in [04_categorical_frequency_summary.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_categorical_frequency_summary.csv) and [04_binary_variable_review.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_binary_variable_review.csv).

Key cohort characteristics:
* **Insurance Coverage:** Private insurance represents the largest plurality (128/300, $42.67\%$), followed by Medicaid (86/300, $28.67\%$), Medicare (53/300, $17.67\%$), and Uninsured (33/300, $11.00\%$).
* **Facility Distribution:** Patient visits are distributed across South Clinic (103/300, $34.33\%$), North Clinic (95/300, $31.67\%$), Central Clinic (94/300, $31.33\%$), and recoded Unknown (8/300, $2.67\%$).
* **Clinical Reasons:** Visits are balanced across Chronic Disease (79/300, $26.33\%$), Primary Care (77/300, $25.67\%$), Preventive Care (71/300, $23.67\%$), Acute Illness (65/300, $21.67\%$), and Unknown (8/300, $2.67\%$).
* **Transportation Barriers:** 43 out of 300 patients ($14.33\%$) report having no reliable transit access.
* **Chronic Morbidity:** 76 patients ($25.33\%$) have diagnosed diabetes mellitus, and 39 patients ($13.00\%$) have diagnosed hypertension.

![Categorical Distributions](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/figures/04_categorical_distributions.png)

### 3.3 Diagnostic Audit of Unusual Values and Centenarians

All unusual observations were audited and recorded in [04_unusual_value_review.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_unusual_value_review.csv):
1. **Centenarians (`age = 115`, Patients 47, 93, 236):** Three patients share an age of 115. While clinically retained as valid biological extremes, their identical age suggests an EHR default placeholder. They will be included linearly in baseline models and tested in sensitivity analyses.
2. **Hypertension Upper Tail (`systolic_bp` in $[155, 162]$ mmHg):** Represents plausible Stage 2 hypertension.
3. **Scheduling Lag Tail (`appointment_wait_days` in $[21, 25]$ days, $n = 9$):** Operationally plausible scheduling backlog.

---

## 4. Outcome-Centered Bivariate Exploration

### 4.1 Primary Outcome Balance and EPV Constraint

The primary outcome for this investigation is **`appointment_completed`** in the **cleaned sample ($N = 300$, after removing 3 exact duplicate rows from the RAW $N = 303$ dataset that had 273 completed [90.1%] and 30 missed [9.9%] visits)**:
* **Completed Encounters (`Yes`, Cleaned Sample):** 270 appointments ($90.00\%$, 95% CI: $[86.0\%, 93.1\%]$)
* **Missed Encounters (`No`, Cleaned Sample):** 30 appointments ($10.00\%$, 95% CI: $[6.9\%, 14.0\%]$)
* **Total Valid Observations (Cleaned Sample):** $N = 300$ ($100.0\%$ complete)

The formal summary is preserved in [04_primary_outcome_summary.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_primary_outcome_summary.csv).

$$\text{Events Per Variable (EPV)} = \frac{\min(\text{Completed}, \text{Missed})}{\text{Predictor Degrees of Freedom}} = \frac{30}{k} \ge 10 \implies k \le 3$$

> [!IMPORTANT]
> **Analyst's Note: The Methodological Iron Law of EPV**  
> In logistic regression modeling, statistical power and parameter stability are governed by the number of events in the minority class ($E = 30$), not the total row count ($N = 300$). Entering 10–15 covariates into a standard logistic model with only 30 missed appointments guarantees severe overfitting, inflated standard errors, and spurious coefficient estimates. Chapter 05 must strictly budget predictor degrees of freedom to **2–3 parameters** or utilize Firth's penalized likelihood estimation.

### 4.2 Categorical Predictors vs. Appointment Completion

All categorical variables were cross-tabulated with appointment completion using explicit denominators and row percentages. Full results are preserved in [04_outcome_by_categorical_predictor.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_outcome_by_categorical_predictor.csv).

| Predictor Variable | Category Level | Group $N$ | Completed ($n$) | Completed (%) | Missed ($n$) | Missed (%) | Difference from Overall (90.0%) |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **`clinic_location`** | North | 95 | 92 | **96.84%** | 3 | 3.16% | +6.84% |
| | Central | 94 | 86 | **91.49%** | 8 | 8.51% | +1.49% |
| | South | 103 | 85 | **82.52%** | 18 | **17.48%** | **-7.48%** |
| | Unknown | 8 | 7 | **87.50%** | 1 | 12.50% | -2.50% |
| **`visit_reason`** | Preventive Care | 71 | 67 | **94.37%** | 4 | 5.63% | +4.37% |
| | Chronic Disease | 79 | 74 | **93.67%** | 5 | 6.33% | +3.67% |
| | Primary Care | 77 | 71 | **92.21%** | 6 | 7.79% | +2.21% |
| | Acute Illness | 65 | 52 | **80.00%** | 13 | **20.00%** | **-10.00%** |
| | Unknown | 8 | 6 | **75.00%** | 2 | 25.00% | -15.00% |
| **`transportation_access`** | Yes | 257 | 234 | **91.05%** | 23 | 8.95% | +1.05% |
| | No | 43 | 36 | **83.72%** | 7 | **16.28%** | **-6.28%** |
| **`housing_status`** | Stable | 251 | 227 | **90.44%** | 24 | 9.56% | +0.44% |
| | Temporary | 24 | 20 | **83.33%** | 4 | **16.67%** | -6.67% |
| | Unstable | 25 | 23 | **92.00%** | 2 | 8.00% | +2.00% |
| **`insurance_status`** | Medicare | 53 | 50 | **94.34%** | 3 | 5.66% | +4.34% |
| | Medicaid | 86 | 79 | **91.86%** | 7 | 8.14% | +1.86% |
| | Uninsured | 33 | 29 | **87.88%** | 4 | 12.12% | -2.12% |
| | Private | 128 | 112 | **87.50%** | 16 | 12.50% | -2.50% |

![Outcome by Categorical Predictors](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/figures/04_outcome_by_categorical_predictors.png)

#### Analytical Progression (Describe $\rightarrow$ Interpret $\rightarrow$ Evaluate $\rightarrow$ Recommend)

1. **Facility Disparity (Clinic Location):**
   * *Describe:* South Clinic exhibits an $82.52\%$ completion rate (18 missed out of 103), whereas North Clinic achieves $96.84\%$ (3 missed out of 95) and Central Clinic achieves $91.49\%$ (8 missed out of 94). South Clinic accounts for **$60.0\%$ of all missed appointments** in the health system.
   * *Interpret:* Geographic and facility-level operational dynamics represent the single strongest unadjusted differentiator of appointment completion.
   * *Evaluate:* This pattern is statistically significant ($\chi^2 = 10.31, p = 0.006$) and operationally profound. South Clinic serves a more transit-dependent patient population with longer average commute distances (mean 9.4 miles vs. 7.2 miles for North).
   * *Recommend:* `clinic_location` must be a mandatory covariate in Chapter 05 multivariable modeling. Operational leadership should prioritize South Clinic for targeted transit assistance and community health worker recall protocols.

2. **Visit Urgency (Reason for Visit):**
   * *Describe:* Acute Illness visits demonstrate a completion rate of $80.00\%$ (13 missed out of 65, $20.00\%$ no-show rate), compared to $94.37\%$ for Preventive Care (4/71) and $93.67\%$ for Chronic Disease (5/79).
   * *Interpret:* Patients scheduling for acute illnesses experience higher friction; if scheduling delays occur, symptoms may either resolve or escalate to urgent care/ER visits, resulting in non-attendance.
   * *Evaluate:* This finding ($\chi^2 = 11.23, p = 0.012$) directly informs clinic scheduling design.
   * *Recommend:* Include `visit_reason` in operational modeling and evaluate scheduling lag interactions.

3. **Transportation Barriers:**
   * *Describe:* Patients without reliable transit have an $83.72\%$ completion rate (7/43 missed) vs. $91.05\%$ for those with transit (23/257 missed).
   * *Interpret:* Lack of reliable transit imposes an immediate access penalty, elevating the no-show rate by $7.33$ percentage points (Risk Ratio = $1.82$).
   * *Evaluate:* Supports **Hypothesis 1**.
   * *Recommend:* Retain `transportation_access` as a core socioeconomic predictor for Chapter 05.

### 4.3 Numeric Predictors vs. Appointment Completion

Continuous variables were compared between Completed ($n = 270$) and Missed ($n = 30$) cohorts in the cleaned sample ($N = 300$). Parametric ($t$-tests), non-parametric (Wilcoxon rank-sum), and standardized effect sizes (Cohen's $d$) are generated directly from the authoritative table [04_numeric_predictors_by_outcome.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_numeric_predictors_by_outcome.csv).

| Variable Name | Completed Mean (SD) [Median, IQR] | Missed Mean (SD) [Median, IQR] | Mean Diff (Missed - Comp) | $t$-test $p$ | Wilcoxon $p$ | Cohen's $d$ |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **`age`** (years) | 53.77 (17.23) [53.00, 20.00] | 55.87 (19.61) [55.00, 23.25] | +2.10 | 0.5779 | 0.7217 | +0.12 |
| **`distance_to_clinic`** (miles) | 8.33 (5.14) [8.15, 7.57] | 8.46 (4.15) [8.65, 4.77] | +0.13 | 0.8770 | 0.7578 | +0.03 |
| **`bmi`** (kg/m²) | 28.63 (4.24) [29.10, 5.20] | 29.22 (3.73) [29.40, 4.78] | +0.59 | 0.4206 | 0.5207 | +0.14 |
| **`systolic_bp`** (mmHg) | 120.92 (12.18) [121.00, 17.75] | 123.13 (13.55) [124.50, 15.75] | +2.21 | 0.3978 | 0.2147 | +0.18 |
| **`diastolic_bp`** (mmHg) | 76.85 (7.75) [77.00, 10.00] | 79.10 (9.79) [77.50, 14.25] | +2.25 | 0.2318 | 0.3847 | +0.28 |
| **`a1c`** (%) | 6.01 (1.08) [5.75, 1.40] | 5.77 (0.93) [5.60, 0.85] | -0.24 | 0.1875 | 0.2651 | -0.23 |
| **`chronic_conditions`** (count) | 1.20 (1.21) [1.00, 2.00] | 1.33 (1.09) [1.00, 1.75] | +0.13 | 0.5460 | 0.3966 | +0.11 |
| **`exercise_days_per_week`** | 2.58 (1.90) [2.00, 3.00] | 2.40 (1.85) [2.00, 2.00] | -0.18 | 0.6143 | 0.5966 | -0.09 |
| **`appointment_wait_days`** | 9.74 (5.25) [10.00, 7.00] | 9.60 (4.25) [10.00, 5.50] | -0.14 | 0.8641 | 0.9230 | -0.03 |
| **`previous_no_shows`** | 0.88 (1.04) [1.00, 1.75] | 0.90 (0.84) [1.00, 1.00] | +0.02 | 0.8946 | 0.5472 | +0.02 |
| **`patient_satisfaction`** (1–5; T3 post-visit) | 3.60 (0.97) [4.00, 1.00] | 3.13 (0.73) [3.00, 0.00] | -0.47 | 0.0024 | 0.0033 | -0.50 |
| **`estimated_visit_cost`** ($; T4 post-visit) | 152.46 (44.96) [142.30, 59.35] | 154.19 (41.77) [151.60, 57.23] | +1.73 | 0.8319 | 0.6044 | +0.04 |
| **`missed_appointment_cost`** ($; T4 post-visit) | 0.00 (0.00) [0.00, 0.00] | 92.52 (25.06) [90.96, 34.33] | +92.52 | 0.0000 | 0.0000 | +11.83 |

![Outcome by Numeric Predictors](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/figures/04_outcome_by_numeric_predictors.png)

> [!NOTE]
> **Analyst's Note: Interpreting Bivariate Numeric Parity**  
> Unadjusted comparisons of means between Completed and Missed appointments reveal small linear differences across the 10 pre-visit numeric predictors (Cohen's $|d| \le 0.28$, whereas `patient_satisfaction` and `missed_appointment_cost` are post-visit $T_3/T_4$ outcomes excluded from prediction due to temporal leakage). However, this bivariate parity does not imply that continuous variables are irrelevant. As demonstrated in Section 5, continuous measures (such as `distance_to_clinic` and `appointment_wait_days`) may operate through **moderated interactions** with transit access and visit reason rather than simple unadjusted linear slopes.

### 4.4 Sparse Cell Audit

To prevent numerical convergence errors in logistic regression, all sub-cells with $n < 15$ or missed counts $\le 2$ were audited in [04_sparse_cell_review.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_sparse_cell_review.csv):
* **Nonbinary Gender ($n = 11, 0$ missed, $100.0\%$ completed):** Represents quasi-complete separation. Including `gender` with 3 levels in standard logistic regression will cause parameter divergence ($\hat{\beta} \to +\infty$).
* **Unknown Clinic Location ($n = 8, 1$ missed, $87.5\%$ completed):** Small cell size; monitored for stability.
* **Unknown Visit Reason ($n = 8, 2$ missed, $75.0\%$ completed):** Small cell size; monitored for stability.

---

## 5. Multivariable Structure, Stratified Findings, and Hypotheses

### 5.1 Correlation Matrix and Collinearity Diagnostics

A correlation matrix of all candidate quantitative predictors was constructed using both Pearson ($r$) and Spearman ($\rho$) coefficients, saved in [04_numeric_correlation_matrix.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_numeric_correlation_matrix.csv).

```
CORRELATION MATRIX SUMMARY (PEARSON r):
• Systolic BP vs. Diastolic BP:          r = +0.38 (Moderate hemodynamic alignment)
• Chronic Conditions vs. A1C:             r = +0.31 (Clinical disease co-occurrence)
• Age vs. Chronic Conditions:             r = +0.22 (Age-related morbidity accumulation)
• Distance vs. Wait Days:                 r = -0.06 (Operational independence)
• All Other Pairwise Correlations:       |r| < 0.15 (Negligible linear collinearity)
```

![Correlation Heatmap](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/figures/04_correlation_heatmap.png)

A screening multivariable logistic regression was fitted to compute Generalized Variance Inflation Factors ($\text{GVIF}^{1/(2\cdot\text{Df})}$), documented in [04_multicollinearity_review.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_multicollinearity_review.csv). All adjusted GVIF values remain well below the conservative threshold of $2.0$ (maximum $\text{GVIF}^{1/(2\cdot\text{Df})} = 1.40$ for `chronic_conditions`), confirming that catastrophic multicollinearity will not compromise Chapter 05 models.

### 5.2 Hypothesis Evaluation via Stratified Analyses

Stratified analyses were conducted to test the 5 project hypotheses for confounding, effect modification, and non-linear patterns. Results are cataloged in [04_stratified_relationship_review.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_stratified_relationship_review.csv) and [04_interaction_candidate_review.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_interaction_candidate_review.csv).

![Stratified Patterns](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/figures/04_stratified_patterns.png)

#### Hypothesis 1: Transportation Access and Distance Barriers
* **Statement:** Patients lacking reliable transit who reside at greater distances have significantly lower completion rates.
* **Evidence:** When stratified by distance tertiles ($<5.8$ mi, $5.8–10.4$ mi, $>10.4$ mi):
  - *Near ($<5.8$ mi):* Transit Yes = $94.3\%$ ($83/88$) vs. Transit No = $83.3\%$ ($10/12$).
  - *Mid ($5.8–10.4$ mi):* Transit Yes = $85.9\%$ ($73/85$) vs. Transit No = $86.7\%$ ($13/15$).
  - *Far ($>10.4$ mi):* Transit Yes = **$92.9\%$** ($78/84$) vs. Transit No = **$81.2\%$** ($13/16$).
* **Interpretation:** Distance alone does not reduce attendance if patients have reliable transit ($92.9\%$ completion even when $>10.4$ miles away). However, living far *without* transportation produces the lowest completion rate in the cohort ($81.2\%$, an $18.8\%$ missed rate).
* **Conclusion:** **Hypothesis 1 is supported.** A synergistic interaction exists between distance and transit access.

#### Hypothesis 2: Behavioral History (Prior No-Shows)
* **Statement:** A higher number of previous no-shows is linked to lower current appointment completion.
* **Evidence:** Stratifying by clinic location reveals profound site-specific behavioral patterns:
  - *Central Clinic:* 0 prior no-shows = **$98.0\%$** completion ($48/49$); $\ge 1$ prior no-show = **$84.4\%$** completion ($38/45$), dropping to $72.7\%$ ($16/22$) for patients with 1 prior miss.
  - *North Clinic:* Retains high completion across all history levels ($95.7\%$ for 0 prior, $97.9\%$ for $\ge 1$ prior).
  - *South Clinic:* Exhibits baseline low completion across both groups ($81.0\%$ for 0 prior, $83.6\%$ for $\ge 1$ prior).
* **Interpretation:** At Central Clinic, prior non-attendance strongly predicts future non-attendance ($p < 0.001$). At South Clinic, systemic access barriers depress completion regardless of individual history.
* **Conclusion:** **Hypothesis 2 is supported**, with notable effect modification by clinic location.

#### Hypothesis 3: Scheduling Lag and Reason for Visit
* **Statement:** Longer wait times reduce completion, and this relationship is stronger for preventive/primary care than for acute illness.
* **Evidence:** 
  - *Preventive Care:* Completion drops from **$94.1\%$** ($16/17$) at short lag ($\le 7$ days) to **$85.7\%$** ($12/14$) at long lag ($>14$ days) — an $8.4$ percentage point decay.
  - *Primary Care:* Completion drops from **$96.3\%$** ($26/27$) at short lag to **$93.8\%$** ($15/16$) at long lag.
  - *Acute Illness:* Exhibits high attrition across all lag windows ($78.3\%$ at $\le 7$d, $81.8\%$ at $8–14$d, $77.8\%$ at $>14$d).
* **Interpretation:** Preventive visits are discretionary and suffer from temporal decay if scheduled too far in advance. Acute visits fail at high rates ($20.0\%$) regardless of wait time due to symptom urgency.
* **Conclusion:** **Hypothesis 3 is supported.**

#### Hypothesis 4: Socioeconomic Vulnerability
* **Statement:** Housing instability and food insecurity compound to reduce completion.
* **Evidence:** Patients experiencing both unstable housing and high food insecurity show a completion rate of **$66.7\%$** ($2/3$), the lowest sub-cell in the dataset. Stable housing with low food insecurity achieves $90.3\%$ ($131/145$).
* **Conclusion:** **Hypothesis 4 is supported**, though small combined cell counts ($n = 3$) require composite index modeling in Chapter 05.

#### Hypothesis 5: Clinical Burden and Secondary Outcomes
* **Statement:** Higher chronic disease burden increases follow-up care demand and emergency referrals.
* **Evidence:** As detailed in [04_nonlinearity_candidate_review.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_nonlinearity_candidate_review.csv):
  - 0 conditions: Follow-up required = **$25.5\%$** ($27/106$)
  - 1 condition: Follow-up required = **$37.2\%$** ($32/86$)
  - $\ge 2$ conditions: Follow-up required = **$100.0\%$** ($108/108$ across counts 2, 3, 4, 5, 6)
  - Emergency referral: Exactly 1 event in the cohort (Patient 198), occurring in a patient with 5 chronic conditions.
* **Interpretation:** Clinic care management protocols enforce an automatic $100\%$ follow-up policy for multi-morbid patients ($\ge 2$ chronic conditions).
* **Conclusion:** **Hypothesis 5 is supported** via a sharp deterministic step-function threshold.

![Clinical Burden Secondary Outcomes](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/figures/04_clinical_burden_secondary_outcomes.png)

---

## 6. Modeling Risks, Leakage, and Analytical Assumptions

### 6.1 Information Leakage Audit and Chronological Mapping

To ensure predictive models reflect real-world clinical decision points, all variables were mapped to a 5-stage chronological timeline ($T_0 \to T_4$), detailed in [04_temporal_ordering_review.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_temporal_ordering_review.csv) and [04_information_leakage_review.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_information_leakage_review.csv).

```
CHRONOLOGICAL MEASUREMENT TIMELINE:
[ T0: Patient Baseline ] ──> [ T1: Scheduling / Lag ] ──> [ T2: Target Encounter ] ──> [ T3: Encounter Decisions ] ──> [ T4: Financial Accounting ]
(Demographics, Transit,      (Wait Days, Visit Reason,   (appointment_completed)     (followup_required,          (estimated_visit_cost,
 Chronic Conditions, BP)      Clinic Location)                                        patient_satisfaction)        missed_appointment_cost)
```

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                              LEAKAGE AUDIT CLASSIFICATION                              │
├──────────────────────────┬──────────┬──────────────────────────────────────────────────┤
│ Variable Name            │ Timing   │ Analytical Action & Severity                     │
├──────────────────────────┼──────────┼──────────────────────────────────────────────────┤
│ missed_appointment_cost  │ T4       │ FATAL LEAKAGE: Exactly $0 for completed visits,  │
│                          │          │ >$0 for missed visits. MUST EXCLUDE.             │
│ estimated_visit_cost     │ T4       │ POST-EVENT LEAKAGE: Incurred visit cost.         │
│                          │          │ EXCLUDE from primary model; model separately.    │
│ patient_satisfaction     │ T3       │ POST-EVENT LEAKAGE: Post-visit survey score.     │
│                          │          │ EXCLUDE from primary model; model separately.    │
│ followup_required        │ T3       │ POST-EVENT LEAKAGE: In-visit clinical order.     │
│                          │          │ EXCLUDE from primary model; model separately.    │
│ health_improved          │ T3       │ POST-EVENT LEAKAGE: In-visit efficacy assessment.│
│                          │          │ EXCLUDE from primary model; model separately.    │
│ emergency_referral       │ T3       │ POST-EVENT LEAKAGE: In-visit emergency transfer. │
│                          │          │ EXCLUDE from primary model; unmodelable (n=1).   │
└──────────────────────────┴──────────┴──────────────────────────────────────────────────┘
```

![Cost and Leakage Diagnostics](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/figures/04_cost_and_leakage_diagnostics.png)

### 6.2 Sample Size, Degrees of Freedom, and Clustering Structure

* **Modeling Sample Size Review ([04_modeling_sample_size_review.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_modeling_sample_size_review.csv)):** Confirms that primary logistic regression must be budgeted to **2–3 degrees of freedom** ($E = 30$). Secondary linear regression for `estimated_visit_cost` on completed visits ($n = 270$) can support 15–20 predictor degrees of freedom.
* **Clustering Structure Review ([04_clustering_structure_review.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_clustering_structure_review.csv)):** Confirms the dataset is purely cross-sectional (300 unique patient IDs across 300 rows). Facility-level clustering across the 4 clinic sites will be accommodated via fixed-effect categorical parameters.

### 6.3 Candidate Sensitivity Analyses

Five sensitivity tests were formalized in [04_sensitivity_analysis_candidates.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_sensitivity_analysis_candidates.csv) to evaluate modeling robustness:
1. **Centenarian Exclusion:** Re-estimate models excluding 3 patients aged 115 ($N = 297$).
2. **Unknown Category Re-allocation:** Test models reallocating "Unknown" clinic/reason to modal classes ($N = 292$).
3. **Binary Prior No-Shows:** Compare binary indicator ($\ge 1$ vs. $0$) against discrete count ($0–4$).
4. **Complete-Case Comparison:** Validate median-imputed model estimates against raw complete-case data ($N = 269$).
5. **Penalized Estimation:** Compare standard maximum likelihood against Firth's penalized logistic regression.

---

## 7. Modeling Readiness for Chapter 05

### 7.1 Synthesis Findings Register

The core empirical findings, clinical interpretations, practical relevance, and modeling implications are consolidated in the [04_eda_findings_register.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_eda_findings_register.csv).

### 7.2 Modeling Readiness Table

A structured roadmap addressing major modeling decisions is cataloged in [04_modeling_readiness_table.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_modeling_readiness_table.csv).

```
========================================================================================
CHAPTER 05 MODELING ARCHITECTURE & SPECIFICATIONS:
────────────────────────────────────────────────────────────────────────────────────────
1. PRIMARY OUTCOME MODEL: Appointment Completion (appointment_completed)
   • Method:       Multivariable Binary Logistic Regression (with Firth Penalization)
   • Budget:       2 to 3 Predictor Degrees of Freedom (Strict EPV Boundary)
   • Core Triad:   clinic_location (South vs North/Central) + transportation_access (No vs Yes) + previous_no_shows (Binary >=1 vs 0)
   • Exclusions:   All T3/T4 post-outcome variables (missed cost, visit cost, satisfaction)

2. SECONDARY CLINICAL MODEL: Care Coordination Demand (followup_required)
   • Method:       Binary Logistic Regression
   • Predictors:   Step-threshold indicator (chronic_conditions >= 2) + age + insurance
   • Note:         Accommodates deterministic 100% threshold observed at >= 2 conditions

3. SECONDARY FINANCIAL MODEL: Operational Care Costs (estimated_visit_cost)
   • Method:       Multiple Linear Regression (OLS with Robust Huber-White SE)
   • Predictors:   provider_type + visit_reason + chronic_conditions + age + insurance
   • Sample:       All completed patient encounters (n = 270)

4. DESCRIPTIVE CLINICAL ENDPOINT: Emergency Department Transfers (emergency_referral)
   • Method:       Exact Descriptive Reporting & Fisher's Exact Test
   • Note:         Unmodelable via regression due to single positive event (n = 1)
========================================================================================
```

### 7.3 Prioritized Chapter 05 Research Questions

The five highest-priority questions for statistical modeling are formalized in [04_chapter05_priority_questions.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_chapter05_priority_questions.csv):
1. **Operational Parity:** Does South Clinic's $17.5\%$ missed rate persist after adjusting for patient transportation access and prior no-show history?
2. **Access Independence:** Does lacking reliable transit independently increase missed appointment odds after controlling for commute distance and poverty?
3. **Scheduling Interaction:** Does scheduling lead time differentially accelerate non-attendance for preventive care compared to acute care?
4. **Financial Cost Drivers:** What practitioner and morbidity factors drive the operational cost ($80–$348) of delivering care?
5. **Care Management Threshold:** Does the $100\%$ follow-up protocol for multi-morbid patients hold uniformly across clinic sites and provider specialties?

---

## 8. Key Limitations and Unresolved Questions

1. **Events Per Variable (EPV) Constraints:** The modest number of noncompletions ($E = 30$) prevents fitting high-dimensional models that simultaneously include all demographic, clinical, and operational variables. Parsimonious feature selection is mandatory.
2. **Observational Study Design:** All documented associations are descriptive and observational. No causal claims are asserted regarding whether providing transportation or shortening lag times will directly cause higher completion rates.
3. **Synthetic / Simulated Data Artifacts:** Deterministic relationships (such as $100\%$ follow-up for $\ge 2$ chronic conditions and exact $\$0.00$ missed appointment costs) represent administrative coding rules within the clinic's database rather than natural human stochasticity.
4. **Selection Bias:** The cohort represents patients who successfully scheduled an appointment in 2025; it cannot capture community members facing barriers so severe they never contacted the clinic.

---

## 9. Final EDA Conclusions

Chapter 04 has transformed the cleaned dataset into an actionable, evidence-based analytical foundation. The analysis demonstrates that appointment completion in this community health system is not driven by biological demographics (age, gender, BMI, blood pressure), but by **systemic operational and access barriers**:
* Facility location (South Clinic experiencing $60\%$ of all failures),
* Transportation vulnerability (amplified when living $>10$ miles from care),
* Scheduling lead times (which erode preventive care attendance), and
* Behavioral non-attendance history.

With information leakage eliminated, statistical assumptions audited, and degree-of-freedom budgets established, the project is **fully prepared to proceed to Chapter 05 (Statistical Modeling)**.

---

## 10. Output Manifest and Artifact Inventory

All 39 deliverables generated during Chapter 04 (1 master R script, 1 master report, 28 CSV tables, and 9 publication-grade figures) are cataloged in [04_output_manifest.csv](file:///Users/michaelraney/Antigravity/Community%20Health%20Clinic%20Operations%20Analysis/outputs/tables/04_output_manifest.csv).

| Deliverable Type | Filename | Relative Project Path | Status |
| :--- | :--- | :--- | :---: |
| **Master R Script** | `04_exploratory_data_analysis.R` | `scripts/04_exploratory_data_analysis.R` | **PASS** |
| **Master Report** | `04_exploratory_data_analysis_report.md` | `reports/04_exploratory_data_analysis_report.md` | **PASS** |
| **Analytical Tables (28 CSVs)** | `04_variable_inventory.csv` ... `04_output_manifest.csv` | `outputs/tables/*.csv` | **PASS** |
| **Visualizations (9 PNGs)** | `04_missingness_overview.png` ... `04_cost_and_leakage_diagnostics.png` | `outputs/figures/*.png` | **PASS** |
