Prompt 05 — Statistical Modeling
## Community Health Clinic Operations Analysis
Version: October 17, 2026

## How Mike should use this file
Open the Community Health Clinic Operations Analysis project in Antigravity. Paste the prompt below into its agent chat, or attach this Markdown file and instruct the agent to execute it. This is an instruction file, not an R script: do not run it in the R console.

The agent must create and run the R # Pscript, save the results, and write the report. No model has been fitted merely by preparing this prompt.

---

## BEGIN EXECUTABLE PROMPT

You are an R data analyst and a patient statistical teacher. Complete Chapter 05 for this project. Create and execute project files; displaying code in chat alone does not satisfy the task. Explain statistical choices in plain language appropriate for an analyst with research experience who is learning logistic regression.

### 1. Project and execution rules
Project root:
 /Users/michaelraney/Antigravity/Community Health Clinic Operations Analysis

Use macOS POSIX paths and file.path(); quote shell paths containing spaces. Never use Windows paths. Confirm the root and its RStudio project before execution. If this root does not exist in the current environment, locate the explicitly opened project; do not invent another root or silently use another dataset.

Create directories as needed:
 scripts/
 outputs/tables/
 outputs/figures/
 outputs/models/
 reports/

Create the main reproducible script:
 scripts/05_statistical_modeling.R

Create the main report:
 reports/05_statistical_modeling_report.md

Use relative project paths after explicitly establishing the project root. Do not overwrite raw data, cleaned data, Chapter 01–04 files, or unrelated work. Put all new analytical outputs under the 05_ prefix. Set a reproducible random seed (20261017). Record R/package versions, runtime warnings, input paths, and input checksums. Use R for analysis. Do not rely on hidden workspace objects or manual console steps.

Inspect installed packages first; use stable, documented functions. Install only necessary missing CRAN packages if permitted by the environment. If a needed package is unavailable, finish feasible work and explicitly label skipped analyses. Never invent successful execution or numerical findings.

### 2. Read inputs before analysis
Required:
 data/community_health_clinic_clean.csv

Read the locally available Chapter 03 cleaning decision log, Chapter 04 EDA report, variable inventory, and data dictionary. Look in documentation/, docs/, reports/, and outputs/tables/ as appropriate. Names may have download suffixes; resolve by content. Also read the existing cleaning script if needed to trace affected records.

Expected cleaned data: 300 rows, 35 variables, 270 completions, 30 missed appointments. Recompute all counts. The current cleaned data govern numerical results. Record discrepancies rather than repeating stale counts such as 273 completions from the cleaning log.

Optional raw input for sensitivity:
 data/community_health_clinic_raw_v2.csv
Resolve the actual raw filename if it differs. Do not rerun or alter the cleaning pipeline.

Check the unit of observation, unique patient IDs, duplicates, missingness, observed categories, numeric ranges, and outcome counts. Do not silently exclude observations or coerce unexpected strings to missing. Stop model fitting with a clear diagnostic if required variables cannot be interpreted safely; save the audit and explain the blocker.

### 3. Agreed scope and research question
Research question:
How are appointment wait time, previous no-shows, and transportation access associated with appointment completion, after accounting for one another?

Primary purpose: interpret adjusted associations. Predictive performance is secondary. This is observational, simulated practice data; do not portray results as evidence from a real clinic or establish causal effects.

One prespecified starting model:
 completion_01 ~ wait_weeks + previous_no_shows + transportation_access

Definitions:
- completion_01 = 1 when appointment_completed is Yes, 0 when No.
- wait_weeks = appointment_wait_days / 7, retaining exact values.
- previous_no_shows remains numeric, per one additional historical no-show.
- transportation_access is a factor with levels Yes, No in that order; Yes is the reference.
- Use binomial logistic regression with a logit link and an intercept.

Explicitly verify coding and model-matrix columns. There should be three predictor coefficients plus an intercept in the starting model.

No automatic stepwise selection, univariate p-value screening, exhaustive model searches, interactions, machine learning, SMOTE, class weighting, or outcome balancing. Do not add age or clinic location to the primary model. Do not collapse clinic categories to manufacture a predictor.

Do not fit secondary cost, follow-up, or emergency-referral models in this chapter. Exclude patient_id as a predictor and exclude all post-visit/outcome-derived variables, including followup_required, emergency_referral, health_improved, patient_satisfaction, estimated_visit_cost, and missed_appointment_cost.

Explain that this agreed scope supersedes the EDA's broader proposed roadmap. Clinic location and visit reason remain plausible omitted influences. The model does not control for every potential confounder.

Treat the approximately 30 minority outcomes per three predictor degrees of freedom as a caution about limited information, not an iron law or guarantee of model adequacy. Penalization does not create more information or justify unlimited predictors.

### 4. Input and sparsity audit
Report counts and denominators for:
- Both outcome classes and the final model sample.
- Completion by transportation access, including counts and row percentages.
- Completion by each observed previous-no-show count.
- Distribution of wait days overall and by outcome.
- Joint transportation/no-show support and empty or sparse cells.

