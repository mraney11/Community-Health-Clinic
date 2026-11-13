# Chapter 05: Statistical Modeling Report
## Community Health Clinic Operations Analysis

Version: October 17, 2026
Script: `scripts/05_statistical_modeling.R` (run with `Rscript --vanilla` in a fresh session; seed 20261017)
Data: simulated practice data. All results describe **observational associations**. They are not causal effects, and they are not evidence about any real clinic.

Every number below comes from the saved tables in `outputs/tables/` (the `05_` prefix).

---

## 1. Research question and agreed modeling decisions

**Question:** How are appointment wait time, previous no-shows, and transportation access associated with appointment completion, after accounting for one another?

**Prespecified primary model:**

```
completion_01 ~ wait_weeks + previous_no_shows + transportation_access
```

- **Logistic regression** models the *log-odds* (logit) of completion as a linear function of the predictors. *Odds* = P(complete) / P(miss). An **odds ratio (OR)** compares the odds between two groups. OR = 1 means the odds are equal.
- **Estimator:** ordinary maximum likelihood, `glm(family = binomial(link = "logit"))`, with an intercept.
- The model uses one prespecified specification. It has no stepwise selection, p-value screening, interactions, machine learning, resampling to balance the classes, or class weights.
- **Primary purpose:** interpret adjusted associations. Predictive performance is secondary.

## 2. Inputs, sample, coding

| Item | Value |
|---|---|
| Input | `data/community_health_clinic_clean.csv` (md5 in `05_input_checksums.csv`) |
| Rows / variables | 300 / 35. There is one row per patient (300 unique IDs) and no duplicate rows |
| Outcome | 270 completed (90.0%), 30 missed (10.0%) |
| Missing values in model variables | none, so the model sample is N = 300 (no exclusions) |
| `completion_01` | 1 = `appointment_completed` "Yes", 0 = "No" |
| `wait_weeks` | `appointment_wait_days / 7`, exact (unrounded). OR is per **additional 7 days** |
| `previous_no_shows` | numeric (observed values 0–4). OR is per **one additional** prior no-show |
| `transportation_access` | factor with levels Yes, No. **Reference = Yes**. The OR compares No with Yes |

The model matrix contains exactly `(Intercept), wait_weeks, previous_no_shows, transportation_accessNo`, and its rank is 4 of 4. A check confirmed that the wait-weeks coefficient equals 7 × the per-day coefficient.

**RAW vs. cleaned count note:** the Chapter 03 cleaning log (`DEC_13` in `03_cleaning_decision_log.csv`) labels `273` completed + `30` missed as the **RAW** count *before* deduplication ($303$ rows, $3$ duplicate IDs) and `270` completed + `30` missed as the **cleaned** sample ($N = 300$). The cleaned data govern all modeling and contain $270$ completions and $30$ missed visits.

**Project root resolution:** anchored to the clinic project via `here::i_am("scripts/05_statistical_modeling.R")`, `Community Health Clinic Operations Analysis.Rproj`, and validated clinic input sentinels, recorded in `05_model_sample_audit.csv`.

**Information caution:** there are 30 missed appointments for 3 predictor degrees of freedom, or about 10 minority outcomes per parameter. This number warns that the data hold limited information. It is not a rule that guarantees the model is adequate, and it does not prove that a larger model would fail. Penalized estimation (Firth) does not create more information.

### Observed sparsity audit (observed summaries, not model estimates)

| Transportation | N | Completed | Missed | % completed |
|---|---|---|---|---|
| Yes | 257 | 234 | 23 | 91.1% |
| No | 43 | 36 | 7 | 83.7% |

| Prior no-shows | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| N | 141 | 84 | 49 | 22 | 4 |
| Missed | 11 | 12 | 6 | 1 | 0 |
| % completed | 92.2 | 85.7 | 87.8 | 95.5 | 100 |