Count missingness only in variables actually needed for each model. Do not delete patients because an unused variable is missing. If required variables are unexpectedly missing, document the number, potential bias, and any complete-case restriction; do not automatically impute anew.

### 5. Fit and diagnose the primary model
Fit glm() with binomial(link = "logit"). Capture convergence warnings and verify finite estimates, standard errors, design-matrix rank, and extreme fitted probabilities.

Use a documented separation diagnostic if available. Zero cells in simple tables alone neither establish nor exclude multivariable separation.

Review:
- Coefficient uncertainty and unusually large estimates.
- Predictor correlation and VIF, explaining that VIF assesses estimation overlap, not whether a variable is a confounder.
- Deviance/Pearson residuals, leverage, Cook's distance, and DFBETAs as review tools. Do not mechanically delete flagged patients.
- Assumed linearity in the log-odds for wait time and prior no-shows.

For functional form, begin with descriptive plots and counts. As limited exploratory checks, assess a centered quadratic term for each numeric predictor separately, retaining the other primary terms. These add a degree of freedom and may be unstable with only 30 missed appointments. Label them diagnostic sensitivity models; do not select a replacement solely by a p-value or fit both extra terms together automatically. If results suggest important nonlinearity, explain the uncertainty and flag the primary linear interpretation as provisional.

If separation or numerical instability makes ordinary maximum likelihood unreliable, use Firth logistic regression through a documented implementation such as logistf, retaining exactly the same primary predictors. Explain why. If stable, retain ordinary logistic regression as primary; Firth may be a sensitivity comparison. Firth is not mandated solely by imbalance. If neither fit is defensible, report that rather than publishing misleading estimates.

### 6. Estimates and interpretation
Save coefficients, standard errors, adjusted odds ratios, 95% confidence intervals, and p-values with the estimator and interval/test method stated. Use profile-likelihood intervals for ordinary logistic regression when feasible; disclose a Wald fallback. For Firth, use the implementation's penalized likelihood inference. Do not mix methods without labeling them.

Interpret ALL THREE predictors regardless of p-value:
1. State the precise comparison and the other two variables adjusted for.
2. Describe direction and magnitude.
3. Explain the confidence interval and uncertainty.
4. Describe practical relevance and limitations.

For odds ratios below 1, (1 - OR) * 100 describes lower odds; above 1, (OR - 1) * 100 describes higher odds. Never call these probability reductions or percentage-point differences. An interval containing 1 is not proof of no association. Do not rank importance using p-values or coefficients measured on different scales. Avoid causal language and unwarranted claims that adjustment removes all confounding.

### 7. Predicted probabilities
Create a compact, explicitly labeled hypothetical patient-profile table:
- Wait days 7 and 14, previous_no_shows = 1, transportation_access = Yes.
- Previous no-shows 0 and 1, wait days = 7, transportation_access = Yes.
- Transportation Yes and No, wait days = 7, previous_no_shows = 1.

Check support for these combinations; if sparse, disclose it and use a better-supported comparison where needed, explaining the change. These are conditional model estimates for profiles, not actual matched patients or overall clinic averages.

Give predicted completion probability with 95% confidence intervals using an estimator-appropriate method. For ordinary glm, obtain uncertainty on the link scale and transform to probability. Also show missed probability = 1 - completion probability with correctly reversed interval endpoints. Explain that these intervals concern estimated probabilities, not individual binary outcomes.

Calculate percentage-point differences between paired estimated completion probabilities. Do not provide confidence intervals for differences unless their covariance is properly accounted for.

Save an odds-ratio plot with reference at 1 and a wait-time probability curve over the observed range with the other predictors explicitly fixed. Include uncertainty bands and observed-data support.

### 8. Secondary performance evaluation
Use completion probabilities for all probability-based measures unless explicitly evaluating missed-appointment outreach.

Report apparent:
- ROC AUC with direction explicitly fixed so higher predicted completion corresponds to actual completion. Never let software reverse direction to obtain AUC above 0.5.
- Brier score = mean((completion_01 - predicted_completion)^2).
- Mean predicted completion versus observed completion.
- A calibration plot with few, adequately supported groups, counts, and a perfect-calibration reference.

Compare Brier score to an intercept-only model on the same sample. Explain that an all-completion classifier has about 90% accuracy in the expected data, so accuracy alone is uninformative. Do not treat perfect apparent mean calibration of an unpenalized intercept model as evidence of validation.

Use bootstrap internal validation rather than a single train/test split. Target 500 resamples, fit the same prespecified model/estimator each time, and evaluate each bootstrap-fitted model both on its bootstrap sample and the original sample to estimate optimism for AUC and Brier score. Use ordinary patient-row resampling after confirming independent records. Document failed fits, separation, missing classes, successful resamples, and denominator; never silently discard failures. Do not switch estimators opportunistically between resamples. If too many failures occur (for example, over 10%), label correction unreliable and explain. Correct AUC by subtracting average bootstrap-minus-original performance; apply the same algebra to Brier, noting lower is better. Do not present bootstrap validation as external validation or bootstrap resamples as new patients.

If Firth validation is unsupported by available tools, implement the same resampling logic with its documented predictions or clearly report the limitation. Label any unavoidable preprocessing reuse and the fact that model choices were informed by this dataset's EDA.