- **Wait days:** median 10 (IQR 6–13), range 0–25. Completed patients had a median of 10 (mean 9.7). Missed patients had a median of 10 (mean 9.6, range 2–19).
- **Joint support:** the transport × prior-no-show cells for 3–4 prior no-shows are sparse. For example, 3 prior no-shows with transport Yes has 0 missed, and 4 prior no-shows has 2 patients per transport group. The transport-No group has only 43 patients, spread across 5 no-show levels. See `05_joint_support_transport_noshows.csv`.

## 3. Differences from the EDA roadmap

The agreed Chapter 05 scope **supersedes** the broader roadmap proposed in the Chapter 04 EDA:
- The model does not include age, clinic location, or visit reason. Clinic location and visit reason remain plausible omitted influences, so **the model does not control for every potential confounder**.
- The model does not collapse clinic categories. Clinic fixed effects would not automatically solve every dependence concern anyway.
- Secondary models for cost, follow-up, and emergency referral are **deferred**. The emergency-referral outcome has 1 event.
- The model excludes post-visit variables (follow-up, referral, health_improved, satisfaction, both costs) because of temporal leakage, and excludes `patient_id` because it is an identifier.

## 4. Model estimates and interpretation

Estimator: ordinary ML logistic regression, N = 300 (30 missed). The 95% CIs are **profile-likelihood** intervals. P-values come from the Wald z test and the likelihood-ratio (LR) drop-one test. Source: `05_adjusted_odds_ratios.csv`.

| Term | log-odds (SE) | Adjusted OR | 95% CI | Wald p | LR p |
|---|---|---|---|---|---|
| Wait time, per +7 days | 0.051 (0.266) | 1.052 | 0.627 – 1.787 | 0.849 | 0.849 |
| Prior no-shows, per +1 | 0.063 (0.199) | 1.065 | 0.732 – 1.607 | 0.751 | 0.750 |
| Transportation No vs Yes | −0.733 (0.493) | 0.481 | 0.189 – 1.340 | 0.137 | 0.154 |

**Wait time.** Compare two patients whose waits differ by 7 days and who have the same number of prior no-shows and the same transportation access. The model estimates the longer wait has 5.2% *higher* odds of completion (OR 1.05). The CI runs from 0.63 to 1.79. The data are therefore compatible with anything from about 37% lower odds to 79% higher odds per week. The direction and size of the association are essentially undetermined. The CI contains 1, but that does **not** prove there is no association: the estimate is simply imprecise. In practical terms, this dataset cannot say whether shorter waits go with better attendance.

**Previous no-shows.** For each additional prior no-show, holding wait time and transportation access fixed, the estimated odds of completion are 6.5% higher (OR 1.07). The CI runs from 0.73 to 1.61, about 27% lower to 61% higher odds. The direction is counter-intuitive, and the estimate is very uncertain. The observed pattern is not monotone: completion dips at 1–2 prior no-shows (86–88%) and is high at 3–4 (95–100%), but only 26 patients have 3–4 prior no-shows. The single linear slope is therefore a crude summary (see Section 6). The practical relevance cannot be determined from these data.

**Transportation access.** Compare patients *without* transportation access to patients with it, at the same wait time and number of prior no-shows. The model estimates the no-access group has 51.9% *lower* odds of completion (OR 0.48). This is the largest point estimate of the three, but it is not more "important" than the others. You cannot rank predictors measured on different scales, and p-values do not rank importance either. The CI runs from 0.19 to 1.34, so the data are compatible with anything from roughly 81% lower odds to 34% higher odds. The estimate rests on 43 patients and 7 missed appointments. The direction is consistent with the observed 83.7% vs 91.1% completion, but the uncertainty is wide. The result is suggestive, not established.

Note that "% lower/higher odds" values are **not** probability reductions or percentage-point differences. Section 5 converts the estimates to probabilities.

## 5. Worked probability comparisons (hypothetical profiles)

These are **model estimates for hypothetical profiles**. They are not real matched patients and not clinic averages. The CIs are computed on the logit scale and back-transformed. They describe uncertainty in the *estimated probability*, not in any individual's binary outcome. The missed-probability CI equals 1 minus the completion CI, with the endpoints reversed. Source: `05_probability_examples.csv`.

| Comparison | Profile | P(complete) [95% CI] | P(missed) [95% CI] | Diff (pp) |
|---|---|---|---|---|
| Wait | 7 days, 1 no-show, transport Yes | 0.910 [0.863, 0.942] | 0.090 [0.058, 0.137] | — |
| Wait | 14 days, 1 no-show, transport Yes | 0.914 [0.859, 0.949] | 0.086 [0.051, 0.141] | +0.4 |
| No-shows | 0 no-shows, 7 days, Yes | 0.905 [0.845, 0.943] | 0.095 [0.057, 0.155] | — |
| No-shows | 1 no-show, 7 days, Yes | 0.910 [0.863, 0.942] | 0.090 [0.058, 0.137] | +0.5 |
| Transport | Yes, 7 days, 1 no-show | 0.910 [0.863, 0.942] | 0.090 [0.058, 0.137] | — |
| Transport | No, 7 days, 1 no-show | 0.830 [0.673, 0.920] | 0.170 [0.080, 0.327] | −8.1 |

"Diff (pp)" is the percentage-point difference in estimated completion probability. No CI is shown for the differences, because a valid interval would need the covariance between the two estimates.

**Support check:** 11 observed patients have no transportation access and exactly 1 prior no-show. Only 2 of them have a wait within ±2 days of 7. The transport-No profile therefore leans heavily on the model's linear-logit structure. I kept the specified comparison because the transport-No group is small at every no-show level, so no better-supported alternative exists. Read that row as especially uncertain. The other profiles have 17–42 nearby observed patients.

Figures: `05_adjusted_odds_ratios.png` (log scale, reference line at 1) and `05_wait_time_probabilities.png`. The second shows curves over the observed 0–25 day range, with prior no-shows fixed at 1, both transport groups, uncertainty bands, and a rug of observed waits.

## 6. Diagnostics and their consequences

Source: `05_model_diagnostics.csv`, `05_influence_flagged_records.csv`.

- **Convergence:** the fit converged in 5 iterations with no warnings. All estimates and SEs are finite, the largest |coef| is 0.73, and the largest SE is 0.49.
- **Separation:** `detectseparation` found no separation and no infinite estimates. Zero cells in simple tables, such as 3 prior no-shows with transport Yes, neither establish nor exclude multivariable separation. A formal check was needed.
- **Fitted probabilities:** these range from 0.817 to 0.929, and none is extreme. The narrow range already signals weak discrimination.
- **VIF** (variance inflation factor) values are 1.01–1.12, and the largest |pairwise r| is 0.27. VIF measures how much the predictors overlap when the coefficients are estimated. It does **not** assess whether a variable is a confounder.
- **Residuals and influence:** 23 missed appointments have |Pearson residual| > 3. This is expected when nearly everyone's predicted completion is about 0.9. Of the 300 records, 24 exceed Cook's D 4/n (max 0.050) and 32 exceed leverage 2p/n. These are rough flags, not deletion rules. As a review, I refit the model without the top-5 Cook's D patients (IDs 51, 63, 55, 190, 123). The wait and no-show ORs stayed near 1, and the transport OR moved to 1.10. The transport estimate therefore depends heavily on a handful of missed appointments among patients without transport. **No records were deleted.**
- **Functional form** (each check is a separate diagnostic sensitivity model with a centered quadratic term):
  - Wait: quadratic coef 0.54 (SE 0.38), LR p = 0.11. Binned completion is flat across wait bands (88–91%). There is no clear evidence of curvature.
  - Prior no-shows: quadratic coef 0.47 (SE 0.25), LR p = 0.033. This matches the observed dip-then-rise pattern, which is driven by 26 patients at 3–4 no-shows (1 missed). The extra parameter is unstable with 30 events, and I did not choose the specification by p-value. **The linear interpretation for prior no-shows is provisional.** The "per additional no-show" OR should not be read as a constant effect across 0–4.