For a teaching-only cutoff table, use missed risk = 1 - predicted completion. Flag when missed risk >= 0.10 and >= 0.20. Define positive as actually missed, and report TP, FN, FP, TN, sensitivity, specificity, precision, accuracy, and total flagged with denominators. Handle undefined metrics explicitly. Do not optimize cutoffs or recommend outreach deployment from this practice analysis. Explain why model probabilities, cutoff decisions, and clinic workload are separate matters.

### 9. Focused sensitivity analyses
Preserve the primary specification and report comparisons without selecting whichever yields significance.

A. Negative wait-time cleaning assumption:
The cleaning log says four negative waits were changed to zero (patient IDs 31, 112, 117, 132). Verify those identities against available source records before exclusion. Refit excluding verified affected records, because zero assumes same-day booking. Do not exclude all zero waits. If raw records are unavailable but cleaned IDs and the log agree, label this a log-based sensitivity and disclose that original negative values were not independently verified.

B. Age 115:
Refit the same three-predictor model excluding records with age == 115, expected IDs 47, 93, 236. Age itself is not a predictor. Explain this is a record-exclusion robustness check, not a test of an age coefficient. Biological possibility alone does not verify these recorded ages.

C. Prior no-shows:
Compare the numeric count specification with a binary any-prior-no-show indicator (>=1 versus 0), retaining wait time and transportation. Explain the changed research comparison. Do not select by p-value.

D. Complete-case sensitivity:
Only exclude originally missing or invalid values in variables required by the model. Missing BMI/A1C/age alone is irrelevant to this model. Do not automatically use the EDA's global complete-case N=269. Verify whether a distinct relevant comparison exists; otherwise report not applicable.

E. Firth comparison if feasible, as described above.
Record sample sizes, outcome counts, estimator, coefficient comparisons where comparable, probability contrasts, warnings, and whether substantive interpretation changes. Do not call a change in statistical significance alone a substantive reversal.

### 10. Required deliverables
Create and verify:
- scripts/05_statistical_modeling.R
- reports/05_statistical_modeling_report.md
- outputs/tables/05_model_sample_audit.csv
- outputs/tables/05_outcome_by_transportation.csv
- outputs/tables/05_adjusted_odds_ratios.csv
- outputs/tables/05_probability_examples.csv
- outputs/tables/05_model_diagnostics.csv
- outputs/tables/05_performance_summary.csv
- outputs/tables/05_cutoff_workload.csv
- outputs/tables/05_sensitivity_comparison.csv
- outputs/tables/05_modeling_decision_log.csv
- outputs/tables/05_output_manifest.csv
- outputs/figures/05_adjusted_odds_ratios.png
- outputs/figures/05_wait_time_probabilities.png
- outputs/figures/05_calibration.png
- outputs/models/05_primary_model.rds
- outputs/models/05_session_info.txt

Add supporting diagnostic tables/figures and bootstrap summaries as useful. When an output cannot be produced, record its skipped/failed status and reason in the manifest; never create plausible-looking placeholders. Save tables with descriptive columns and readable labels. Figures should use large readable fonts, labeled axes, clear probability/percentage units, and captions specifying sample and adjustment.

### 11. Report structure and teaching requirements
Write a readable report covering:
1. Research question and agreed modeling decisions.
2. Inputs, sample, coding, reference category, and comparison units.
3. Differences from the EDA roadmap, including deferred secondary models.
4. Model estimates and full interpretation of each predictor.
5. Worked probability comparisons.
6. Diagnostics and their consequences.
7. Secondary performance, validation, and cutoff workload.
8. Sensitivity results.
9. Limitations and cautious clinic implications.
10. Short guide to reading the key tables and suggested next learning step.

Explain terminology at first use. Keep tables compact and avoid decorative text boxes, ASCII art, or extremely wide layouts. Label hypothetical examples, observed summaries, model estimates, and validation results clearly.

Do not repeat overstatements from earlier documents: median imputation does not guarantee unbiased estimates; a low event count does not guarantee failure of every larger model; a nonsignificant result does not prove absence; clinic categories as fixed effects would not automatically solve every dependence concern. Preserve prior files and document corrections in the current decision log.

### 12. Execute, verify, and hand off
Run the saved script in a fresh R session. Fix code errors within this scope and rerun. Verify:
- Exact coding, sample counts, three primary predictor coefficients, and reference category.
- Exponentiation and seven-day scaling are correct.
- Confidence limits are ordered and probabilities are between 0 and 1.
- Cutoff tables sum to the sample and use missed appointments as positive.
- Printed interpretations match numeric results and interval uncertainty.
- Sensitivity samples exclude only intended records.
- Every reported file exists and the manifest accurately records status.
- The script can reproduce the outputs without hidden objects.

Finish with a concise chat handoff: files created, primary sample, estimator, main findings with uncertainty, unresolved limitations, and exactly which files Mike should share for review. Request the report, adjusted odds-ratio table, diagnostic summary, and modeling decision log first. Do not claim this completes the later Quarto, README, executive summary, or final QA chapters.

## END EXECUTABLE PROMPT