**Consequence:** ordinary ML is numerically stable, so it remains the primary estimator. Firth is reported only as a sensitivity comparison.

## 7. Secondary performance, validation, and cutoff workload

Source: `05_performance_summary.csv`, `05_cutoff_workload.csv`, `05_calibration.png`.

| Measure | Value |
|---|---|
| Apparent ROC AUC (direction fixed: higher predicted completion = completion) | 0.536 |
| Optimism-corrected AUC (bootstrap) | 0.476 |
| Apparent Brier score, model | 0.0893 |
| Brier score, intercept-only (same sample) | 0.0900 |
| Optimism-corrected Brier | 0.0910 |
| Mean predicted vs observed completion | 0.900 vs 0.900 |

- **AUC** is the probability that a randomly chosen completer receives a higher predicted completion than a randomly chosen non-completer. A value of 0.5 means chance-level ranking. The **Brier score** is the mean squared error of the predicted probabilities, and lower is better.
- **Bootstrap internal validation:** 500 resamples of patient rows, refitting the same glm each time. All 500 fits succeeded (0 failures, 0 warnings). Optimism is the average of (bootstrap-sample performance − original-sample performance). For AUC the optimism is +0.059. For Brier it is −0.0017, which means the bootstrap fits looked better on their own resample. After correction, the AUC falls *below* 0.5, and the Brier score is slightly *worse* than the intercept-only model's. **The model has no demonstrable ability to discriminate between patients who complete and patients who miss.** Bootstrap validation is internal only. It is not external validation, and the resamples are not new patients. The prespecified model was also informed by this dataset's EDA.
- The **all-completion classifier** is 90% accurate, so accuracy alone tells you nothing here.
- The match between mean predicted and observed completion is automatic for ML logistic regression with an intercept. It is not evidence of validity. On the calibration plot, the predicted values span only 0.86–0.92, and the quintile groups (58–63 patients each) scatter around the diagonal without any meaningful spread.

**Teaching-only cutoff table.** Missed risk = 1 − P(complete). Positive = actually missed. The table is apparent (in-sample).

| Missed-risk cutoff | Flagged | TP | FN | FP | TN | Sensitivity | Specificity | Precision | Accuracy |
|---|---|---|---|---|---|---|---|---|---|
| ≥ 0.10 | 43 | 7 | 23 | 36 | 234 | 7/30 = 0.233 | 234/270 = 0.867 | 7/43 = 0.163 | 0.803 |
| ≥ 0.20 | 0 | 0 | 30 | 0 | 270 | 0/30 = 0 | 270/270 = 1 | undefined (0 flagged) | 0.900 |

At ≥ 0.10, the flagged group is exactly the 43 patients without transport access, so the "model" collapses to a single variable. No patient reaches a missed risk of 0.20. Three things must be kept separate: a model's probabilities, the choice of cutoff, and clinic outreach workload. These cutoffs were not optimized, and this practice analysis does not support any outreach deployment.

## 8. Sensitivity results

Source: `05_sensitivity_comparison.csv`. The primary specification is preserved throughout, and the sensitivity analyses were not used to select a model.

| Analysis | N (missed) | Wait OR [CI] | No-shows OR [CI] | Transport No OR [CI] | pp: Transport No − Yes |
|---|---|---|---|---|---|
| Primary (ML) | 300 (30) | 1.05 [0.63, 1.79] | 1.07 [0.73, 1.61] | 0.48 [0.19, 1.34] | −8.1 |
| A. Exclude recoded negative waits | 296 (30) | 1.10 [0.65, 1.90] | 1.08 [0.74, 1.64] | 0.48 [0.19, 1.35] | −8.1 |
| B. Exclude age = 115 | 297 (29) | 1.11 [0.65, 1.91] | 1.05 [0.72, 1.58] | 0.47 [0.18, 1.31] | −8.3 |
| C. Any prior no-show (≥1 vs 0) | 300 (30) | 1.02 [0.60, 1.73] | 0.69 [0.30, 1.51]* | 0.56 [0.23, 1.52] | −6.9 |
| D. Complete-case | not applicable | — | — | — | — |
| E. Firth penalized | 300 (30) | 1.04 [0.63, 1.76] | 1.05 [0.73, 1.57] | 0.47 [0.19, 1.27] | −8.7 |

\*In C, the no-shows OR compares *any* prior no-show with none. It is a different question from the per-additional-no-show comparison.

- **A:** The raw file **independently verified** that IDs 31, 112, 117, 132 had wait = −3, which cleaning changed to 0. Only those 4 records were excluded. The other 8 genuine zero-wait records were kept.
- **B:** IDs 47, 93, 236 (age 115) were excluded. This checks robustness to questionable records, not an age effect. Age is not in the model, and a recorded age being biologically possible does not verify it.
- **C:** With a binary indicator, the no-show estimate points toward *lower* odds of completion, unlike the per-count slope. This is consistent with the non-monotone pattern in Section 6, and both intervals are wide and include 1.
- **D:** None of the model variables had missing values. The only raw issues were 5 lowercase "y" transport entries (IDs 6, 54, 171, 216, 250), which are unambiguous recodes to "Yes", and the negative waits covered in A. The EDA's global complete-case N = 269 depends on variables this model does not use, so a distinct comparison does not exist.
- **E:** The Firth estimates (with profile penalized-likelihood CIs) are nearly identical to the ML estimates, which supports keeping ordinary ML as primary.

**Conclusion:** no sensitivity analysis changes the substantive interpretation. The wait and no-show associations remain imprecise and centered near 1. The transport point estimate stays near 0.47–0.56, and its CI includes 1 in every analysis. The only variation that is more than cosmetic is C's change of direction for no-shows, and it reflects a changed comparison plus a large amount of uncertainty.

## 9. Limitations and cautious clinic implications

- The data are simulated and observational. No estimate is causal. Clinic location, visit reason, and other factors could confound the associations.
- Only 30 missed appointments are available, so every interval is wide. A non-significant result does not show absence of association.
- The linear form for prior no-shows is provisional, and the upper no-show categories are sparse.
- The transport estimate depends on 43 patients (7 missed) and is sensitive to a few influential records.
- The model has no useful discrimination (corrected AUC is about 0.48), so it should not be used to target patients.
- Earlier chapters made some overstatements, and they are corrected here:
  - Median imputation does **not** guarantee unbiased estimates. It does not affect this model, which uses no imputed variables.
  - A low event count does **not** guarantee that every larger model would fail.
  - Clinic fixed effects would not solve every dependence concern.
- **Cautious implication:** transportation barriers are a plausible lead for further study, because the direction is consistent and the point estimate is moderately large. Neither wait time nor prior no-show history shows a detectable association in this sample. Better data, mainly more missed appointments, would be needed before acting.

## 10. Reading guide and next step

- `05_adjusted_odds_ratios.csv`: the core estimates. Read `odds_ratio` with `or_ci_low`/`or_ci_high`. `pct_change_odds` gives the plain-language odds change.
- `05_probability_examples.csv`: hypothetical profiles on the probability scale, with support counts.
- `05_model_diagnostics.csv`: convergence, separation, VIF, influence, and functional-form checks.
- `05_sensitivity_comparison.csv`: one row per term per analysis.
- `05_modeling_decision_log.csv`: every decision and the reason for it.
- `05_output_manifest.csv`: status of every file.

**Suggested next learning step:** practice explaining *why* a model can have a moderately large OR (transport) and still discriminate at chance level. Then try a restricted cubic spline for prior no-shows as a teaching exercise, and compare its uncertainty with the linear term, without replacing the primary model.

*This chapter does not complete the later Quarto, README, executive summary, or final QA chapters.*
